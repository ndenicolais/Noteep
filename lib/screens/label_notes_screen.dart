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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n.dart';
import '../providers/settings/ui_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/item_card.dart';

/// The notes with one label, opened from the Labels screen.
class LabelNotesScreen extends ConsumerWidget {
  const LabelNotesScreen({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesWithTagProvider(label));

    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body:
          notes.isEmpty
              ? EmptyState(
                icon: Icons.label_off_outlined,
                message: context.l10n.labelNotesEmpty,
                iconSize: 64,
              )
              : ItemCardList(
                itemCount: notes.length,
                itemBuilder: (_, i) => NoteCard(note: notes[i]),
              ),
    );
  }
}
