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

class TitleStyleControls extends StatelessWidget {
  const TitleStyleControls({
    super.key,
    required this.style,
    required this.onChanged,
  });
  final NoteStyle style;
  final ValueChanged<NoteStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    // Effective values shown in the controls
    final effectiveFamily = style.titleFontFamily ?? style.fontFamily;
    final effectiveSize = style.titleFontSize ?? style.fontSize;
    final effectiveColor =
        style.titleFontColor ??
        style.fontColor ??
        Theme.of(context).colorScheme.onSurface;
    final effectiveBold = style.titleIsBold ?? true;
    final effectiveItalic = style.titleIsItalic ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font family
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
                  selected: effectiveFamily == f,
                  onSelected:
                      (_) => onChanged(style.copyWith(titleFontFamily: f)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Font size
        Text(
          'Dimensione: ${effectiveSize.toStringAsFixed(0)}pt',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          min: 12,
          max: 40,
          divisions: 28,
          value: effectiveSize,
          onChanged: (v) => onChanged(style.copyWith(titleFontSize: v)),
        ),
        const SizedBox(height: 8),

        // Bold / Italic
        Row(
          children: [
            FilterChip(
              label: const Text('Grassetto'),
              selected: effectiveBold,
              onSelected: (v) => onChanged(style.copyWith(titleIsBold: v)),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Corsivo'),
              selected: effectiveItalic,
              onSelected: (v) => onChanged(style.copyWith(titleIsItalic: v)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Title font color
        Text('Colore titolo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ColorPickerWidget(
          current: effectiveColor,
          isDark: true,
          onPick: (c) => onChanged(style.copyWith(titleFontColor: c)),
        ),
        const SizedBox(height: 16),

        // Reset to inherit from content
        OutlinedButton.icon(
          onPressed:
              () => onChanged(
                style.copyWith(
                  clearTitleFontColor: true,
                  clearTitleFontFamily: true,
                  clearTitleFontSize: true,
                  clearTitleIsBold: true,
                  clearTitleIsItalic: true,
                ),
              ),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Ripristina stile titolo'),
        ),
      ],
    );
  }
}
