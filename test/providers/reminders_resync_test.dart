// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/auth_provider.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/reminders_actions.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/utils/event_alerts.dart';
import 'package:noteep/utils/notification_service.dart';
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
    if (task.hasDueTime) scheduled.add('task:${task.id}');
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

  test('resync reschedules the notifications of the loaded account', () async {
    final at = DateTime(later.year, later.month, later.day, 10, 30);
    final note = NoteModel(title: 'Nota', reminder: later);
    final trashed = NoteModel(
      title: 'Cestinata',
      reminder: later,
      deletedAt: DateTime.now(),
    );
    final task = TaskModel(title: 'Task', dueDate: at);
    final dayOnly = TaskModel(
      title: 'Solo data',
      dueDate: DateTime(later.year, later.month, later.day),
    );
    final done = TaskModel(title: 'Fatto', dueDate: at, isCompleted: true);
    final event = CalendarEventModel(
      title: 'Evento',
      startTime: at,
      endTime: at.add(const Duration(hours: 1)),
    );
    final allDay = CalendarEventModel(
      title: 'Ferie',
      startTime: DateTime(later.year, later.month, later.day),
      endTime: DateTime(later.year, later.month, later.day + 1),
      isAllDay: true,
    );
    await put('notes', note.id, note.toJson());
    await put('notes', trashed.id, trashed.toJson());
    for (final t in [task, dayOnly, done]) {
      await put('tasks', t.id, t.toJson());
    }
    for (final e in [event, allDay]) {
      await put('calendar_events', e.id, e.toJson());
    }

    await actions().resync();

    expect(notifications.cancelAllCalls, 1);
    expect(
      notifications.scheduled,
      unorderedEquals([
        'note:${note.id}',
        'task:${task.id}',
        'alerts:${event.id}',
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

  test('resync after a sign-in schedules the new account reminders', () async {
    // The data notifiers are already built signed out (as in the app, where
    // the home widget listeners read them at startup), then the user signs
    // in and resync runs from the uid listener.
    final at = DateTime(later.year, later.month, later.day, 10, 30);
    final task = TaskModel(title: 'Task', dueDate: at);
    await put('tasks', task.id, task.toJson());
    final uid = StateProvider<String>((_) => '');
    final container = ProviderContainer(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
        currentUidProvider.overrideWith((ref) => ref.watch(uid)),
        notificationServiceProvider.overrideWithValue(notifications),
        sharedPreferencesProvider.overrideWithValue(basePrefs),
      ],
    );
    addTearDown(container.dispose);
    container
      ..read(notesProvider)
      ..read(tasksProvider)
      ..read(calendarProvider);
    await pumpEventQueue();
    Future<void>? resync;
    container.listen<String>(currentUidProvider, (_, next) {
      if (next.isNotEmpty) {
        resync = container.read(remindersActionsProvider).resync();
      }
    });

    container.read(uid.notifier).state = 'test-uid';
    container.read(currentUidProvider);
    await resync;

    expect(notifications.cancelAllCalls, 1);
    expect(notifications.scheduled, ['task:${task.id}']);
  });

  test('cancelAll cancels every scheduled reminder', () async {
    await actions().cancelAll();
    expect(notifications.cancelAllCalls, 1);
  });

  group('legacy task reminders', () {
    Map<String, dynamic> legacy({DateTime? due, required DateTime reminder}) =>
        {
          ...TaskModel(title: 'Old', dueDate: due).toJson(),
          'reminder': reminder.toIso8601String(),
        };

    test('a reminder without a due date becomes the due date', () {
      final reminder = DateTime(2026, 12, 24, 18, 30);
      final task = TaskModel.fromJson(legacy(reminder: reminder));
      expect(task.dueDate, reminder);
      expect(task.hasDueTime, isTrue);
    });

    test('a reminder on a date-only due day gives it its time', () {
      final reminder = DateTime(2026, 12, 24, 18, 30);
      final task = TaskModel.fromJson(
        legacy(due: DateTime(2026, 12, 24), reminder: reminder),
      );
      expect(task.dueDate, reminder);
    });

    test('a reminder on another day leaves the due date alone', () {
      final due = DateTime(2026, 12, 24);
      final task = TaskModel.fromJson(
        legacy(due: due, reminder: DateTime(2026, 12, 23, 18)),
      );
      expect(task.dueDate, due);
    });
  });
}
