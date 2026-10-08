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
import 'calendar_event_tile.dart';
import 'calendar_utils.dart';

/// Single-day agenda view of the calendar workspace.
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
    final dayEvents =
        allEvents.where((e) => calendarEventOccursOn(e, day)).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'it_IT').format(day);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                onPressed: onPreviousDay,
                tooltip: 'Giorno precedente',
              ),
              Expanded(
                child: Text(
                  dateStr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isToday ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                onPressed: onNextDay,
                tooltip: 'Giorno successivo',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              dayEvents.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessun evento per questo giorno',
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: dayEvents.length,
                    itemBuilder: (_, i) {
                      final event = dayEvents[i];
                      return CalendarEventListTile(
                        event: event,
                        onTap: () => AppNav.openEvent(context, event),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
