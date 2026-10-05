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
import 'settings_section_header.dart';

/// "Note" section: home layout (grid/list) toggle.
class SettingsNotesPrefsSection extends StatelessWidget {
  const SettingsNotesPrefsSection({
    super.key,
    required this.homeLayout,
    required this.onToggleLayout,
  });

  final HomeLayout homeLayout;
  final VoidCallback onToggleLayout;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Note'),
        ListTile(
          title: const Text('Layout'),
          subtitle: Text(homeLayout == HomeLayout.grid ? 'Griglia' : 'Lista'),
          trailing: Icon(
            homeLayout == HomeLayout.grid ? Icons.grid_view : Icons.view_list,
          ),
          onTap: onToggleLayout,
        ),
      ],
    );
  }
}
