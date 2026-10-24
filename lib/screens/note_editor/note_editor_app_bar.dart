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
import '../../models/note_model.dart';
import '../../providers/notes_undo_redo_provider.dart';
import '../../theme/app_spacing.dart';

/// App bar for [NoteEditorScreen]: undo/redo, insert link, markdown toggle and the
/// pin/archive/share overflow menu.
class NoteEditorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const NoteEditorAppBar({
    super.key,
    required this.note,
    required this.effectiveBg,
    required this.uiFg,
    this.isSaving = false,
    required this.markdownMode,
    required this.onToggleMarkdown,
    required this.onInsertLink,
    required this.onUndo,
    required this.onRedo,
    required this.onPin,
    required this.onArchive,
    required this.onShare,
  });

  final NoteModel note;
  final Color effectiveBg;
  final Color uiFg;
  final bool isSaving;
  final bool markdownMode;
  final VoidCallback onToggleMarkdown;
  final VoidCallback onInsertLink;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onShare;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(noteChangeHistoryProvider(note.id));

    return AppBar(
      backgroundColor: effectiveBg,
      elevation: 0,
      foregroundColor: uiFg,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child:
            isSaving
                ? const LinearProgressIndicator(minHeight: 2)
                : const SizedBox(height: AppSpacing.xxs),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: history.canUndo ? onUndo : null,
          tooltip: context.l10n.editorUndo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: history.canRedo ? onRedo : null,
          tooltip: context.l10n.editorRedo,
        ),
        if (note.type == NoteType.note)
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: context.l10n.editorInsertLink,
            onPressed: onInsertLink,
          ),
        if (note.type == NoteType.note)
          IconButton(
            icon: Icon(
              markdownMode ? Icons.edit_outlined : Icons.preview_outlined,
            ),
            tooltip:
                markdownMode
                    ? context.l10n.editorEdit
                    : context.l10n.editorMarkdownPreview,
            onPressed: onToggleMarkdown,
          ),
        PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'pin':
                onPin();
              case 'archive':
                onArchive();
              case 'share':
                onShare();
            }
          },
          itemBuilder:
              (_) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(Icons.share_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Text(context.l10n.editorShare),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                      ),
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
                      Icon(
                        note.isArchived
                            ? Icons.unarchive
                            : Icons.archive_outlined,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        note.isArchived
                            ? context.l10n.commonUnarchive
                            : context.l10n.commonArchive,
                      ),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }
}
