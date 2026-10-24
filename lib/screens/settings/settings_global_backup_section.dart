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
import '../../l10n/l10n.dart';
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

/// "Backup globale" section: full JSON backup export/import and clear-all.
class SettingsGlobalBackupSection extends StatelessWidget {
  const SettingsGlobalBackupSection({
    super.key,
    required this.onExportFullBackup,
    required this.onImportFullBackup,
    required this.onClearAll,
  });

  final VoidCallback onExportFullBackup;
  final VoidCallback onImportFullBackup;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(context.l10n.settingsGlobalBackupTitle),
        ActionTile(
          icon: Icons.save_alt_outlined,
          title: context.l10n.settingsExportFullBackup,
          subtitle: context.l10n.settingsExportFullBackupSubtitle,
          onTap: onExportFullBackup,
        ),
        ActionTile(
          icon: Icons.restore_outlined,
          title: context.l10n.settingsImportFullBackup,
          subtitle: context.l10n.settingsImportFullBackupSubtitle,
          onTap: onImportFullBackup,
        ),
        ActionTile(
          icon: Icons.delete_forever_outlined,
          title: context.l10n.settingsClearAll,
          subtitle: context.l10n.settingsClearAllSubtitle,
          destructive: true,
          onTap: onClearAll,
        ),
      ],
    );
  }
}
