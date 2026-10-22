import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:noteep/l10n/l10n.dart';
import 'package:noteep/providers/settings/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/l10n.dart';

void main() {
  Future<String> startup(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return startupLanguageCode(await SharedPreferences.getInstance());
  }

  test('startup language: saved choice, else the device language', () async {
    expect(await startup({'app_language': 'it'}), 'it');
    expect(await startup({'app_language': 'en'}), 'en');
    // The test device is en_US.
    expect(await startup({'app_language': 'system'}), 'en');
    expect(await startup({}), 'en');
  });

  test('currentL10n follows Intl.defaultLocale, English if unsupported', () {
    addTearDown(() => Intl.defaultLocale = null);
    Intl.defaultLocale = 'it';
    expect(currentL10n().localeName, 'it');
    Intl.defaultLocale = 'fr_FR';
    expect(currentL10n().localeName, 'en');
  });

  test('home widget labels use the plural', () {
    expect(itL10n.widgetNoteCount(1), '1 nota');
    expect(itL10n.widgetNoteCount(3), '3 note');
    expect(lookupAppLocalizations(testLocale).widgetTaskCount(0), '0 task');
  });
}
