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

/// Bottom action bar for [NoteEditorScreen]: background, style, reminder,
/// linked notes, audio recorder, checklist item and delete actions.
class NoteEditorBottomBar extends StatelessWidget {
  const NoteEditorBottomBar({
    super.key,
    required this.effectiveBg,
    required this.uiFg,
    required this.hasReminder,
    required this.isChecklist,
    required this.onBackgroundPicker,
    required this.onStyleEditor,
    required this.onReminder,
    required this.onLinkNote,
    required this.onRecordAudio,
    required this.onAddChecklistItem,
    required this.onDelete,
  });

  final Color effectiveBg;
  final Color uiFg;
  final bool hasReminder;
  final bool isChecklist;
  final VoidCallback onBackgroundPicker;
  final VoidCallback onStyleEditor;
  final VoidCallback onReminder;
  final VoidCallback onLinkNote;
  final VoidCallback onRecordAudio;
  final VoidCallback onAddChecklistItem;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: effectiveBg,
      elevation: 1,
      child: IconTheme(
        data: IconThemeData(color: uiFg),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              onPressed: onBackgroundPicker,
              tooltip: 'Colore sfondo',
            ),
            IconButton(
              icon: const Icon(Icons.text_format),
              onPressed: onStyleEditor,
              tooltip: 'Modifica stile',
            ),
            IconButton(
              icon: Icon(
                hasReminder ? Icons.alarm : Icons.alarm_add_outlined,
                color:
                    hasReminder ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: onReminder,
              tooltip: 'Promemoria',
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: onLinkNote,
              tooltip: 'Collega nota',
            ),
            IconButton(
              icon: const Icon(Icons.mic_none_outlined),
              onPressed: onRecordAudio,
              tooltip: 'Registra audio',
            ),
            if (isChecklist)
              IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: onAddChecklistItem,
                tooltip: 'Aggiungi elemento',
              ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Elimina nota',
            ),
          ],
        ),
      ),
    );
  }
}
