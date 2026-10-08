// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import 'calendar_day_cell.dart';
import 'calendar_day_events_sheet.dart';
import 'calendar_utils.dart';

/// Classic month grid view of the calendar workspace.
class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.focusedMonth,
    required this.allEvents,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final List<CalendarEventModel> allEvents;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    final monthLabel = DateFormat('MMMM yyyy', 'it_IT').format(focusedMonth);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                onPressed: onPreviousMonth,
                tooltip: 'Mese precedente',
              ),
              Expanded(
                child: Text(
                  monthLabel,
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
                onPressed: onNextMonth,
                tooltip: 'Mese successivo',
              ),
            ],
          ),
        ),
        Row(
          children:
              ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              final cellHeight = constraints.maxHeight / totalRows;

              return Column(
                children: List.generate(totalRows, (rowIndex) {
                  return SizedBox(
                    height: cellHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(7, (colIndex) {
                        final cellIndex = rowIndex * 7 + colIndex;
                        final dayIndex = cellIndex - startOffset;
                        final isCurrentMonth =
                            dayIndex >= 0 && dayIndex < daysInMonth;

                        DateTime? day;
                        List<CalendarEventModel> dayEvents = [];
                        bool isToday = false;

                        if (isCurrentMonth) {
                          day = DateTime(year, month, dayIndex + 1);
                          dayEvents =
                              allEvents
                                  .where((e) => calendarEventOccursOn(e, day!))
                                  .toList();
                          isToday =
                              day.year == now.year &&
                              day.month == now.month &&
                              day.day == now.day;
                        }

                        return CalendarDayCell(
                          width: cellWidth,
                          height: cellHeight,
                          dayNumber: isCurrentMonth ? dayIndex + 1 : null,
                          events: dayEvents,
                          isToday: isToday,
                          isCurrentMonth: isCurrentMonth,
                          colorScheme: colorScheme,
                          onTap:
                              isCurrentMonth && day != null
                                  ? dayEvents.length == 1
                                      ? () => AppNav.openEvent(
                                        context,
                                        dayEvents.first,
                                      )
                                      : () => showDayEventsBottomSheet(
                                        context,
                                        day!,
                                        dayEvents,
                                      )
                                  : null,
                        );
                      }),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
