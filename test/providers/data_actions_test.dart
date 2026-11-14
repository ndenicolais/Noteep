// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/constants/app_version.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_list_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/labels_provider.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/settings/data_actions.dart';
import 'package:noteep/providers/settings/theme_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_container.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;
  late DataActions actions;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        ...firestoreOverrides(firestore, uid: 'u'),
        sharedPreferencesProvider.overrideWithValue(prefs),
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

      const header = ['app', 'schemaVersion', 'appVersion', 'exportedAt'];

      final notes = actions.notesExport();
      expect(notes.keys, unorderedEquals([...header, 'notes']));
      expect((notes['notes'] as List).single['id'], note.id);

      final tasks = actions.tasksExport();
      expect(tasks.keys, unorderedEquals([...header, 'tasks', 'taskLists']));

      final calendar = actions.calendarExport();
      expect((calendar['calendar'] as List).single['id'], event.id);

      final full = actions.fullBackupExport();
      expect(full['app'], DataActions.backupAppId);
      expect(full['schemaVersion'], DataActions.backupSchemaVersion);
      expect(full['appVersion'], appVersion);
      expect(
        full.keys,
        containsAll([
          'notes',
          'tasks',
          'taskLists',
          'calendar',
          'labels',
          'settings',
        ]),
      );
      expect(DateTime.tryParse(full['exportedAt'] as String), isNotNull);
    });
  });

  group('backup file header', () {
    test('a file of another app is refused', () {
      expect(
        () => actions.parseFullBackup({'app': 'flowdget', 'notes': []}),
        throwsA(isA<BackupFileException>()),
      );
      expect(
        () => actions.importNotes({'app': 'flowdget', 'notes': []}),
        throwsA(isA<BackupFileException>()),
      );
    });

    test('a newer schema is refused', () {
      expect(
        () => actions.parseFullBackup({
          'app': DataActions.backupAppId,
          'schemaVersion': DataActions.backupSchemaVersion + 1,
        }),
        throwsA(isA<BackupFileException>()),
      );
    });

    test('files of older versions (only "version") are accepted', () async {
      final data = actions.parseFullBackup({
        'version': '1.0.0',
        'exportedAt': '2026-01-01T10:00:00.000',
        'notes': [note.toJson()],
      });
      await actions.restore(data);
      expect(container.read(notesProvider).single.id, note.id);
    });
  });

  group('JSON imports', () {
    test('full backup export re-imports into an empty account', () async {
      await seed();
      final exported = actions.fullBackupExport();
      await actions.clearAll();
      expect(container.read(notesProvider), isEmpty);

      await actions.restore(actions.parseFullBackup(exported));
      expect(container.read(notesProvider).single.id, note.id);
      expect(container.read(tasksProvider).single.id, task.id);
      expect(container.read(taskListsProvider).single.id, list.id);
      expect(container.read(calendarProvider).single.id, event.id);
    });

    test(
      'full backup carries labels and settings, restored on request',
      () async {
        await container.read(labelsProvider.notifier).add('Casa');
        container.read(themeModeProvider.notifier).set(ThemeMode.dark);
        final exported = actions.fullBackupExport();
        expect(exported['labels'], ['Casa']);
        expect((exported['settings'] as Map)['themeMode'], 'dark');

        await container.read(labelsProvider.notifier).delete('Casa');
        container.read(themeModeProvider.notifier).set(ThemeMode.light);
        final data = actions.parseFullBackup(exported);

        await actions.restore(data);
        expect(container.read(labelsProvider).map((l) => l.name), ['Casa']);
        expect(container.read(themeModeProvider), ThemeMode.light);

        await actions.restore(data, restoreSettings: true);
        expect(container.read(themeModeProvider), ThemeMode.dark);
      },
    );

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

  group('account deletion', () {
    test('wipeRemoteData deletes documents not loaded in state', () async {
      await seed();
      // Written behind the notifiers' back: absent from provider state.
      await firestore.doc('users/u/notes/extra').set({'title': 'x'});
      await firestore.doc('users/u').set({'name': 'u'});
      await firestore.doc('users/other/notes/n').set({'title': 'y'});

      await actions.wipeRemoteData();

      for (final c in ['notes', 'tasks', 'task_lists', 'calendar_events']) {
        final snap = await firestore.collection('users/u/$c').get();
        expect(snap.docs, isEmpty, reason: c);
      }
      expect((await firestore.doc('users/u').get()).exists, isFalse);
      expect((await firestore.doc('users/other/notes/n').get()).exists, isTrue);
    });
  });
}
