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
import '../../models/subtask_model.dart';

/// Lists the task's subtasks with completion checkboxes and delete buttons.
/// Only rendered when [subtasks] is non-empty.
class TaskSubtasksList extends StatelessWidget {
  const TaskSubtasksList({
    super.key,
    required this.subtasks,
    required this.onToggle,
    required this.onDelete,
  });

  final List<SubtaskModel> subtasks;
  final void Function(int index, bool completed) onToggle;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final completed = subtasks.where((s) => !s.isCompleted).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sottoattività ($completed/${subtasks.length})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: subtask.isCompleted,
                    onChanged: (v) => onToggle(index, v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      subtask.title,
                      style: TextStyle(
                        decoration:
                            subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            subtask.isCompleted
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(100)
                                : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => onDelete(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Text field + add button used to append a new subtask.
class TaskAddSubtaskField extends StatelessWidget {
  const TaskAddSubtaskField({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Aggiungi sottoattività...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
        ],
      ),
    );
  }
}
