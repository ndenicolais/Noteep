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
        SectionHeader(context.l10n.navNotes),
        ListTile(
          title: Text(context.l10n.settingsLayout),
          subtitle: Text(
            homeLayout == HomeLayout.grid
                ? context.l10n.settingsLayoutGrid
                : context.l10n.settingsLayoutList,
          ),
          trailing: Icon(
            homeLayout == HomeLayout.grid ? Icons.grid_view : Icons.view_list,
          ),
          onTap: onToggleLayout,
        ),
        SwitchListTile(
          title: Text(context.l10n.settingsFabMenu),
          subtitle: Text(
            fabMenu
                ? context.l10n.settingsFabMenuOn
                : context.l10n.settingsFabMenuOff,
          ),
          value: fabMenu,
          onChanged: (_) => onToggleFabMenu(),
        ),
      ],
    );
  }
}
