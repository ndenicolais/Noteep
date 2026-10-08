// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_list_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/settings/backup_restore.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/utils/backup_service.dart';

const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(
      overrides: [
        notesProvider.overrideWith(
          (ref) => NotesNotifier('u', firestore, (_) {}, () {}),
        ),
        tasksProvider.overrideWith(
          (ref) => TasksNotifier('u', firestore, (_) {}, () {}),
        ),
        taskListsProvider.overrideWith(
          (ref) => TaskListsNotifier('u', firestore, ref),
        ),
        calendarProvider.overrideWith(
          (ref) => CalendarNotifier('u', firestore),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<int> docCount(String collection) async =>
      (await firestore
              .collection('users')
              .doc('u')
              .collection(collection)
              .get())
          .size;

  final note = NoteModel(title: 'Spesa');
  final task = TaskModel(title: 'Chiamare');
  final list = TaskListModel(name: 'Lavoro');
  final event = CalendarEventModel(
    title: 'Dentista',
    startTime: DateTime(2026, 3, 10, 9),
    endTime: DateTime(2026, 3, 10, 10),
  );

  Map<String, dynamic> flatJson() => {
    'version': '2.0.0',
    'notes': [note.toJson()],
    'tasks': [task.toJson()],
    'taskLists': [list.toJson()],
    'calendar': [event.toJson()],
  };

  group('FullBackupData', () {
    test('fromJson parses every section', () {
      final data = FullBackupData.fromJson(flatJson());
      expect(data.notes!.single.title, 'Spesa');
      expect(data.tasks!.single.title, 'Chiamare');
      expect(data.taskLists!.single.name, 'Lavoro');
      expect(data.events!.single.title, 'Dentista');
    });

    test('fromJson leaves absent sections null', () {
      final data = FullBackupData.fromJson({
        'notes': [note.toJson()],
      });
      expect(data.notes, hasLength(1));
      expect(data.tasks, isNull);
      expect(data.taskLists, isNull);
      expect(data.events, isNull);
    });

    test('fromJson throws on a malformed section', () {
      expect(
        () => FullBackupData.fromJson({'notes': 'not a list'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromZipContents flattens the nested zip layout', () {
      final data = FullBackupData.fromZipContents({
        'notes': {
          'notes': [note.toJson()],
        },
        'tasks': {
          'tasks': [task.toJson()],
          'taskLists': [list.toJson()],
        },
        'calendar': {
          'calendar': [event.toJson()],
        },
      });
      expect(data.notes!.single.id, note.id);
      expect(data.tasks!.single.id, task.id);
      expect(data.taskLists!.single.id, list.id);
      expect(data.events!.single.id, event.id);
    });
  });

  group('BackupRestorer.apply', () {
    test('replaces state and persists every section', () async {
      final restorer = container.read(backupRestorerProvider);
      await restorer.apply(FullBackupData.fromJson(flatJson()));

      expect(container.read(notesProvider).single.id, note.id);
      expect(container.read(tasksProvider).single.id, task.id);
      expect(container.read(taskListsProvider).single.id, list.id);
      expect(container.read(calendarProvider).single.id, event.id);
      expect(await docCount('notes'), 1);
      expect(await docCount('tasks'), 1);
      expect(await docCount('task_lists'), 1);
      expect(await docCount('calendar_events'), 1);
    });

    test('updates state before persistence completes', () {
      final restorer = container.read(backupRestorerProvider);
      restorer.apply(FullBackupData(notes: [note]));
      expect(container.read(notesProvider).single.id, note.id);
    });

    test('deletes from Firestore what the backup does not contain', () async {
      // Created after the backup: must not survive a restore (it would
      // otherwise come back on the next load from Firestore).
      await container.read(notesProvider.notifier).addNote(NoteModel());
      await container.read(tasksProvider.notifier).addTask(TaskModel());
      await container
          .read(taskListsProvider.notifier)
          .addList(TaskListModel(name: 'Nuova'));
      await container
          .read(calendarProvider.notifier)
          .addEvent(
            CalendarEventModel(
              startTime: DateTime(2026, 4, 1),
              endTime: DateTime(2026, 4, 2),
            ),
          );

      await container
          .read(backupRestorerProvider)
          .apply(FullBackupData.fromJson(flatJson()));

      final notes = await firestore.collection('users/u/notes').get();
      expect(notes.docs.map((d) => d.id), [note.id]);
      expect(await docCount('tasks'), 1);
      expect(await docCount('task_lists'), 1);
      expect(await docCount('calendar_events'), 1);
    });

    test('leaves sections absent from the backup untouched', () async {
      final existing = TaskModel(title: 'Esistente');
      await container.read(tasksProvider.notifier).addTask(existing);

      await container
          .read(backupRestorerProvider)
          .apply(FullBackupData(notes: [note]));

      expect(container.read(tasksProvider).single.id, existing.id);
    });
  });

  group('BackupRestorer.readZip', () {
    late Directory docsDir;

    setUp(() {
      docsDir = Directory.systemTemp.createTempSync('noteep_restore_test_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            _pathProviderChannel,
            (call) async => docsDir.path,
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_pathProviderChannel, null);
      docsDir.deleteSync(recursive: true);
    });

    test('reads back an automatic backup made by BackupService', () async {
      // Same payload shape as HomeScreen._maybeRunAutoBackup.
      final path = await BackupService.createBackup(
        notesData: {
          'notes': [note.toJson()],
        },
        tasksData: {
          'tasks': [task.toJson()],
          'taskLists': [list.toJson()],
        },
        calendarData: {
          'calendar': [event.toJson()],
        },
      );

      final data = await container.read(backupRestorerProvider).readZip(path!);
      expect(data, isNotNull);
      expect(data!.notes!.single.title, 'Spesa');
      expect(data.tasks!.single.title, 'Chiamare');
      expect(data.taskLists!.single.name, 'Lavoro');
      expect(data.events!.single.startTime, event.startTime);
    });

    test('returns null for an unreadable or malformed backup', () async {
      final restorer = container.read(backupRestorerProvider);
      expect(await restorer.readZip('${docsDir.path}/missing.zip'), isNull);

      final path = await BackupService.createBackup(
        notesData: {'notes': 'broken'},
        tasksData: {},
        calendarData: {},
      );
      expect(await restorer.readZip(path!), isNull);
    });
  });
}
