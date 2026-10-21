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
import '../../models/task_model.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/fade_switcher.dart';
import '../../widgets/shared/pull_to_refresh.dart';
import '../../widgets/shared/skeleton.dart';
import 'task_item.dart';
import 'task_sorting.dart';

/// One tab of the Tasks screen: the tasks from [source], with skeleton on
/// first load, empty/error state and pull-to-refresh.
class TaskListView extends ConsumerWidget {
  const TaskListView({super.key, required this.source});

  final ProviderListenable<List<TaskModel>> source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(source);
    final sort = ref.watch(taskSortOrderProvider);

    // Task-list failures surface through tasksLoadErrorProvider on the tasks
    // reload, which hits the same backend, so they are not reported twice.
    Future<void> refresh() => Future.wait([
      ref.read(tasksProvider.notifier).reload(),
      ref.read(taskListsProvider.notifier).reload().catchError((_) {}),
    ]);

    if (tasks.isEmpty) {
      final loadError = ref.watch(tasksLoadErrorProvider);
      final isLoading = ref.watch(tasksLoadingProvider);
      if (isLoading && loadError == null) {
        return const FadeSwitcher(
          child: ListSkeleton(key: ValueKey('loading')),
        );
      }
      return FadeSwitcher(
        child: PullToRefresh(
          key: ValueKey(loadError != null ? 'error' : 'empty'),
          onRefresh: refresh,
          // No "create" action: the add FAB is always visible.
          child: EmptyState(
            icon: loadError != null ? Icons.cloud_off : Icons.task_alt,
            message:
                loadError != null
                    ? 'Errore di sincronizzazione. Verifica la connessione e riprova.'
                    : 'Nessun task trovato',
            actionLabel: loadError != null ? 'Riprova' : null,
            actionIcon: Icons.refresh,
            onAction: refresh,
          ),
        ),
      );
    }

    final (:active, :completed) = sortTasksForDisplay(tasks, sort);
    return FadeSwitcher(
      child: PullToRefresh(
        key: const ValueKey('list'),
        onRefresh: refresh,
        childIsScrollable: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            for (final task in active)
              TaskItem(key: ValueKey(task.id), task: task),
            if (completed.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(),
              ),
              const Text(
                'Completati',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final task in completed)
                TaskItem(key: ValueKey(task.id), task: task),
            ],
          ],
        ),
      ),
    );
  }
}
