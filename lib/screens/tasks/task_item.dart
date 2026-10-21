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
import '../../core/routing/app_router.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/dialogs/move_to_list_dialog.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/error_feedback.dart';
import '../../widgets/shared/swipe_actions.dart';

/// A task row: checkbox, title/description, star and overflow menu, with
/// swipe right to complete/reopen and swipe left to trash.
class TaskItem extends ConsumerWidget {
  const TaskItem({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tasksProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return SwipeActions(
      id: task.id,
      start: SwipeAction(
        icon: task.isCompleted ? Icons.undo : Icons.check,
        label: task.isCompleted ? 'Riapri' : 'Completa',
        color: Colors.green,
        // A completed task stays in the list (or is hidden by the
        // "show completed" setting), so the row snaps back.
        removesItem: false,
        onTriggered:
            () => notifyWithUndo(
              notifier.toggleComplete(task.id),
              context,
              message: task.isCompleted ? 'Task riaperto' : 'Task completato',
              onUndo: () => notifier.toggleComplete(task.id),
            ),
      ),
      end: SwipeAction(
        icon: Icons.delete_outline,
        label: 'Cestino',
        color: cs.error,
        onTriggered: () => _trash(context, ref),
      ),
      child: ListTile(
        onTap: () => AppNav.openTask(context, task),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged:
              (_) => notifyOnError(notifier.toggleComplete(task.id), context),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle:
            task.description.isNotEmpty
                ? Text(
                  task.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                )
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isSpecial ? Icons.star : Icons.star_border,
                color: task.isSpecial ? Colors.amber : null,
              ),
              onPressed: () => notifier.toggleSpecial(task.id),
              tooltip:
                  task.isSpecial
                      ? 'Rimuovi dagli speciali'
                      : 'Aggiungi agli speciali',
            ),
            _TaskMenu(
              onEdit: () => AppNav.openTask(context, task),
              onMove:
                  () => showMoveToListDialog(
                    context: context,
                    ref: ref,
                    currentListId: task.listId,
                    onListSelected:
                        (listId) => notifier.moveToList(task.id, listId),
                  ),
              onDelete: () => _confirmTrash(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _trash(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tasksProvider.notifier);
    notifyWithUndo(
      notifier.softDelete(task.id),
      context,
      message: 'Task spostato nel cestino',
      onUndo: () => notifier.restoreFromTrash(task.id),
    );
  }

  Future<void> _confirmTrash(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Elimina task',
      message: 'Vuoi spostare "${task.title}" nel cestino?',
      confirmLabel: 'Elimina',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    _trash(context, ref);
  }
}

class _TaskMenu extends StatelessWidget {
  const _TaskMenu({
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => action(),
      itemBuilder:
          (_) => [
            PopupMenuItem(value: onEdit, child: const Text('Modifica')),
            PopupMenuItem(value: onMove, child: const Text('Sposta in elenco')),
            PopupMenuItem(
              value: onDelete,
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: error),
                  const SizedBox(width: AppSpacing.md),
                  Text('Elimina', style: TextStyle(color: error)),
                ],
              ),
            ),
          ],
    );
  }
}
