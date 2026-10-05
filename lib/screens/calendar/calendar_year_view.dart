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
import '../../models/calendar_model.dart';
import 'calendar_mini_month.dart';

/// Full-year overview showing a mini calendar grid for each month.
class CalendarYearView extends StatelessWidget {
  const CalendarYearView({
    super.key,
    required this.focusedMonth,
    required this.allEvents,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.onMonthSelected,
  });

  final DateTime focusedMonth;
  final List<CalendarEventModel> allEvents;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final year = focusedMonth.year;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                onPressed: onPreviousYear,
                tooltip: 'Anno precedente',
              ),
              Expanded(
                child: Text(
                  '$year',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                onPressed: onNextYear,
                tooltip: 'Anno successivo',
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (_, monthIndex) {
              return CalendarMiniMonthView(
                year: year,
                month: monthIndex + 1,
                allEvents: allEvents,
                today: DateTime.now(),
                colorScheme: colorScheme,
                onMonthTap: () => onMonthSelected(DateTime(year, monthIndex + 1)),
              );
            },
          ),
        ),
      ],
    );
  }
}
