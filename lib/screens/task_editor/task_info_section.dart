// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/recurrence.dart';

String recurrenceLabel(RecurrenceType type) {
  switch (type) {
    case RecurrenceType.none:
      return 'Nessuna';
    case RecurrenceType.daily:
      return 'Giornaliero';
    case RecurrenceType.weekly:
      return 'Settimanale';
    case RecurrenceType.monthly:
      return 'Mensile';
    case RecurrenceType.yearly:
      return 'Annuale';
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (task.dueDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMM yyyy').format(task.dueDate!),
                    style: TextStyle(color: primary, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onClearDueDate,
                    child: Icon(Icons.close, size: 16, color: primary),
                  ),
                ],
              ),
            ),
          if (task.recurrence != RecurrenceType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 16, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    recurrenceLabel(task.recurrence),
                    style: TextStyle(color: primary, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (task.listId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Consumer(
                builder: (context, ref, _) {
                  final lists = ref.watch(taskListsProvider);
                  final listName =
                      lists
                          .firstWhere(
                            (l) => l.id == task.listId,
                            orElse:
                                () =>
                                    TaskListModel(id: '', name: 'Sconosciuto'),
                          )
                          .name;
                  return Row(
                    children: [
                      Icon(Icons.playlist_add_check, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        listName,
                        style: TextStyle(color: primary, fontSize: 12),
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
