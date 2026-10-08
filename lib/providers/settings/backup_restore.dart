// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/calendar_model.dart';
import '../../models/note_model.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../utils/backup_service.dart';
import '../calendar_provider.dart';
import '../notes_provider.dart';
import '../tasks_provider.dart';

/// Parsed content of a full backup. A null section was absent from the
/// backup and is left untouched on restore.
class FullBackupData {
  const FullBackupData({this.notes, this.tasks, this.taskLists, this.events});

  final List<NoteModel>? notes;
  final List<TaskModel>? tasks;
  final List<TaskListModel>? taskLists;
  final List<CalendarEventModel>? events;

  /// Parses the flat layout of the `.json` full backup
  /// (`{notes, tasks, taskLists, calendar}`). Throws on malformed data, so
  /// nothing is applied from a partially valid file.
  factory FullBackupData.fromJson(Map<String, dynamic> json) {
    List<T>? parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final list = json[key];
      if (list == null) return null;
      return (list as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return FullBackupData(
      notes: parse('notes', NoteModel.fromJson),
      tasks: parse('tasks', TaskModel.fromJson),
      taskLists: parse('taskLists', TaskListModel.fromJson),
      events: parse('calendar', CalendarEventModel.fromJson),
    );
  }

  /// Parses the nested layout returned by [BackupService.restoreBackup]
  /// (`{notes: {notes}, tasks: {tasks, taskLists}, calendar: {calendar}}`).
  factory FullBackupData.fromZipContents(Map<String, dynamic> contents) {
    Map<String, dynamic> section(String key) =>
        (contents[key] as Map<String, dynamic>?) ?? const {};
    return FullBackupData.fromJson({
      ...section('notes'),
      ...section('tasks'),
      ...section('calendar'),
    });
  }
}

/// Applies full backups (from a `.json` file or an automatic zip backup) to
/// the notes, tasks, task lists and calendar providers.
class BackupRestorer {
  BackupRestorer(this._ref);

  final Ref _ref;

  /// Replaces local state synchronously; the returned future completes when
  /// Firestore has persisted every section.
  Future<void> apply(FullBackupData data) {
    return Future.wait([
      if (data.notes != null)
        _ref.read(notesProvider.notifier).replaceAll(data.notes!),
      if (data.tasks != null)
        _ref.read(tasksProvider.notifier).replaceAll(data.tasks!),
      if (data.taskLists != null)
        _ref.read(taskListsProvider.notifier).replaceAll(data.taskLists!),
      if (data.events != null)
        _ref.read(calendarProvider.notifier).replaceAll(data.events!),
    ]).then((_) {});
  }

  /// Reads and parses an automatic zip backup without applying it. Returns
  /// null if the file can't be read or its content is malformed.
  Future<FullBackupData?> readZip(String path) async {
    final contents = await BackupService.restoreBackup(path);
    if (contents == null) return null;
    try {
      return FullBackupData.fromZipContents(contents);
    } catch (_) {
      return null;
    }
  }
}

final backupRestorerProvider = Provider<BackupRestorer>(BackupRestorer.new);
