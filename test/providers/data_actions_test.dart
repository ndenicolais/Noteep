// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/constants/app_version.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_list_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/settings/data_actions.dart';
import 'package:noteep/providers/tasks_provider.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late DataActions actions;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    container = ProviderContainer(
      overrides: [
        notesProvider.overrideWith(
          (ref) => NotesNotifier('u', firestore, (_) {}, () {}),
        ),
        tasksProvider.overrideWith(
          (ref) => TasksNotifier('u', firestore, (_) {}, () {}),
        ),
        taskListsProvider.overrideWith(
          (ref) => TaskListsNotifier('u', firestore, ref),
        ),
        calendarProvider.overrideWith(
          (ref) => CalendarNotifier('u', firestore),
        ),
      ],
    );
    actions = container.read(dataActionsProvider);
  });

  tearDown(() => container.dispose());

  final note = NoteModel(title: 'Spesa');
  final task = TaskModel(title: 'Chiamare');
  final list = TaskListModel(name: 'Lavoro');
  final event = CalendarEventModel(
    title: 'Dentista',
    startTime: DateTime(2026, 3, 10, 9),
    endTime: DateTime(2026, 3, 10, 10),
  );

  Future<void> seed() async {
    await container.read(notesProvider.notifier).addNote(note);
    await container.read(tasksProvider.notifier).addTask(task);
    await container.read(taskListsProvider.notifier).addList(list);
    await container.read(calendarProvider.notifier).addEvent(event);
  }

  group('exports', () {
    test('each export carries its own sections and a header', () async {
      await seed();

      final notes = actions.notesExport();
      expect(notes.keys, unorderedEquals(['version', 'exportedAt', 'notes']));
      expect((notes['notes'] as List).single['id'], note.id);

      final tasks = actions.tasksExport();
      expect(
        tasks.keys,
        unorderedEquals(['version', 'exportedAt', 'tasks', 'taskLists']),
      );

      final calendar = actions.calendarExport();
      expect((calendar['calendar'] as List).single['id'], event.id);

      final full = actions.fullBackupExport();
      expect(full['version'], appVersion);
      expect(
        full.keys,
        containsAll(['notes', 'tasks', 'taskLists', 'calendar']),
      );
      expect(DateTime.tryParse(full['exportedAt'] as String), isNotNull);
    });

    test('hasLockedNotes reflects the notes', () async {
      expect(actions.hasLockedNotes, isFalse);
      await container
          .read(notesProvider.notifier)
          .addNote(NoteModel(title: 'Segreta', isLocked: true));
      expect(actions.hasLockedNotes, isTrue);
    });
  });

  group('JSON imports', () {
    test('full backup export re-imports into an empty account', () async {
      await seed();
      final exported = actions.fullBackupExport();
      await actions.clearAll();
      expect(container.read(notesProvider), isEmpty);

      await actions.importFullBackup(exported);
      expect(container.read(notesProvider).single.id, note.id);
      expect(container.read(tasksProvider).single.id, task.id);
      expect(container.read(taskListsProvider).single.id, list.id);
      expect(container.read(calendarProvider).single.id, event.id);
    });

    test('importNotes reads only the notes from a full backup', () async {
      await seed();
      final exported = actions.fullBackupExport();
      await actions.clearAll();

      await actions.importNotes(exported);
      expect(container.read(notesProvider).single.id, note.id);
      expect(container.read(tasksProvider), isEmpty);
      expect(container.read(calendarProvider), isEmpty);
    });

    test('importTasks replaces tasks and lists together', () async {
      await actions.importTasks({
        'tasks': [task.toJson()],
        'taskLists': [list.toJson()],
      });
      expect(container.read(tasksProvider).single.id, task.id);
      expect(container.read(taskListsProvider).single.id, list.id);
      expect(container.read(notesProvider), isEmpty);
    });

    test('importCalendar replaces the events', () async {
      await actions.importCalendar({
        'calendar': [event.toJson()],
      });
      expect(container.read(calendarProvider).single.id, event.id);
    });

    test('a file without the section changes nothing', () async {
      await seed();
      await actions.importNotes({'something': 'else'});
      expect(container.read(notesProvider).single.id, note.id);
    });

    test('malformed data throws synchronously and changes nothing', () async {
      await seed();
      expect(
        () => actions.importTasks({
          'tasks': [task.toJson()],
          'taskLists': 'broken',
        }),
        throwsA(isA<TypeError>()),
      );
      expect(container.read(tasksProvider).single.id, task.id);
      expect(container.read(taskListsProvider).single.id, list.id);
    });
  });

  group('ICS', () {
    test('icsExport is null without active events', () {
      expect(actions.icsExport(), isNull);
    });

    test('icsExport includes the active events', () async {
      await seed();
      expect(actions.icsExport(), contains('SUMMARY:Dentista'));
    });

    test('importIcs adds the parsed events and reports the count', () async {
      final result = actions.importIcs(
        'BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY:Ferie\n'
        'DTSTART;VALUE=DATE:20260810\nEND:VEVENT\nEND:VCALENDAR',
      );
      expect(result.count, 1);
      await result.saved;
      expect(container.read(calendarProvider).single.title, 'Ferie');
    });

    test('importIcs with no events imports nothing', () async {
      final result = actions.importIcs('BEGIN:VCALENDAR\nEND:VCALENDAR');
      expect(result.count, 0);
      await result.saved;
      expect(container.read(calendarProvider), isEmpty);
    });
  });

  group('clear', () {
    test('each clear empties only its own data', () async {
      await seed();
      await actions.clearNotes();
      expect(container.read(notesProvider), isEmpty);
      expect(container.read(tasksProvider), isNotEmpty);

      await actions.clearTasks();
      expect(container.read(tasksProvider), isEmpty);
      expect(container.read(taskListsProvider), isEmpty);
      expect(container.read(calendarProvider), isNotEmpty);

      await actions.clearCalendar();
      expect(container.read(calendarProvider), isEmpty);
    });

    test('clearAll empties state and Firestore', () async {
      await seed();
      await actions.clearAll();
      expect(container.read(notesProvider), isEmpty);
      expect(container.read(tasksProvider), isEmpty);
      expect(container.read(taskListsProvider), isEmpty);
      expect(container.read(calendarProvider), isEmpty);
      for (final c in ['notes', 'tasks', 'task_lists', 'calendar_events']) {
        final snap = await firestore.collection('users/u/$c').get();
        expect(snap.docs, isEmpty, reason: c);
      }
    });
  });
}
