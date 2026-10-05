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
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/shared/error_feedback.dart';
import '../../widgets/shared/swipe_actions.dart';

/// Home list-layout swipes: right to archive, left to trash, both undoable.
/// Not used in the grid layout, where horizontal drags reorder notes.
class NoteSwipeActions extends ConsumerWidget {
  const NoteSwipeActions({super.key, required this.note, required this.child});

  final NoteModel note;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notesProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return SwipeActions(
      id: note.id,
      start: SwipeAction(
        icon: Icons.archive_outlined,
        label: 'Archivia',
        color: cs.secondary,
        onTriggered:
            () => notifyWithUndo(
              notifier.toggleArchive(note.id),
              context,
              message: 'Nota archiviata',
              onUndo: () => notifier.toggleArchive(note.id),
            ),
      ),
      end: SwipeAction(
        icon: Icons.delete_outline,
        label: 'Cestino',
        color: cs.error,
        onTriggered:
            () => notifyWithUndo(
              notifier.softDelete(note.id),
              context,
              message: 'Nota spostata nel cestino',
              onUndo: () => notifier.restoreFromTrash(note.id),
            ),
      ),
      child: child,
    );
  }
}
