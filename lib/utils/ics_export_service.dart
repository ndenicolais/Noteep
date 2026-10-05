// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../models/calendar_model.dart';
import 'recurrence.dart';

class IcsExportService {
  /// Generates an ICS (iCalendar) string from a list of [CalendarEventModel].
  static String generateIcs(List<CalendarEventModel> events) {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCALENDAR');
    buf.writeln('VERSION:2.0');
    buf.writeln('PRODID:-//Noteep//Noteep Calendar//IT');
    buf.writeln('CALSCALE:GREGORIAN');
    buf.writeln('METHOD:PUBLISH');

    for (final event in events) {
      buf.writeln('BEGIN:VEVENT');
      buf.writeln('UID:${event.id}');

      final now = DateTime.now().toUtc();
      buf.writeln('DTSTAMP:${_formatDateTimeUtc(now)}');

      if (event.isAllDay) {
        buf.writeln('DTSTART;VALUE=DATE:${_formatDate(event.startTime)}');
        buf.writeln('DTEND;VALUE=DATE:${_formatDate(event.endTime)}');
      } else {
        buf.writeln('DTSTART:${_formatDateTimeUtc(event.startTime.toUtc())}');
        buf.writeln('DTEND:${_formatDateTimeUtc(event.endTime.toUtc())}');
      }

      if (event.recurrence != RecurrenceType.none) {
        buf.writeln('RRULE:${_rrule(event.recurrence)}');
      }

      buf.writeln(
        'SUMMARY:${_escape(event.title.isEmpty ? '(senza titolo)' : event.title)}',
      );

      if (event.description.isNotEmpty) {
        buf.writeln('DESCRIPTION:${_escape(event.description)}');
      }

      if (event.isBirthday) {
        buf.writeln('CATEGORIES:BIRTHDAY');
      }

      buf.writeln('END:VEVENT');
    }

    buf.writeln('END:VCALENDAR');
    return buf.toString();
  }

  /// Formats a [DateTime] as `YYYYMMDDTHHMMSSz` (UTC).
  static String _formatDateTimeUtc(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$mo${d}T$h$mi${s}Z';
  }

  /// Formats a [DateTime] as `YYYYMMDD` (date-only, for all-day events).
  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y$mo$d';
  }

  /// Returns the RRULE string for a given [RecurrenceType].
  static String _rrule(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'FREQ=DAILY';
      case RecurrenceType.weekly:
        return 'FREQ=WEEKLY';
      case RecurrenceType.monthly:
        return 'FREQ=MONTHLY';
      case RecurrenceType.yearly:
        return 'FREQ=YEARLY';
      case RecurrenceType.none:
        return '';
    }
  }

  /// Escapes special characters in ICS text values.
  static String _escape(String s) {
    return s
        .replaceAll(r'\', r'\\')
        .replaceAll(',', r'\,')
        .replaceAll(';', r'\;')
        .replaceAll('\n', r'\n');
  }
}
