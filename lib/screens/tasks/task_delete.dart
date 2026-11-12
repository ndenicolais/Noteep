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
import '../../l10n/l10n.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/notification_service.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/error_feedback.dart';

/// What deleting a task removes: for a recurring task, only the current
/// occurrence or the task with all its following occurrences.
enum TaskDeleteScope { thisOccurrence, all }

/// Asks how to delete [task]. A recurring task offers "only this task" or
/// "this and all following"; any other task gets the plain confirm with
/// [message]. Resolves to `null` when the user cancels.
Future<TaskDeleteScope?> askTaskDeleteScope(
  BuildContext context,
  TaskModel task, {
  required String message,
}) async {
  if (task.isRecurring) {
    return showDialog<TaskDeleteScope>(
      context: context,
      builder: (_) => const _RecurringTaskDeleteDialog(),
    );
  }
  final confirmed = await showAppConfirmDialog(
    context,
    title: context.l10n.tasksDeleteTask,
    message: message,
    confirmLabel: context.l10n.commonDelete,
    destructive: true,
  );
  return confirmed ? TaskDeleteScope.all : null;
}

/// Applies [scope] to [task] with an undo snackbar: moves it to the trash, or
/// skips just its current occurrence (rescheduling its reminder).
void deleteTaskWithUndo(
  BuildContext context,
  WidgetRef ref,
  TaskModel task,
  TaskDeleteScope scope,
) {
  final notifier = ref.read(tasksProvider.notifier);
  final l10n = context.l10n;
  switch (scope) {
    case TaskDeleteScope.all:
      notifyWithUndo(
        notifier.softDelete(task.id),
        context,
        message: l10n.tasksTrashed,
        onUndo: () => notifier.restoreFromTrash(task.id),
      );
    case TaskDeleteScope.thisOccurrence:
      notifyWithUndo(
        notifier.skipOccurrence(task).then(_rescheduleReminder),
        context,
        message: l10n.tasksOccurrenceDeleted,
        onUndo: () async {
          await notifier.updateTask(task);
          await _rescheduleReminder(task);
        },
      );
  }
}

Future<void> _rescheduleReminder(TaskModel task) async {
  final notifications = NotificationService.instance;
  await notifications.cancelNotification(
    NotificationService.idForTask(task.id),
  );
  await notifications.scheduleTaskReminder(task, askPermission: false);
}

class _RecurringTaskDeleteDialog extends StatefulWidget {
  const _RecurringTaskDeleteDialog();

  @override
  State<_RecurringTaskDeleteDialog> createState() =>
      _RecurringTaskDeleteDialogState();
}

class _RecurringTaskDeleteDialogState
    extends State<_RecurringTaskDeleteDialog> {
  TaskDeleteScope _scope = TaskDeleteScope.thisOccurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.tasksDeleteRecurringTitle),
      contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
      content: RadioGroup<TaskDeleteScope>(
        groupValue: _scope,
        onChanged: (v) {
          if (v != null) setState(() => _scope = v);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<TaskDeleteScope>(
              title: Text(l10n.tasksDeleteThisOccurrence),
              value: TaskDeleteScope.thisOccurrence,
            ),
            RadioListTile<TaskDeleteScope>(
              title: Text(l10n.tasksDeleteAllOccurrences),
              value: TaskDeleteScope.all,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          onPressed: () => Navigator.pop(context, _scope),
          child: Text(l10n.commonDelete),
        ),
      ],
    );
  }
}
