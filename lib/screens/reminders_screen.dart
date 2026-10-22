// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_spacing.dart';
import '../utils/notification_service.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/shared/item_card.dart';
import '../widgets/shared/section_header.dart';

// ─── Sealed union for reminder items ─────────────────────────────────────────

sealed class _ReminderItem {
  DateTime get reminder;
  String title(AppLocalizations l);
}

class _NoteReminder implements _ReminderItem {
  const _NoteReminder(this.note);
  final NoteModel note;

  @override
  DateTime get reminder => note.reminder!;

  @override
  String title(AppLocalizations l) =>
      note.title.isEmpty ? l.remindersUntitledNote : note.title;
}

class _TaskReminder implements _ReminderItem {
  const _TaskReminder(this.task);
  final TaskModel task;

  @override
  DateTime get reminder => task.reminder!;

  @override
  String title(AppLocalizations l) =>
      task.title.isEmpty ? l.remindersUntitledTask : task.title;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes =
        ref
            .watch(activeNotesProvider)
            .where((n) => n.reminder != null)
            .toList();
    final tasks =
        ref
            .watch(activeTasksProvider)
            .where((t) => t.reminder != null)
            .toList();

    final List<_ReminderItem> items = [
      ...notes.map(_NoteReminder.new),
      ...tasks.map(_TaskReminder.new),
    ]..sort((a, b) => a.reminder.compareTo(b.reminder));

    final now = DateTime.now();
    final upcoming = items.where((i) => i.reminder.isAfter(now)).toList();
    final past = items.where((i) => !i.reminder.isAfter(now)).toList();

    return NavScaffold(
      section: DrawerSection.reminders,
      titleWidget: Text(context.l10n.navReminders),
      body:
          items.isEmpty
              ? _EmptyState()
              : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    SectionHeader(
                      context.l10n.remindersUpcoming,
                      icon: Icons.upcoming_outlined,
                      padding: SectionHeader.inlinePadding,
                    ),
                    ...upcoming.map((item) => _ReminderCard(item: item)),
                  ],
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SectionHeader(
                      context.l10n.remindersPast,
                      icon: Icons.history,
                      padding: SectionHeader.inlinePadding,
                    ),
                    ...past.map(
                      (item) => _ReminderCard(item: item, past: true),
                    ),
                  ],
                ],
              ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_outlined, size: 72, color: cs.outlineVariant),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.remindersEmpty,
            style: TextStyle(
              color: cs.outline,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.remindersEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.outline, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Reminder card ────────────────────────────────────────────────────────────

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.item, this.past = false});
  final _ReminderItem item;
  final bool past;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.reminder);
    final isNote = item is _NoteReminder;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ItemCard(
        leading: CircleAvatar(
          backgroundColor: past ? cs.errorContainer : cs.primaryContainer,
          child: Icon(
            isNote ? Icons.note_alt_outlined : Icons.task_alt,
            color: past ? cs.onErrorContainer : cs.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item.title(context.l10n),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: past ? TextDecoration.lineThrough : null,
            color: past ? cs.outline : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Icon(
              past ? Icons.alarm_off_outlined : Icons.alarm_outlined,
              size: 14,
              color: past ? cs.error : cs.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: AppFontSizes.sm,
                color: past ? cs.error : cs.secondary,
                fontWeight: past ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.alarm_off_outlined),
          tooltip: context.l10n.commonRemoveReminder,
          onPressed: () => _removeReminder(context, ref),
        ),
        onTap: () => _openItem(context),
      ),
    );
  }

  void _openItem(BuildContext context) {
    if (item is _NoteReminder) {
      AppNav.openNote(context, (item as _NoteReminder).note);
    } else {
      AppNav.openTask(context, (item as _TaskReminder).task);
    }
  }

  void _removeReminder(BuildContext context, WidgetRef ref) {
    if (item is _NoteReminder) {
      final note = (item as _NoteReminder).note;
      ref
          .read(notesProvider.notifier)
          .updateNote(note.copyWith(clearReminder: true));
      NotificationService.instance.cancelNotification(
        NotificationService.idForNote(note.id),
      );
    } else {
      final task = (item as _TaskReminder).task;
      ref
          .read(tasksProvider.notifier)
          .updateTask(task.copyWith(clearReminder: true));
      NotificationService.instance.cancelNotification(
        NotificationService.idForTask(task.id),
      );
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.commonReminderRemoved)));
  }
}
