// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../models/task_model.dart';
import '../../providers/settings/ui_provider.dart';

/// Tasks as shown in a list tab: active first, then completed, each group
/// ordered by [sort]. Returns a new list; [tasks] is left untouched.
///
/// The completed/active tie-break is explicit instead of relying on the
/// input order, since Dart's `List.sort` isn't guaranteed stable.
({List<TaskModel> active, List<TaskModel> completed}) sortTasksForDisplay(
  List<TaskModel> tasks,
  SortOrder sort,
) {
  final sorted = List<TaskModel>.from(tasks)..sort((a, b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return switch (sort) {
      SortOrder.createdNewest => b.createdAt.compareTo(a.createdAt),
      SortOrder.createdOldest => a.createdAt.compareTo(b.createdAt),
      SortOrder.modifiedNewest => b.updatedAt.compareTo(a.updatedAt),
      SortOrder.modifiedOldest => a.updatedAt.compareTo(b.updatedAt),
      SortOrder.custom => 0,
    };
  });
  return (
    active: sorted.where((t) => !t.isCompleted).toList(),
    completed: sorted.where((t) => t.isCompleted).toList(),
  );
}
