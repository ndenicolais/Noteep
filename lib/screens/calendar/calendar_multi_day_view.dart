// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
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
        Row(
          children:
              days.map((day) {
                final isToday =
                    day.year == now.year &&
                    day.month == now.month &&
                    day.day == now.day;
                final dayName = DateFormat('E').format(day);
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: AppFontSizes.xs,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
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
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        itemCount: dayEvents.length,
                        itemBuilder: (_, i) {
                          final event = dayEvents[i];
                          return GestureDetector(
                            onTap: () => AppNav.openEvent(context, event),
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(
                                AppSpacing.xxs,
                                0,
                                AppSpacing.xxs,
                                AppSpacing.xxs,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: AppSpacing.xxs,
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
                                    ? context.l10n.commonUntitledParens
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
