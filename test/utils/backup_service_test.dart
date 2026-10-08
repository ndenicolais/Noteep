// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/constants/app_version.dart';
import 'package:noteep/utils/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;

  setUp(() {
    docsDir = Directory.systemTemp.createTempSync('noteep_backup_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return docsDir.path;
          }
          return null;
        });
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    docsDir.deleteSync(recursive: true);
  });

  Future<String> backupPath() async {
    final path = await BackupService.createBackup(
      notesData: {
        'notes': [
          {'id': 'n1', 'title': 'Spesa', 'content': 'pane, latte'},
        ],
      },
      tasksData: {
        'tasks': [
          {'id': 't1', 'title': 'Chiamare', 'isCompleted': false},
        ],
        'taskLists': <Object>[],
      },
      calendarData: {'calendar': <Object>[]},
    );
    expect(path, isNotNull);
    return path!;
  }

  group('createBackup / restoreBackup', () {
    test('round-trips notes, tasks and calendar data', () async {
      final path = await backupPath();
      expect(File(path).existsSync(), isTrue);
      expect(path, matches(RegExp(r'noteep_backup_[\d_-]+\.zip$')));

      final restored = await BackupService.restoreBackup(path);
      expect(restored, isNotNull);
      expect(restored!['notes'], {
        'notes': [
          {'id': 'n1', 'title': 'Spesa', 'content': 'pane, latte'},
        ],
      });
      expect(restored['tasks']['tasks'][0]['title'], 'Chiamare');
      expect(restored['tasks']['taskLists'], isEmpty);
      expect(restored['calendar'], {'calendar': <Object>[]});
    });

    test('writes metadata with the current app version', () async {
      final path = await backupPath();
      final archive = ZipDecoder().decodeBytes(File(path).readAsBytesSync());
      final meta = archive.findFile('metadata.json');
      expect(meta, isNotNull);
      final json =
          jsonDecode(utf8.decode(meta!.content as List<int>))
              as Map<String, dynamic>;
      expect(json['version'], appVersion);
      expect(DateTime.tryParse(json['timestamp'] as String), isNotNull);
    });

    test('leaves no temporary folders behind', () async {
      final path = await backupPath();
      await BackupService.restoreBackup(path);
      final dir = await BackupService.getBackupDirectory();
      final leftovers = dir.listSync().whereType<Directory>();
      expect(leftovers, isEmpty);
    });

    test('returns null for a corrupted or missing file', () async {
      final dir = await BackupService.getBackupDirectory();
      final bogus = File('${dir.path}/broken.zip')..writeAsStringSync('nope');
      expect(await BackupService.restoreBackup(bogus.path), isNull);
      expect(
        await BackupService.restoreBackup('${dir.path}/missing.zip'),
        isNull,
      );
    });

    test('returns null when the zip lacks one of the data files', () async {
      final dir = await BackupService.getBackupDirectory();
      final archive =
          Archive()..addFile(ArchiveFile.string('notes.json', '{"notes":[]}'));
      final zip = File('${dir.path}/partial.zip')
        ..writeAsBytesSync(ZipEncoder().encode(archive)!);
      expect(await BackupService.restoreBackup(zip.path), isNull);
    });
  });

  group('backup list and pruning', () {
    test('keeps only the 30 most recent backups', () async {
      final dir = await BackupService.getBackupDirectory();
      final base = DateTime(2026, 1, 1);
      for (var i = 0; i < 31; i++) {
        File('${dir.path}/old_$i.zip')
          ..writeAsStringSync('x')
          ..setLastModifiedSync(base.add(Duration(days: i)));
      }
      final path = await backupPath();

      final names =
          (await BackupService.listBackups())
              .map((f) => BackupService.getBackupInfo(f)['name'])
              .toList();
      expect(names, hasLength(30));
      expect(names.first, path.split('/').last);
      // The two oldest dummies are pruned, the newest ones survive.
      expect(names, isNot(contains('old_0.zip')));
      expect(names, isNot(contains('old_1.zip')));
      expect(names, contains('old_30.zip'));
    });

    test('lists only zip files, newest first', () async {
      final dir = await BackupService.getBackupDirectory();
      File('${dir.path}/a.zip')
        ..writeAsStringSync('x')
        ..setLastModifiedSync(DateTime(2026, 1, 1));
      File('${dir.path}/b.zip')
        ..writeAsStringSync('x')
        ..setLastModifiedSync(DateTime(2026, 2, 1));
      File('${dir.path}/notes.txt').writeAsStringSync('x');

      final names =
          (await BackupService.listBackups())
              .map((f) => BackupService.getBackupInfo(f)['name'])
              .toList();
      expect(names, ['b.zip', 'a.zip']);
    });

    test('getBackupInfo reports name, size, date and path', () async {
      final path = await backupPath();
      final info = BackupService.getBackupInfo(File(path));
      expect(info['name'], path.split('/').last);
      expect(info['size'], greaterThan(0));
      expect(info['date'], isA<DateTime>());
      expect(info['path'], path);
    });

    test('deleteBackup removes the file and reports missing ones', () async {
      final path = await backupPath();
      expect(await BackupService.deleteBackup(path), isTrue);
      expect(File(path).existsSync(), isFalse);
      expect(await BackupService.deleteBackup(path), isFalse);
    });
  });

  group('isBackupDue', () {
    Future<void> lastBackupAgo(Duration ago) async {
      SharedPreferences.setMockInitialValues({
        'last_backup_time': DateTime.now().subtract(ago).toIso8601String(),
      });
    }

    test('is due when no backup was ever made', () async {
      for (final f in BackupFrequency.values) {
        expect(await BackupService.isBackupDue(f), isTrue, reason: f.name);
      }
    });

    test('respects each frequency threshold', () async {
      await lastBackupAgo(const Duration(hours: 23));
      expect(await BackupService.isBackupDue(BackupFrequency.daily), isFalse);

      await lastBackupAgo(const Duration(days: 1, minutes: 1));
      expect(await BackupService.isBackupDue(BackupFrequency.daily), isTrue);
      expect(await BackupService.isBackupDue(BackupFrequency.weekly), isFalse);

      await lastBackupAgo(const Duration(days: 7, minutes: 1));
      expect(await BackupService.isBackupDue(BackupFrequency.weekly), isTrue);
      expect(await BackupService.isBackupDue(BackupFrequency.monthly), isFalse);

      await lastBackupAgo(const Duration(days: 30, minutes: 1));
      expect(await BackupService.isBackupDue(BackupFrequency.monthly), isTrue);
    });

    test('setLastBackupTime marks a backup as just made', () async {
      await BackupService.setLastBackupTime();
      final last = await BackupService.getLastBackupTime();
      expect(last, isNotNull);
      expect(DateTime.now().difference(last!).inSeconds, lessThan(5));
      expect(await BackupService.isBackupDue(BackupFrequency.daily), isFalse);
    });

    test('treats a corrupted timestamp as never backed up', () async {
      SharedPreferences.setMockInitialValues({'last_backup_time': 'boh'});
      expect(await BackupService.getLastBackupTime(), isNull);
      expect(await BackupService.isBackupDue(BackupFrequency.monthly), isTrue);
    });
  });
}
