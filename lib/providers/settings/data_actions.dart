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
import '../../core/constants/app_version.dart';
import '../../utils/ics_export_service.dart';
import '../../utils/ics_import_service.dart';
import '../calendar_provider.dart';
import '../notes_provider.dart';
import '../tasks_provider.dart';
import 'backup_restore.dart';

/// Data operations behind the Settings screen (JSON/ICS export and import,
/// clear), kept out of the UI so the screen only handles dialogs/SnackBars.
///
/// Import methods parse synchronously (throwing on malformed data before
/// any provider is touched) and return the persistence future; clear
/// methods also return it. Local state is updated immediately either way.
class DataActions {
  DataActions(this._ref);

  final Ref _ref;

  BackupRestorer get _restorer => _ref.read(backupRestorerProvider);

  /// Whether exporting notes would include locked notes in plaintext.
  bool get hasLockedNotes => _ref.read(notesProvider).any((n) => n.isLocked);

  // -- Export payloads -------------------------------------------------------

  Map<String, dynamic> _header(String version) => {
    'version': version,
    'exportedAt': DateTime.now().toIso8601String(),
  };

  List<Map<String, dynamic>> get _notes =>
      _ref.read(notesProvider).map((n) => n.toJson()).toList();
  List<Map<String, dynamic>> get _tasks =>
      _ref.read(tasksProvider).map((t) => t.toJson()).toList();
  List<Map<String, dynamic>> get _taskLists =>
      _ref.read(taskListsProvider).map((l) => l.toJson()).toList();
  List<Map<String, dynamic>> get _calendar =>
      _ref.read(calendarProvider).map((e) => e.toJson()).toList();

  Map<String, dynamic> notesExport() => {..._header('1.0.0'), 'notes': _notes};

  Map<String, dynamic> tasksExport() => {
    ..._header('1.0.0'),
    'tasks': _tasks,
    'taskLists': _taskLists,
  };

  Map<String, dynamic> calendarExport() => {
    ..._header('1.0.0'),
    'calendar': _calendar,
  };

  Map<String, dynamic> fullBackupExport() => {
    ..._header(appVersion),
    'notes': _notes,
    'tasks': _tasks,
    'taskLists': _taskLists,
    'calendar': _calendar,
  };

  // -- JSON import -----------------------------------------------------------

  /// Only the given [keys] are read from [decoded], so e.g. importing a full
  /// backup file as "notes" replaces just the notes.
  Future<void> _import(Map<String, dynamic> decoded, List<String> keys) {
    final data = FullBackupData.fromJson({
      for (final k in keys)
        if (decoded.containsKey(k)) k: decoded[k],
    });
    return _restorer.apply(data);
  }

  Future<void> importNotes(Map<String, dynamic> decoded) =>
      _import(decoded, const ['notes']);

  Future<void> importTasks(Map<String, dynamic> decoded) =>
      _import(decoded, const ['tasks', 'taskLists']);

  Future<void> importCalendar(Map<String, dynamic> decoded) =>
      _import(decoded, const ['calendar']);

  Future<void> importFullBackup(Map<String, dynamic> decoded) =>
      _restorer.apply(FullBackupData.fromJson(decoded));

  // -- ICS -------------------------------------------------------------------

  /// ICS content for the active events, or null if there are none.
  String? icsExport() {
    final events = _ref.read(activeEventsProvider);
    return events.isEmpty ? null : IcsExportService.generateIcs(events);
  }

  /// Adds the events found in [content] to the calendar. `count` is 0 when
  /// the file has no events (nothing is imported); `saved` completes when
  /// Firestore has persisted them.
  ({int count, Future<void> saved}) importIcs(String content) {
    final events = IcsImportService.parseIcs(content);
    if (events.isEmpty) return (count: 0, saved: Future.value());
    return (
      count: events.length,
      saved: _ref.read(calendarProvider.notifier).importEvents(events),
    );
  }

  // -- Clear -----------------------------------------------------------------

  Future<void> clearNotes() => _ref.read(notesProvider.notifier).clearAll();

  Future<void> clearTasks() => Future.wait([
    _ref.read(tasksProvider.notifier).clearAll(),
    _ref.read(taskListsProvider.notifier).clearAll(),
  ]).then((_) {});

  Future<void> clearCalendar() =>
      _ref.read(calendarProvider.notifier).clearAllEvents();

  Future<void> clearAll() =>
      Future.wait([clearNotes(), clearTasks(), clearCalendar()]).then((_) {});
}

final dataActionsProvider = Provider<DataActions>(DataActions.new);
