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
import '../../models/task_model.dart';
import '../../providers/tasks_undo_redo_provider.dart';
import '../../theme/app_spacing.dart';

/// App bar for [TaskEditorScreen]: undo/redo, pin, archive and share menu.
class TaskEditorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TaskEditorAppBar({
    super.key,
    required this.task,
    required this.onUndo,
    required this.onRedo,
    required this.onTogglePin,
    required this.onArchive,
    required this.onShare,
  });

  final TaskModel task;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onTogglePin;
  final VoidCallback onArchive;
  final VoidCallback onShare;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(taskChangeHistoryProvider(task.id));

    return AppBar(
      title: Text(context.l10n.taskEditorTitle),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: history.canUndo ? onUndo : null,
          tooltip: context.l10n.taskEditorUndo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: history.canRedo ? onRedo : null,
          tooltip: context.l10n.taskEditorRedo,
        ),
        IconButton(
          icon: Icon(task.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: onTogglePin,
          tooltip:
              task.isPinned
                  ? context.l10n.taskEditorUnpin
                  : context.l10n.taskEditorPin,
        ),
        IconButton(
          icon: Icon(
            task.isArchived ? Icons.unarchive : Icons.archive_outlined,
          ),
          tooltip:
              task.isArchived
                  ? context.l10n.commonUnarchive
                  : context.l10n.commonArchive,
          onPressed: onArchive,
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'share') onShare();
          },
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Text(context.l10n.commonShare),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }
}
