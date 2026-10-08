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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_radius.dart';
import '../utils/note_lock_service.dart';
import 'shared/error_feedback.dart';

class NoteCard extends ConsumerWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onToggleChecklist,
  });

  final NoteModel note;
  final VoidCallback? onTap;
  final Function(String)? onToggleChecklist;

  Future<void> _openNote(BuildContext context) async {
    if (note.isLocked) {
      final ok = await NoteLockService.instance.authenticate();
      if (!ok) return;
    }
    if (!context.mounted) return;
    AppNav.openNote(context, note);
  }

  Future<void> _showQuickActions(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              const SizedBox(width: 12),
              Text(note.isPinned ? 'Rimuovi pin' : 'Fissa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(note.isArchived ? Icons.unarchive : Icons.archive_outlined),
              const SizedBox(width: 12),
              Text(note.isArchived ? 'Ripristina' : 'Archivia'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'lock',
          child: Row(
            children: [
              Icon(note.isLocked ? Icons.lock_open_outlined : Icons.lock),
              const SizedBox(width: 12),
              Text(note.isLocked ? 'Sblocca' : 'Blocca'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Sposta nel cestino',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );

    if (!context.mounted) return;
    switch (action) {
      case 'pin':
        notifyOnError(
          ref.read(notesProvider.notifier).togglePin(note.id),
          context,
        );
        break;
      case 'archive':
        final notifier = ref.read(notesProvider.notifier);
        notifyWithUndo(
          notifier.toggleArchive(note.id),
          context,
          message:
              note.isArchived
                  ? 'Nota rimossa dall\'archivio'
                  : 'Nota archiviata',
          onUndo: () => notifier.toggleArchive(note.id),
        );
        break;
      case 'lock':
        if (note.isLocked) {
          final ok = await NoteLockService.instance.authenticate();
          if (!ok) return;
        }
        if (!context.mounted) return;
        notifyOnError(
          ref
              .read(notesProvider.notifier)
              .updateNote(note.copyWith(isLocked: !note.isLocked)),
          context,
        );
        break;
      case 'delete':
        final notifier = ref.read(notesProvider.notifier);
        notifyWithUndo(
          notifier.softDelete(note.id),
          context,
          message: 'Nota spostata nel cestino',
          onUndo: () => notifier.restoreFromTrash(note.id),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = note.style;
    final effectiveBg = s.backgroundColor ?? Theme.of(context).cardColor;
    // Fall back to a color that contrasts with the card background instead of
    // the Flutter default (near-black), which can be unreadable against a
    // dark custom background.
    final autoFg = AppColors.contrastingTextColor(effectiveBg);
    final textStyle = TextStyle(
      fontFamily: s.fontFamily,
      fontSize: s.fontSize,
      color: s.fontColor ?? autoFg,
      fontWeight: s.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: s.isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: s.isStrikethrough ? TextDecoration.lineThrough : null,
      decorationColor: s.fontColor ?? autoFg,
    );
    final titleStyle = TextStyle(
      fontFamily: s.titleFontFamily ?? s.fontFamily,
      fontSize: s.titleFontSize ?? (s.fontSize + 4),
      color: s.titleFontColor ?? s.fontColor ?? autoFg,
      fontWeight: (s.titleIsBold ?? true) ? FontWeight.bold : FontWeight.normal,
      fontStyle:
          (s.titleIsItalic ?? false) ? FontStyle.italic : FontStyle.normal,
    );

    return GestureDetector(
      onTap: onTap ?? () => _openNote(context),
      onLongPressStart:
          (details) => _showQuickActions(context, ref, details.globalPosition),
      child: Card(
        color: s.backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.isPinned || note.isLocked || note.reminder != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (note.reminder != null)
                      Icon(
                        Icons.alarm,
                        size: 14,
                        color: s.fontColor?.withAlpha(153),
                        semanticLabel: 'Promemoria impostato',
                      ),
                    if (note.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: s.fontColor?.withAlpha(153),
                          semanticLabel: 'Nota protetta',
                        ),
                      ),
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.push_pin,
                          size: 14,
                          color: s.fontColor?.withAlpha(153),
                          semanticLabel: 'Nota fissata',
                        ),
                      ),
                  ],
                ),
              if (note.isLocked) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 16, color: textStyle.color),
                    const SizedBox(width: 6),
                    Text(
                      'Nota protetta',
                      style: textStyle.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ] else ...[
                if (note.title.isNotEmpty) ...[
                  Text(
                    note.title,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                if (note.type == NoteType.checklist)
                  _ChecklistPreview(note: note, textStyle: textStyle)
                else
                  Text(
                    note.content,
                    style: textStyle,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children:
                      note.tags
                          .map(
                            (t) => Chip(
                              label: Text(
                                t,
                                style: TextStyle(
                                  fontSize: AppFontSizes.xs,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistPreview extends StatelessWidget {
  const _ChecklistPreview({required this.note, required this.textStyle});
  final NoteModel note;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final items = note.checklistItems.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map(
          (item) => Row(
            children: [
              Icon(
                item.isChecked
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 16,
                color: textStyle.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.text,
                  style: textStyle.copyWith(
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                    color:
                        item.isChecked
                            ? textStyle.color?.withAlpha(128)
                            : textStyle.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (note.checklistItems.length > 5)
          Text(
            '+${note.checklistItems.length - 5} altri',
            style: textStyle.copyWith(fontSize: AppFontSizes.xs),
          ),
      ],
    );
  }
}
