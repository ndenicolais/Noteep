// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
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
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'shared/note_hero.dart';
import 'shared/error_feedback.dart';
import 'shared/tag_chip.dart';

class NoteCard extends ConsumerWidget {
  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onToggleChecklist,
    this.extraSemanticsActions = const {},
  });

  final NoteModel note;
  final VoidCallback? onTap;
  final Function(String)? onToggleChecklist;

  /// Screen-reader actions added by the container (e.g. "Sposta prima/dopo"
  /// in the Home grid, where reordering is otherwise drag-only).
  final Map<CustomSemanticsAction, VoidCallback> extraSemanticsActions;

  void _openNote(BuildContext context) => AppNav.openNote(context, note);

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
              const SizedBox(width: AppSpacing.md),
              Text(
                note.isPinned
                    ? context.l10n.commonUnpin
                    : context.l10n.commonPin,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(note.isArchived ? Icons.unarchive : Icons.archive_outlined),
              const SizedBox(width: AppSpacing.md),
              Text(
                note.isArchived
                    ? context.l10n.commonUnarchive
                    : context.l10n.commonArchive,
              ),
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
              const SizedBox(width: AppSpacing.md),
              Text(
                context.l10n.commonMoveToTrash,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );

    if (!context.mounted || action == null) return;
    await _runAction(context, ref, action);
  }

  /// Runs a quick action, from the long-press menu or from the matching
  /// screen-reader custom action.
  Future<void> _runAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
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
                  ? context.l10n.noteUnarchived
                  : context.l10n.noteArchived,
          onUndo: () => notifier.toggleArchive(note.id),
        );
        break;
      case 'delete':
        final notifier = ref.read(notesProvider.notifier);
        notifyWithUndo(
          notifier.softDelete(note.id),
          context,
          message: context.l10n.noteTrashed,
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

    // One screen-reader node per card: its text, tap to open, and the
    // long-press menu entries as custom actions (TalkBack "Azioni"), so
    // they don't depend on a long press at an arbitrary position.
    final l10n = context.l10n;
    return MergeSemantics(
      child: Semantics(
        onTapHint: l10n.noteOpenHint,
        customSemanticsActions: {
          CustomSemanticsAction(
                label: note.isPinned ? l10n.commonUnpin : l10n.commonPin,
              ):
              () => _runAction(context, ref, 'pin'),
          CustomSemanticsAction(
            label: note.isArchived ? l10n.commonUnarchive : l10n.commonArchive,
          ): () => _runAction(context, ref, 'archive'),
          CustomSemanticsAction(label: l10n.commonMoveToTrash):
              () => _runAction(context, ref, 'delete'),
          ...extraSemanticsActions,
        },
        child: GestureDetector(
          onTap: onTap ?? () => _openNote(context),
          onLongPressStart:
              (details) =>
                  _showQuickActions(context, ref, details.globalPosition),
          child: NoteHero(
            noteId: note.id,
            color: effectiveBg,
            isPage: false,
            child: Card(
              color: s.backgroundColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.isPinned || note.reminder != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (note.reminder != null)
                            Icon(
                              Icons.alarm,
                              size: 14,
                              color: s.fontColor?.withAlpha(153),
                              semanticLabel: l10n.noteReminderSetLabel,
                            ),
                          if (note.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.xs,
                              ),
                              child: Icon(
                                Icons.push_pin,
                                size: 14,
                                color: s.fontColor?.withAlpha(153),
                                semanticLabel: l10n.notePinnedLabel,
                              ),
                            ),
                        ],
                      ),
                    if (note.title.isNotEmpty) ...[
                      Text(
                        note.title,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
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
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 4,
                        children:
                            note.tags
                                .map((t) => TagChip(t, dense: true))
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
              const SizedBox(width: AppSpacing.xs),
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
            context.l10n.noteChecklistMore(note.checklistItems.length - 5),
            style: textStyle.copyWith(fontSize: AppFontSizes.xs),
          ),
      ],
    );
  }
}
