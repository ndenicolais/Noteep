// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader('Dati note'),
        ActionTile(
          icon: Icons.bar_chart_outlined,
          title: 'Statistiche',
          subtitle: 'Visualizza tutte le informazioni sulle tue note',
          onTap: () => AppNav.openStatistics(context),
        ),
        ActionTile(
          icon: Icons.upload,
          title: 'Esporta note',
          subtitle: 'Esporta tutte le note in diversi formati',
          onTap: () => AppNav.openExport(context),
        ),
        ActionTile(
          icon: Icons.download_outlined,
          title: 'Esporta note JSON',
          subtitle: 'Scarica le note come file .json',
          onTap: onExportJson,
        ),
        ActionTile(
          icon: Icons.upload_file_outlined,
          title: 'Importa note JSON',
          subtitle: 'Ripristina le note da un file .json',
          onTap: onImportJson,
        ),
        ActionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Cancella note',
          subtitle: 'Rimuove tutte le note',
          destructive: true,
          onTap: onClearNotes,
        ),
      ],
    );
  }
}
