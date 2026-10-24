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
import '../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../models/calendar_model.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/calendar_provider.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_spacing.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/shared/app_dialogs.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/error_feedback.dart';
import '../widgets/shared/item_card.dart';
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
      titleWidget: Text(context.l10n.navTrash),
      appBarActions: [
        if (notes.isNotEmpty || tasks.isNotEmpty || events.isNotEmpty)
          TextButton(
            onPressed: () => _confirmEmptyTrash(context, ref),
            child: Text(context.l10n.trashEmptyAction),
          ),
      ],
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 10,
              ),
              child: Text(
                context.l10n.trashAutoDeleteInfo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: context.l10n.commonTabNotes),
                Tab(text: context.l10n.commonTabTasks),
                Tab(text: context.l10n.commonTabEvents),
              ],
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

  Future<void> _confirmEmptyTrash(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.trashEmptyTitle,
      message: context.l10n.trashEmptyConfirm,
      confirmLabel: context.l10n.trashEmptyAction,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    notifyOnError(ref.read(notesProvider.notifier).emptyTrash(), context);
    // Svuotiamo anche gli altri
    for (final t in ref.read(trashedTasksProvider)) {
      notifyOnError(
        ref.read(tasksProvider.notifier).permanentlyDelete(t.id),
        context,
      );
    }
    for (final e in ref.read(trashedEventsProvider)) {
      notifyOnError(
        ref.read(calendarProvider.notifier).permanentlyDelete(e.id),
        context,
      );
    }
  }
}

class _NoteTrashList extends StatelessWidget {
  const _NoteTrashList({required this.items});
  final List<NoteModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.note_alt_outlined,
        message: context.l10n.trashEmptyNotes,
        iconSize: 64,
      );
    }
    return ItemCardList(
      itemCount: items.length,
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
      return EmptyState(
        icon: Icons.check_circle_outline,
        message: context.l10n.trashEmptyTasks,
        iconSize: 64,
      );
    }
    return ItemCardList(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final task = items[i];
        return _TrashRow(
          title: task.title,
          onRestore:
              () => notifyOnError(
                ref.read(tasksProvider.notifier).restoreFromTrash(task.id),
                context,
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
      return EmptyState(
        icon: Icons.event_busy,
        message: context.l10n.trashEmptyEvents,
        iconSize: 64,
      );
    }
    return ItemCardList(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final event = items[i];
        return _TrashRow(
          title: event.title,
          onRestore:
              () => notifyOnError(
                ref.read(calendarProvider.notifier).restoreFromTrash(event.id),
                context,
              ),
        );
      },
    );
  }
}

/// A trashed task/event: title, auto-purge hint and a restore button.
class _TrashRow extends StatelessWidget {
  const _TrashRow({required this.title, required this.onRestore});
  final String title;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      title: Text(title),
      subtitle: Text(context.l10n.trashExpiresSoon),
      trailing: IconButton(
        icon: const Icon(Icons.restore),
        onPressed: onRestore,
        tooltip: context.l10n.commonRestore,
      ),
    );
  }
}

class _TrashNoteCard extends ConsumerWidget {
  const _TrashNoteCard({required this.note});
  final NoteModel note;

  String _daysLeft(AppLocalizations l) {
    if (note.deletedAt == null) return '';
    final expiry = note.deletedAt!.add(const Duration(days: 7));
    final remaining = expiry.difference(DateTime.now()).inDays;
    if (remaining <= 0) return l.trashExpiresToday;
    return l.trashExpiresInDays(remaining);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(note.id),
      background: DismissBackground(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        icon: Icons.restore,
        label: context.l10n.commonRestore,
      ),
      secondaryBackground: DismissBackground(
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete_forever,
        label: context.l10n.commonDelete,
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
      child: ItemCard(
        title: Text(
          note.title.isNotEmpty
              ? note.title
              : context.l10n.commonUntitledParens,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _daysLeft(context.l10n),
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: AppFontSizes.sm,
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
                    ref.read(notesProvider.notifier).permanentlyDelete(note.id),
                    context,
                  );
                }
              });
            }
          },
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: 'restore',
                  child: Text(context.l10n.commonRestore),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    context.l10n.trashDeleteForever,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Future<bool> _confirmPermanentDelete(BuildContext context) {
    return showAppConfirmDialog(
      context,
      title: context.l10n.trashDeleteForever,
      message: context.l10n.trashDeleteForeverConfirm,
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
  }
}
