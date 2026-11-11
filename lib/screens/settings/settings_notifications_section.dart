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

/// "Notifications" section: the default time of the notifications that have
/// no time of their own (all-day events, birthdays, name days).
class SettingsNotificationsSection extends StatelessWidget {
  const SettingsNotificationsSection({
    super.key,
    required this.defaultAlertMinutes,
    required this.onChanged,
  });

  /// Minutes after midnight.
  final int defaultAlertMinutes;
  final ValueChanged<int> onChanged;

  TimeOfDay get _time => TimeOfDay(
    hour: defaultAlertMinutes ~/ 60,
    minute: defaultAlertMinutes % 60,
  );

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    onChanged(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(l10n.settingsNotificationsTitle),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(l10n.settingsDefaultAlertTime),
          subtitle: Text(l10n.settingsDefaultAlertTimeSubtitle),
          trailing: Text(
            MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(_time, alwaysUse24HourFormat: true),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () => _pick(context),
        ),
      ],
    );
  }
}
