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
import '../../theme/app_spacing.dart';
import 'color_picker_widget.dart';
import 'font_family_picker.dart';

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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.commonFont, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        FontFamilyPicker(
          selected: style.fontFamily,
          onSelected: (f) => onChanged(style.copyWith(fontFamily: f)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.styleSize(style.fontSize.toStringAsFixed(0)),
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
              label: Text(l10n.commonBold),
              selected: style.isBold,
              onSelected: (v) => onChanged(style.copyWith(isBold: v)),
            ),
            FilterChip(
              label: Text(l10n.commonItalic),
              selected: style.isItalic,
              onSelected: (v) => onChanged(style.copyWith(isItalic: v)),
            ),
            FilterChip(
              label: Text(l10n.styleStrikethrough),
              selected: style.isStrikethrough,
              onSelected: (v) => onChanged(style.copyWith(isStrikethrough: v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.styleTextColor,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        ColorPickerWidget(
          current: style.fontColor ?? Theme.of(context).colorScheme.onSurface,
          isDark: true,
          onPick: (c) => onChanged(style.copyWith(fontColor: c)),
        ),
      ],
    );
  }
}
