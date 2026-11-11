// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';

bool calendarEventOccursOn(CalendarEventModel event, DateTime day) =>
    event.occursOn(day);

/// Orders the entries of one day: all-day ones first, then by time of day
/// (not by the full start date, which for a recurring event is its first
/// occurrence), then by title.
int compareCalendarItems(CalendarEventModel a, CalendarEventModel b) {
  if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
  final byTime = minuteOfDay(a.startTime).compareTo(minuteOfDay(b.startTime));
  if (byTime != 0) return byTime;
  return a.title.toLowerCase().compareTo(b.title.toLowerCase());
}

int minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

/// The entries occurring on [day], sorted with [compareCalendarItems].
List<CalendarEventModel> calendarItemsOn(
  List<CalendarEventModel> items,
  DateTime day,
) =>
    items.where((e) => calendarEventOccursOn(e, day)).toList()
      ..sort(compareCalendarItems);

/// Monday-first weekday names in the UI language, formatted with [pattern]
/// (`E` short, `EEEEE` narrow) and capitalized.
List<String> weekdayLabels(String pattern) {
  final format = DateFormat(pattern);
  return [
    // 2024-01-01 is a Monday.
    for (var i = 0; i < 7; i++) format.format(DateTime(2024, 1, 1 + i)),
  ].map((d) => d[0].toUpperCase() + d.substring(1)).toList();
}
