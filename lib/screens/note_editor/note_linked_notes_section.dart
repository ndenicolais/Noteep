// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../models/note_model.dart';

/// "Note collegate" section: chips linking to the notes referenced by the
/// current one, each opening its own editor on tap.
class NoteLinkedNotesSection extends StatelessWidget {
  const NoteLinkedNotesSection({super.key, required this.linkedNotes});

  final List<NoteModel> linkedNotes;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.link, size: 16, color: onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Note collegate',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                linkedNotes.map((ln) {
                  return ActionChip(
                    avatar: const Icon(Icons.note_alt_outlined, size: 16),
                    label: Text(
                      ln.title.isEmpty ? 'Senza titolo' : ln.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => AppNav.openNote(context, ln),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
