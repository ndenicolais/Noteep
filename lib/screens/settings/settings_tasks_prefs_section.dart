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

/// "Task" preferences section: show-completed and group-by-priority switches.
class SettingsTasksPrefsSection extends StatelessWidget {
  const SettingsTasksPrefsSection({
    super.key,
    required this.showCompletedTasks,
    required this.groupTasksByPriority,
    required this.onToggleShowCompleted,
    required this.onToggleGroupByPriority,
  });

  final bool showCompletedTasks;
  final bool groupTasksByPriority;
  final VoidCallback onToggleShowCompleted;
  final VoidCallback onToggleGroupByPriority;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Task'),
        SwitchListTile(
          title: const Text('Mostra task completati'),
          subtitle: const Text('Visualizza i task marcati come completati'),
          value: showCompletedTasks,
          onChanged: (_) => onToggleShowCompleted(),
        ),
        SwitchListTile(
          title: const Text('Raggruppa per priorità'),
          subtitle: const Text('Ordina task per priorità (speciali in alto)'),
          value: groupTasksByPriority,
          onChanged: (_) => onToggleGroupByPriority(),
        ),
      ],
    );
  }
}
