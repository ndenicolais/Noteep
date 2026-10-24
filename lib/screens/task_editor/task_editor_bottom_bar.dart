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

/// Bottom action bar for [TaskEditorScreen]: due date, reminder, recurrence,
/// move-to-list and delete actions.
class TaskEditorBottomBar extends StatelessWidget {
  const TaskEditorBottomBar({
    super.key,
    required this.hasReminder,
    required this.onDatePicker,
    required this.onReminder,
    required this.onRecurrence,
    required this.onMoveToList,
    required this.onDelete,
  });

  final bool hasReminder;
  final VoidCallback onDatePicker;
  final VoidCallback onReminder;
  final VoidCallback onRecurrence;
  final VoidCallback onMoveToList;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: onDatePicker,
            tooltip: context.l10n.taskEditorDueDate,
          ),
          IconButton(
            icon: Icon(
              hasReminder ? Icons.alarm : Icons.alarm_add_outlined,
              color: hasReminder ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: onReminder,
            tooltip: context.l10n.taskEditorReminder,
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: onRecurrence,
            tooltip: context.l10n.taskEditorRecurrence,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add_check_outlined),
            onPressed: onMoveToList,
            tooltip: context.l10n.tasksMoveToList,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: context.l10n.tasksDeleteTask,
          ),
        ],
      ),
    );
  }
}
