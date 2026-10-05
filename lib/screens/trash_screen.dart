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
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../models/calendar_model.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/shared/error_feedback.dart';
import '../widgets/shared/swipe_actions.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(trashedNotesProvider);
    final tasks = ref.watch(trashedTasksProvider);
    final events = ref.watch(trashedEventsProvider);

    return NavScaffold(
      section: DrawerSection.trash,
      titleWidget: const Text('Cestino'),
      appBarActions: [
        if (notes.isNotEmpty || tasks.isNotEmpty || events.isNotEmpty)
          TextButton(
            onPressed: () => _confirmEmptyTrash(context, ref),
            child: const Text('Svuota'),
          ),
      ],
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Gli elementi vengono eliminati definitivamente dopo 7 giorni.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const TabBar(
              tabs: [Tab(text: 'Note'), Tab(text: 'Task'), Tab(text: 'Eventi')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _NoteTrashList(items: notes),
                  _TaskTrashList(items: tasks),
                  _EventTrashList(items: events),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Svuota cestino'),
            content: const Text(
              'Tutti gli elementi nel cestino verranno eliminati definitivamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  notifyOnError(
                    ref.read(notesProvider.notifier).emptyTrash(),
                    context,
                  );
                  // Svuotiamo anche gli altri
                  for (final t in ref.read(trashedTasksProvider)) {
                    notifyOnError(
                      ref.read(tasksProvider.notifier).permanentlyDelete(t.id),
                      context,
                    );
                  }
                  for (final e in ref.read(trashedEventsProvider)) {
                    notifyOnError(
                      ref
                          .read(calendarProvider.notifier)
                          .permanentlyDelete(e.id),
                      context,
                    );
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Svuota'),
              ),
            ],
          ),
    );
  }
}

class _NoteTrashList extends StatelessWidget {
  const _NoteTrashList({required this.items});
  final List<NoteModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessuna nota nel cestino',
              style: TextStyle(color: colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _TrashNoteCard(note: items[i]),
    );
  }
}

class _TaskTrashList extends ConsumerWidget {
  const _TaskTrashList({required this.items});
  final List<TaskModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun task nel cestino',
              style: TextStyle(color: colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final task = items[i];
        return ListTile(
          title: Text(task.title),
          subtitle: const Text('Scade tra poco (auto-purge)'),
          trailing: IconButton(
            icon: const Icon(Icons.restore),
            onPressed:
                () => notifyOnError(
                  ref.read(tasksProvider.notifier).restoreFromTrash(task.id),
                  context,
                ),
            tooltip: 'Ripristina',
          ),
        );
      },
    );
  }
}

class _EventTrashList extends ConsumerWidget {
  const _EventTrashList({required this.items});
  final List<CalendarEventModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Nessun evento nel cestino',
              style: TextStyle(color: colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final event = items[i];
        return ListTile(
          title: Text(event.title),
          subtitle: const Text('Scade tra poco (auto-purge)'),
          trailing: IconButton(
            icon: const Icon(Icons.restore),
            onPressed:
                () => notifyOnError(
                  ref
                      .read(calendarProvider.notifier)
                      .restoreFromTrash(event.id),
                  context,
                ),
            tooltip: 'Ripristina',
          ),
        );
      },
    );
  }
}

class _TrashNoteCard extends ConsumerWidget {
  const _TrashNoteCard({required this.note});
  final NoteModel note;

  String _daysLeft() {
    if (note.deletedAt == null) return '';
    final expiry = note.deletedAt!.add(const Duration(days: 7));
    final remaining = expiry.difference(DateTime.now()).inDays;
    if (remaining <= 0) return 'Scade oggi';
    return 'Scade tra $remaining giorn${remaining == 1 ? "o" : "i"}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(note.id),
      background: DismissBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        icon: Icons.restore,
        label: 'Ripristina',
      ),
      secondaryBackground: DismissBackground(
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete_forever,
        label: 'Elimina',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          notifyOnError(
            ref.read(notesProvider.notifier).restoreFromTrash(note.id),
            context,
          );
          return true;
        } else {
          return await _confirmPermanentDelete(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          notifyOnError(
            ref.read(notesProvider.notifier).permanentlyDelete(note.id),
            context,
          );
        }
      },
      child: Card(
        child: ListTile(
          title: Text(
            note.title.isNotEmpty ? note.title : '(senza titolo)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _daysLeft(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'restore') {
                notifyOnError(
                  ref.read(notesProvider.notifier).restoreFromTrash(note.id),
                  context,
                );
              } else if (v == 'delete') {
                _confirmPermanentDelete(context).then((confirmed) {
                  if (confirmed == true && context.mounted) {
                    notifyOnError(
                      ref
                          .read(notesProvider.notifier)
                          .permanentlyDelete(note.id),
                      context,
                    );
                  }
                });
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'restore', child: Text('Ripristina')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Elimina definitivamente',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmPermanentDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Elimina definitivamente'),
            content: const Text('La nota verrà eliminata in modo permanente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annulla'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Elimina'),
              ),
            ],
          ),
    );
  }
}
