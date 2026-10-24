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
        RadioGroup<AppLanguage>(
          groupValue: language,
          onChanged: (v) => onChanged(v!),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLanguage>(
                title: Text(l10n.settingsLanguageSystem),
                value: AppLanguage.system,
              ),
              const RadioListTile<AppLanguage>(
                title: Text('Italiano'),
                value: AppLanguage.it,
              ),
              const RadioListTile<AppLanguage>(
                title: Text('English'),
                value: AppLanguage.en,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
