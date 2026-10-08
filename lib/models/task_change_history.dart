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
