// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/backup_service.dart' show BackupFrequency;
import '../calendar_provider.dart';
import 'backup_provider.dart';
import 'locale_provider.dart';
import 'theme_provider.dart';
import 'ui_provider.dart';

/// One preference carried by the full backup: how to read its current value
/// as JSON and how to apply a value read from a backup.
class _BackedUpSetting {
  const _BackedUpSetting(this.read, this.write);

  final Object Function(Ref ref) read;

  /// Ignores values of the wrong type or no longer valid.
  final void Function(Ref ref, Object? value) write;
}

_BackedUpSetting _enumSetting<
  N extends PersistedEnumNotifier<T>,
  T extends Enum
>(NotifierProvider<N, T> provider, List<T> values) =>
    _BackedUpSetting((ref) => ref.read(provider).name, (ref, value) {
      for (final v in values) {
        if (v.name == value) {
          ref.read(provider.notifier).set(v);
          return;
        }
      }
    });

_BackedUpSetting _boolSetting(NotifierProvider<BoolSettingNotifier, bool> p) =>
    _BackedUpSetting((ref) => ref.read(p), (ref, value) {
      if (value is bool) ref.read(p.notifier).set(value);
    });

/// The user's preferences (kept only on the device) included in the full
/// backup under `settings`, keyed by stable names independent of the
/// SharedPreferences keys. Device bookkeeping (onboarding seen, last backup
/// time, last changelog seen, migration flags) is left out.
class PreferencesBackup {
  PreferencesBackup(this._ref);

  final Ref _ref;

  static final Map<String, _BackedUpSetting> _settings = {
    'themeMode': _enumSetting(themeModeProvider, ThemeMode.values),
    'language': _enumSetting(appLanguageProvider, AppLanguage.values),
    'startSection': _enumSetting(startSectionProvider, StartSection.values),
    'notesLayout': _enumSetting(homeLayoutProvider, HomeLayout.values),
    'notesSortOrder': _enumSetting(sortOrderProvider, SortOrder.values),
    'notesFabMenu': _boolSetting(notesFabMenuProvider),
    'tasksSortOrder': _enumSetting(taskSortOrderProvider, SortOrder.values),
    'showCompletedTasks': _boolSetting(showCompletedTasksProvider),
    'groupTasksByPriority': _boolSetting(groupTasksByPriorityProvider),
    'calendarView': _enumSetting(
      calendarViewModeProvider,
      CalendarViewMode.values,
    ),
    'calendarShowTasks': _boolSetting(calendarShowTasksProvider),
    // The alerts scheduled on the device are rebuilt by the data restore
    // that follows.
    'defaultAlertMinutes': _BackedUpSetting(
      (ref) => ref.read(defaultAlertTimeProvider),
      (ref, value) {
        if (value is int && value >= 0 && value < 24 * 60) {
          ref.read(defaultAlertTimeProvider.notifier).set(value);
        }
      },
    ),
    'dayBeforeAlertMinutes': _BackedUpSetting(
      (ref) => ref.read(dayBeforeAlertTimeProvider),
      (ref, value) {
        if (value is int && value >= 0 && value < 24 * 60) {
          ref.read(dayBeforeAlertTimeProvider.notifier).set(value);
        }
      },
    ),
    'autoBackupEnabled': _BackedUpSetting(
      (ref) => ref.read(backupSettingsProvider).enabled,
      (ref, value) {
        if (value is bool) {
          ref.read(backupSettingsProvider.notifier).setEnabled(value);
        }
      },
    ),
    'autoBackupFrequency': _BackedUpSetting(
      (ref) => ref.read(backupSettingsProvider).frequency.name,
      (ref, value) {
        for (final f in BackupFrequency.values) {
          if (f.name == value) {
            ref.read(backupSettingsProvider.notifier).setFrequency(f);
          }
        }
      },
    ),
  };

  /// The current value of every backed-up preference.
  Map<String, Object> export() => {
    for (final e in _settings.entries) e.key: e.value.read(_ref),
  };

  /// Applies the preferences found in [json]; unknown keys and invalid
  /// values are skipped, keeping the current value.
  void restore(Map<String, dynamic> json) {
    for (final e in _settings.entries) {
      if (json.containsKey(e.key)) e.value.write(_ref, json[e.key]);
    }
  }
}

final preferencesBackupProvider = Provider<PreferencesBackup>(
  PreferencesBackup.new,
);
