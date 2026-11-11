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
import '../../models/calendar_model.dart';

/// Colors and icon of a calendar entry, shared by every calendar view so the
/// same kind of entry always looks the same (list cards, month and week chips).
class CalendarItemStyle {
  const CalendarItemStyle({
    required this.background,
    required this.foreground,
    this.icon,
    this.isDone = false,
  });

  final Color background;
  final Color foreground;
  final IconData? icon;

  /// A completed task: shown faded and struck through.
  final bool isDone;

  TextDecoration? get decoration => isDone ? TextDecoration.lineThrough : null;
}

final birthdayColor = Colors.lightBlue.shade600;
final nameDayColor = Colors.lime.shade600;

/// Tasks, birthdays, name days, all-day and timed events each get their own
/// color.
CalendarItemStyle calendarItemStyle(
  CalendarEventModel item,
  ColorScheme colorScheme,
) {
  if (item is TaskCalendarEvent) {
    final done = item.task.isCompleted;
    return _style(
      Colors.green.shade600.withValues(alpha: done ? 0.55 : 1),
      done ? Icons.check_circle : Icons.radio_button_unchecked,
      isDone: done,
    );
  }
  if (item.isBirthday) return _style(birthdayColor, Icons.cake);
  if (item.isNameDay) return _style(nameDayColor, Icons.auto_awesome);
  if (item.isAllDay) return _style(Colors.deepPurple.shade300, null);
  return _style(colorScheme.primary, null);
}

CalendarItemStyle _style(Color bg, IconData? icon, {bool isDone = false}) {
  final opaque = bg.withValues(alpha: 1);
  return CalendarItemStyle(
    background: bg,
    foreground:
        ThemeData.estimateBrightnessForColor(opaque) == Brightness.dark
            ? Colors.white
            : Colors.black87,
    icon: icon,
    isDone: isDone,
  );
}
