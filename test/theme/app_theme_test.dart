// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/theme/app_font_sizes.dart';
import 'package:noteep/theme/app_theme.dart';

void main() {
  for (final entry
      in {'light': AppTheme.light, 'dark': AppTheme.dark}.entries) {
    group('AppTheme.${entry.key} textTheme', () {
      final t = entry.value.textTheme;

      test('type roles follow AppFontSizes', () {
        expect(t.headlineMedium?.fontSize, AppFontSizes.display);
        expect(t.headlineSmall?.fontSize, AppFontSizes.headline);
        expect(t.titleLarge?.fontSize, AppFontSizes.xxl);
        expect(t.titleMedium?.fontSize, AppFontSizes.lg);
        expect(t.titleSmall?.fontSize, AppFontSizes.md);
        expect(t.bodyLarge?.fontSize, AppFontSizes.lg);
        expect(t.bodyMedium?.fontSize, AppFontSizes.md);
        expect(t.bodySmall?.fontSize, AppFontSizes.sm);
        expect(t.labelLarge?.fontSize, AppFontSizes.md);
        expect(t.labelMedium?.fontSize, AppFontSizes.sm);
        expect(t.labelSmall?.fontSize, AppFontSizes.xs);
      });

      test('every role uses Exo 2 and title roles are semi-bold', () {
        for (final style in [
          t.headlineMedium,
          t.titleMedium,
          t.bodyMedium,
          t.labelSmall,
        ]) {
          expect(style?.fontFamily, 'Exo 2');
        }
        expect(t.titleLarge?.fontWeight, FontWeight.w600);
        expect(t.titleMedium?.fontWeight, FontWeight.w600);
        expect(t.titleSmall?.fontWeight, FontWeight.w600);
      });
    });
  }
}
