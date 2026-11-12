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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/routing/app_router.dart';
import '../../l10n/l10n.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/detail_row.dart';
import '../../widgets/shared/error_feedback.dart';
import '../tasks/task_delete.dart';
import 'task_info_section.dart';

/// Read-only view of a saved task, opened by tapping it (like Google
/// Calendar / Tasks): the pencil opens [TaskEditorScreen]. Follows the task
/// in [tasksProvider], so edits show up on return and the screen closes once
/// the task is trashed. Completion and subtasks can still be checked here.
class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});
  final TaskModel task;

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  bool _closing = false;

  TaskModel _current(List<TaskModel> tasks) {
    for (final t in tasks) {
      if (t.id == widget.task.id) return t;
    }
    return widget.task;
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.maybePop(context);
    });
  }

  Future<void> _delete(TaskModel task) async {
    final scope = await askTaskDeleteScope(
      context,
      task,
      message: context.l10n.tasksDeleteTaskConfirm,
    );
    if (scope == null || !mounted) return;
    deleteTaskWithUndo(context, ref, task, scope);
    _close();
  }

  void _toggleSubtask(TaskModel task, int index) {
    final subtasks = [...task.subtasks];
    final s = subtasks[index];
    subtasks[index] = s.copyWith(
      isCompleted: !s.isCompleted,
      updatedAt: DateTime.now(),
    );
    notifyOnError(
      ref
          .read(tasksProvider.notifier)
          .updateTask(
            task.copyWith(subtasks: subtasks, updatedAt: DateTime.now()),
          ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _current(ref.watch(tasksProvider));
    if (task.deletedAt != null) _close();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = cs.onSurfaceVariant;
    final completedSubtasks = task.subtasks.where((s) => s.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskEditorTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.commonEdit,
            onPressed: () => AppNav.openTask(context, task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.tasksDeleteTask,
            onPressed: () => _delete(task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title.isEmpty ? l10n.commonUntitled : task.title,
                  style: TextStyle(
                    fontSize: AppFontSizes.headline,
                    fontWeight: FontWeight.bold,
                    color: task.title.isEmpty ? muted : null,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (task.isSpecial)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm, top: 4),
                  child: Icon(Icons.star, color: Colors.amber),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (task.isCompleted)
            DetailRow(
              icon: Icons.check_circle,
              iconColor: Colors.green.shade600,
              child: Text(l10n.tasksCompleted),
            ),
          if (task.dueDate != null)
            DetailRow(
              // The alarm marks a due time, which notifies.
              icon:
                  task.hasDueTime ? Icons.alarm : Icons.calendar_today_outlined,
              child: Text(
                DateFormat(
                  task.hasDueTime
                      ? 'EEEE d MMMM yyyy, HH:mm'
                      : 'EEEE d MMMM yyyy',
                ).format(task.dueDate!),
              ),
            ),
          if (task.recurrence != RecurrenceType.none)
            DetailRow(
              icon: Icons.repeat,
              child: Text(recurrenceLabel(l10n, task.recurrence)),
            ),
          if (task.listId != null)
            DetailRow(
              icon: Icons.playlist_add_check,
              child: Text(_listName(ref, task.listId!, l10n.tasksUnknownList)),
            ),
          if (task.description.isNotEmpty)
            DetailRow(
              icon: Icons.notes,
              child: SelectableText(task.description),
            ),
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.taskEditorSubtasks(completedSubtasks, task.subtasks.length),
              style: theme.textTheme.titleSmall,
            ),
            for (var i = 0; i < task.subtasks.length; i++)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: task.subtasks[i].isCompleted,
                onChanged: (_) => _toggleSubtask(task, i),
                title: Text(
                  task.subtasks[i].title,
                  style: TextStyle(
                    decoration:
                        task.subtasks[i].isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.commonLastModified(
              DateFormat('dd MMM, HH:mm').format(task.updatedAt),
            ),
            style: TextStyle(fontSize: AppFontSizes.sm, color: muted),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.tonalIcon(
            icon: Icon(task.isCompleted ? Icons.replay : Icons.check),
            label: Text(
              task.isCompleted ? l10n.tasksReopen : l10n.tasksComplete,
            ),
            onPressed:
                () => notifyOnError(
                  ref.read(tasksProvider.notifier).toggleComplete(task.id),
                  context,
                ),
          ),
        ),
      ),
    );
  }

  String _listName(WidgetRef ref, String listId, String fallback) {
    for (final TaskListModel l in ref.watch(taskListsProvider)) {
      if (l.id == listId) return l.name;
    }
    return fallback;
  }
}
