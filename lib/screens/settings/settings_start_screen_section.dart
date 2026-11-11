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
import '../../theme/app_spacing.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/shared/segmented_choice.dart';

/// "Start screen" section: which section the app opens on, in drawer order.
class SettingsStartScreenSection extends StatelessWidget {
  const SettingsStartScreenSection({
    super.key,
    required this.section,
    required this.onChanged,
  });

  final StartSection section;
  final ValueChanged<StartSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.settingsStartScreenTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            l10n.settingsStartScreenSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SegmentedChoice<StartSection>(
          selected: section,
          onChanged: onChanged,
          segments: [
            ButtonSegment(
              value: StartSection.calendar,
              label: Text(l10n.navCalendar),
            ),
            ButtonSegment(
              value: StartSection.tasks,
              label: Text(l10n.navTasks),
            ),
            ButtonSegment(
              value: StartSection.notes,
              label: Text(l10n.navNotes),
            ),
          ],
        ),
      ],
    );
  }
}
