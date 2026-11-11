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
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import 'calendar_time_grid.dart';

/// Single-day view of the calendar workspace: date navigation above an hour
/// grid ([CalendarTimeGrid]).
class CalendarDayView extends StatelessWidget {
  const CalendarDayView({
    super.key,
    required this.day,
    required this.allEvents,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  final DateTime day;
  final List<CalendarEventModel> allEvents;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(day);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                onPressed: onPreviousDay,
                tooltip: context.l10n.calendarPreviousDay,
              ),
              Expanded(
                child: Text(
                  dateStr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSizes.md,
                    fontWeight: FontWeight.bold,
                    color:
                        isToday ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                onPressed: onNextDay,
                tooltip: context.l10n.calendarNextDay,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: CalendarTimeGrid(
            days: [day],
            allEvents: allEvents,
            showDayHeader: false,
          ),
        ),
      ],
    );
  }
}
