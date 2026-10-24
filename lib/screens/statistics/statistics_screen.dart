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
import 'package:noteep/providers/settings/ui_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../theme/app_spacing.dart';
import 'statistics_widgets.dart';

/// Class d'appoggio immutabile per aggregare i dati ed evitare re-build inutili
@immutable
class StatsSummary {
  final int activeNotes;
  final int archivedNotes;
  final int trashedNotes;

  final int activeTasks;
  final int completedTasks;
  final int archivedTasks;
  final int trashedTasks;

  final int activeEvents;
  final int archivedEvents;
  final int trashedEvents;
  final int birthdays;
  final int nameDays;

  final int totalTags;

  const StatsSummary({
    required this.activeNotes,
    required this.archivedNotes,
    required this.trashedNotes,
    required this.activeTasks,
    required this.completedTasks,
    required this.archivedTasks,
    required this.trashedTasks,
    required this.activeEvents,
    required this.archivedEvents,
    required this.trashedEvents,
    required this.birthdays,
    required this.nameDays,
    required this.totalTags,
  });
}

/// Provider aggregato computato per calcolare le metriche in background
final statisticsSummaryProvider = Provider<StatsSummary>((ref) {
  final activeNotes = ref.watch(activeNotesProvider);
  final archivedNotes = ref.watch(archivedNotesProvider);
  final trashedNotes = ref.watch(trashedNotesProvider);

  final activeTasks = ref.watch(activeTasksProvider);
  final archivedTasks = ref.watch(archivedTasksProvider);
  final trashedTasks = ref.watch(trashedTasksProvider);

  final activeEvents = ref.watch(activeEventsProvider);
  final archivedEvents = ref.watch(archivedEventsProvider);
  final trashedEvents = ref.watch(trashedEventsProvider);

  final tags = ref.watch(allTagsProvider);

  return StatsSummary(
    activeNotes: activeNotes.length,
    archivedNotes: archivedNotes.length,
    trashedNotes: trashedNotes.length,
    activeTasks: activeTasks.where((t) => !t.isCompleted).length,
    completedTasks: activeTasks.where((t) => t.isCompleted).length,
    archivedTasks: archivedTasks.length,
    trashedTasks: trashedTasks.length,
    activeEvents: activeEvents.length,
    archivedEvents: archivedEvents.length,
    trashedEvents: trashedEvents.length,
    birthdays: activeEvents.where((e) => e.isBirthday).length,
    nameDays: activeEvents.where((e) => e.isNameDay).length,
    totalTags: tags.length,
  );
});

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statsTitle)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NotesSection(),
            SizedBox(height: AppSpacing.xl),
            _TasksSection(),
            SizedBox(height: AppSpacing.xl),
            _CalendarSection(),
            SizedBox(height: AppSpacing.xl),
            _TagsSection(),
            SizedBox(height: AppSpacing.xxl),
            _ChartsSection(),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Sezione Note ────────────────────────────────────────────────────────────

