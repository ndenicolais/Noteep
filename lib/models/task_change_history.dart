// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../utils/recurrence.dart';

abstract class TaskChange {
  TaskModel apply(TaskModel task);
  TaskModel undo(TaskModel task);
}

class TaskTitleChange implements TaskChange {
  final String oldTitle;
  final String newTitle;

  TaskTitleChange({required this.oldTitle, required this.newTitle});

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(title: newTitle);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(title: oldTitle);
  }
}

class TaskDescriptionChange implements TaskChange {
  final String oldDescription;
  final String newDescription;

  TaskDescriptionChange({
    required this.oldDescription,
    required this.newDescription,
  });

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(description: newDescription);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(description: oldDescription);
  }
}

class TaskCompletedChange implements TaskChange {
  final bool oldCompleted;
  final bool newCompleted;

  TaskCompletedChange({required this.oldCompleted, required this.newCompleted});

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(isCompleted: newCompleted);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(isCompleted: oldCompleted);
  }
}

class TaskDueDateChange implements TaskChange {
  final DateTime? oldDueDate;
  final DateTime? newDueDate;

  TaskDueDateChange({required this.oldDueDate, required this.newDueDate});

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(dueDate: newDueDate);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(dueDate: oldDueDate);
  }
}

class TaskPinnedChange implements TaskChange {
  final bool oldPinned;
  final bool newPinned;

  TaskPinnedChange({required this.oldPinned, required this.newPinned});

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(isPinned: newPinned);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(isPinned: oldPinned);
  }
}

class TaskRecurrenceChange implements TaskChange {
  final RecurrenceType oldRecurrence;
  final RecurrenceType newRecurrence;

  TaskRecurrenceChange({
    required this.oldRecurrence,
    required this.newRecurrence,
  });

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(recurrence: newRecurrence);
  }

  @override
  TaskModel undo(TaskModel task) {
    return task.copyWith(recurrence: oldRecurrence);
  }
}

class SubtaskAddChange implements TaskChange {
  final SubtaskModel subtask;

  SubtaskAddChange({required this.subtask});

  @override
  TaskModel apply(TaskModel task) {
    return task.copyWith(subtasks: [...task.subtasks, subtask]);
  }

  @override
  TaskModel undo(TaskModel task) {
    final subtasks = task.subtasks.where((s) => s.id != subtask.id).toList();
    return task.copyWith(subtasks: subtasks);
  }
}

class SubtaskDeleteChange implements TaskChange {
  final SubtaskModel subtask;
  final int index;

  SubtaskDeleteChange({required this.subtask, required this.index});

  @override
  TaskModel apply(TaskModel task) {
    final subtasks = task.subtasks.where((s) => s.id != subtask.id).toList();
    return task.copyWith(subtasks: subtasks);
  }

  @override
  TaskModel undo(TaskModel task) {
    final subtasks = [...task.subtasks];
    subtasks.insert(index, subtask);
    return task.copyWith(subtasks: subtasks);
  }
}

class SubtaskToggleChange implements TaskChange {
  final String subtaskId;
  final bool oldCompleted;
  final bool newCompleted;

  SubtaskToggleChange({
    required this.subtaskId,
    required this.oldCompleted,
    required this.newCompleted,
  });

  @override
  TaskModel apply(TaskModel task) {
    final subtasks =
        task.subtasks.map((s) {
          return s.id == subtaskId ? s.copyWith(isCompleted: newCompleted) : s;
        }).toList();
    return task.copyWith(subtasks: subtasks);
  }

  @override
  TaskModel undo(TaskModel task) {
    final subtasks =
        task.subtasks.map((s) {
          return s.id == subtaskId ? s.copyWith(isCompleted: oldCompleted) : s;
        }).toList();
    return task.copyWith(subtasks: subtasks);
  }
}
