// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/reminders_actions.dart';
import 'package:noteep/utils/notification_service.dart';
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

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifications = _FakeNotifications();
  });

  RemindersActions actions() {
    final container = createTestContainer(
      firestore,
      overrides: [notificationServiceProvider.overrideWithValue(notifications)],
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
}
