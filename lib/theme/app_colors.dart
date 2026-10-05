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

/// Central color palette for the app.
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF3D3F4D);
  static const Color warmYellow = Color(0xFFFEDFA9);
  static const Color warmBrown = Color(0xFFCCA775);

  /// Preset note colors offered in [ColorPickerWidget] for light theme notes.
  static const List<Color> noteSwatchesLight = [
    Colors.white,
    Color(0xFFFFF9C4),
    Color(0xFFB2EBF2),
    Color(0xFFDCEDC8),
    Color(0xFFFFCCBC),
    Color(0xFFE1BEE7),
    Color(0xFFCFD8DC),
    Color(0xFFF8BBD9),
  ];

  /// Preset note colors offered in [ColorPickerWidget] for dark theme notes.
  static const List<Color> noteSwatchesDark = [
    Colors.black87,
    Color(0xFF212121),
    Color(0xFF37474F),
    Color(0xFF4A148C),
    Color(0xFF1A237E),
    Color(0xFF880E4F),
    Color(0xFF1B5E20),
    Color(0xFFBF360C),
  ];

  /// WCAG relative-luminance contrast ratio between two colors (1–21).
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Picks black or white — whichever gives the higher WCAG contrast ratio
  /// against [background] — instead of a flat luminance threshold, which can
  /// pick the weaker option for mid-luminance/saturated swatches.
  static Color contrastingTextColor(Color background) {
    return contrastRatio(background, Colors.black87) >=
            contrastRatio(background, Colors.white)
        ? Colors.black87
        : Colors.white;
  }
}
