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
import '../../providers/settings/locale_provider.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/shared/segmented_choice.dart';

/// "Lingua" section: system/Italian/English UI language selector. Language
/// names are written in their own language, so they are not translated.
class SettingsLanguageSection extends StatelessWidget {
  const SettingsLanguageSection({
    super.key,
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(l10n.settingsLanguageTitle),
        SegmentedChoice<AppLanguage>(
          selected: language,
          onChanged: onChanged,
          segments: [
            ButtonSegment(
              value: AppLanguage.system,
              icon: const Icon(Icons.smartphone),
              label: Text(l10n.settingsLanguageSystem),
            ),
            const ButtonSegment(value: AppLanguage.it, label: Text('Italiano')),
            const ButtonSegment(value: AppLanguage.en, label: Text('English')),
          ],
        ),
      ],
    );
  }
}
