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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import 'calendar_time_grid.dart';

/// Multi-day view used for the "Settimana" and "7 giorni" modes: range
/// navigation above an hour grid ([CalendarTimeGrid]).
class CalendarMultiDayView extends StatelessWidget {
  const CalendarMultiDayView({
    super.key,
    required this.startDay,
    required this.dayCount,
    required this.allEvents,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime startDay;
  final int dayCount;
  final List<CalendarEventModel> allEvents;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final endDay = startDay.add(Duration(days: dayCount - 1));
    final days = List.generate(
      dayCount,
      (i) => startDay.add(Duration(days: i)),
    );
    final rangeLabel =
        '${DateFormat('d MMM').format(startDay)} – ${DateFormat('d MMM yyyy').format(endDay)}';

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
                onPressed: onPrevious,
              ),
              Expanded(
                child: Text(
                  rangeLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFontSizes.md,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                onPressed: onNext,
              ),
            ],
          ),
        ),
        Expanded(child: CalendarTimeGrid(days: days, allEvents: allEvents)),
      ],
    );
  }
}
