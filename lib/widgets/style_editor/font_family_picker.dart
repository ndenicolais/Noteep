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
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';

/// Font families offered by the style editor (title and content).
const kNoteFonts = [
  'Exo 2',
  'Montserrat',
  'Open Sans',
  'Dancing Script',
  'Playfair Display',
  'Pacifico',
];

/// Horizontal strip of font chips, each previewing its own family.
class FontFamilyPicker extends StatefulWidget {
  const FontFamilyPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  State<FontFamilyPicker> createState() => _FontFamilyPickerState();
}

class _FontFamilyPickerState extends State<FontFamilyPicker> {
  // Own controller: an always-visible Scrollbar without one falls back to
  // the PrimaryScrollController, which belongs to another (vertical) list.
  final _controller = ScrollController();

  static const _baseHeight = 44.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The strip is horizontal, so its height must grow with the system
    // text size or the chips get clipped (×1.5 ≈ the chip label's line
    // height).
    const fontSize = AppFontSizes.sm;
    final extra = MediaQuery.textScalerOf(context).scale(fontSize) - fontSize;
    return SizedBox(
      height: _baseHeight + extra * 1.5,
      // An always-visible scrollbar hints that more fonts are scrollable
      // off-screen — otherwise desktop/web users with a mouse (no swipe
      // gesture) may never discover the rest.
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: kNoteFonts.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final f = kNoteFonts[i];
            return ChoiceChip(
              label: Text(
                f,
                style: TextStyle(fontFamily: f, fontSize: fontSize),
              ),
              selected: widget.selected == f,
              onSelected: (_) => widget.onSelected(f),
            );
          },
        ),
      ),
    );
  }
}
