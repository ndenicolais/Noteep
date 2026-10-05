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
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../utils/notification_service.dart';
import '../widgets/nav_scaffold.dart';
import 'note_editor/note_editor_screen.dart';
import 'task_editor/task_editor_screen.dart';

// ─── Sealed union for reminder items ─────────────────────────────────────────

sealed class _ReminderItem {
  DateTime get reminder;
  String get title;
}

class _NoteReminder implements _ReminderItem {
  const _NoteReminder(this.note);
  final NoteModel note;

  @override
  DateTime get reminder => note.reminder!;

  @override
  String get title => note.title.isEmpty ? 'Nota senza titolo' : note.title;
}

class _TaskReminder implements _ReminderItem {
  const _TaskReminder(this.task);
  final TaskModel task;

  @override
  DateTime get reminder => task.reminder!;

  @override
  String get title => task.title.isEmpty ? 'Task senza titolo' : task.title;
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
      titleWidget: const Text('Promemoria'),
      body:
          items.isEmpty
              ? _EmptyState()
              : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    const _SectionHeader(
                      icon: Icons.upcoming_outlined,
                      label: 'In arrivo',
                    ),
                    ...upcoming.map((item) => _ReminderCard(item: item)),
                  ],
                  if (past.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const _SectionHeader(icon: Icons.history, label: 'Scaduti'),
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
          const SizedBox(height: 16),
          Text(
            'Nessun promemoria',
            style: TextStyle(
              color: cs.outline,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi un promemoria aprendo\nuna nota o un task.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.outline, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: past ? cs.errorContainer : cs.primaryContainer,
          child: Icon(
            isNote ? Icons.note_alt_outlined : Icons.task_alt,
            color: past ? cs.onErrorContainer : cs.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
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
            const SizedBox(width: 4),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: past ? cs.error : cs.secondary,
                fontWeight: past ? FontWeight.w500 : null,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.alarm_off_outlined),
          tooltip: 'Rimuovi promemoria',
          onPressed: () => _removeReminder(context, ref),
        ),
        onTap: () => _openItem(context),
      ),
    );
  }

  void _openItem(BuildContext context) {
    if (item is _NoteReminder) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEditorScreen(note: (item as _NoteReminder).note),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskEditorScreen(task: (item as _TaskReminder).task),
        ),
      );
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
    ).showSnackBar(const SnackBar(content: Text('Promemoria rimosso')));
  }
}
