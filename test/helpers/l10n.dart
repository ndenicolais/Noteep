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
import 'package:noteep/l10n/app_localizations.dart';

/// Tests assert on the Italian strings: pass [testLocale],
/// [testSupportedLocales] and [testLocalizationsDelegates] to the
/// MaterialApp of a widget test.
const testLocale = Locale('it');
const testSupportedLocales = AppLocalizations.supportedLocales;
const testLocalizationsDelegates = AppLocalizations.localizationsDelegates;

/// Italian strings, for code that takes an [AppLocalizations] directly.
final itL10n = lookupAppLocalizations(testLocale);
