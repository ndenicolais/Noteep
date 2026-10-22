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
        const SectionHeader('Backup globale'),
        ActionTile(
          icon: Icons.save_alt_outlined,
          title: 'Esporta backup completo',
          subtitle: 'Scarica un file .json con note, task ed eventi',
          onTap: onExportFullBackup,
        ),
        ActionTile(
          icon: Icons.restore_outlined,
          title: 'Importa backup completo',
          subtitle: 'Ripristina dati da un file .json di backup',
          onTap: onImportFullBackup,
        ),
        ActionTile(
          icon: Icons.delete_forever_outlined,
          title: 'Cancella tutti i dati',
          subtitle: 'Elimina definitivamente note, task ed eventi',
          destructive: true,
          onTap: onClearAll,
        ),
      ],
    );
  }
}
