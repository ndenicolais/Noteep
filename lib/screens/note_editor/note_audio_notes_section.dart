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
import '../../models/audio_note.dart';
import 'note_audio_player_tile.dart';

/// "Audio" section listing the audio notes attached to the current note.
class NoteAudioNotesSection extends StatelessWidget {
  const NoteAudioNotesSection({
    super.key,
    required this.audioNotes,
    required this.onDelete,
  });

  final List<AudioNote> audioNotes;
  final ValueChanged<AudioNote> onDelete;

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
              Icon(Icons.mic_none_outlined, size: 16, color: onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Audio',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: onSurfaceVariant),
              ),
            ],
          ),
        ),
        ...audioNotes.map(
          (a) => AudioNotePlayerTile(
            key: ValueKey(a.id),
            audioNote: a,
            onDelete: () => onDelete(a),
          ),
        ),
      ],
    );
  }
}
