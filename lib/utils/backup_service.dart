// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BackupFrequency { daily, weekly, monthly }

class BackupService {
  static const String _backupDirName = 'noteep_backups';
  static const int _maxBackups = 30;

  /// Get the backup directory
  static Future<Directory> getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/$_backupDirName');
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }

  /// Create a backup of data
  static Future<String?> createBackup({
    required Map<String, dynamic> notesData,
    required Map<String, dynamic> tasksData,
    required Map<String, dynamic> calendarData,
  }) async {
    try {
      final backupDir = await getBackupDirectory();
      final timestamp = DateFormat(
        'yyyy-MM-dd_HH-mm-ss',
      ).format(DateTime.now());
      final backupName = 'noteep_backup_$timestamp.zip';
      final backupPath = '${backupDir.path}/$backupName';

      // Create temporary directory for files
      final tempDir = Directory('${backupDir.path}/temp_$timestamp');
      tempDir.createSync();

      try {
        // Write JSON files
        final notesFile = File('${tempDir.path}/notes.json');
        final tasksFile = File('${tempDir.path}/tasks.json');
        final calendarFile = File('${tempDir.path}/calendar.json');

        await notesFile.writeAsString(jsonEncode(notesData));
        await tasksFile.writeAsString(jsonEncode(tasksData));
        await calendarFile.writeAsString(jsonEncode(calendarData));

        // Create metadata
        final metadata = {
          'timestamp': DateTime.now().toIso8601String(),
          'version': '2.0.0',
        };
        final metadataFile = File('${tempDir.path}/metadata.json');
        await metadataFile.writeAsString(jsonEncode(metadata));

        // Compress to zip
        ZipFileEncoder().zipDirectory(
          tempDir,
          filename: backupPath,
          onProgress: (file) {
            if (kDebugMode) debugPrint('Backup: $file');
          },
        );

        // Clean up temp directory
        tempDir.deleteSync(recursive: true);

        // Clean old backups
        await _cleanOldBackups(backupDir);

        return backupPath;
      } catch (e) {
        tempDir.deleteSync(recursive: true);
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Backup error: $e');
      return null;
    }
  }

  /// Restore backup from a file
  static Future<Map<String, dynamic>?> restoreBackup(String backupPath) async {
    try {
      final backupDir = await getBackupDirectory();
      final extractDir = Directory('${backupDir.path}/restore_temp');

      if (extractDir.existsSync()) {
        extractDir.deleteSync(recursive: true);
      }
      extractDir.createSync();

      try {
        // Extract zip
        final inputStream = InputFileStream(backupPath);
        final archive = ZipDecoder().decodeBuffer(inputStream);
        extractArchiveToDisk(archive, extractDir.path);
        inputStream.close();

        // Read files
        final notesFile = File('${extractDir.path}/notes.json');
        final tasksFile = File('${extractDir.path}/tasks.json');
        final calendarFile = File('${extractDir.path}/calendar.json');

        final notes = jsonDecode(await notesFile.readAsString());
        final tasks = jsonDecode(await tasksFile.readAsString());
        final calendar = jsonDecode(await calendarFile.readAsString());

        // Clean up
        extractDir.deleteSync(recursive: true);

        return {'notes': notes, 'tasks': tasks, 'calendar': calendar};
      } catch (e) {
        extractDir.deleteSync(recursive: true);
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Restore error: $e');
      return null;
    }
  }

  /// List all available backups
  static Future<List<FileSystemEntity>> listBackups() async {
    try {
      final backupDir = await getBackupDirectory();
      final files =
          backupDir.listSync().where((f) => f.path.endsWith('.zip')).toList();
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files;
    } catch (e) {
      if (kDebugMode) debugPrint('List backups error: $e');
      return [];
    }
  }

  /// Get backup file info
  static Map<String, dynamic> getBackupInfo(FileSystemEntity file) {
    final stat = file.statSync();
    final name = file.path.split('/').last;

    return {
      'name': name,
      'size': stat.size,
      'date': stat.modified,
      'path': file.path,
    };
  }

  /// Delete a backup
  static Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete backup error: $e');
      return false;
    }
  }

  /// Clean old backups keeping only the most recent ones
  static Future<void> _cleanOldBackups(Directory backupDir) async {
    try {
      final files =
          backupDir.listSync().where((f) => f.path.endsWith('.zip')).toList();

      if (files.length > _maxBackups) {
        files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        );
        final toDelete = files.sublist(_maxBackups);
        for (final file in toDelete) {
          await File(file.path).delete();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Clean old backups error: $e');
    }
  }

  /// Whether an automatic backup is due now for [frequency], based on the
  /// timestamp of the last backup.
  static Future<bool> isBackupDue(BackupFrequency frequency) async {
    final last = await getLastBackupTime();
    if (last == null) return true;
    final dueSince = switch (frequency) {
      BackupFrequency.daily => const Duration(days: 1),
      BackupFrequency.weekly => const Duration(days: 7),
      BackupFrequency.monthly => const Duration(days: 30),
    };
    return DateTime.now().difference(last) >= dueSince;
  }

  /// Get the last backup time
  static Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('last_backup_time');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Get last backup time error: $e');
      return null;
    }
  }

  /// Set the last backup time
  static Future<void> setLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_backup_time',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Set last backup time error: $e');
    }
  }
}
