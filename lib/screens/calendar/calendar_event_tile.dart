// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_spacing.dart';
import 'calendar_event_style.dart';

/// Formats the time range of an entry (a single time when it has no end),
/// or "Tutto il giorno" for all-day entries.
String formatEventTimeRange(AppLocalizations l, CalendarEventModel event) {
  if (event.isAllDay) return l.calendarAllDay;
  final start = DateFormat('HH:mm').format(event.startTime);
  if (!event.hasEndTime) return start;
  return '$start – ${DateFormat('HH:mm').format(event.endTime)}';
}

/// Subtitle of a list card: the time (none for all-day entries), the kind
/// when it is a birthday or a name day and the location, e.g.
/// "10:00 – 11:00 · Ufficio" or "Compleanno". Null when there is none. The
/// card color and icon already tell tasks and all-day entries apart.
String? calendarItemSubtitle(AppLocalizations l, CalendarEventModel event) {
  final parts = [
    if (!event.isAllDay) formatEventTimeRange(l, event),
    if (event.isBirthday)
      l.calendarBirthday
    else if (event.isNameDay)
      l.calendarNameDay,
    if (event.location.isNotEmpty) event.location,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// A colored card shared by the day, schedule and day-events-sheet calendar
/// views: the background tells the kind of entry (see [calendarItemStyle]),
/// with title and time range on top of it.
class CalendarEventListTile extends StatelessWidget {
  const CalendarEventListTile({
    super.key,
    required this.event,
    required this.onTap,
    this.dense = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xxs,
    ),
  });

  final CalendarEventModel event;
  final VoidCallback onTap;
  final bool dense;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = calendarItemStyle(event, Theme.of(context).colorScheme);
    final subtitle = calendarItemSubtitle(context.l10n, event);
    final festive = style.isFestive;
    final radius = BorderRadius.circular(festive ? 12 : 8);
    final double vertical =
        festive
            ? (dense ? AppSpacing.md : AppSpacing.lg)
            : (dense ? AppSpacing.sm : AppSpacing.md);
    return Padding(
      padding: padding,
      child: Material(
        color: festive ? Colors.transparent : style.background,
        borderRadius: radius,
        clipBehavior: festive ? Clip.antiAlias : Clip.none,
        child: Ink(
          decoration:
              festive
                  ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [style.background, style.festiveEnd!],
                    ),
                  )
                  : null,
          child: CustomPaint(
            painter:
                festive
                    ? _ConfettiPainter(
                      seed: event.title.hashCode,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      accent: style.accent,
                    )
                    : null,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: vertical,
                ),
                child: _content(context, style, subtitle, festive),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    CalendarItemStyle style,
    String? subtitle,
    bool festive,
  ) {
    return Row(
      children: [
        if (style.icon != null && festive) ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.foreground.withValues(alpha: 0.15),
            ),
            child: Icon(style.icon, size: 20, color: style.foreground),
          ),
          const SizedBox(width: AppSpacing.md),
        ] else if (style.icon != null) ...[
          Icon(style.icon, size: 18, color: style.foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title.isEmpty
                    ? context.l10n.commonUntitledParens
                    : event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.foreground,
                  fontSize: festive ? 16 : null,
                  fontWeight: festive ? FontWeight.w700 : FontWeight.w600,
                  decoration: style.decoration,
                  decorationColor: style.foreground,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: style.foreground.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Scattered confetti (dots and short strips) behind birthday and name day
/// cards. Positions come from [seed], so a card keeps the same pattern
/// across rebuilds.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.seed,
    required this.isDark,
    required this.accent,
  });

  final int seed;
  final bool isDark;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final alpha = isDark ? 0.35 : 0.5;
    final colors =
        [
          accent,
          Colors.pink.shade300,
          Colors.amber.shade600,
          Colors.purple.shade300,
          Colors.teal.shade300,
        ].map((c) => c.withValues(alpha: alpha)).toList();
    final paint = Paint()..style = PaintingStyle.fill;
    final count = (size.width / 18).round().clamp(8, 40);
    for (var i = 0; i < count; i++) {
      paint.color = colors[rnd.nextInt(colors.length)];
      final center = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      if (rnd.nextBool()) {
        canvas.drawCircle(center, 1.5 + rnd.nextDouble() * 1.5, paint);
      } else {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rnd.nextDouble() * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -1.25, 8, 2.5),
            const Radius.circular(1),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.seed != seed || old.isDark != isDark || old.accent != accent;
}
