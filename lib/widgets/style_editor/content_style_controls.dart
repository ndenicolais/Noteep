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
import '../../theme/app_font_sizes.dart';
import 'color_picker_widget.dart';

const _kFonts = [
  'Exo 2',
  'Montserrat',
  'Open Sans',
  'Dancing Script',
  'Playfair Display',
  'Pacifico',
];

class ContentStyleControls extends StatelessWidget {
  const ContentStyleControls({
    super.key,
    required this.style,
    required this.onChanged,
  });
  final NoteStyle style;
  final ValueChanged<NoteStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Font', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          // An always-visible scrollbar hints that more fonts are
          // scrollable off-screen — otherwise desktop/web users with a
          // mouse (no swipe gesture) may never discover the rest.
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kFonts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _kFonts[i];
                return ChoiceChip(
                  label: Text(
                    f,
                    style: TextStyle(fontFamily: f, fontSize: AppFontSizes.sm),
                  ),
                  selected: style.fontFamily == f,
                  onSelected: (_) => onChanged(style.copyWith(fontFamily: f)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Dimensione: ${style.fontSize.toStringAsFixed(0)}pt',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          min: 10,
          max: 32,
          divisions: 22,
          value: style.fontSize,
          onChanged: (v) => onChanged(style.copyWith(fontSize: v)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Grassetto'),
              selected: style.isBold,
              onSelected: (v) => onChanged(style.copyWith(isBold: v)),
            ),
            FilterChip(
              label: const Text('Corsivo'),
              selected: style.isItalic,
              onSelected: (v) => onChanged(style.copyWith(isItalic: v)),
            ),
            FilterChip(
              label: const Text('Sbarrato'),
              selected: style.isStrikethrough,
              onSelected: (v) => onChanged(style.copyWith(isStrikethrough: v)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Colore testo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ColorPickerWidget(
          current: style.fontColor ?? Theme.of(context).colorScheme.onSurface,
          isDark: true,
          onPick: (c) => onChanged(style.copyWith(fontColor: c)),
        ),
      ],
    );
  }
}
