// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notes_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/note_card.dart';
import 'note_swipe_actions.dart';

/// Home list layout of the notes in [noteIds]; like `ReorderableGridView`,
/// each row watches its own note.
class ReorderableListViewWidget extends StatelessWidget {
  const ReorderableListViewWidget({
    super.key,
    required this.noteIds,
    required this.onReorder,
  });

  final List<String> noteIds;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          80,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        // onReorderItem gives the post-removal index; onReorder (and
        // NotesNotifier.reorderNotes) expect the legacy pre-removal one.
        onReorderItem: (o, n) => onReorder(o, n > o ? n + 1 : n),
        itemCount: noteIds.length,
        itemBuilder: (_, i) {
          final id = noteIds[i];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(id),
            index: i,
            child: Consumer(
              builder: (_, ref, _) {
                final note = ref.watch(noteByIdProvider(id));
                if (note == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: NoteSwipeActions(
                    note: note,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: NoteCard(note: note),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
