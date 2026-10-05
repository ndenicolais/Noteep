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
import '../../models/note_model.dart';
import '../../theme/app_radius.dart';
import 'title_style_controls.dart';
import 'content_style_controls.dart';

enum _StyleSection { title, content }

class StyleEditorSheet extends StatefulWidget {
  const StyleEditorSheet({
    super.key,
    required this.style,
    required this.onChanged,
  });

  final NoteStyle style;
  final ValueChanged<NoteStyle> onChanged;

  @override
  State<StyleEditorSheet> createState() => _StyleEditorSheetState();
}

class _StyleEditorSheetState extends State<StyleEditorSheet> {
  late NoteStyle _style;
  _StyleSection _section = _StyleSection.content;

  @override
  void initState() {
    super.initState();
    final s = widget.style;
    _style = s.copyWith(
      titleFontFamily: s.titleFontFamily ?? s.fontFamily,
      titleFontSize: s.titleFontSize ?? (s.fontSize + 8),
      titleFontColor: s.titleFontColor ?? s.fontColor,
      titleIsBold: s.titleIsBold ?? true,
      titleIsItalic: s.titleIsItalic ?? false,
    );
  }

  void _update(NoteStyle s) {
    setState(() => _style = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.95,
      builder:
          (context, scroll) => Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ListView(
                controller: scroll,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Stile Testo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<_StyleSection>(
                    segments: const [
                      ButtonSegment(
                        value: _StyleSection.title,
                        label: Text('Titolo'),
                        icon: Icon(Icons.title),
                      ),
                      ButtonSegment(
                        value: _StyleSection.content,
                        label: Text('Corpo'),
                        icon: Icon(Icons.notes),
                      ),
                    ],
                    selected: {_section},
                    onSelectionChanged:
                        (s) => setState(() => _section = s.first),
                  ),
                  const SizedBox(height: 16),
                  if (_section == _StyleSection.title)
                    TitleStyleControls(style: _style, onChanged: _update)
                  else
                    ContentStyleControls(style: _style, onChanged: _update),
                ],
              ),
            ),
          ),
    );
  }
}
