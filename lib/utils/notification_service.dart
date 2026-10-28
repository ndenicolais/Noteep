// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../core/routing/notification_target.dart';
import '../l10n/l10n.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
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
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // Asked here, when the user sets a reminder, rather than at startup:
    // Android shows the dialog only if the permission is not granted yet.
    await requestPermissions();

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
  Future<void> scheduleNoteReminder(NoteModel note) async {
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
    );
  }

  /// Schedules the reminder of [task] at [TaskModel.reminder] (no-op if it is
  /// null or in the past).
  Future<void> scheduleTaskReminder(TaskModel task) async {
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
    );
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
}
