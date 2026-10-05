// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/backup_service.dart';
import '../notes_provider.dart';

const _kBackupEnabledKey = 'backup_enabled';
const _kBackupFrequencyKey = 'backup_frequency_v2';

class BackupSettings {
  final bool enabled;
  final BackupFrequency frequency;

  const BackupSettings({
    this.enabled = false,
    this.frequency = BackupFrequency.daily,
  });

  BackupSettings copyWith({bool? enabled, BackupFrequency? frequency}) {
    return BackupSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
    );
  }
}

class BackupSettingsNotifier extends StateNotifier<BackupSettings> {
  BackupSettingsNotifier(this._prefs) : super(const BackupSettings()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final enabled = _prefs.getBool(_kBackupEnabledKey) ?? false;
    final frequencyName = _prefs.getString(_kBackupFrequencyKey);
    final frequency = BackupFrequency.values.firstWhere(
      (f) => f.name == frequencyName,
      orElse: () => BackupFrequency.daily,
    );
    state = BackupSettings(enabled: enabled, frequency: frequency);
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _prefs.setBool(_kBackupEnabledKey, enabled);
  }

  Future<void> setFrequency(BackupFrequency frequency) async {
    state = state.copyWith(frequency: frequency);
    await _prefs.setString(_kBackupFrequencyKey, frequency.name);
  }
}

final backupSettingsProvider =
    StateNotifierProvider<BackupSettingsNotifier, BackupSettings>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return BackupSettingsNotifier(prefs);
    });

// Provider to get available backups
final availableBackupsProvider = FutureProvider<List<String>>((ref) async {
  final backups = await BackupService.listBackups();
  return backups
      .map((b) => BackupService.getBackupInfo(b)['name'] as String)
      .toList();
});

// Provider for backup status
class BackupStatus {
  final bool isLoading;
  final bool isSuccess;
  final String? message;

  const BackupStatus({
    this.isLoading = false,
    this.isSuccess = false,
    this.message,
  });
}

class BackupStatusNotifier extends StateNotifier<BackupStatus> {
  BackupStatusNotifier() : super(const BackupStatus());

  void setLoading(bool loading) {
    state = BackupStatus(
      isLoading: loading,
      isSuccess: state.isSuccess,
      message: state.message,
    );
  }

  void setSuccess(bool success) {
    state = BackupStatus(
      isLoading: false,
      isSuccess: success,
      message: state.message,
    );
  }

  void setMessage(String? message) {
    state = BackupStatus(
      isLoading: state.isLoading,
      isSuccess: state.isSuccess,
      message: message,
    );
  }

  void reset() {
    state = const BackupStatus();
  }
}

final backupStatusProvider =
    StateNotifierProvider<BackupStatusNotifier, BackupStatus>((ref) {
      return BackupStatusNotifier();
    });
