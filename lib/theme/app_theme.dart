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
import 'app_colors.dart';
import 'app_font_sizes.dart';
import 'app_radius.dart';

/// App-wide Material 3 themes built from the [AppColors] palette.
///
/// Light  → warm-white surfaces, warm-brown primary, warm-yellow containers.
/// Dark   → dark-slate surfaces, warm-yellow primary, warm-brown containers.
class AppTheme {
  AppTheme._();

  // ─── Light ──────────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.warmBrown,
      brightness: Brightness.light,
    );
    final cs = base.copyWith(
      primary: AppColors.warmBrown,
      onPrimary: AppColors.dark,
      primaryContainer: AppColors.warmYellow,
      onPrimaryContainer: AppColors.dark,
      secondary: AppColors.warmYellow,
      onSecondary: AppColors.dark,
      secondaryContainer: const Color(0xFFFFF3DC),
      onSecondaryContainer: AppColors.dark,
      surface: AppColors.white,
      onSurface: AppColors.dark,
      surfaceContainerHighest: const Color(0xFFF5EDD8),
      onSurfaceVariant: AppColors.dark,
    );
    return _build(cs);
  }

  // ─── Dark ───────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.warmBrown,
      brightness: Brightness.dark,
    );
    final cs = base.copyWith(
      primary: AppColors.warmYellow,
      onPrimary: AppColors.dark,
      primaryContainer: AppColors.warmBrown,
      onPrimaryContainer: AppColors.dark,
      secondary: AppColors.warmBrown,
      onSecondary: AppColors.dark,
      secondaryContainer: const Color(0xFF5A4A32),
      onSecondaryContainer: AppColors.white,
      surface: AppColors.dark,
      onSurface: AppColors.white,
      surfaceContainerHighest: const Color(0xFF4A4C5A),
      onSurfaceVariant: AppColors.white,
    );
    return _build(cs);
  }

  // ─── Shared builder ─────────────────────────────────────────────────────────

  static ThemeData _build(ColorScheme cs) {
    return ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      textTheme: ThemeData(
        brightness: cs.brightness,
      ).textTheme.apply(fontFamily: 'Exo 2'),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'Exo 2',
          color: cs.onSurface,
          fontSize: AppFontSizes.xl,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Drawer
      drawerTheme: DrawerThemeData(backgroundColor: cs.surface),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        selectedIconTheme: IconThemeData(color: cs.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: cs.onSurface.withAlpha(150)),
        selectedLabelTextStyle: TextStyle(
          fontFamily: 'Exo 2',
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: AppFontSizes.sm,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: 'Exo 2',
          color: cs.onSurface.withAlpha(150),
          fontSize: AppFontSizes.sm,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: cs.secondaryContainer,
        labelStyle: TextStyle(
          color: cs.onSecondaryContainer,
          fontSize: AppFontSizes.xs,
        ),
      ),

      // Sliders (style editor)
      sliderTheme: SliderThemeData(activeTrackColor: cs.primary),
    );
  }
}
