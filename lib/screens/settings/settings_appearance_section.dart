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
import '../../widgets/shared/section_header.dart';
import '../../widgets/shared/segmented_choice.dart';

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
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(l10n.settingsAppearanceTitle),
        SegmentedChoice<ThemeMode>(
          selected: themeMode,
          onChanged: onChanged,
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.smartphone),
              label: Text(l10n.settingsThemeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode),
              label: Text(l10n.settingsThemeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode),
              label: Text(l10n.settingsThemeDark),
            ),
          ],
        ),
      ],
    );
  }
}
