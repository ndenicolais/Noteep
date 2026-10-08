// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/change_history.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_change_history.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/providers/notes_undo_redo_provider.dart';
import 'package:noteep/providers/tasks_provider.dart';
import 'package:noteep/providers/tasks_undo_redo_provider.dart';

NoteTitleChange _title(int i) =>
    NoteTitleChange(oldTitle: 't$i', newTitle: 't${i + 1}');

/// Pumps a [Consumer] and returns its [WidgetRef], since the undo/redo
/// managers take a WidgetRef.
Future<WidgetRef> _pumpRef(
  WidgetTester tester,
  ProviderContainer container,
) async {
  late WidgetRef captured;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          captured = ref;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('NoteChangeHistoryNotifier', () {
    late NoteChangeHistoryNotifier history;

    setUp(() => history = NoteChangeHistoryNotifier());

    test('starts empty', () {
      expect(history.state.canUndo, isFalse);
      expect(history.state.canRedo, isFalse);
      expect(history.undo(), isNull);
      expect(history.redo(), isNull);
    });

    test('undo and redo move changes between the stacks', () {
      final a = _title(0);
      final b = _title(1);
      history
        ..addChange(a)
        ..addChange(b);
      expect(history.state.canUndo, isTrue);
      expect(history.state.canRedo, isFalse);

      expect(history.undo(), same(b));
      expect(history.undo(), same(a));
      expect(history.state.canUndo, isFalse);
      expect(history.state.canRedo, isTrue);

      expect(history.redo(), same(a));
      expect(history.redo(), same(b));
      expect(history.redo(), isNull);
      expect(history.state.canRedo, isFalse);
    });

    test('a new change clears the redo stack', () {
      history
        ..addChange(_title(0))
        ..undo();
      expect(history.state.canRedo, isTrue);

      history.addChange(_title(5));
      expect(history.state.canRedo, isFalse);
      expect(history.redo(), isNull);
    });

    test('keeps only the 50 most recent changes', () {
      final changes = List.generate(51, _title);
      changes.forEach(history.addChange);

      final undone = <NoteChange>[];
      for (NoteChange? c; (c = history.undo()) != null;) {
        undone.add(c!);
      }
      expect(undone, hasLength(50));
      expect(undone.last, same(changes[1])); // changes[0] was dropped
    });

    test('clear empties both stacks', () {
      history
        ..addChange(_title(0))
        ..addChange(_title(1))
        ..undo()
        ..clear();
      expect(history.state.canUndo, isFalse);
      expect(history.state.canRedo, isFalse);
    });
  });

  group('TaskChangeHistoryNotifier', () {
    test('mirrors the note history behaviour', () {
      final history = TaskChangeHistoryNotifier();
      final a = TaskTitleChange(oldTitle: 'a', newTitle: 'b');
      final b = TaskDescriptionChange(oldDescription: '', newDescription: 'x');
      history
        ..addChange(a)
        ..addChange(b);
      expect(history.undo(), same(b));
      expect(history.state.canRedo, isTrue);
      history.addChange(a);
      expect(history.state.canRedo, isFalse);

      for (var i = 0; i < 60; i++) {
        history.addChange(a);
      }
      var count = 0;
      while (history.undo() != null) {
        count++;
      }
      expect(count, 50);
    });
  });

  group('change classes used by the editors', () {
    test('note title and text changes touch only their field', () {
      final note = NoteModel(title: 'Vecchio', content: 'testo');
      final title = NoteTitleChange(oldTitle: 'Vecchio', newTitle: 'Nuovo');
      final applied = title.apply(note);
      expect(applied.title, 'Nuovo');
      expect(applied.content, 'testo');
      expect(applied.id, note.id);
      expect(title.undo(applied).title, 'Vecchio');

      final text = NoteTextChange(oldText: 'testo', newText: '');
      expect(text.apply(note).content, '');
      expect(text.apply(note).title, 'Vecchio');
      expect(text.undo(text.apply(note)).content, 'testo');
    });

    test('task title and description changes touch only their field', () {
      final task = TaskModel(title: 'A', description: 'd', isCompleted: true);
      final title = TaskTitleChange(oldTitle: 'A', newTitle: 'B');
      expect(title.apply(task).title, 'B');
      expect(title.apply(task).isCompleted, isTrue);
      expect(title.undo(title.apply(task)).title, 'A');

      final desc = TaskDescriptionChange(
        oldDescription: 'd',
        newDescription: 'e',
      );
      expect(desc.apply(task).description, 'e');
      expect(desc.apply(task).title, 'A');
      expect(desc.undo(desc.apply(task)).description, 'd');
    });
  });

  group('NoteUndoRedoManager', () {
    late FakeFirebaseFirestore firestore;
    late ProviderContainer container;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      container = ProviderContainer(
        overrides: [
          notesProvider.overrideWith(
            (ref) => NotesNotifier('u', firestore, (_) {}, () {}),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    testWidgets('undo/redo return the note and persist it', (tester) async {
      final ref = await _pumpRef(tester, container);
      final note = NoteModel(title: 'Nuovo');
      await container.read(notesProvider.notifier).addNote(note);
      ref
          .read(noteChangeHistoryProvider(note.id).notifier)
          .addChange(NoteTitleChange(oldTitle: 'Vecchio', newTitle: 'Nuovo'));

      final undone = NoteUndoRedoManager.performUndo(ref, note.id, note);
      expect(undone!.title, 'Vecchio');
      expect(container.read(notesProvider).single.title, 'Vecchio');

      final redone = NoteUndoRedoManager.performRedo(ref, note.id, undone);
      expect(redone!.title, 'Nuovo');
      expect(container.read(notesProvider).single.title, 'Nuovo');
    });

    testWidgets('returns null with nothing to undo or redo', (tester) async {
      final ref = await _pumpRef(tester, container);
      final note = NoteModel(title: 'X');
      expect(NoteUndoRedoManager.performUndo(ref, note.id, note), isNull);
      expect(NoteUndoRedoManager.performRedo(ref, note.id, note), isNull);
    });

    testWidgets('does not save a note that is not stored yet', (tester) async {
      final ref = await _pumpRef(tester, container);
      final draft = NoteModel(title: 'Bozza');
      ref
          .read(noteChangeHistoryProvider(draft.id).notifier)
          .addChange(NoteTitleChange(oldTitle: '', newTitle: 'Bozza'));

      final undone = NoteUndoRedoManager.performUndo(ref, draft.id, draft);
      expect(undone!.title, '');
      expect(container.read(notesProvider), isEmpty);
    });
  });

  group('TaskUndoRedoManager', () {
    testWidgets('undo/redo return the task and persist it', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith(
            (ref) => TasksNotifier('u', firestore, (_) {}, () {}),
          ),
        ],
      );
      addTearDown(container.dispose);
      final ref = await _pumpRef(tester, container);

      final task = TaskModel(title: 'Nuovo');
      await container.read(tasksProvider.notifier).addTask(task);
      ref
          .read(taskChangeHistoryProvider(task.id).notifier)
          .addChange(TaskTitleChange(oldTitle: 'Vecchio', newTitle: 'Nuovo'));

      final undone = TaskUndoRedoManager.performUndo(ref, task.id, task);
      expect(undone!.title, 'Vecchio');
      expect(container.read(tasksProvider).single.title, 'Vecchio');

      final redone = TaskUndoRedoManager.performRedo(ref, task.id, undone);
      expect(redone!.title, 'Nuovo');
      expect(container.read(tasksProvider).single.title, 'Nuovo');
    });
  });
}
