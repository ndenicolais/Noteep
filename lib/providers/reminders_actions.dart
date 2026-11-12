// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/notification_service.dart';
import 'calendar_provider.dart';
import 'notes_provider.dart';
import 'settings/ui_provider.dart';
import 'tasks_provider.dart';

/// The plugin-backed notification service; tests override it with a fake.
final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService.instance,
);

/// Keeps the notifications scheduled on this device (note reminders, task
/// due times, event alerts) in line with the signed-in account.
class RemindersActions {
  RemindersActions(this._ref);

  final Ref _ref;

  NotificationService get _notifications =>
      _ref.read(notificationServiceProvider);

  /// Rebuilds the notifications scheduled on this device from the signed-in
  /// user's data: cancels them all, then schedules the future reminders of
  /// notes and alerts of events not in the trash, and the due times of open
  /// tasks.
  ///
  /// Reminders are scheduled locally when an item is edited, so without this
  /// a new sign-in (or a second device, or a reinstall) would have none.
  /// Waits for the first fetch of notes, tasks and events; if any of them
  /// fails (e.g. offline with an empty cache) nothing is touched, so the
  /// reminders already scheduled survive. No permission dialog is shown.
  Future<void> resync() async {
    if (kIsWeb) return;
    try {
      final loaded = await Future.wait([
        _ref.read(notesProvider.notifier).initialLoad,
        _ref.read(tasksProvider.notifier).initialLoad,
        _ref.read(calendarProvider.notifier).initialLoad,
      ]);
      if (loaded.contains(false)) return;
      final notifications = _notifications;
      final allDayMinutes = _ref.read(defaultAlertTimeProvider);
      await notifications.cancelAllNotifications();
      await Future.wait([
        for (final note in _ref.read(notesProvider))
          if (note.deletedAt == null)
            notifications.scheduleNoteReminder(note, askPermission: false),
        for (final task in _ref.read(tasksProvider))
          if (task.deletedAt == null && !task.isCompleted)
            notifications.scheduleTaskReminder(task, askPermission: false),
        for (final event in _ref.read(calendarProvider))
          if (event.deletedAt == null)
            // Also moves the window of recurring alerts forward.
            notifications.scheduleEventAlerts(
              event,
              allDayMinutes: allDayMinutes,
              askPermission: false,
            ),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('Reminders resync failed: $e');
    }
  }

  /// Saves the default alert time (minutes after midnight) and reschedules
  /// the alerts of every event, so all-day ones move to the new time.
  Future<void> setDefaultAlertTime(int minutes) async {
    _ref.read(defaultAlertTimeProvider.notifier).set(minutes);
    if (kIsWeb) return;
    try {
      final notifications = _notifications;
      await Future.wait([
        for (final event in _ref.read(calendarProvider))
          if (event.deletedAt == null && event.isAllDay)
            notifications.scheduleEventAlerts(
              event,
              allDayMinutes: minutes,
              askPermission: false,
            ),
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('Default alert time reschedule failed: $e');
    }
  }

  /// Cancels every reminder scheduled on this device, so the reminders of an
  /// account that signed out do not keep firing.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _notifications.cancelAllNotifications();
    } catch (e) {
      if (kDebugMode) debugPrint('Reminders cancel failed: $e');
    }
  }
}

final remindersActionsProvider = Provider<RemindersActions>(
  RemindersActions.new,
);