class _NotesSection extends ConsumerWidget {
  const _NotesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsSummaryProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsSectionHeader(title: context.l10n.navNotes, icon: Icons.notes),
        const SizedBox(height: AppSpacing.md),
        StatsGrid(
          items: [
            StatsDataItem(
              icon: Icons.notes,
              label: context.l10n.statsNotesActive,
              value: stats.activeNotes,
              color: theme.colorScheme.primary,
            ),
            StatsDataItem(
              icon: Icons.archive_outlined,
              label: context.l10n.statsNotesArchived,
              value: stats.archivedNotes,
              color: Colors.orange,
            ),
            StatsDataItem(
              icon: Icons.delete_outline,
              label: context.l10n.statsNotesTrashed,
              value: stats.trashedNotes,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sezione Task ────────────────────────────────────────────────────────────

class _TasksSection extends ConsumerWidget {
  const _TasksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsSummaryProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsSectionHeader(
          title: context.l10n.commonTabTasks,
          icon: Icons.task_alt,
        ),
        const SizedBox(height: AppSpacing.md),
        StatsGrid(
          items: [
            StatsDataItem(
              icon: Icons.task_alt,
              label: context.l10n.statsActive,
              value: stats.activeTasks,
              color: Colors.teal,
            ),
            StatsDataItem(
              icon: Icons.archive_outlined,
              label: context.l10n.statsArchived,
              value: stats.archivedTasks,
              color: Colors.orange,
            ),
            StatsDataItem(
              icon: Icons.delete_outline,
              label: context.l10n.statsTrashed,
              value: stats.trashedTasks,
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sezione Calendario ──────────────────────────────────────────────────────

class _CalendarSection extends ConsumerWidget {
  const _CalendarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsSummaryProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsSectionHeader(
          title: context.l10n.navCalendar,
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: AppSpacing.md),
        StatsGrid(
          items: [
            StatsDataItem(
              icon: Icons.calendar_today,
              label: context.l10n.statsActive,
              value: stats.activeEvents,
              color: theme.colorScheme.tertiary,
            ),
            StatsDataItem(
              icon: Icons.archive_outlined,
              label: context.l10n.statsArchived,
              value: stats.archivedEvents,
              color: Colors.orange,
            ),
            StatsDataItem(
              icon: Icons.delete_outline,
              label: context.l10n.statsTrashed,
              value: stats.trashedEvents,
              color: theme.colorScheme.error,
            ),
            StatsDataItem(
              icon: Icons.cake,
              label: context.l10n.statsBirthdays,
              value: stats.birthdays,
              color: Colors.pink,
            ),
            StatsDataItem(
              icon: Icons.auto_awesome,
              label: context.l10n.statsNameDays,
              value: stats.nameDays,
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sezione Etichette ───────────────────────────────────────────────────────

class _TagsSection extends ConsumerWidget {
  const _TagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTags = ref.watch(
      statisticsSummaryProvider.select((s) => s.totalTags),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsSectionHeader(
          title: context.l10n.navLabels,
          icon: Icons.label_outline,
        ),
        const SizedBox(height: AppSpacing.md),
        StatsGrid(
          items: [
            StatsDataItem(
              icon: Icons.label_outline,
              label: context.l10n.statsTotal,
              value: totalTags,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Sezione Grafici e Visualizzazioni ────────────────────────────────────────

class _ChartsSection extends ConsumerWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsSummaryProvider);
    final theme = Theme.of(context);

    final totalNotes =
        stats.activeNotes + stats.archivedNotes + stats.trashedNotes;
    final totalActiveTasks = stats.activeTasks + stats.completedTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grafico Note
        StatsSectionHeader(
          title: context.l10n.statsNotesDistribution,
          icon: Icons.pie_chart_outline,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child:
              totalNotes == 0
                  ? _EmptyChartPlaceholder(message: context.l10n.statsNoNotes)
                  : StatsPieChart(
                    sections: [
                      StatsPieSection(
                        context.l10n.statsNotesActive,
                        stats.activeNotes.toDouble(),
                        theme.colorScheme.primary,
                      ),
                      StatsPieSection(
                        context.l10n.statsNotesArchived,
                        stats.archivedNotes.toDouble(),
                        Colors.orange,
                      ),
                      StatsPieSection(
                        context.l10n.statsNotesTrashed,
                        stats.trashedNotes.toDouble(),
                        theme.colorScheme.error,
                      ),
                    ],
                  ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Grafico Task
        StatsSectionHeader(
          title: context.l10n.statsTasksDistribution,
          icon: Icons.pie_chart_outline,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child:
              (totalActiveTasks + stats.archivedTasks) == 0
                  ? _EmptyChartPlaceholder(message: context.l10n.statsNoTasks)
                  : StatsPieChart(
                    sections: [
                      StatsPieSection(
                        context.l10n.statsActive,
                        stats.activeTasks.toDouble(),
                        Colors.teal,
                      ),
                      StatsPieSection(
                        context.l10n.tasksCompletedSection,
                        stats.completedTasks.toDouble(),
                        Colors.green,
                      ),
                      StatsPieSection(
                        context.l10n.statsArchived,
                        stats.archivedTasks.toDouble(),
                        Colors.orange,
                      ),
                    ],
                  ),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Barra di Completamento
        StatsSectionHeader(
          title: context.l10n.statsTaskCompletion,
          icon: Icons.bar_chart_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: TaskCompletionBar(
            total: totalActiveTasks,
            completed: stats.completedTasks,
          ),
        ),
      ],
    );
  }
}

// ─── Placeholder per Grafici Vuoti ───────────────────────────────────────────

class _EmptyChartPlaceholder extends StatelessWidget {
  final String message;

  const _EmptyChartPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
