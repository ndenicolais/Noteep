// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:timezone/timezone.dart' as tz;
import '../models/calendar_model.dart';
import 'recurrence.dart';

class IcsImportService {
  /// Parses an ICS string and returns a list of [CalendarEventModel].
  static List<CalendarEventModel> parseIcs(String icsContent) {
    // Unfold folded lines: a line that starts with SPACE or TAB is a
    // continuation of the previous line.
    final unfolded = icsContent.replaceAll(RegExp(r'\r\n[ \t]|\n[ \t]'), '');
    final lines = unfolded.split(RegExp(r'\r\n|\n'));

    final events = <CalendarEventModel>[];
    bool inEvent = false;
    final props = <String, String>{};
    final propParams = <String, String>{};
    // Same as propParams but preserving original case, since TZID values
    // (e.g. "America/New_York") are case-sensitive IANA names.
    final rawPropParams = <String, String>{};

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed == 'BEGIN:VEVENT') {
        inEvent = true;
        props.clear();
        propParams.clear();
        rawPropParams.clear();
      } else if (trimmed == 'END:VEVENT') {
        if (inEvent) {
          final event = _buildEvent(props, propParams, rawPropParams);
          if (event != null) events.add(event);
        }
        inEvent = false;
      } else if (inEvent && trimmed.isNotEmpty) {
        final colonIdx = trimmed.indexOf(':');
        if (colonIdx == -1) continue;

        final keyPart = trimmed.substring(0, colonIdx);
        final value = trimmed.substring(colonIdx + 1);

        final semiIdx = keyPart.indexOf(';');
        final baseKey =
            (semiIdx == -1 ? keyPart : keyPart.substring(0, semiIdx))
                .toUpperCase();
        final rawParamStr = semiIdx == -1 ? '' : keyPart.substring(semiIdx + 1);

        props[baseKey] = value;
        propParams[baseKey] = rawParamStr.toUpperCase();
        rawPropParams[baseKey] = rawParamStr;
      }
    }
    return events;
  }

  /// Extracts the TZID value (original case preserved) from a raw param
  /// string like "TZID=America/New_York" or "VALUE=DATE-TIME;TZID=Europe/Rome".
  static String? _extractTzid(String rawParamStr) {
    final match = RegExp(
      r'TZID=([^;:]+)',
      caseSensitive: false,
    ).firstMatch(rawParamStr);
    return match?.group(1);
  }

  static CalendarEventModel? _buildEvent(
    Map<String, String> props,
    Map<String, String> propParams,
    Map<String, String> rawPropParams,
  ) {
    final summary = _unescape(props['SUMMARY'] ?? '');
    if (summary.isEmpty) return null;

    final dtstartValue = props['DTSTART'];
    if (dtstartValue == null) return null;

    final dtstartParams = propParams['DTSTART'] ?? '';
    final isAllDay =
        dtstartParams.contains('VALUE=DATE') || dtstartValue.length == 8;
    final dtstartTzid = _extractTzid(rawPropParams['DTSTART'] ?? '');

    final startTime = _parseIcsDate(dtstartValue, isAllDay, tzid: dtstartTzid);
    if (startTime == null) return null;

    DateTime endTime;
    final dtendValue = props['DTEND'];
    if (dtendValue != null) {
      final dtendParams = propParams['DTEND'] ?? '';
      final endIsAllDay =
          dtendParams.contains('VALUE=DATE') || dtendValue.length == 8;
      final dtendTzid = _extractTzid(rawPropParams['DTEND'] ?? '');
      endTime =
          _parseIcsDate(dtendValue, endIsAllDay, tzid: dtendTzid) ??
          startTime.add(
            isAllDay ? const Duration(days: 1) : const Duration(hours: 1),
          );
    } else {
      endTime = startTime.add(
        isAllDay ? const Duration(days: 1) : const Duration(hours: 1),
      );
    }

    final uid = props['UID'];
    final description = _stripHtml(_unescape(props['DESCRIPTION'] ?? ''));

    final categoriesRaw = (props['CATEGORIES'] ?? '').toUpperCase();
    final isBirthday = categoriesRaw.contains('BIRTHDAY');

    // Birthdays from Google Calendar use RRULE:FREQ=YEARLY but we store them
    // as yearly recurring all-day events.
    RecurrenceType recurrence = RecurrenceType.none;
    final rrule = (props['RRULE'] ?? '').toUpperCase();
    if (rrule.contains('FREQ=YEARLY')) {
      recurrence = RecurrenceType.yearly;
    } else if (rrule.contains('FREQ=MONTHLY')) {
      recurrence = RecurrenceType.monthly;
    } else if (rrule.contains('FREQ=WEEKLY')) {
      recurrence = RecurrenceType.weekly;
    } else if (rrule.contains('FREQ=DAILY')) {
      recurrence = RecurrenceType.daily;
    }

    final recurrenceEndDate =
        recurrence == RecurrenceType.none
            ? null
            : _resolveRecurrenceEnd(rrule, recurrence, startTime);

    return CalendarEventModel(
      id: uid != null ? _sanitizeId(uid) : null,
      title: summary,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      isBirthday: isBirthday,
      recurrence: recurrence,
      recurrenceEndDate: recurrenceEndDate,
    );
  }

  /// Resolves an RRULE's UNTIL= or COUNT= clause into a concrete end date,
  /// so a bounded recurrence doesn't get imported as an infinite one.
  static DateTime? _resolveRecurrenceEnd(
    String rrule,
    RecurrenceType recurrence,
    DateTime startTime,
  ) {
    final untilMatch = RegExp(r'UNTIL=([^;]+)').firstMatch(rrule);
    if (untilMatch != null) {
      final untilValue = untilMatch.group(1)!;
      final isAllDayUntil = untilValue.length == 8;
      return _parseIcsDate(untilValue, isAllDayUntil);
    }

    final countMatch = RegExp(r'COUNT=(\d+)').firstMatch(rrule);
    if (countMatch != null) {
      final count = int.parse(countMatch.group(1)!);
      if (count <= 1) return startTime;
      final n = count - 1;
      switch (recurrence) {
        case RecurrenceType.daily:
          return startTime.add(Duration(days: n));
        case RecurrenceType.weekly:
          return startTime.add(Duration(days: n * 7));
        case RecurrenceType.monthly:
          return DateTime(startTime.year, startTime.month + n, startTime.day);
        case RecurrenceType.yearly:
          return DateTime(startTime.year + n, startTime.month, startTime.day);
        case RecurrenceType.none:
          return null;
      }
    }
    return null;
  }

  static DateTime? _parseIcsDate(String value, bool isAllDay, {String? tzid}) {
    try {
      if (isAllDay) {
        // Format: YYYYMMDD
        final y = int.parse(value.substring(0, 4));
        final m = int.parse(value.substring(4, 6));
        final d = int.parse(value.substring(6, 8));
        return DateTime(y, m, d);
      } else {
        // Format: YYYYMMDDTHHMMSSz or YYYYMMDDTHHMMSS
        final isUtc = value.endsWith('Z');
        final cleaned = value.replaceAll('Z', '');
        final y = int.parse(cleaned.substring(0, 4));
        final mo = int.parse(cleaned.substring(4, 6));
        final d = int.parse(cleaned.substring(6, 8));
        final h = int.parse(cleaned.substring(9, 11));
        final mi = int.parse(cleaned.substring(11, 13));
        final s = int.parse(cleaned.substring(13, 15));
        if (isUtc) {
          return DateTime.utc(y, mo, d, h, mi, s).toLocal();
        }
        if (tzid != null) {
          try {
            final location = tz.getLocation(tzid);
            return tz.TZDateTime(location, y, mo, d, h, mi, s).toLocal();
          } catch (_) {
            // Unknown/unavailable TZID — fall back to treating it as local.
          }
        }
        return DateTime(y, mo, d, h, mi, s);
      }
    } catch (_) {
      return null;
    }
  }

  /// Unescape ICS text escape sequences.
  static String _unescape(String s) {
    return s
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\N', '\n')
        .replaceAll(r'\,', ',')
        .replaceAll(r'\;', ';')
        .replaceAll(r'\\', r'\');
  }

  /// Strip HTML tags and convert <br> to newlines.
  static String _stripHtml(String s) {
    return s
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  /// Sanitize a UID string for use as a model ID.
  static String _sanitizeId(String uid) {
    return uid.replaceAll(RegExp(r'[^\w\-@.]'), '_');
  }
}
