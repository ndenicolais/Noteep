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

/// Chronological agenda ("Programma") view listing upcoming events grouped
/// by day, looking ahead a fixed number of days.
class CalendarScheduleView extends StatelessWidget {
  const CalendarScheduleView({super.key, required this.allEvents});

  final List<CalendarEventModel> allEvents;

  static const _lookaheadDays = 90;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entries = <MapEntry<DateTime, CalendarEventModel>>[];
    for (int d = 0; d < _lookaheadDays; d++) {
      final day = today.add(Duration(days: d));
      for (final event in allEvents) {
        if (calendarEventOccursOn(event, day)) {
          entries.add(MapEntry(day, event));
        }
      }
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Nessun evento in programma',
              style: TextStyle(color: colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final grouped = <DateTime, List<CalendarEventModel>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.key, () => []).add(entry.value);
    }
    final sortedDays = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (_, i) {
        final day = sortedDays[i];
        final dayEvents = grouped[day]!;
        final isToday = day.isAtSameMomentAs(today);
        final dayLabel =
            isToday ? 'Oggi' : DateFormat('EEEE, d MMMM', 'it_IT').format(day);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                dayLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isToday
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...dayEvents.map(
              (event) => CalendarEventListTile(
                event: event,
                dense: true,
                onTap: () => AppNav.openEvent(context, event),
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ],
        );
      },
    );
  }
}
