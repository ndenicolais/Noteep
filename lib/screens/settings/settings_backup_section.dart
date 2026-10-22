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
import '../../l10n/l10n.dart';
import '../../providers/settings/backup_provider.dart';
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

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
        SectionHeader(context.l10n.settingsBackupTitle),
        SwitchListTile(
          title: Text(context.l10n.settingsAutoBackup),
          subtitle: Text(context.l10n.settingsAutoBackupSubtitle),
          value: backupSettings.enabled,
          onChanged: onToggleEnabled,
        ),
        if (backupSettings.enabled)
          ListTile(
            title: Text(context.l10n.settingsBackupFrequency),
            subtitle: Text(frequencyLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: onShowFrequencySheet,
          ),
        ActionTile(
          icon: Icons.backup,
          title: context.l10n.settingsViewBackups,
          subtitle: context.l10n.settingsViewBackupsSubtitle,
          onTap: onShowBackupsSheet,
        ),
      ],
    );
  }
}
