// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/screens/home/reorderable_grid_view.dart';
import 'package:noteep/screens/tasks/task_item.dart';
import 'package:noteep/screens/tasks/task_list_view.dart';
import 'package:noteep/widgets/note_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/test_container.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = createTestContainer(
      FakeFirebaseFirestore(),
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  NotesNotifier notes() => container.read(notesProvider.notifier);
  TasksNotifier tasks() => container.read(tasksProvider.notifier);

  group('IdList', () {
    test('compares by content', () {
      expect(IdList(['a', 'b']), IdList(['a', 'b']));
      expect(IdList(['a', 'b']).hashCode, IdList(['a', 'b']).hashCode);
      expect(IdList(['a', 'b']), isNot(IdList(['b', 'a'])));
    });
  });

  group('per-id providers', () {
    test('filteredNoteIdsProvider ignores content-only edits', () async {
      final a = NoteModel(title: 'A');
      final b = NoteModel(title: 'B');
      await notes().addNote(a);
      await notes().addNote(b);

      var notified = 0;
      container.listen(filteredNoteIdsProvider, (_, _) => notified++);
      await notes().updateNote(a.copyWith(title: 'A modificata'));
      await container.pump();
      expect(notified, 0);

      await notes().addNote(NoteModel(title: 'C'));
      await container.pump();
      expect(notified, 1);
    });

    test('noteByIdProvider notifies only for its own note', () async {
      final a = NoteModel(title: 'A');
      final b = NoteModel(title: 'B');
      await notes().addNote(a);
      await notes().addNote(b);

      var aChanges = 0;
      var bChanges = 0;
      container.listen(noteByIdProvider(a.id), (_, _) => aChanges++);
      container.listen(noteByIdProvider(b.id), (_, _) => bChanges++);
      await notes().updateNote(a.copyWith(title: 'A modificata'));
      await container.pump();

      expect(aChanges, 1);
      expect(bChanges, 0);
      expect(container.read(noteByIdProvider(a.id))!.title, 'A modificata');
    });

    test('noteByIdProvider is null once the note is gone', () async {
      final a = NoteModel(title: 'A');
      await notes().addNote(a);
      container.listen(noteByIdProvider(a.id), (_, _) {});
      await notes().deleteNote(a.id);
      await container.pump();
      expect(container.read(noteByIdProvider(a.id)), isNull);
    });
  });

  group('rebuilds', () {
    Widget app(Widget body) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: body)),
    );

    NoteCard cardOf(WidgetTester tester, String title) => tester.widget(
      find.ancestor(of: find.text(title), matching: find.byType(NoteCard)),
    );

    testWidgets('editing a note rebuilds only its Home card', (tester) async {
      final a = NoteModel(title: 'A');
      final b = NoteModel(title: 'B');
      await notes().addNote(a);
      await notes().addNote(b);
      await tester.pumpWidget(
        app(
          Consumer(
            builder:
                (_, ref, _) => ReorderableGridView(
                  noteIds: ref.watch(filteredNoteIdsProvider).ids,
                  onReorder: (_, _) {},
                ),
          ),
        ),
      );
      final cardB = cardOf(tester, 'B');

      await notes().updateNote(a.copyWith(title: 'A2'));
      await tester.pump();

      expect(find.text('A2'), findsOneWidget);
      // Same widget instance: B's card was not rebuilt.
      expect(identical(cardOf(tester, 'B'), cardB), isTrue);
    });

    testWidgets('editing a task rebuilds only its row', (tester) async {
      final a = TaskModel(title: 'Uno');
      final b = TaskModel(title: 'Due');
      await tasks().addTask(a);
      await tasks().addTask(b);
      await tester.pumpWidget(app(TaskListView(source: activeTasksProvider)));
      await tester.pump();
      TaskItem rowOf(String title) => tester.widget(
        find.ancestor(of: find.text(title), matching: find.byType(TaskItem)),
      );
      final rowB = rowOf('Due');

      await tasks().updateTask(a.copyWith(title: 'Uno bis'));
      await tester.pump();
      expect(find.text('Uno bis'), findsOneWidget);
      expect(identical(rowOf('Due'), rowB), isTrue);

      // Completing a task moves it between sections.
      await tasks().toggleComplete(b.id);
      await tester.pumpAndSettle();
      expect(find.text('Completati'), findsOneWidget);
    });
  });
}
