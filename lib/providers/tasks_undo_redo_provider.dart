// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteep/models/task_model.dart';
import '../models/task_change_history.dart';
import 'tasks_provider.dart';

class TaskHistoryState {
  final bool canUndo;
  final bool canRedo;
  const TaskHistoryState({required this.canUndo, required this.canRedo});
  static const empty = TaskHistoryState(canUndo: false, canRedo: false);
}

/// Provider to manage undo/redo history for a specific task.
/// `autoDispose` releases each task's history once no editor screen is
/// watching it anymore — without it, every task ever opened during a
/// session keeps its (up to 50-entry) undo/redo stack alive forever.
final taskChangeHistoryProvider = StateNotifierProvider.autoDispose
    .family<TaskChangeHistoryNotifier, TaskHistoryState, String>(
      (ref, taskId) => TaskChangeHistoryNotifier(),
    );

class TaskChangeHistoryNotifier extends StateNotifier<TaskHistoryState> {
  TaskChangeHistoryNotifier() : super(TaskHistoryState.empty);

  final List<TaskChange> _undoStack = [];
  final List<TaskChange> _redoStack = [];
  static const int _maxSize = 50;

  void addChange(TaskChange change) {
    _undoStack.add(change);
    _redoStack.clear();
    if (_undoStack.length > _maxSize) _undoStack.removeAt(0);
    _notify();
  }

  TaskChange? undo() {
    if (_undoStack.isEmpty) return null;
    final change = _undoStack.removeLast();
    _redoStack.add(change);
    _notify();
    return change;
  }

  TaskChange? redo() {
    if (_redoStack.isEmpty) return null;
    final change = _redoStack.removeLast();
    _undoStack.add(change);
    _notify();
    return change;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    _notify();
  }

  void _notify() {
    state = TaskHistoryState(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }
}

/// Provider to handle undo/redo operations for tasks
class TaskUndoRedoManager {
  static TaskModel? performUndo(
    WidgetRef ref,
    String taskId,
    TaskModel currentTask,
  ) {
    final notifier = ref.read(taskChangeHistoryProvider(taskId).notifier);
    final change = notifier.undo();
    if (change == null) return null;
    final undoneTask = change.undo(currentTask);
    final tasks = ref.read(tasksProvider);
    if (tasks.any((t) => t.id == taskId)) {
      ref.read(tasksProvider.notifier).updateTask(undoneTask);
    }
    return undoneTask;
  }

  static TaskModel? performRedo(
    WidgetRef ref,
    String taskId,
    TaskModel currentTask,
  ) {
    final notifier = ref.read(taskChangeHistoryProvider(taskId).notifier);
    final change = notifier.redo();
    if (change == null) return null;
    final redoneTask = change.apply(currentTask);
    final tasks = ref.read(tasksProvider);
    if (tasks.any((t) => t.id == taskId)) {
      ref.read(tasksProvider.notifier).updateTask(redoneTask);
    }
    return redoneTask;
  }
}
