// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Strings of the current UI language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings of the current UI language for code without a [BuildContext]
/// (notifications, home widget, exported files): the language of
/// `Intl.defaultLocale`, set at startup by `AppBootstrap` and then kept in
/// sync by `MaterialApp.builder`.
AppLocalizations currentL10n() {
  final locale = Locale(Intl.getCurrentLocale().split(RegExp('[_-]')).first);
  return lookupAppLocalizations(
    AppLocalizations.delegate.isSupported(locale) ? locale : const Locale('en'),
  );
}
