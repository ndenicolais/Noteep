// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const _appGroupId = 'com.ndn21.noteep.widget';
  static const _qualifiedAndroidName = 'com.ndn21.noteep.NoteepWidget';

  Future<void> init() async {
    // home_widget plugin is not available on web
    if (!kIsWeb) {
      await HomeWidget.setAppGroupId(_appGroupId);
    }
  }

  /// Updates the home widget with latest note info.
  Future<void> updateWidget({
    required String noteCount,
    required String taskCount,
    required String latestNote,
  }) async {
    // home_widget plugin is not available on web
    if (kIsWeb) return;

    await HomeWidget.saveWidgetData<String>('note_count', noteCount);
    await HomeWidget.saveWidgetData<String>('task_count', taskCount);
    await HomeWidget.saveWidgetData<String>('latest_note', latestNote);
    await HomeWidget.updateWidget(androidName: _qualifiedAndroidName);
  }
}
