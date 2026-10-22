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

/// "Task" data section: JSON export/import/clear for tasks and task lists.
class SettingsTasksDataSection extends StatelessWidget {
  const SettingsTasksDataSection({
    super.key,
    required this.onExportJson,
    required this.onImportJson,
    required this.onClearTasks,
  });

  final VoidCallback onExportJson;
  final VoidCallback onImportJson;
  final VoidCallback onClearTasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader('Task'),
        ActionTile(
          icon: Icons.download_outlined,
          title: 'Esporta task JSON',
          subtitle: 'Scarica i task come file .json',
          onTap: onExportJson,
        ),
        ActionTile(
          icon: Icons.upload_file_outlined,
          title: 'Importa task JSON',
          subtitle: 'Ripristina i task da un file .json',
          onTap: onImportJson,
        ),
        ActionTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Cancella task',
          subtitle: 'Rimuove tutti i task',
          destructive: true,
          onTap: onClearTasks,
        ),
      ],
    );
  }
}
