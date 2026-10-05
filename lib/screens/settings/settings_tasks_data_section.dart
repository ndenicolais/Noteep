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
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Task'),
        ListTile(
          leading: Icon(Icons.download_outlined, color: primary),
          title: const Text('Esporta task JSON'),
          subtitle: const Text('Scarica i task come file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onExportJson,
        ),
        ListTile(
          leading: Icon(Icons.upload_file_outlined, color: primary),
          title: const Text('Importa task JSON'),
          subtitle: const Text('Ripristina i task da un file .json'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onImportJson,
        ),
        ListTile(
          leading: Icon(Icons.delete_sweep_outlined, color: error),
          title: Text('Cancella task', style: TextStyle(color: error)),
          subtitle: const Text('Rimuove tutti i task'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onClearTasks,
        ),
      ],
    );
  }
}
