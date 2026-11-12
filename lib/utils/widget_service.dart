// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../l10n/l10n.dart';
import '../models/calendar_model.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import 'home_widget_rows.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _appGroupId = 'com.ndn21.noteep.widget';
  static const _package = 'com.ndn21.noteep';
  static const _debounce = Duration(milliseconds: 500);

  /// Android provider of each widget and the keys it reads, so a change
  /// refreshes only the widgets that show it.
  static const _widgetKeys = {
    'NoteepWidget': ['note_count', 'task_count', 'latest_note'],
    'NotesSummaryWidget': ['notes_title', 'notes_empty', 'notes_rows'],
    'TasksSummaryWidget': ['tasks_title', 'tasks_empty', 'tasks_rows'],
    'CalendarSummaryWidget': [
      'calendar_title',
      'calendar_empty',
      'calendar_rows',
    ],
  };

  /// Day labels shared by the list widgets, which pick them by date.
  static const _sharedKeys = [
    'label_today',
    'label_tomorrow',
    'label_yesterday',
  ];

  Timer? _pending;
  final Map<String, String> _lastWritten = {};

  Future<void> init() async {
    // home_widget plugin is not available on web
    if (!kIsWeb) {
      await HomeWidget.setAppGroupId(_appGroupId);
    }
  }

  /// Schedules a refresh of every widget from the current notes, tasks and
  /// events. Bursts of changes (e.g. notes and tasks emitting back to back)
  /// collapse into a single write, and identical values are not rewritten.
  void scheduleSync(
    List<NoteModel> notes,
    List<TaskModel> tasks,
    List<CalendarEventModel> events,
  ) {
    if (kIsWeb) return;
    _pending?.cancel();
    _pending = Timer(
      _debounce,
      () => _write(_buildValues(notes, tasks, events)),
    );
  }

  /// Ready-to-show values in the UI language: the Android widgets only
  /// display them.
  Map<String, String> _buildValues(
    List<NoteModel> notes,
    List<TaskModel> tasks,
    List<CalendarEventModel> events,
  ) {
    final l10n = currentL10n();
    final now = DateTime.now();
    NoteModel? latest;
    for (final n in notes) {
      if (latest == null || n.updatedAt.isAfter(latest.updatedAt)) {
        latest = n;
      }
    }
    final latestTitle = latest?.title ?? '';
    return {
      'note_count': l10n.widgetNoteCount(notes.length),
      'task_count': l10n.widgetTaskCount(
        tasks.where((t) => !t.isCompleted).length,
      ),
      'latest_note':
          latestTitle.isEmpty ? l10n.widgetNoRecentNote : latestTitle,
      'label_today': l10n.commonToday,
      'label_tomorrow': l10n.commonTomorrow,
      'label_yesterday': l10n.commonYesterday,
      'notes_title': l10n.navNotes,
      'notes_empty': l10n.widgetNotesEmpty,
      'notes_rows': jsonEncode(noteRows(notes, l10n)),
      'tasks_title': l10n.navTasks,
      'tasks_empty': l10n.widgetTasksEmpty,
      'tasks_rows': jsonEncode(taskRows(tasks, l10n, now)),
      'calendar_title': l10n.navCalendar,
      'calendar_empty': l10n.widgetCalendarEmpty,
      'calendar_rows': jsonEncode(calendarRows(events, tasks, l10n, now)),
    };
  }

  Future<void> _write(Map<String, String> values) async {
    final changed = {
      for (final e in values.entries)
        if (_lastWritten[e.key] != e.value) e.key,
    };
    if (changed.isEmpty) return;

    for (final key in changed) {
      await HomeWidget.saveWidgetData<String>(key, values[key]);
      _lastWritten[key] = values[key]!;
    }
    final sharedChanged = _sharedKeys.any(changed.contains);
    for (final MapEntry(key: widget, value: keys) in _widgetKeys.entries) {
      final isList = widget != 'NoteepWidget';
      if (keys.any(changed.contains) || (isList && sharedChanged)) {
        await HomeWidget.updateWidget(
          qualifiedAndroidName: '$_package.$widget',
        );
      }
    }
  }
}
