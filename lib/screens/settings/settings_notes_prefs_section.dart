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
import '../../providers/settings/ui_provider.dart';
import '../../widgets/shared/section_header.dart';

/// "Note" section: home layout (grid/list) toggle and "+" button behavior.
class SettingsNotesPrefsSection extends StatelessWidget {
  const SettingsNotesPrefsSection({
    super.key,
    required this.homeLayout,
    required this.onToggleLayout,
    required this.fabMenu,
    required this.onToggleFabMenu,
  });

  final HomeLayout homeLayout;
  final VoidCallback onToggleLayout;
  final bool fabMenu;
  final VoidCallback onToggleFabMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader('Note'),
        ListTile(
          title: const Text('Layout'),
          subtitle: Text(homeLayout == HomeLayout.grid ? 'Griglia' : 'Lista'),
          trailing: Icon(
            homeLayout == HomeLayout.grid ? Icons.grid_view : Icons.view_list,
          ),
          onTap: onToggleLayout,
        ),
        SwitchListTile(
          title: const Text('Menu del pulsante +'),
          subtitle: Text(
            fabMenu
                ? 'Scegli tra nota, lista, task, audio e modello'
                : 'Il pulsante + crea subito una nuova nota',
          ),
          value: fabMenu,
          onChanged: (_) => onToggleFabMenu(),
        ),
      ],
    );
  }
}
