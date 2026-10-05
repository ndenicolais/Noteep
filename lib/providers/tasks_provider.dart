// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/task_list_model.dart';
import 'auth_provider.dart';
import 'settings/ui_provider.dart'; // For SortOrder

// ─── Tasks Notifier ───────────────────────────────────────────────────────────

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier(this._uid, this._db, this._onLoadError, this._onLoadDone)
    : super([]) {
    _load();
  }

  final String _uid;
  final FirebaseFirestore _db;
  final void Function(Object? error) _onLoadError;
  final void Function() _onLoadDone;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('tasks');

  /// Applies [apply] to state immediately (optimistic update), then runs
  /// [persist]; if it throws, the state change is rolled back and the error
  /// is rethrown instead of being silently swallowed.
  Future<void> _mutate(
    List<TaskModel> Function(List<TaskModel> current) apply,
    Future<void> Function() persist,
  ) async {
    final previous = state;
    state = apply(previous);
    try {
      await persist();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> _load() async {
    if (_uid.isEmpty) return;
    try {
      final snap = await _col.get();
      final tasks =
          snap.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return TaskModel.fromJson(data);
          }).toList();
      // Merge instead of replace: any task added/edited locally while this
      // initial fetch was in flight must not be wiped out by it.
      final existingIds = state.map((t) => t.id).toSet();
      state = [...state, ...tasks.where((t) => !existingIds.contains(t.id))];
      _onLoadError(null);
      await _purgeOldTrashFirestore();
    } catch (e) {
      _onLoadError(e);
    } finally {
      _onLoadDone();
    }
  }

  Future<void> _saveDoc(TaskModel task) async {
    await _col.doc(task.id).set(task.toJson());
  }

  Future<void> _deleteDoc(String id) async {
    await _col.doc(id).delete();
  }

  /// Commits Firestore batch writes in chunks of 500 (Firestore's per-batch
  /// operation limit).
  Future<void> _commitInChunks(
    List<void Function(WriteBatch batch)> ops,
  ) async {
    for (var i = 0; i < ops.length; i += 500) {
      final batch = _db.batch();
      for (final op in ops.skip(i).take(500)) {
        op(batch);
      }
      await batch.commit();
    }
  }

  Future<void> _purgeOldTrashFirestore() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final expired =
        state
            .where((t) => t.deletedAt != null && t.deletedAt!.isBefore(cutoff))
            .toList();
    if (expired.isEmpty) return;
    state =
        state
            .where((t) => t.deletedAt == null || t.deletedAt!.isAfter(cutoff))
            .toList();
    await _commitInChunks(
      expired.map((t) => (WriteBatch b) => b.delete(_col.doc(t.id))).toList(),
    );
  }

  void purgeOldTrash() {
    _purgeOldTrashFirestore();
  }

  Future<void> addTask(TaskModel task) => _mutate(
    (current) => [task, ...current],
    () => _saveDoc(task),
  );

  Future<void> updateTask(TaskModel updated) => _mutate(
    (current) =>
        current.map((t) => t.id == updated.id ? updated : t).toList(),
    () => _saveDoc(updated),
  );

  Future<void> softDelete(String id) async {
    final updated = state
        .firstWhere((t) => t.id == id)
        .copyWith(deletedAt: DateTime.now(), isArchived: false);
    await _mutate(
      (current) => current.map((t) => t.id == id ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final updated = state.firstWhere((t) => t.id == id).copyWith(
      clearDeletedAt: true,
    );
    await _mutate(
      (current) => current.map((t) => t.id == id ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> permanentlyDelete(String id) => _mutate(
    (current) => current.where((t) => t.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> toggleArchive(String id) async {
    final updated = state
        .firstWhere((t) => t.id == id)
        .copyWith(isArchived: !state.firstWhere((t) => t.id == id).isArchived);
    await _mutate(
      (current) => current.map((t) => t.id == id ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> deleteTask(String id) => _mutate(
    (current) => current.where((t) => t.id != id).toList(),
    () => _deleteDoc(id),
  );

  Future<void> toggleComplete(String id) async {
    final updated = state
        .firstWhere((t) => t.id == id)
        .copyWith(
          isCompleted: !state.firstWhere((t) => t.id == id).isCompleted,
        );
    await _mutate(
      (current) => current.map((t) => t.id == id ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> toggleSpecial(String id) async {
    final updated = state
        .firstWhere((t) => t.id == id)
        .copyWith(isSpecial: !state.firstWhere((t) => t.id == id).isSpecial);
    await _mutate(
      (current) => current.map((t) => t.id == id ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  Future<void> moveToList(String taskId, String? listId) async {
    final updated = state
        .firstWhere((t) => t.id == taskId)
        .copyWith(listId: listId, clearListId: listId == null);
    await _mutate(
      (current) => current.map((t) => t.id == taskId ? updated : t).toList(),
      () => _saveDoc(updated),
    );
  }

  /// Clears [listId] on every task that pointed at a now-deleted list, both
  /// locally and on Firestore, so tasks don't keep a dangling reference.
  Future<void> clearListReferences(String listId) async {
    final affected = state.where((t) => t.listId == listId).toList();
    if (affected.isEmpty) return;
    await _mutate(
      (current) =>
          current
              .map(
                (t) => t.listId == listId ? t.copyWith(clearListId: true) : t,
              )
              .toList(),
      () => _commitInChunks(
        affected
            .map(
              (t) =>
                  (WriteBatch b) => b.set(
                    _col.doc(t.id),
                    t.copyWith(clearListId: true).toJson(),
                  ),
            )
            .toList(),
      ),
    );
  }

  /// Replaces the entire tasks collection (used for full backup restore).
  Future<void> replaceAll(List<TaskModel> tasks) => _mutate(
    (_) => tasks,
    () => _commitInChunks(
      tasks
          .map((t) => (WriteBatch b) => b.set(_col.doc(t.id), t.toJson()))
          .toList(),
    ),
  );

  /// Permanently removes all tasks.
  Future<void> clearAll() {
    final ids = state.map((t) => t.id).toList();
    return _mutate(
      (_) => [],
      () => _commitInChunks(
        ids.map((id) => (WriteBatch b) => b.delete(_col.doc(id))).toList(),
      ),
    );
  }
}

/// Set (or cleared) whenever the initial Firestore load in [TasksNotifier]
/// succeeds or fails, so the UI can tell a real sync error apart from a
/// genuinely empty task list.
final tasksLoadErrorProvider = StateProvider<Object?>((ref) => null);

/// True while the initial Firestore load in [TasksNotifier] is in flight,
/// so the UI can tell "still loading" apart from a genuinely empty list.
final tasksLoadingProvider = StateProvider<bool>((ref) => true);

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  return TasksNotifier(
    user?.uid ?? '',
    FirebaseFirestore.instance,
    (error) => ref.read(tasksLoadErrorProvider.notifier).state = error,
    () => ref.read(tasksLoadingProvider.notifier).state = false,
  );
});

// ─── Task Lists Notifier ──────────────────────────────────────────────────────

class TaskListsNotifier extends StateNotifier<List<TaskListModel>> {
  TaskListsNotifier(this._uid, this._db, this._ref) : super([]) {
    _load();
  }

  final String _uid;
  final FirebaseFirestore _db;
  final Ref _ref;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('task_lists');

  Future<void> _mutate(
    List<TaskListModel> Function(List<TaskListModel> current) apply,
    Future<void> Function() persist,
  ) async {
    final previous = state;
    state = apply(previous);
    try {
      await persist();
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<void> _commitInChunks(
    List<void Function(WriteBatch batch)> ops,
  ) async {
    for (var i = 0; i < ops.length; i += 500) {
      final batch = _db.batch();
      for (final op in ops.skip(i).take(500)) {
        op(batch);
      }
      await batch.commit();
    }
  }

  Future<void> _load() async {
    if (_uid.isEmpty) return;
    final snap = await _col.get();
    final lists =
        snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return TaskListModel.fromJson(data);
        }).toList();
    final existingIds = state.map((l) => l.id).toSet();
    state = [...state, ...lists.where((l) => !existingIds.contains(l.id))];
  }

  Future<void> addList(TaskListModel taskList) => _mutate(
    (current) => [...current, taskList],
    () => _col.doc(taskList.id).set(taskList.toJson()),
  );

  Future<void> updateList(TaskListModel updated) => _mutate(
    (current) => current.map((l) => l.id == updated.id ? updated : l).toList(),
    () => _col.doc(updated.id).set(updated.toJson()),
  );

  Future<void> deleteList(String id) async {
    await _mutate(
      (current) => current.where((l) => l.id != id).toList(),
      () => _col.doc(id).delete(),
    );
    // Tasks pointing at this now-deleted list must not keep a dangling
    // listId, otherwise they become invisible in every filter/tab forever.
    await _ref.read(tasksProvider.notifier).clearListReferences(id);
  }

  /// Replaces the entire task-lists collection (used for full backup restore).
  Future<void> replaceAll(List<TaskListModel> lists) => _mutate(
    (_) => lists,
    () => _commitInChunks(
      lists
          .map((l) => (WriteBatch b) => b.set(_col.doc(l.id), l.toJson()))
          .toList(),
    ),
  );

  /// Permanently removes all task lists.
  Future<void> clearAll() {
    final ids = state.map((l) => l.id).toList();
    return _mutate(
      (_) => [],
      () => _commitInChunks(
        ids.map((id) => (WriteBatch b) => b.delete(_col.doc(id))).toList(),
      ),
    );
  }
}

final taskListsProvider =
    StateNotifierProvider<TaskListsNotifier, List<TaskListModel>>((ref) {
      final user = ref.watch(currentUserProvider);
      return TaskListsNotifier(user?.uid ?? '', FirebaseFirestore.instance, ref);
    });

// ─── Filtered & Sorted Providers ─────────────────────────────────────────────

final activeTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final sort = ref.watch(taskSortOrderProvider);

  var filtered =
      tasks.where((t) => !t.isArchived && t.deletedAt == null).toList();

  _sortTasks(filtered, sort);
  return filtered;
});

final specialTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final sort = ref.watch(taskSortOrderProvider);

  var filtered =
      tasks
          .where((t) => t.isSpecial && !t.isArchived && t.deletedAt == null)
          .toList();

  _sortTasks(filtered, sort);
  return filtered;
});

final archivedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final sort = ref.watch(taskSortOrderProvider);

  var filtered =
      tasks.where((t) => t.isArchived && t.deletedAt == null).toList();

  _sortTasks(filtered, sort);
  return filtered;
});

final trashedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final sort = ref.watch(taskSortOrderProvider);

  var filtered = tasks.where((t) => t.deletedAt != null).toList();

  _sortTasks(filtered, sort);
  return filtered;
});

void _sortTasks(List<TaskModel> tasks, SortOrder sort) {
  switch (sort) {
    case SortOrder.createdNewest:
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOrder.createdOldest:
      tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOrder.modifiedNewest:
      tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case SortOrder.modifiedOldest:
      tasks.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      break;
    case SortOrder.custom:
      break;
  }
}

final taskListTasksProvider = Provider.family<List<TaskModel>, String>((
  ref,
  listId,
) {
  final tasks = ref.watch(activeTasksProvider);
  final query = ref.watch(taskSearchQueryProvider).toLowerCase();
  var filtered = tasks.where((t) => t.listId == listId).toList();
  if (query.isNotEmpty) {
    filtered =
        filtered
            .where(
              (t) =>
                  t.title.toLowerCase().contains(query) ||
                  t.description.toLowerCase().contains(query),
            )
            .toList();
  }
  return filtered;
});
