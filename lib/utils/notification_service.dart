// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../core/routing/notification_target.dart';
import '../l10n/l10n.dart';
import '../models/calendar_model.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import 'event_alerts.dart';
import 'markdown_text.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Target of the last tapped reminder, waiting to be opened by
  /// `NotificationLaunchHandler` (which resets it to `null` once handled).
  /// Set both when the app was launched by the tap and when it was already
  /// running.
  final ValueNotifier<NotificationTarget?> pendingTarget = ValueNotifier(null);

  static const _channelId = 'noteep_reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (r) => _onTapped(r.payload),
    );

    // App started (cold) by tapping a notification.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _onTapped(launch!.notificationResponse?.payload);
    }
  }

  void _onTapped(String? payload) {
    final target = NotificationTarget.parse(payload);
    if (target != null) pendingTarget.value = target;
  }

  Future<bool> requestPermissions() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required NotificationTarget target,
    bool askPermission = true,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Asked here, when the user sets a reminder, rather than at startup:
    // Android shows the dialog only if the permission is not granted yet.
    // The resync after sign-in passes false, so no dialog pops up on its own.
    if (askPermission) await requestPermissions();

    // The channel name is updated by Android on every schedule, so it
    // follows the current language.
    final l10n = currentL10n();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.notificationChannelName,
          channelDescription: l10n.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: target.encode(),
    );
  }

  /// Schedules the reminder of [note] at [NoteModel.reminder] (no-op if it is
  /// null or in the past).
  Future<void> scheduleNoteReminder(
    NoteModel note, {
    bool askPermission = true,
  }) async {
    final reminder = note.reminder;
    if (reminder == null) return;
    final l10n = currentL10n();
    final content = markdownToPlainText(note.content);
    await scheduleNotification(
      id: idForNote(note.id),
      title:
          note.title.isEmpty
              ? l10n.editorReminderNotificationTitle
              : note.title,
      body:
          content.isEmpty
              ? l10n.editorReminderNotificationBody
              : _preview(content),
      scheduledAt: reminder,
      target: NotificationTarget.note(note.id),
      askPermission: askPermission,
    );
  }

  /// Schedules the reminder of [task] at [TaskModel.reminder] (no-op if it is
  /// null or in the past).
  Future<void> scheduleTaskReminder(
    TaskModel task, {
    bool askPermission = true,
  }) async {
    final reminder = task.reminder;
    if (reminder == null) return;
    final l10n = currentL10n();
    await scheduleNotification(
      id: idForTask(task.id),
      title:
          task.title.isEmpty
              ? l10n.taskEditorReminderNotificationTitle
              : task.title,
      body:
          task.description.isEmpty
              ? l10n.taskEditorReminderNotificationBody
              : _preview(task.description),
      scheduledAt: reminder,
      target: NotificationTarget.task(task.id),
      askPermission: askPermission,
    );
  }

  /// Schedules the reminder of [event] at [CalendarEventModel.reminder]
  /// (no-op if it is null or in the past).
  Future<void> scheduleEventReminder(
    CalendarEventModel event, {
    bool askPermission = true,
  }) async {
    final reminder = event.reminder;
    if (reminder == null) return;
    final l10n = currentL10n();
    await scheduleNotification(
      id: idForEvent(event.id),
      title:
          event.title.isEmpty
              ? l10n.calendarReminderNotificationTitle
              : event.title,
      body:
          event.description.isEmpty
              ? l10n.calendarReminderNotificationBody
              : _preview(event.description),
      scheduledAt: reminder,
      target: NotificationTarget.event(event.id),
      askPermission: askPermission,
    );
  }

  /// Replaces the scheduled day-before / same-day alerts of [event] with
  /// its [upcomingEventAlerts] (none if it has no alert, or is archived or
  /// trashed). Each alert gets its own notification id; all-day events
  /// alert at [allDayMinutes] (minutes after midnight, the Settings value).
  Future<void> scheduleEventAlerts(
    CalendarEventModel event, {
    required int allDayMinutes,
    bool askPermission = true,
  }) async {
    if (kIsWeb) return;
    await cancelEventAlerts(event.id);
    final alerts = upcomingEventAlerts(
      event,
      DateTime.now(),
      allDayMinutes: allDayMinutes,
    );
    if (alerts.isEmpty) return;
    final l10n = currentL10n();
    final title =
        event.title.isEmpty
            ? l10n.calendarReminderNotificationTitle
            : event.title;
    for (var i = 0; i < alerts.length; i++) {
      final alert = alerts[i];
      final when =
          event.isAllDay
              ? l10n.calendarAllDay
              : '${alert.occurrence.hour.toString().padLeft(2, '0')}:'
                  '${alert.occurrence.minute.toString().padLeft(2, '0')}';
      await scheduleNotification(
        id: idForEventAlert(event.id, i),
        title: title,
        body:
            alert.dayBefore
                ? l10n.calendarAlertBodyTomorrow(when)
                : l10n.calendarAlertBodyToday(when),
        scheduledAt: alert.at,
        target: NotificationTarget.event(event.id),
        // Ask once, on the first alert, not for each of them.
        askPermission: askPermission && i == 0,
      );
    }
  }

  /// Cancels every day-before / same-day alert of the event [eventId].
  Future<void> cancelEventAlerts(String eventId) async {
    if (kIsWeb) return;
    for (var i = 0; i < maxEventAlerts; i++) {
      await _plugin.cancel(idForEventAlert(eventId, i));
    }
  }

  static String _preview(String text) =>
      text.substring(0, text.length > 80 ? 80 : text.length);

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Unique int ID derived from a note UUID.
  static int idForNote(String noteId) => noteId.hashCode.abs() % 100000;

  /// Unique int ID derived from a task UUID (offset to avoid collisions).
  static int idForTask(String taskId) =>
      (taskId.hashCode.abs() % 100000) + 100000;

  /// Unique int ID derived from a calendar event UUID (offset to avoid collisions).
  static int idForEvent(String eventId) =>
      (eventId.hashCode.abs() % 100000) + 200000;

  /// Alerts per event: one day-before and one same-day per occurrence.
  static const maxEventAlerts = maxAlertOccurrences * 2;

  /// Id of the [index]-th recurring alert of a calendar event, in its own
  /// range above the single reminders.
  static int idForEventAlert(String eventId, int index) =>
      1000000 + (eventId.hashCode.abs() % 100000) * maxEventAlerts + index;
}
