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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/task_list_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/notes_provider.dart' show sharedPreferencesProvider;
import 'package:noteep/providers/tasks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exposes a usable [Ref] tied to a [ProviderContainer], for constructing
/// notifiers (like [TaskListsNotifier]) that need one outside of Riverpod's
/// normal provider wiring.
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  late FakeFirebaseFirestore firestore;
  late TasksNotifier notifier;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    notifier = TasksNotifier('test-uid', firestore, (_) {}, () {});
  });

  group('TasksNotifier CRUD', () {
    test('addTask adds to state and persists to Firestore', () async {
      final task = TaskModel(title: 'Buy milk');
      await notifier.addTask(task);

      expect(notifier.state.map((t) => t.id), contains(task.id));
      final doc =
          await firestore
              .collection('users')
              .doc('test-uid')
              .collection('tasks')
              .doc(task.id)
              .get();
      expect(doc.data()!['title'], 'Buy milk');
    });

    test('updateTask replaces the existing task', () async {
      final task = TaskModel(title: 'Original');
      await notifier.addTask(task);

      await notifier.updateTask(task.copyWith(title: 'Updated'));

      expect(notifier.state.single.title, 'Updated');
    });

    test('deleteTask removes from state and Firestore', () async {
      final task = TaskModel(title: 'ToDelete');
      await notifier.addTask(task);

      await notifier.deleteTask(task.id);

      expect(notifier.state, isEmpty);
    });

    test('clearAll removes every task', () async {
      await notifier.addTask(TaskModel(title: 'A'));
      await notifier.addTask(TaskModel(title: 'B'));

      await notifier.clearAll();

      expect(notifier.state, isEmpty);
    });
  });

  group('TasksNotifier trash lifecycle', () {
    test('softDelete sets deletedAt and clears archive flag', () async {
      final task = TaskModel(title: 'Archived', isArchived: true);
      await notifier.addTask(task);

      await notifier.softDelete(task.id);

      final result = notifier.state.single;
      expect(result.deletedAt, isNotNull);
      expect(result.isArchived, isFalse);
    });

    test('restoreFromTrash clears deletedAt', () async {
      final task = TaskModel(title: 'Trashed');
      await notifier.addTask(task);
      await notifier.softDelete(task.id);

      await notifier.restoreFromTrash(task.id);

      expect(notifier.state.single.deletedAt, isNull);
    });

    test('permanentlyDelete removes the task entirely', () async {
      final task = TaskModel(title: 'Gone');
      await notifier.addTask(task);
      await notifier.softDelete(task.id);

      await notifier.permanentlyDelete(task.id);

      expect(notifier.state, isEmpty);
    });
  });

  group('TasksNotifier toggles', () {
    test('toggleComplete flips isCompleted', () async {
      final task = TaskModel(title: 'A');
      await notifier.addTask(task);

      await notifier.toggleComplete(task.id);
      expect(notifier.state.single.isCompleted, isTrue);

      await notifier.toggleComplete(task.id);
      expect(notifier.state.single.isCompleted, isFalse);
    });

    test('toggleSpecial flips isSpecial', () async {
      final task = TaskModel(title: 'A');
      await notifier.addTask(task);

      await notifier.toggleSpecial(task.id);

      expect(notifier.state.single.isSpecial, isTrue);
    });

    test('toggleArchive flips isArchived', () async {
      final task = TaskModel(title: 'A');
      await notifier.addTask(task);

      await notifier.toggleArchive(task.id);

      expect(notifier.state.single.isArchived, isTrue);
    });
  });

  test('moveToList sets and clears listId', () async {
    final task = TaskModel(title: 'A');
    await notifier.addTask(task);

    await notifier.moveToList(task.id, 'list-1');
    expect(notifier.state.single.listId, 'list-1');

    await notifier.moveToList(task.id, null);
    expect(notifier.state.single.listId, isNull);
  });

  test('clearListReferences clears listId on every matching task', () async {
    final a = TaskModel(title: 'A', listId: 'list-1');
    final b = TaskModel(title: 'B', listId: 'list-1');
    final c = TaskModel(title: 'C', listId: 'list-2');
    await notifier.addTask(a);
    await notifier.addTask(b);
    await notifier.addTask(c);

    await notifier.clearListReferences('list-1');

    expect(notifier.state.firstWhere((t) => t.id == a.id).listId, isNull);
    expect(notifier.state.firstWhere((t) => t.id == b.id).listId, isNull);
    expect(notifier.state.firstWhere((t) => t.id == c.id).listId, 'list-2');
  });

  group('TaskListsNotifier', () {
    test('addList/updateList/clearAll manage the lists collection', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final listsNotifier = TaskListsNotifier(
        'test-uid',
        firestore,
        container.read(_refProvider),
      );

      final list = TaskListModel(name: 'Work');
      await listsNotifier.addList(list);
      expect(listsNotifier.state.single.name, 'Work');

      await listsNotifier.updateList(list.copyWith(name: 'Personal'));
      expect(listsNotifier.state.single.name, 'Personal');

      await listsNotifier.clearAll();
      expect(listsNotifier.state, isEmpty);
    });

    test(
      'deleteList removes the list and clears listId on referencing tasks',
      () async {
        final container = ProviderContainer(
          overrides: [tasksProvider.overrideWith((ref) => notifier)],
        );
        addTearDown(container.dispose);
        final listsNotifier = TaskListsNotifier(
          'test-uid',
          firestore,
          container.read(_refProvider),
        );

        final list = TaskListModel(name: 'Work');
        await listsNotifier.addList(list);

        final task = TaskModel(title: 'T1', listId: list.id);
        await notifier.addTask(task);

        await listsNotifier.deleteList(list.id);

        expect(listsNotifier.state, isEmpty);
        expect(notifier.state.single.listId, isNull);
      },
    );
  });

  group('Derived task providers', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
      'activeTasksProvider/archivedTasksProvider/trashedTasksProvider '
      'filter by archive/trash status',
      () async {
        final container = ProviderContainer(
          overrides: [
            tasksProvider.overrideWith((ref) => notifier),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
        );
        addTearDown(container.dispose);

        final active = TaskModel(title: 'Active');
        final archived = TaskModel(title: 'Archived', isArchived: true);
        final trashed = TaskModel(title: 'Trashed', deletedAt: DateTime.now());
        await notifier.addTask(active);
        await notifier.addTask(archived);
        await notifier.addTask(trashed);

        expect(
          container.read(activeTasksProvider).map((t) => t.title),
          ['Active'],
        );
        expect(
          container.read(archivedTasksProvider).map((t) => t.title),
          ['Archived'],
        );
        expect(
          container.read(trashedTasksProvider).map((t) => t.title),
          ['Trashed'],
        );
      },
    );

    test('specialTasksProvider only returns non-archived special tasks', () async {
      final container = ProviderContainer(
        overrides: [
          tasksProvider.overrideWith((ref) => notifier),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final special = TaskModel(title: 'Special', isSpecial: true);
      final archivedSpecial = TaskModel(
        title: 'ArchivedSpecial',
        isSpecial: true,
        isArchived: true,
      );
      await notifier.addTask(special);
      await notifier.addTask(archivedSpecial);

      expect(
        container.read(specialTasksProvider).map((t) => t.title),
        ['Special'],
      );
    });
  });
}
