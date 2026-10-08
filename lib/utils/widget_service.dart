// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _appGroupId = 'com.ndn21.noteep.widget';
  static const _qualifiedAndroidName = 'com.ndn21.noteep.NoteepWidget';
  static const _debounce = Duration(milliseconds: 500);

  Timer? _pending;
  (String, String, String)? _lastWritten;

  Future<void> init() async {
    // home_widget plugin is not available on web
    if (!kIsWeb) {
      await HomeWidget.setAppGroupId(_appGroupId);
    }
  }

  /// Schedules a widget refresh from the current notes/tasks. Bursts of
  /// changes (e.g. notes and tasks emitting back to back) collapse into a
  /// single write, and identical values are not rewritten.
  void scheduleSync(List<NoteModel> notes, List<TaskModel> tasks) {
    if (kIsWeb) return;
    _pending?.cancel();
    _pending = Timer(_debounce, () {
      NoteModel? latest;
      for (final n in notes) {
        if (latest == null || n.updatedAt.isAfter(latest.updatedAt)) {
          latest = n;
        }
      }
      updateWidget(
        noteCount: notes.length.toString(),
        taskCount: tasks.where((t) => !t.isCompleted).length.toString(),
        latestNote: latest?.title ?? '',
      );
    });
  }

  /// Updates the home widget with latest note info.
  Future<void> updateWidget({
    required String noteCount,
    required String taskCount,
    required String latestNote,
  }) async {
    // home_widget plugin is not available on web
    if (kIsWeb) return;

    final values = (noteCount, taskCount, latestNote);
    if (values == _lastWritten) return;
    _lastWritten = values;

    await HomeWidget.saveWidgetData<String>('note_count', noteCount);
    await HomeWidget.saveWidgetData<String>('task_count', taskCount);
    await HomeWidget.saveWidgetData<String>('latest_note', latestNote);
    await HomeWidget.updateWidget(androidName: _qualifiedAndroidName);
  }
}
