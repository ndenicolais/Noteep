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
import 'settings_section_header.dart';

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
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Backup globale'),
        ListTile(
          leading: Icon(Icons.save_alt_outlined, color: primary),
          title: const Text('Esporta backup completo'),
          subtitle: const Text(
            'Scarica un file .json con note, task ed eventi',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportFullBackup,
        ),
        ListTile(
          leading: Icon(Icons.restore_outlined, color: primary),
          title: const Text('Importa backup completo'),
          subtitle: const Text('Ripristina dati da un file .json di backup'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportFullBackup,
        ),
        ListTile(
          leading: Icon(Icons.delete_forever_outlined, color: error),
          title: Text('Cancella tutti i dati', style: TextStyle(color: error)),
          subtitle: const Text('Elimina definitivamente note, task ed eventi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onClearAll,
        ),
      ],
    );
  }
}
