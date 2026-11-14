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

/// "Notifications" section: the times of the notifications that have no
/// time of their own (all-day events, birthdays, name days), one for the
/// same-day alert and one for the day-before alert.
class SettingsNotificationsSection extends StatelessWidget {
  const SettingsNotificationsSection({
    super.key,
    required this.defaultAlertMinutes,
    required this.dayBeforeAlertMinutes,
    required this.onChanged,
    required this.onDayBeforeChanged,
  });

  /// Same-day alert time, minutes after midnight.
  final int defaultAlertMinutes;

  /// Day-before alert time, minutes after midnight.
  final int dayBeforeAlertMinutes;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onDayBeforeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(l10n.settingsNotificationsTitle),
        _AlertTimeTile(
          icon: Icons.notifications_outlined,
          title: l10n.settingsDayBeforeAlertTime,
          subtitle: l10n.settingsDayBeforeAlertTimeSubtitle,
          minutes: dayBeforeAlertMinutes,
          onChanged: onDayBeforeChanged,
        ),
        _AlertTimeTile(
          icon: Icons.notifications_active_outlined,
          title: l10n.settingsDefaultAlertTime,
          subtitle: l10n.settingsDefaultAlertTimeSubtitle,
          minutes: defaultAlertMinutes,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A time setting: tapping opens the time picker.
class _AlertTimeTile extends StatelessWidget {
  const _AlertTimeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int minutes;
  final ValueChanged<int> onChanged;

  TimeOfDay get _time => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    onChanged(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(_time, alwaysUse24HourFormat: true),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => _pick(context),
    );
  }
}
