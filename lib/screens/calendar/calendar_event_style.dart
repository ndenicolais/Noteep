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
import '../../theme/app_colors.dart';

/// Colors and icon of a calendar entry, shared by every calendar view so the
/// same kind of entry always looks the same (list cards, month and week chips).
class CalendarItemStyle {
  const CalendarItemStyle({
    required this.background,
    required this.foreground,
    required this.accent,
    this.icon,
    this.isDone = false,
    this.festiveEnd,
  });

  /// Second gradient stop of birthdays and name days, whose list cards are
  /// larger and festive; null for every other kind.
  final Color? festiveEnd;

  bool get isFestive => festiveEnd != null;

  /// Card fill, taken from the note swatches of the current theme.
  final Color background;
  final Color foreground;

  /// Saturated tone of the same kind, for small markers and icons drawn on
  /// the plain surface (where a pastel fill would be barely visible).
  final Color accent;
  final IconData? icon;

  /// A completed task: shown faded and struck through.
  final bool isDone;

  TextDecoration? get decoration => isDone ? TextDecoration.lineThrough : null;
}

final birthdayColor = Colors.lightBlue.shade600;
final nameDayColor = Colors.orange.shade700;

/// Note swatches reused for calendar cards: a pastel fill in light theme and
/// a deep tone in dark theme, so calendar entries look like the notes.
typedef _Swatch = ({Color light, Color dark, Color accent});

final _Swatch _taskSwatch = (
  light: const Color(0xFFDCEDC8),
  dark: const Color(0xFF1B5E20),
  accent: Colors.green.shade600,
);
final _Swatch _birthdaySwatch = (
  light: const Color(0xFFB2EBF2),
  dark: const Color(0xFF1A237E),
  accent: birthdayColor,
);
final _Swatch _nameDaySwatch = (
  light: const Color(0xFFFFCCBC),
  dark: const Color(0xFFBF360C),
  accent: nameDayColor,
);
final _Swatch _allDaySwatch = (
  light: const Color(0xFFE1BEE7),
  dark: const Color(0xFF4A148C),
  accent: Colors.deepPurple.shade300,
);

/// Tasks, birthdays, name days, all-day and timed events each get their own
/// color; an event with a [CalendarEventModel.color] uses that one instead
/// (birthdays and name days keep their icon and festive gradient).
CalendarItemStyle calendarItemStyle(
  CalendarEventModel item,
  ColorScheme colorScheme,
) {
  final isDark = colorScheme.brightness == Brightness.dark;
  if (item is TaskCalendarEvent) {
    // The task icon, not a checkbox: tapping opens the task, it does not
    // toggle it. Completion shows as faded, struck-through text.
    return _style(
      _taskSwatch,
      isDark,
      Icons.task_alt,
      isDone: item.task.isCompleted,
    );
  }
  final custom = item.color;
  if (item.isBirthday) {
    return _style(
      custom != null ? _customSwatch(custom) : _birthdaySwatch,
      isDark,
      Icons.cake,
      festiveEnd: isDark ? const Color(0xFF4A148C) : const Color(0xFFF8BBD0),
    );
  }
  if (item.isNameDay) {
    return _style(
      custom != null ? _customSwatch(custom) : _nameDaySwatch,
      isDark,
      Icons.auto_awesome,
      festiveEnd: isDark ? const Color(0xFF880E4F) : const Color(0xFFFFF59D),
    );
  }
  if (custom != null) return _style(_customSwatch(custom), isDark, null);
  if (item.isAllDay) return _style(_allDaySwatch, isDark, null);
  final _Swatch timed = (
    light: const Color(0xFFFFF9C4),
    dark: const Color(0xFF37474F),
    accent: colorScheme.primary,
  );
  return _style(timed, isDark, null);
}

/// A user-picked event color: a note swatch maps to the swatch at the same
/// position in the other theme (pastel in light, deep tone in dark), so the
/// card follows the theme like the built-in kinds; any other color is used
/// as is. The accent is a mid tone of the color, visible on the surface.
_Swatch _customSwatch(Color color) {
  var i = AppColors.noteSwatchesLight.indexOf(color);
  if (i < 0) i = AppColors.noteSwatchesDark.indexOf(color);
  final light = i >= 0 ? AppColors.noteSwatchesLight[i] : color;
  final dark = i >= 0 ? AppColors.noteSwatchesDark[i] : color;
  final hsl = HSLColor.fromColor(i >= 0 ? dark : color);
  final accent =
      hsl.saturation < 0.1
          ? Colors.blueGrey.shade400
          : hsl.withLightness(0.5).toColor();
  return (light: light, dark: dark, accent: accent);
}

CalendarItemStyle _style(
  _Swatch swatch,
  bool isDark,
  IconData? icon, {
  bool isDone = false,
  Color? festiveEnd,
}) {
  final opaque = isDark ? swatch.dark : swatch.light;
  return CalendarItemStyle(
    background: isDone ? opaque.withValues(alpha: 0.55) : opaque,
    foreground: AppColors.contrastingTextColor(opaque),
    accent: swatch.accent,
    icon: icon,
    isDone: isDone,
    festiveEnd: festiveEnd,
  );
}
