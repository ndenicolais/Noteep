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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_spacing.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/app_dialogs.dart';
import 'calendar_event_tile.dart';

/// Date/time, all-day, birthday, name-day and recurrence of an event.
///
/// Edits are reported through [onChanged] with the updated event; picking
/// the date/time is delegated to [onPickDateTime] (it chains two pickers
/// and keeps the duration, which the screen owns) and the optional end time
/// to [onPickEndTime] / [onClearEndTime].
class CalendarEventDetailsSection extends StatelessWidget {
  const CalendarEventDetailsSection({
    super.key,
    required this.event,
    required this.onPickDateTime,
    required this.onPickEndTime,
    required this.onClearEndTime,
    required this.onChanged,
  });

  final CalendarEventModel event;
  final VoidCallback onPickDateTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onClearEndTime;
  final ValueChanged<CalendarEventModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(DateFormat('EEEE, dd MMMM yyyy').format(event.startTime)),
          subtitle: Text(formatEventTimeRange(context.l10n, event)),
          onTap: onPickDateTime,
        ),
        if (!event.isAllDay)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_outlined),
            title: Text(context.l10n.calendarEndTime),
            subtitle: Text(
              event.hasEndTime
                  ? DateFormat('HH:mm').format(event.endTime)
                  : context.l10n.calendarNoEndTime,
            ),
            trailing:
                event.hasEndTime
                    ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.calendarRemoveEndTime,
                      onPressed: onClearEndTime,
                    )
                    : null,
            onTap: onPickEndTime,
          ),
        const SizedBox(height: AppSpacing.sm),
        _Toggle(
          title: context.l10n.calendarAllDay,
          value: event.isAllDay,
          // Back to a timed event: start without an end (the all-day end is
          // the next midnight, not a meaningful end time).
          onChanged:
              (v) => onChanged(
                v
                    ? event.copyWith(isAllDay: true)
                    : event.copyWith(isAllDay: false, endTime: event.startTime),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Toggle(
          icon: Icons.cake_outlined,
          title: context.l10n.calendarBirthday,
          value: event.isBirthday,
          onChanged: (v) => onChanged(event.copyWith(isBirthday: v)),
        ),
        _Toggle(
          icon: Icons.auto_awesome_outlined,
          title: context.l10n.calendarNameDay,
          value: event.isNameDay,
          onChanged: (v) => onChanged(event.copyWith(isNameDay: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.repeat_outlined),
          title: Text(context.l10n.calendarRecurrence),
          subtitle: Text(event.recurrence.label(context.l10n)),
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
                  title: Text(type.label(ctx.l10n)),
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
