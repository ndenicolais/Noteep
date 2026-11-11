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
import 'calendar_event_style.dart';

/// Formats the time range of an event (a single time when it has no end),
/// "Tutto il giorno" for all-day events, or "Task" for a task.
String formatEventTimeRange(AppLocalizations l, CalendarEventModel event) {
  if (event is TaskCalendarEvent) return l.calendarTaskLabel;
  if (event.isAllDay) return l.calendarAllDay;
  final start = DateFormat('HH:mm').format(event.startTime);
  if (!event.hasEndTime) return start;
  return '$start – ${DateFormat('HH:mm').format(event.endTime)}';
}

/// A colored card shared by the day, schedule and day-events-sheet calendar
/// views: the background tells the kind of entry (see [calendarItemStyle]),
/// with title and time range on top of it.
class CalendarEventListTile extends StatelessWidget {
  const CalendarEventListTile({
    super.key,
    required this.event,
    required this.onTap,
    this.dense = false,
  });

  final CalendarEventModel event;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(event, Theme.of(context).colorScheme);
    final radius = BorderRadius.circular(8);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: Material(
        color: style.background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: dense ? AppSpacing.sm : AppSpacing.md,
            ),
            child: Row(
              children: [
                if (style.icon != null) ...[
                  Icon(style.icon, size: 18, color: style.foreground),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title.isEmpty
                            ? context.l10n.commonUntitledParens
                            : event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: style.foreground,
                          fontWeight: FontWeight.w600,
                          decoration: style.decoration,
                          decorationColor: style.foreground,
                        ),
                      ),
                      Text(
                        formatEventTimeRange(context.l10n, event),
                        style: TextStyle(
                          color: style.foreground.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
