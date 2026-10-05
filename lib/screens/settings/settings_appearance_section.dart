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

/// "Aspetto" section: system/light/dark theme mode selector.
class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({
    super.key,
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Aspetto'),
        RadioGroup<ThemeMode>(
          groupValue: themeMode,
          onChanged: (v) => onChanged(v!),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Sistema'),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Chiaro'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Scuro'),
                value: ThemeMode.dark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
