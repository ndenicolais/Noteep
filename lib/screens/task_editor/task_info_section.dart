// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/recurrence.dart';

String recurrenceLabel(AppLocalizations l, RecurrenceType type) {
  switch (type) {
    case RecurrenceType.none:
      return l.recurrenceNone;
    case RecurrenceType.daily:
      return l.recurrenceDaily;
    case RecurrenceType.weekly:
      return l.recurrenceWeekly;
    case RecurrenceType.monthly:
      return l.recurrenceMonthly;
    case RecurrenceType.yearly:
      return l.recurrenceYearly;
  }
}

/// Shows the task's due date, recurrence and containing list, when set.
class TaskInfoSection extends StatelessWidget {
  const TaskInfoSection({
    super.key,
    required this.task,
    required this.onClearDueDate,
  });

  final TaskModel task;
  final VoidCallback onClearDueDate;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          if (task.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('d MMM yyyy').format(task.dueDate!),
                    style: TextStyle(color: primary, fontSize: AppFontSizes.sm),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GestureDetector(
                    onTap: onClearDueDate,
                    child: Icon(Icons.close, size: 16, color: primary),
                  ),
                ],
              ),
            ),
          if (task.recurrence != RecurrenceType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 16, color: primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    recurrenceLabel(context.l10n, task.recurrence),
                    style: TextStyle(color: primary, fontSize: AppFontSizes.sm),
                  ),
                ],
              ),
            ),
          if (task.listId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Consumer(
                builder: (context, ref, _) {
                  final lists = ref.watch(taskListsProvider);
                  final listName =
                      lists
                          .firstWhere(
                            (l) => l.id == task.listId,
                            orElse:
                                () => TaskListModel(
                                  id: '',
                                  name: context.l10n.tasksUnknownList,
                                ),
                          )
                          .name;
                  return Row(
                    children: [
                      Icon(Icons.playlist_add_check, size: 16, color: primary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        listName,
                        style: TextStyle(
                          color: primary,
                          fontSize: AppFontSizes.sm,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
