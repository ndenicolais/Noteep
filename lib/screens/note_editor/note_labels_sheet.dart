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
import '../../theme/app_spacing.dart';

/// Picks the labels of a note: a search field that also creates a missing
/// label, and a checkbox per existing label.
class NoteLabelsSheet extends StatefulWidget {
  const NoteLabelsSheet({
    super.key,
    required this.allLabels,
    required this.selected,
    required this.onToggle,
    required this.onCreate,
  });

  final List<String> allLabels;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onCreate;

  @override
  State<NoteLabelsSheet> createState() => _NoteLabelsSheetState();
}

class _NoteLabelsSheetState extends State<NoteLabelsSheet> {
  final _queryController = TextEditingController();
  late final List<String> _labels = [...widget.allLabels];
  late final Set<String> _selected = {...widget.selected};

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _toggle(String label) {
    setState(() {
      if (!_selected.remove(label)) _selected.add(label);
    });
    widget.onToggle(label);
  }

  void _create(String name) {
    setState(() {
      _labels
        ..add(name)
        ..sort();
      _selected.add(name);
      _queryController.clear();
    });
    widget.onCreate(name);
  }

  @override
  Widget build(BuildContext context) {
    final query = _queryController.text.trim();
    final lower = query.toLowerCase();
    final filtered =
        query.isEmpty
            ? _labels
            : _labels.where((l) => l.toLowerCase().contains(lower)).toList();
    final canCreate = query.isNotEmpty && !_labels.contains(query);

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
                  controller: _queryController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.l10n.editorLabelsSearchHint,
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (canCreate) _create(query);
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  children: [
                    if (canCreate)
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: Text(context.l10n.editorLabelsCreate(query)),
                        onTap: () => _create(query),
                      ),
                    if (_labels.isEmpty && !canCreate)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          context.l10n.editorLabelsEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    for (final label in filtered)
                      CheckboxListTile(
                        value: _selected.contains(label),
                        title: Text(label),
                        secondary: const Icon(Icons.label_outline),
                        onChanged: (_) => _toggle(label),
                      ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
