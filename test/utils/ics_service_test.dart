// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/screens/calendar/calendar_utils.dart';
import 'package:noteep/utils/ics_export_service.dart';
import 'package:noteep/utils/ics_import_service.dart';
import 'package:noteep/utils/recurrence.dart';
import 'package:timezone/data/latest.dart' as tz_data;

String _ics(List<String> eventLines) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'BEGIN:VEVENT',
  ...eventLines,
  'END:VEVENT',
  'END:VCALENDAR',
].join('\r\n');

CalendarEventModel _single(List<String> eventLines) {
  final events = IcsImportService.parseIcs(_ics(eventLines));
  expect(events, hasLength(1));
  return events.single;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

void main() {
  setUpAll(tz_data.initializeTimeZones);

  group('IcsImportService.parseIcs', () {
    test('parses an all-day event', () {
      final e = _single([
        'UID:abc-123',
        'SUMMARY:Ferie',
        'DTSTART;VALUE=DATE:20260810',
        'DTEND;VALUE=DATE:20260811',
      ]);
      expect(e.id, 'abc-123');
      expect(e.title, 'Ferie');
      expect(e.isAllDay, isTrue);
      expect(e.startTime, DateTime(2026, 8, 10));
      expect(e.endTime, DateTime(2026, 8, 11));
      expect(e.recurrence, RecurrenceType.none);
    });

    test('converts UTC times to local', () {
      final e = _single([
        'SUMMARY:Call',
        'DTSTART:20260115T090000Z',
        'DTEND:20260115T100000Z',
      ]);
      expect(e.isAllDay, isFalse);
      expect(e.startTime, DateTime.utc(2026, 1, 15, 9).toLocal());
      expect(e.endTime, DateTime.utc(2026, 1, 15, 10).toLocal());
    });

    test('honours TZID on DTSTART', () {
      final e = _single([
        'SUMMARY:NY meeting',
        'DTSTART;TZID=America/New_York:20260115T090000',
      ]);
      // 09:00 EST (UTC-5) is 14:00 UTC.
      expect(e.startTime, DateTime.utc(2026, 1, 15, 14).toLocal());
      expect(e.startTime.isUtc, isFalse);
    });

    test('defaults the end to +1h (timed) or +1 day (all-day)', () {
      final timed = _single(['SUMMARY:A', 'DTSTART:20260115T090000']);
      expect(timed.endTime, DateTime(2026, 1, 15, 10));
      final allDay = _single(['SUMMARY:B', 'DTSTART;VALUE=DATE:20260115']);
      expect(allDay.endTime, DateTime(2026, 1, 16));
    });

    test('skips events without summary or with an invalid start', () {
      expect(
        IcsImportService.parseIcs(_ics(['DTSTART:20260115T090000'])),
        isEmpty,
      );
      expect(
        IcsImportService.parseIcs(_ics(['SUMMARY:X', 'DTSTART:boh'])),
        isEmpty,
      );
      expect(IcsImportService.parseIcs(_ics(['SUMMARY:X'])), isEmpty);
    });

    test('unfolds continuation lines', () {
      final e = _single([
        'SUMMARY:Riunione di',
        '  progetto',
        'DTSTART;VALUE=DATE:20260115',
      ]);
      expect(e.title, 'Riunione di progetto');
    });

    test('unescapes text, including an escaped backslash before n', () {
      final e = _single([
        r'SUMMARY:Pane\, latte\; uova',
        r'DESCRIPTION:riga 1\nriga 2 C:\\new',
        'DTSTART;VALUE=DATE:20260115',
      ]);
      expect(e.title, 'Pane, latte; uova');
      expect(e.description, 'riga 1\nriga 2 C:\\new');
    });

    test('strips HTML from the description', () {
      final e = _single([
        'SUMMARY:X',
        'DESCRIPTION:<b>uno</b><br>due',
        'DTSTART;VALUE=DATE:20260115',
      ]);
      expect(e.description, 'uno\ndue');
    });

    test('flags birthdays from CATEGORIES', () {
      final e = _single([
        'SUMMARY:Mario',
        'CATEGORIES:BIRTHDAY',
        'DTSTART;VALUE=DATE:19900501',
        'RRULE:FREQ=YEARLY',
      ]);
      expect(e.isBirthday, isTrue);
      expect(e.recurrence, RecurrenceType.yearly);
      expect(e.recurrenceEndDate, isNull);
    });

    test('maps every RRULE frequency', () {
      const map = {
        'DAILY': RecurrenceType.daily,
        'WEEKLY': RecurrenceType.weekly,
        'MONTHLY': RecurrenceType.monthly,
        'YEARLY': RecurrenceType.yearly,
      };
      map.forEach((freq, type) {
        final e = _single([
          'SUMMARY:X',
          'DTSTART;VALUE=DATE:20260115',
          'RRULE:FREQ=$freq',
        ]);
        expect(e.recurrence, type, reason: freq);
      });
    });

    test('resolves UNTIL into an end date', () {
      final e = _single([
        'SUMMARY:X',
        'DTSTART;VALUE=DATE:20260115',
        'RRULE:FREQ=WEEKLY;UNTIL=20260312',
      ]);
      expect(e.recurrenceEndDate, DateTime(2026, 3, 12));
    });

    test('resolves COUNT into the date of the last occurrence', () {
      DateTime? endFor(String freq, int count) =>
          _single([
            'SUMMARY:X',
            'DTSTART;VALUE=DATE:20260131',
            'RRULE:FREQ=$freq;COUNT=$count',
          ]).recurrenceEndDate;

      expect(endFor('DAILY', 1), DateTime(2026, 1, 31));
      expect(endFor('DAILY', 3), DateTime(2026, 2, 2));
      expect(endFor('WEEKLY', 3), DateTime(2026, 2, 14));
      expect(endFor('YEARLY', 3), DateTime(2028, 1, 31));
    });

    test('COUNT keeps the last occurrence across a DST change', () {
      // Starts at local midnight; the range crosses the end of daylight
      // saving time in zones that observe it (last Sunday of October in
      // Europe, first Sunday of November in the US).
      final e = _single([
        'SUMMARY:X',
        'DTSTART;VALUE=DATE:20261020',
        'RRULE:FREQ=DAILY;COUNT=20',
      ]);
      expect(_day(e.recurrenceEndDate!), DateTime(2026, 11, 8));
      expect(calendarEventOccursOn(e, DateTime(2026, 11, 8)), isTrue);
      expect(calendarEventOccursOn(e, DateTime(2026, 11, 9)), isFalse);

      final w = _single([
        'SUMMARY:X',
        'DTSTART;VALUE=DATE:20261013',
        'RRULE:FREQ=WEEKLY;COUNT=5',
      ]);
      expect(_day(w.recurrenceEndDate!), DateTime(2026, 11, 10));
    });

    test('parses several events and ignores lines outside VEVENT', () {
      const ics =
          'BEGIN:VCALENDAR\r\n'
          'SUMMARY:fuori\r\n'
          'BEGIN:VEVENT\r\nSUMMARY:Uno\r\nDTSTART;VALUE=DATE:20260101\r\n'
          'END:VEVENT\r\n'
          'BEGIN:VEVENT\nSUMMARY:Due\nDTSTART;VALUE=DATE:20260102\n'
          'END:VEVENT\n'
          'END:VCALENDAR';
      final events = IcsImportService.parseIcs(ics);
      expect(events.map((e) => e.title), ['Uno', 'Due']);
    });
  });

  group('IcsExportService.generateIcs', () {
    test('writes all-day dates and an RRULE', () {
      final ics = IcsExportService.generateIcs([
        CalendarEventModel(
          id: 'id-1',
          title: 'Compleanno',
          startTime: DateTime(2026, 5, 1),
          endTime: DateTime(2026, 5, 2),
          isAllDay: true,
          isBirthday: true,
          recurrence: RecurrenceType.yearly,
        ),
      ]);
      expect(ics, contains('UID:id-1'));
      expect(ics, contains('DTSTART;VALUE=DATE:20260501'));
      expect(ics, contains('DTEND;VALUE=DATE:20260502'));
      expect(ics, contains('RRULE:FREQ=YEARLY'));
      expect(ics, contains('CATEGORIES:BIRTHDAY'));
    });

    test('uses a placeholder title for untitled events', () {
      final ics = IcsExportService.generateIcs([
        CalendarEventModel(
          startTime: DateTime(2026, 5, 1),
          endTime: DateTime(2026, 5, 2),
          isAllDay: true,
        ),
      ]);
      expect(ics, contains('SUMMARY:(senza titolo)'));
    });

    test('writes timed events in UTC', () {
      final start = DateTime(2026, 1, 15, 9, 30);
      final ics = IcsExportService.generateIcs([
        CalendarEventModel(
          title: 'X',
          startTime: start,
          endTime: start.add(const Duration(hours: 1)),
        ),
      ]);
      final u = start.toUtc();
      final stamp =
          '${u.year}${'${u.month}'.padLeft(2, '0')}'
          '${'${u.day}'.padLeft(2, '0')}T'
          '${'${u.hour}'.padLeft(2, '0')}${'${u.minute}'.padLeft(2, '0')}00Z';
      expect(ics, contains('DTSTART:$stamp'));
    });
  });

  group('ICS round trip', () {
    CalendarEventModel roundTrip(CalendarEventModel e) {
      final events = IcsImportService.parseIcs(
        IcsExportService.generateIcs([e]),
      );
      expect(events, hasLength(1));
      return events.single;
    }

    test('preserves fields and special characters', () {
      final original = CalendarEventModel(
        id: 'rt-1',
        title: r'Spesa: pane, latte; C:\new',
        description: 'riga 1\nriga 2',
        startTime: DateTime(2026, 3, 10, 18, 30),
        endTime: DateTime(2026, 3, 10, 19, 30),
        recurrence: RecurrenceType.weekly,
      );
      final back = roundTrip(original);
      expect(back.id, original.id);
      expect(back.title, original.title);
      expect(back.description, original.description);
      expect(back.startTime, original.startTime);
      expect(back.endTime, original.endTime);
      expect(back.isAllDay, isFalse);
      expect(back.recurrence, RecurrenceType.weekly);
    });

    test('preserves the recurrence end date of all-day events', () {
      final back = roundTrip(
        CalendarEventModel(
          title: 'Corso',
          startTime: DateTime(2026, 3, 2),
          endTime: DateTime(2026, 3, 3),
          isAllDay: true,
          recurrence: RecurrenceType.weekly,
          recurrenceEndDate: DateTime(2026, 5, 25),
        ),
      );
      expect(back.recurrenceEndDate, isNotNull);
      expect(_day(back.recurrenceEndDate!), DateTime(2026, 5, 25));
    });

    test('preserves the recurrence end date of timed events', () {
      final back = roundTrip(
        CalendarEventModel(
          title: 'Palestra',
          startTime: DateTime(2026, 3, 2, 19),
          endTime: DateTime(2026, 3, 2, 20),
          recurrence: RecurrenceType.daily,
          recurrenceEndDate: DateTime(2026, 3, 20),
        ),
      );
      expect(back.recurrenceEndDate, isNotNull);
      expect(calendarEventOccursOn(back, DateTime(2026, 3, 20)), isTrue);
      expect(calendarEventOccursOn(back, DateTime(2026, 3, 21)), isFalse);
    });
  });
}
