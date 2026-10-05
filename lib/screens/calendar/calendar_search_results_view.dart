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
import 'calendar_event_editor_screen.dart';
import 'calendar_event_tile.dart';

/// List of events matching the current search query, sorted most-recent first.
class CalendarSearchResultsView extends StatelessWidget {
  const CalendarSearchResultsView({super.key, required this.events});

  final List<CalendarEventModel> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Nessun evento trovato',
              style: TextStyle(color: colorScheme.outline, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final sorted = [...events]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final event = sorted[i];
        final dayOfWeek = DateFormat('EEEE', 'it_IT').format(event.startTime);
        final dateStr = DateFormat(
          'd MMMM yyyy',
          'it_IT',
        ).format(event.startTime);
        final timeStr = formatEventTimeRange(event);

        return ListTile(
          leading: _buildLeading(context, event, colorScheme),
          title: Text(event.title.isEmpty ? '(senza titolo)' : event.title),
          subtitle: Text('$dayOfWeek, $dateStr • $timeStr'),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarEventEditorScreen(event: event),
                ),
              ),
        );
      },
    );
  }

  Widget _buildLeading(
    BuildContext context,
    CalendarEventModel event,
    ColorScheme colorScheme,
  ) {
    if (event.isBirthday) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.pink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.cake, color: Colors.pink, size: 22),
      );
    }
    if (event.isNameDay) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('d').format(event.startTime),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
              height: 1.1,
            ),
          ),
          Text(
            DateFormat('MMM', 'it_IT').format(event.startTime),
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onPrimaryContainer,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
