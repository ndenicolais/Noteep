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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notes_provider.dart';
import 'ui_provider.dart' show PersistedEnumNotifier;

const _kThemeKey = 'theme_mode_v2';

class ThemeModeNotifier extends PersistedEnumNotifier<ThemeMode> {
  ThemeModeNotifier(SharedPreferences prefs)
    : super(prefs, _kThemeKey, ThemeMode.values, ThemeMode.system);

  void setMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});
