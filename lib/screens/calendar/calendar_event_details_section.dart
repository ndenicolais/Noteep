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
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/event_alerts.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/style_editor/color_picker_widget.dart';
import 'calendar_event_style.dart';
import 'calendar_event_tile.dart';

/// Date/time, all-day, birthday, name-day, recurrence, card color and
/// alerts (day before / same day) of an event.
///
/// Edits are reported through [onChanged] with the updated event; picking
/// the date/time is delegated to [onPickDateTime] (it chains two pickers
/// and keeps the duration, which the screen owns) and the optional end time
/// to [onPickEndTime] / [onClearEndTime].
class CalendarEventDetailsSection extends StatelessWidget {
  const CalendarEventDetailsSection({
    super.key,
    required this.event,
    required this.allDayAlertMinutes,
    required this.onPickDateTime,
    required this.onPickEndTime,
    required this.onClearEndTime,
    required this.onChanged,
  });

  final CalendarEventModel event;

  /// Alert time of all-day events (minutes after midnight, from Settings).
  final int allDayAlertMinutes;
  final VoidCallback onPickDateTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onClearEndTime;
  final ValueChanged<CalendarEventModel> onChanged;

  /// Sets the kind (birthday and name day exclude each other). Turning one
  /// on makes the event a yearly all-day one alerting the day before and on
  /// the day, like Google Calendar birthdays; all of it can be changed after.
  CalendarEventModel _withKind({bool birthday = false, bool nameDay = false}) {
    final special = birthday || nameDay;
    return event.copyWith(
      isBirthday: birthday,
      isNameDay: nameDay,
      isAllDay: special ? true : null,
      recurrence:
          special && event.recurrence == RecurrenceType.none
              ? RecurrenceType.yearly
              : null,
      alertDayBefore: special ? true : null,
      alertSameDay: special ? true : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(event, Theme.of(context).colorScheme);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The kind in its calendar color, so the choice shows right away.
        if (event.isBirthday || event.isNameDay)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(style.icon, size: 18, color: style.foreground),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  event.isBirthday
                      ? context.l10n.calendarBirthday
                      : context.l10n.calendarNameDay,
                  style: TextStyle(
                    color: style.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
          activeColor: birthdayColor,
          onChanged: (v) => onChanged(_withKind(birthday: v)),
        ),
        _Toggle(
          icon: Icons.auto_awesome_outlined,
          title: context.l10n.calendarNameDay,
          value: event.isNameDay,
          activeColor: nameDayColor,
          onChanged: (v) => onChanged(_withKind(nameDay: v)),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.repeat_outlined),
          title: Text(context.l10n.calendarRecurrence),
          subtitle: Text(event.recurrence.label(context.l10n)),
          onTap: () => _pickRecurrence(context),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.palette_outlined),
          title: Text(context.l10n.calendarColor),
          subtitle:
              event.color == null
                  ? Text(context.l10n.calendarColorDefault)
                  : null,
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: style.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          onTap: () => _pickColor(context),
        ),
        // A timed event always alerts at its start: the choice is only for
        // all-day ones, which alert at the Settings time.
        if (event.isAllDay) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              context.l10n.calendarAlerts,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          _Toggle(
            icon: Icons.notifications_outlined,
            title: context.l10n.calendarAlertDayBefore,
            subtitle: _alertTimeLabel(context),
            value: event.alertDayBefore,
            onChanged: (v) => onChanged(event.copyWith(alertDayBefore: v)),
          ),
          _Toggle(
            icon: Icons.notifications_active_outlined,
            title: context.l10n.calendarAlertSameDay,
            subtitle: _alertTimeLabel(context),
            value: event.alertSameDay,
            onChanged: (v) => onChanged(event.copyWith(alertSameDay: v)),
          ),
        ],
      ],
    );
  }

  /// "Alle" and the Settings alert time (alerts are shown for all-day
  /// events only).
  String _alertTimeLabel(BuildContext context) => context.l10n.calendarAlertAt(
    DateFormat('HH:mm').format(
      occurrenceTime(event, event.startTime, allDayMinutes: allDayAlertMinutes),
    ),
  );

  /// Note swatches plus a custom Material color; "Predefinito" goes back to
  /// the color of the event kind.
  Future<void> _pickColor(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = event.color;
    // A swatch picked in the other theme shows as selected here too.
    final from =
        isDark ? AppColors.noteSwatchesLight : AppColors.noteSwatchesDark;
    final to =
        isDark ? AppColors.noteSwatchesDark : AppColors.noteSwatchesLight;
    final i = current == null ? -1 : from.indexOf(current);
    final shown = i >= 0 ? to[i] : current;
    await showAppSheet<void>(
      context,
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ctx.l10n.calendarColor,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                ColorPickerWidget(
                  current: shown ?? Colors.transparent,
                  isDark: isDark,
                  onPick: (color) {
                    onChanged(event.copyWith(color: color));
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.format_color_reset_outlined),
                  title: Text(ctx.l10n.calendarColorDefault),
                  selected: current == null,
                  onTap: () {
                    onChanged(event.copyWith(clearColor: true));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
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
    this.subtitle,
    this.activeColor,
    required this.value,
    required this.onChanged,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Color? activeColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      secondary: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      activeColor: activeColor,
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
