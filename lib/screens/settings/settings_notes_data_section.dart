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
import '../export_screen.dart';
import '../statistics/statistics_screen.dart';
import 'settings_section_header.dart';

/// "Dati note" section: statistics, export screen, JSON export/import/clear.
class SettingsNotesDataSection extends StatelessWidget {
  const SettingsNotesDataSection({
    super.key,
    required this.onExportJson,
    required this.onImportJson,
    required this.onClearNotes,
  });

  final VoidCallback onExportJson;
  final VoidCallback onImportJson;
  final VoidCallback onClearNotes;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Dati note'),
        ListTile(
          leading: Icon(Icons.bar_chart_outlined, color: primary),
          title: const Text('Statistiche'),
          subtitle: const Text(
            'Visualizza tutte le informazioni sulle tue note',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              ),
        ),
        ListTile(
          leading: Icon(Icons.upload, color: primary),
          title: const Text('Esporta note'),
          subtitle: const Text('Esporta tutte le note in diversi formati'),
          trailing: const Icon(Icons.chevron_right),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportScreen()),
              ),
        ),
        ListTile(
          leading: Icon(Icons.download_outlined, color: primary),
          title: const Text('Esporta note JSON'),
          subtitle: const Text('Scarica le note come file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportJson,
        ),
        ListTile(
          leading: Icon(Icons.upload_file_outlined, color: primary),
          title: const Text('Importa note JSON'),
          subtitle: const Text('Ripristina le note da un file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportJson,
        ),
        ListTile(
          leading: Icon(Icons.delete_sweep_outlined, color: error),
          title: Text('Cancella note', style: TextStyle(color: error)),
          subtitle: const Text('Rimuove tutte le note'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onClearNotes,
        ),
      ],
    );
  }
}
