// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/reminders_actions.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/utils/event_alerts.dart';
import 'package:noteep/utils/notification_service.dart';
import 'package:noteep/utils/recurrence.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_container.dart';

/// Records what would be scheduled or cancelled, without the plugin.
class _FakeNotifications implements NotificationService {
  final scheduled = <String>[];
  var cancelAllCalls = 0;
  final askedPermission = <bool>[];

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<void> scheduleNoteReminder(
    NoteModel note, {
    bool askPermission = true,
  }) async {
    askedPermission.add(askPermission);
    if (note.reminder != null) scheduled.add('note:${note.id}');
  }

  @override
  Future<void> scheduleTaskReminder(
    TaskModel task, {
    bool askPermission = true,
  }) async {
    askedPermission.add(askPermission);
    if (task.reminder != null) scheduled.add('task:${task.id}');
  }

  @override
  Future<void> scheduleEventReminder(
    CalendarEventModel event, {
    bool askPermission = true,
  }) async {
    askedPermission.add(askPermission);
    if (event.reminder != null) scheduled.add('event:${event.id}');
  }

  @override
  Future<void> scheduleEventAlerts(
    CalendarEventModel event, {
    required int allDayMinutes,
    bool askPermission = true,
  }) async {
    askedPermission.add(askPermission);
    final alerts = upcomingEventAlerts(
      event,
      DateTime.now(),
      allDayMinutes: allDayMinutes,
    );
    if (alerts.isNotEmpty) {
      scheduled.add('alerts:${event.id}');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final later = DateTime.now().add(const Duration(days: 1));

  late FakeFirebaseFirestore firestore;
  late _FakeNotifications notifications;

  Future<void> put(String collection, String id, Map<String, dynamic> data) =>
      firestore
          .collection('users')
          .doc('test-uid')
          .collection(collection)
          .doc(id)
          .set(data);

  late SharedPreferences basePrefs;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    notifications = _FakeNotifications();
    SharedPreferences.setMockInitialValues({});
    basePrefs = await SharedPreferences.getInstance();
  });

  RemindersActions actions() {
    final container = createTestContainer(
      firestore,
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
        sharedPreferencesProvider.overrideWithValue(basePrefs),
      ],
    );
    return container.read(remindersActionsProvider);
  }

  test('resync reschedules the reminders of the loaded account', () async {
    final note = NoteModel(title: 'Nota', reminder: later);
    final trashed = NoteModel(
      title: 'Cestinata',
      reminder: later,
      deletedAt: DateTime.now(),
    );
    final task = TaskModel(title: 'Task', reminder: later);
    final done = TaskModel(title: 'Fatto', reminder: later, isCompleted: true);
    final event = CalendarEventModel(
      title: 'Evento',
      startTime: later,
      endTime: later.add(const Duration(hours: 1)),
      reminder: later,
    );
    await put('notes', note.id, note.toJson());
    await put('notes', trashed.id, trashed.toJson());
    await put('tasks', task.id, task.toJson());
    await put('tasks', done.id, done.toJson());
    await put('calendar_events', event.id, event.toJson());

    await actions().resync();

    expect(notifications.cancelAllCalls, 1);
    expect(
      notifications.scheduled,
      unorderedEquals([
        'note:${note.id}',
        'task:${task.id}',
        'event:${event.id}',
      ]),
    );
    expect(notifications.askedPermission, everyElement(isFalse));
  });

  test('resync leaves reminders alone when nobody is signed in', () async {
    final container = createTestContainer(
      firestore,
      uid: '',
      overrides: [notificationServiceProvider.overrideWithValue(notifications)],
    );

    await container.read(remindersActionsProvider).resync();

    expect(notifications.cancelAllCalls, 0);
  });

  test('cancelAll cancels every scheduled reminder', () async {
    await actions().cancelAll();
    expect(notifications.cancelAllCalls, 1);
  });

  group('migrateTimedReminders', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer migrationContainer() => createTestContainer(
      firestore,
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    test('gives future timed tasks and events an alert, once', () async {
      final past = DateTime.now().subtract(const Duration(days: 2));
      final timedTask = TaskModel(title: 'Timed', dueDate: later);
      final dayOnly = TaskModel(
        title: 'Day only',
        dueDate: DateTime(later.year, later.month, later.day),
      );
      final pastTask = TaskModel(title: 'Past', dueDate: past);
      final custom = TaskModel(
        title: 'Custom',
        dueDate: later,
        reminder: later.subtract(const Duration(hours: 1)),
      );
      final timedEvent = CalendarEventModel(
        title: 'Meeting',
        startTime: later,
        endTime: later,
      );
      final allDay = CalendarEventModel(
        title: 'Holiday',
        startTime: later,
        endTime: later,
        isAllDay: true,
      );
      final weeklyPast = CalendarEventModel(
        title: 'Weekly',
        startTime: past,
        endTime: past,
        recurrence: RecurrenceType.weekly,
      );
      for (final t in [timedTask, dayOnly, pastTask, custom]) {
        await put('tasks', t.id, t.toJson());
      }
      for (final e in [timedEvent, allDay, weeklyPast]) {
        await put('calendar_events', e.id, e.toJson());
      }

      final container = migrationContainer();
      await container
          .read(remindersActionsProvider)
          .migrateTimedReminders('test-uid');

      final tasks = {for (final t in container.read(tasksProvider)) t.title: t};
      expect(tasks['Timed']!.reminder, later);
      expect(tasks['Day only']!.reminder, isNull);
      expect(tasks['Past']!.reminder, isNull);
      expect(tasks['Custom']!.reminder, custom.reminder);
      final events = {
        for (final e in container.read(calendarProvider)) e.title: e,
      };
      expect(events['Meeting']!.alertSameDay, isTrue);
      expect(events['Holiday']!.alertSameDay, isFalse);
      expect(events['Weekly']!.alertSameDay, isTrue);
      expect(prefs.getBool('timed_reminders_migrated_test-uid'), isTrue);

      // A reminder removed afterwards is not put back.
      await container
          .read(tasksProvider.notifier)
          .updateTask(tasks['Timed']!.copyWith(clearReminder: true));
      await container
          .read(remindersActionsProvider)
          .migrateTimedReminders('test-uid');
      expect(
        container
            .read(tasksProvider)
            .firstWhere((t) => t.title == 'Timed')
            .reminder,
        isNull,
      );
    });
  });
}
