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
import '../../models/note_model.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/markdown_text.dart';

class NoteLinkSheet extends StatefulWidget {
  const NoteLinkSheet({
    super.key,
    required this.allNotes,
    required this.linkedIds,
    required this.onToggle,
  });

  final List<NoteModel> allNotes;
  final List<String> linkedIds;
  final ValueChanged<String> onToggle;

  @override
  State<NoteLinkSheet> createState() => _NoteLinkSheetState();
}

class _NoteLinkSheetState extends State<NoteLinkSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
        _query.isEmpty
            ? widget.allNotes
            : widget.allNotes
                .where(
                  (n) =>
                      n.title.toLowerCase().contains(_query.toLowerCase()) ||
                      n.content.toLowerCase().contains(_query.toLowerCase()),
                )
                .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder:
          (_, scroll) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.l10n.editorSearchNoteHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final note = filtered[i];
                    final isLinked = widget.linkedIds.contains(note.id);
                    return CheckboxListTile(
                      value: isLinked,
                      title: Text(
                        note.title.isEmpty
                            ? context.l10n.editorUntitledNote
                            : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          note.content.isNotEmpty
                              ? Text(
                                markdownToPlainText(note.content),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.sm,
                                ),
                              )
                              : null,
                      onChanged: (_) => widget.onToggle(note.id),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}
