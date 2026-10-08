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
import 'calendar_utils.dart';

/// Multi-day agenda view used for the "Settimana" and "7 giorni" modes.
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
    final now = DateTime.now();
    final endDay = startDay.add(Duration(days: dayCount - 1));
    final days = List.generate(
      dayCount,
      (i) => startDay.add(Duration(days: i)),
    );
    final rangeLabel =
        '${DateFormat('d MMM', 'it_IT').format(startDay)} – ${DateFormat('d MMM yyyy', 'it_IT').format(endDay)}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                    fontSize: 14,
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
        Row(
          children:
              days.map((day) {
                final isToday =
                    day.year == now.year &&
                    day.month == now.month &&
                    day.day == now.day;
                final dayName = DateFormat('E', 'it_IT').format(day);
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration:
                            isToday
                                ? BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                )
                                : null,
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color:
                                isToday
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                days.map((day) {
                  final dayEvents =
                      allEvents
                          .where((e) => calendarEventOccursOn(e, day))
                          .toList()
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.35,
                            ),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: dayEvents.length,
                        itemBuilder: (_, i) {
                          final event = dayEvents[i];
                          return GestureDetector(
                            onTap: () => AppNav.openEvent(context, event),
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    event.isBirthday
                                        ? Colors.lightBlue.shade600
                                        : event.isNameDay
                                        ? Colors.lime.shade600
                                        : colorScheme.primary.withValues(
                                          alpha: 0.85,
                                        ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                event.title.isEmpty
                                    ? '(senza titolo)'
                                    : event.title,
                                style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      event.isBirthday
                                          ? Colors.white
                                          : colorScheme.onPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
