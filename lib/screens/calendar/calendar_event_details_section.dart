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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_spacing.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/app_dialogs.dart';

/// Date/time, all-day, birthday, name-day and recurrence of an event.
///
/// Edits are reported through [onChanged] with the updated event; picking
/// the date/time is delegated to [onPickDateTime] (it chains two pickers
/// and keeps the duration, which the screen owns).
class CalendarEventDetailsSection extends StatelessWidget {
  const CalendarEventDetailsSection({
    super.key,
    required this.event,
    required this.onPickDateTime,
    required this.onChanged,
  });

  final CalendarEventModel event;
  final VoidCallback onPickDateTime;
  final ValueChanged<CalendarEventModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(
            DateFormat('EEEE, dd MMMM yyyy', 'it_IT').format(event.startTime),
          ),
          subtitle: Text(
            event.isAllDay
                ? 'Tutto il giorno'
                : '${time.format(event.startTime)} - ${time.format(event.endTime)}',
          ),
          onTap: onPickDateTime,
        ),
        const SizedBox(height: AppSpacing.sm),
        _Toggle(
          title: 'Tutto il giorno',
          value: event.isAllDay,
          onChanged: (v) => onChanged(event.copyWith(isAllDay: v)),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Toggle(
          icon: Icons.cake_outlined,
          title: 'Compleanno',
          value: event.isBirthday,
          onChanged: (v) => onChanged(event.copyWith(isBirthday: v)),
        ),
        _Toggle(
          icon: Icons.auto_awesome_outlined,
          title: 'Onomastico',
          value: event.isNameDay,
          onChanged: (v) => onChanged(event.copyWith(isNameDay: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.repeat_outlined),
          title: const Text('Ricorrenza'),
          subtitle: Text(event.recurrence.label),
          onTap: () => _pickRecurrence(context),
        ),
      ],
    );
  }

  Future<void> _pickRecurrence(BuildContext context) async {
    final type = await showAppSheet<RecurrenceType>(
      context,
      builder:
          (ctx) => ListView(
            shrinkWrap: true,
            children: [
              for (final type in RecurrenceType.values)
                ListTile(
                  title: Text(type.label),
                  selected: event.recurrence == type,
                  onTap: () => Navigator.pop(ctx, type),
                ),
            ],
          ),
    );
    if (type != null) onChanged(event.copyWith(recurrence: type));
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData? icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      secondary: icon == null ? null : Icon(icon),
      title: Text(title),
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
