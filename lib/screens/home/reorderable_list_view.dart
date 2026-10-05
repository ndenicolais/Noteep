// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../widgets/note_card.dart';

class ReorderableListViewWidget extends StatelessWidget {
  const ReorderableListViewWidget({
    super.key,
    required this.notes,
    required this.onReorder,
  });

  final List<NoteModel> notes;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        buildDefaultDragHandles: false,
        // onReorderItem gives the post-removal index; onReorder (and
        // NotesNotifier.reorderNotes) expect the legacy pre-removal one.
        onReorderItem: (o, n) => onReorder(o, n > o ? n + 1 : n),
        itemCount: notes.length,
        itemBuilder: (_, i) {
          final note = notes[i];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(note.id),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: NoteCard(note: note),
              ),
            ),
          );
        },
      ),
    );
  }
}
