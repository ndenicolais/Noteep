// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
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
/// with pinned tasks on top and then ordered by [sort]. Returns a new list;
/// [tasks] is left untouched.
///
/// The completed/active and pinned tie-breaks are explicit instead of
/// relying on the input order, since Dart's `List.sort` isn't guaranteed
/// stable.
({List<TaskModel> active, List<TaskModel> completed}) sortTasksForDisplay(
  List<TaskModel> tasks,
  SortOrder sort,
) {
  final sorted = List<TaskModel>.from(tasks)..sort((a, b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
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

/// [active] tasks (already in display order) split by due day: one group per
/// day in date order, then the tasks without a due date (`day == null`).
/// Within a day, pinned tasks stay on top, then timed tasks by time, then
/// the day-only ones, each keeping their order in [active].
List<({DateTime? day, List<TaskModel> tasks})> groupTasksByDay(
  List<TaskModel> active,
) {
  final byDay = <DateTime?, List<TaskModel>>{};
  for (final t in active) {
    final due = t.dueDate;
    final day = due == null ? null : DateTime(due.year, due.month, due.day);
    (byDay[day] ??= []).add(t);
  }
  final days =
      byDay.keys.whereType<DateTime>().toList()..sort((a, b) => a.compareTo(b));
  int rank(TaskModel t) => t.isPinned ? 0 : (t.hasDueTime ? 1 : 2);
  List<TaskModel> ordered(List<TaskModel> tasks) {
    final indexed =
        tasks.indexed.toList()..sort((a, b) {
          final (ia, ta) = a;
          final (ib, tb) = b;
          final r = rank(ta).compareTo(rank(tb));
          if (r != 0) return r;
          if (rank(ta) == 1) {
            final c = ta.dueDate!.compareTo(tb.dueDate!);
            if (c != 0) return c;
          }
          return ia.compareTo(ib);
        });
    return [for (final (_, t) in indexed) t];
  }

  return [
    for (final d in days) (day: d, tasks: ordered(byDay[d]!)),
    if (byDay[null] case final undated?) (day: null, tasks: undated),
  ];
}
