// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import 'ui_provider.dart' show PersistedEnumNotifier;

/// UI language. [system] follows the device and falls back to English when
/// the device language is not supported.
enum AppLanguage { system, it, en }

extension AppLanguageLocale on AppLanguage {
  /// Locale forced on `MaterialApp`; null lets it follow the device.
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.it => const Locale('it'),
    AppLanguage.en => const Locale('en'),
  };
}

const _kLanguageKey = 'app_language';

class AppLanguageNotifier extends PersistedEnumNotifier<AppLanguage> {
  AppLanguageNotifier()
    : super(_kLanguageKey, AppLanguage.values, AppLanguage.system);
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

/// Language code to use before the UI is built: the saved choice, else the
/// device language when supported, else English — the same resolution as
/// `MaterialApp`.
String startupLanguageCode(SharedPreferences prefs) {
  final saved = prefs.getString(_kLanguageKey);
  for (final language in AppLanguage.values) {
    if (language.name == saved && language.locale != null) {
      return language.locale!.languageCode;
    }
  }
  final device = Locale(PlatformDispatcher.instance.locale.languageCode);
  return AppLocalizations.delegate.isSupported(device)
      ? device.languageCode
      : 'en';
}
