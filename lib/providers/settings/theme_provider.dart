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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui_provider.dart' show PersistedEnumNotifier;

const _kThemeKey = 'theme_mode_v2';

class ThemeModeNotifier extends PersistedEnumNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_kThemeKey, ThemeMode.values, ThemeMode.system);

  void setMode(ThemeMode mode) => set(mode);
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
