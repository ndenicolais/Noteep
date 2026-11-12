// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_model.dart';
import '../../providers/core_providers.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/shared/fade_switcher.dart';
import '../../widgets/shared/pull_to_refresh.dart';
import '../../widgets/shared/skeleton.dart';
import 'task_item.dart';
import 'task_sorting.dart';
import '../../widgets/shared/section_header.dart';

/// One tab of the Tasks screen: the tasks from [source], with skeleton on
/// first load, empty/error state and pull-to-refresh.
class TaskListView extends ConsumerWidget {
  const TaskListView({super.key, required this.source});

  final ProviderListenable<List<TaskModel>> source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(taskSortOrderProvider);
    // Only the ids of each section: editing a task without moving it (e.g.
    // its title) rebuilds that row alone, not the whole list.
    final (:active, :completed) = ref.watch(
      source.select((tasks) {
        final sorted = sortTasksForDisplay(tasks, sort);
        return (
          active: _DayGroups([
            for (final g in groupTasksByDay(sorted.active))
              (day: g.day, ids: IdList(g.tasks.map((t) => t.id))),
          ]),
          completed: IdList(sorted.completed.map((t) => t.id)),
        );
      }),
    );

    // Task-list failures surface through tasksLoadErrorProvider on the tasks
    // reload, which hits the same backend, so they are not reported twice.
    Future<void> refresh() => Future.wait([
      ref.read(tasksProvider.notifier).reload(),
      ref.read(taskListsProvider.notifier).reload().catchError((_) {}),
    ]);

    if (active.isEmpty && completed.isEmpty) {
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
                    ? context.l10n.commonSyncError
                    : context.l10n.tasksEmpty,
            actionLabel: loadError != null ? context.l10n.commonRetry : null,
            actionIcon: Icons.refresh,
            onAction: refresh,
          ),
        ),
      );
    }

    return FadeSwitcher(
      child: PullToRefresh(
        key: const ValueKey('list'),
        onRefresh: refresh,
        childIsScrollable: true,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            for (final (i, g) in active.groups.indexed) ...[
              SectionHeader(
                _dayLabel(context, g.day),
                key: ValueKey('day-${g.day}'),
                padding:
                    i == 0
                        ? SectionHeader.inlinePadding
                        : const EdgeInsets.only(
                          top: AppSpacing.lg,
                          bottom: AppSpacing.sm,
                        ),
                muted: g.day == null,
              ),
              for (final id in g.ids.ids) _TaskRow(key: ValueKey(id), id: id),
            ],
            if (completed.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(),
              ),
              SectionHeader(
                context.l10n.tasksCompletedSection,
                padding: SectionHeader.inlinePadding,
              ),
              for (final id in completed.ids)
                _TaskRow(key: ValueKey(id), id: id),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header of a day group: Today/Tomorrow/Yesterday, otherwise the full
/// date (with the year only when it is not the current one).
String _dayLabel(BuildContext context, DateTime? day) {
  final l10n = context.l10n;
  if (day == null) return l10n.tasksNoDateSection;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = DateTime(day.year, day.month, day.day).difference(today).inDays;
  if (diff == 0) return l10n.commonToday;
  if (diff == 1) return l10n.commonTomorrow;
  if (diff == -1) return l10n.commonYesterday;
  final label = DateFormat(
    day.year == today.year ? 'EEEE d MMMM' : 'EEEE d MMMM y',
  ).format(day);
  return label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);
}

/// The active tasks' ids per due day, compared by value so the list
/// rebuilds only when a task changes group or position.
class _DayGroups {
  _DayGroups(this.groups);

  final List<({DateTime? day, IdList ids})> groups;

  bool get isEmpty => groups.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is _DayGroups && listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hashAll(groups);
}

/// A [TaskItem] that watches its own task, so it rebuilds only when that
/// task changes.
class _TaskRow extends ConsumerWidget {
  const _TaskRow({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdProvider(id));
    if (task == null) return const SizedBox.shrink();
    return TaskItem(task: task);
  }
}
