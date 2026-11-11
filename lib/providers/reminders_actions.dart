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
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../utils/event_alerts.dart';
import '../utils/notification_service.dart';
import 'calendar_provider.dart';
import 'core_providers.dart';
import 'notes_provider.dart';
import 'tasks_provider.dart';

/// The plugin-backed notification service; tests override it with a fake.
final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService.instance,
);

/// Reminder operations: removing reminders from notes and tasks (one or all
/// the past ones) and undoing the removal (Reminders screen), and keeping the
/// reminders scheduled on this device in line with the signed-in account.
class RemindersActions {
  RemindersActions(this._ref);

  final Ref _ref;

  NotificationService get _notifications =>
      _ref.read(notificationServiceProvider);

  /// Rebuilds the reminders scheduled on this device from the signed-in
  /// user's data: cancels them all, then schedules the future reminders of
  /// notes and events not in the trash and of open tasks.
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
      await notifications.cancelAllNotifications();
      await Future.wait([
        for (final note in _ref.read(notesProvider))
          if (note.deletedAt == null)
            notifications.scheduleNoteReminder(note, askPermission: false),
        for (final task in _ref.read(tasksProvider))
          if (task.deletedAt == null && !task.isCompleted)
            notifications.scheduleTaskReminder(task, askPermission: false),
        for (final event in _ref.read(calendarProvider))
          if (event.deletedAt == null) ...[
            notifications.scheduleEventReminder(event, askPermission: false),
            // Also moves the window of recurring alerts forward.
            notifications.scheduleEventAlerts(event, askPermission: false),
          ],
      ]);
    } catch (e) {
      if (kDebugMode) debugPrint('Reminders resync failed: $e');
    }
  }

  /// One-time switch to "anything with a day and a time alerts", per account
  /// (flag in `SharedPreferences`): open tasks whose due date has a future
  /// time and no reminder get a reminder at that time, and timed events with
  /// an occurrence still ahead and no reminder or alert get the same-day
  /// alert. Runs on web too (the data is shared), before [resync]; skipped,
  /// and retried at the next start, if the first fetch fails.
  Future<void> migrateTimedReminders(String uid) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final key = 'timed_reminders_migrated_$uid';
    if (prefs.getBool(key) ?? false) return;
    try {
      final loaded = await Future.wait([
        _ref.read(tasksProvider.notifier).initialLoad,
        _ref.read(calendarProvider.notifier).initialLoad,
      ]);
      if (loaded.contains(false)) return;
      final now = DateTime.now();
      await Future.wait([
        _ref.read(tasksProvider.notifier).updateTasks([
          for (final t in _ref.read(tasksProvider))
            if (t.deletedAt == null &&
                !t.isCompleted &&
                t.reminder == null &&
                t.hasDueTime &&
                t.dueDate!.isAfter(now))
              t.copyWith(reminder: t.dueDate),
        ]),
        _ref.read(calendarProvider.notifier).updateEvents([
          for (final e in _ref.read(calendarProvider))
            if (e.deletedAt == null &&
                !e.isArchived &&
                !e.isAllDay &&
                e.reminder == null &&
                !e.hasAlerts &&
                eventHasFutureOccurrence(e, now))
              e.copyWith(alertSameDay: true),
        ]),
      ]);
      await prefs.setBool(key, true);
    } catch (e) {
      if (kDebugMode) debugPrint('Timed reminders migration failed: $e');
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

  /// Clears the reminder of [notes] and [tasks] and cancels their
  /// notifications. Returns the persistence future.
  Future<void> clear({
    List<NoteModel> notes = const [],
    List<TaskModel> tasks = const [],
  }) async {
    final notesNotifier = _ref.read(notesProvider.notifier);
    final tasksNotifier = _ref.read(tasksProvider.notifier);
    await Future.wait([
      for (final note in notes) ...[
        notesNotifier.updateNote(note.copyWith(clearReminder: true)),
        _notifications.cancelNotification(
          NotificationService.idForNote(note.id),
        ),
      ],
      for (final task in tasks) ...[
        tasksNotifier.updateTask(task.copyWith(clearReminder: true)),
        _notifications.cancelNotification(
          NotificationService.idForTask(task.id),
        ),
      ],
    ]);
  }

  /// Puts back the reminders of [notes] and [tasks] as they were before
  /// [clear], on the current version of each item (still existing ones only),
  /// and reschedules the notifications still in the future.
  Future<void> restore({
    List<NoteModel> notes = const [],
    List<TaskModel> tasks = const [],
  }) async {
    final currentNotes = {for (final n in _ref.read(notesProvider)) n.id: n};
    final currentTasks = {for (final t in _ref.read(tasksProvider)) t.id: t};
    final notesNotifier = _ref.read(notesProvider.notifier);
    final tasksNotifier = _ref.read(tasksProvider.notifier);
    await Future.wait([
      for (final note in notes)
        if (currentNotes[note.id] case final current?) ...[
          notesNotifier.updateNote(current.copyWith(reminder: note.reminder)),
          _notifications.scheduleNoteReminder(
            current.copyWith(reminder: note.reminder),
          ),
        ],
      for (final task in tasks)
        if (currentTasks[task.id] case final current?) ...[
          tasksNotifier.updateTask(current.copyWith(reminder: task.reminder)),
          _notifications.scheduleTaskReminder(
            current.copyWith(reminder: task.reminder),
          ),
        ],
    ]);
  }
}

final remindersActionsProvider = Provider<RemindersActions>(
  RemindersActions.new,
);
