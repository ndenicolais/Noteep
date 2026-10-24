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

    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font family
        Text(l10n.commonFont, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        FontFamilyPicker(
          selected: effectiveFamily,
          onSelected: (f) => onChanged(style.copyWith(titleFontFamily: f)),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Font size
        Text(
          l10n.styleSize(effectiveSize.toStringAsFixed(0)),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          min: 12,
          max: 40,
          divisions: 28,
          value: effectiveSize,
          onChanged: (v) => onChanged(style.copyWith(titleFontSize: v)),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Bold / Italic
        Row(
          children: [
            FilterChip(
              label: Text(l10n.commonBold),
              selected: effectiveBold,
              onSelected: (v) => onChanged(style.copyWith(titleIsBold: v)),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: Text(l10n.commonItalic),
              selected: effectiveItalic,
              onSelected: (v) => onChanged(style.copyWith(titleIsItalic: v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Title font color
        Text(
          l10n.styleTitleColor,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        ColorPickerWidget(
          current: effectiveColor,
          isDark: true,
          onPick: (c) => onChanged(style.copyWith(titleFontColor: c)),
        ),
        const SizedBox(height: AppSpacing.lg),

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
          label: Text(l10n.styleResetTitle),
        ),
      ],
    );
  }
}
