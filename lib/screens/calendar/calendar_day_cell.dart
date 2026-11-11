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
import '../../models/calendar_model.dart';
import '../../theme/app_spacing.dart';
import 'calendar_event_style.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.width,
    required this.height,
    required this.dayNumber,
    required this.events,
    required this.isToday,
    required this.isCurrentMonth,
    required this.colorScheme,
    required this.onTap,
  });

  final double width;
  final double height;
  final int? dayNumber;
  final List<CalendarEventModel> events;
  final bool isToday;
  final bool isCurrentMonth;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  static const double _dayNumberHeight = 26.0;
  static const double _chipHeight = 15.0;
  static const double _chipSpacing = 2.0;
  static const double _topPad = 2.0;
  static const double _bottomPad = 2.0;

  @override
  Widget build(BuildContext context) {
    // How many event chips can fit in the remaining vertical space
    final availableForChips = height - _dayNumberHeight - _topPad - _bottomPad;
    final maxVisible = ((availableForChips + _chipSpacing) /
            (_chipHeight + _chipSpacing))
        .floor()
        .clamp(0, 5);

    final hasOverflow = events.length > maxVisible;
    final visibleCount =
        hasOverflow ? (maxVisible - 1).clamp(0, maxVisible) : maxVisible;
    final visibleEvents = events.take(visibleCount).toList();
    final overflowCount = events.length - visibleEvents.length;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 0.5,
            ),
          ),
          color:
              isCurrentMonth
                  ? null
                  : colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        child:
            isCurrentMonth
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Day number
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.xs,
                        right: AppSpacing.xs,
                        top: _topPad,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration:
                              isToday
                                  ? BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  )
                                  : null,
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color:
                                  isToday
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Event chips
                    ...visibleEvents.map(
                      (e) => _EventChip(event: e, colorScheme: colorScheme),
                    ),
                    // Overflow indicator
                    if (overflowCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.xs,
                          top: 1,
                        ),
                        child: Text(
                          '+$overflowCount',
                          style: TextStyle(
                            fontSize: 9,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.event, required this.colorScheme});

  final CalendarEventModel event;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(event, colorScheme);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: CalendarDayCell._chipSpacing / 2,
      ),
      child: Container(
        height: CalendarDayCell._chipHeight,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (style.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(style.icon, size: 8, color: style.foreground),
              ),
            Expanded(
              child: Text(
                event.title.isEmpty
                    ? context.l10n.commonUntitledParens
                    : event.title,
                style: TextStyle(
                  fontSize: 9,
                  color: style.foreground,
                  decoration: style.decoration,
                  decorationColor: style.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
