// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/providers/calendar_provider.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:noteep/providers/settings/backup_provider.dart';
import 'package:noteep/providers/settings/locale_provider.dart';
import 'package:noteep/providers/settings/preferences_backup.dart';
import 'package:noteep/providers/settings/theme_provider.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:noteep/utils/backup_service.dart' show BackupFrequency;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  ProviderContainer newContainer() {
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('export carries every preference with its current value', () {
    final c = newContainer();
    c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    c.read(startSectionProvider.notifier).set(StartSection.calendar);
    c.read(notesFabMenuProvider.notifier).set(false);
    c.read(defaultAlertTimeProvider.notifier).set(420);

    final json = c.read(preferencesBackupProvider).export();
    expect(json['themeMode'], 'dark');
    expect(json['startSection'], 'calendar');
    expect(json['notesFabMenu'], false);
    expect(json['defaultAlertMinutes'], 420);
    expect(
      json.keys,
      containsAll([
        'language',
        'notesLayout',
        'notesSortOrder',
        'tasksSortOrder',
        'showCompletedTasks',
        'groupTasksByPriority',
        'calendarView',
        'calendarShowTasks',
        'autoBackupEnabled',
        'autoBackupFrequency',
      ]),
    );
  });

  test(
    'restore applies and persists an exported set on another device',
    () async {
      final source = newContainer();
      source.read(appLanguageProvider.notifier).set(AppLanguage.en);
      source.read(homeLayoutProvider.notifier).set(HomeLayout.list);
      source.read(calendarViewModeProvider.notifier).set(CalendarViewMode.year);
      source.read(backupSettingsProvider.notifier).setEnabled(true);
      source
          .read(backupSettingsProvider.notifier)
          .setFrequency(BackupFrequency.weekly);
      final json = source.read(preferencesBackupProvider).export();
      source.dispose();

      await prefs.clear();
      expect(prefs.getString('calendar_view_mode'), isNull);
      final target = newContainer();
      target.read(preferencesBackupProvider).restore(json);
      expect(target.read(appLanguageProvider), AppLanguage.en);
      expect(target.read(homeLayoutProvider), HomeLayout.list);
      expect(target.read(calendarViewModeProvider), CalendarViewMode.year);
      expect(target.read(backupSettingsProvider).enabled, isTrue);
      expect(
        target.read(backupSettingsProvider).frequency,
        BackupFrequency.weekly,
      );
      expect(prefs.getString('calendar_view_mode'), 'year');
    },
  );

  test('restore skips unknown keys and invalid values', () {
    final c = newContainer();
    c.read(themeModeProvider.notifier).set(ThemeMode.light);

    c.read(preferencesBackupProvider).restore({
      'themeMode': 'neon',
      'notesFabMenu': 'yes',
      'defaultAlertMinutes': 99999,
      'somethingNew': true,
    });
    expect(c.read(themeModeProvider), ThemeMode.light);
    expect(c.read(notesFabMenuProvider), isTrue);
    expect(c.read(defaultAlertTimeProvider), isNot(99999));
  });
}
