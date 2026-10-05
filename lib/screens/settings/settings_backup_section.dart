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
import '../../providers/settings/backup_provider.dart';
import 'settings_section_header.dart';

/// "Backup" section: automatic backup toggle, frequency and history entry.
class SettingsBackupSection extends StatelessWidget {
  const SettingsBackupSection({
    super.key,
    required this.backupSettings,
    required this.frequencyLabel,
    required this.onToggleEnabled,
    required this.onShowFrequencySheet,
    required this.onShowBackupsSheet,
  });

  final BackupSettings backupSettings;
  final String frequencyLabel;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onShowFrequencySheet;
  final VoidCallback onShowBackupsSheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Backup'),
        SwitchListTile(
          title: const Text('Backup automatico'),
          subtitle: const Text('Salva automaticamente i tuoi dati'),
          value: backupSettings.enabled,
          onChanged: onToggleEnabled,
        ),
        if (backupSettings.enabled)
          ListTile(
            title: const Text('Frequenza backup'),
            subtitle: Text(frequencyLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: onShowFrequencySheet,
          ),
        ListTile(
          leading: Icon(
            Icons.backup,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Visualizza backup'),
          subtitle: const Text('Gestisci i backup salvati'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onShowBackupsSheet,
        ),
      ],
    );
  }
}
