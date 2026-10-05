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
import 'calendar_utils.dart';

class CalendarMiniMonthView extends StatelessWidget {
  const CalendarMiniMonthView({
    super.key,
    required this.year,
    required this.month,
    required this.allEvents,
    required this.today,
    required this.colorScheme,
    required this.onMonthTap,
  });

  final int year;
  final int month;
  final List<CalendarEventModel> allEvents;
  final DateTime today;
  final ColorScheme colorScheme;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    final monthDate = DateTime(year, month);
    final monthLabel = DateFormat('MMMM', 'it_IT').format(monthDate);
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return GestureDetector(
      onTap: onMonthTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Row(
              children:
                  ['L', 'M', 'M', 'G', 'V', 'S', 'D']
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 7,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            Expanded(
              child: Column(
                children: List.generate(totalRows, (rowIndex) {
                  return Expanded(
                    child: Row(
                      children: List.generate(7, (colIndex) {
                        final cellIndex = rowIndex * 7 + colIndex;
                        final dayIndex = cellIndex - startOffset;
                        final isInMonth =
                            dayIndex >= 0 && dayIndex < daysInMonth;

                        if (!isInMonth) {
                          return const Expanded(child: SizedBox());
                        }

                        final day = DateTime(year, month, dayIndex + 1);
                        final isToday =
                            day.year == today.year &&
                            day.month == today.month &&
                            day.day == today.day;
                        final hasEvents = allEvents.any(
                          (e) => calendarEventOccursOn(e, day),
                        );

                        return Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration:
                                    isToday
                                        ? BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        )
                                        : null,
                                alignment: Alignment.center,
                                child: Text(
                                  '${dayIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color:
                                        isToday
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                    fontWeight:
                                        isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (hasEvents && !isToday)
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
