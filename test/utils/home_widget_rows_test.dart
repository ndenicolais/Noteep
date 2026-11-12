import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/utils/home_widget_rows.dart';
import 'package:noteep/utils/recurrence.dart';

import '../helpers/l10n.dart';

void main() {
  final now = DateTime(2026, 11, 12, 9);

  List<Object?> titles(List<HomeWidgetRow> rows) => [
    for (final r in rows) r['t'] == 'h' ? '# ${r['label']}' : r['title'],
  ];

  group('noteRows', () {
    test('pinned first, then by last change; untitled and colored', () {
      final rows = noteRows([
        NoteModel(id: 'old', title: 'Old', updatedAt: DateTime(2026, 1, 1)),
        NoteModel(id: 'new', title: '', updatedAt: DateTime(2026, 11, 1)),
        NoteModel(
          id: 'pin',
          title: 'Pinned',
          isPinned: true,
          updatedAt: DateTime(2025, 1, 1),
          style: const NoteStyle(backgroundColor: Color(0xFFFFF9C4)),
        ),
      ], itL10n);

      expect(titles(rows), ['Pinned', itL10n.commonUntitled, 'Old']);
      expect(rows.first['color'], 0xFFFFF9C4);
      expect(rows.first['kind'], 'note');
      expect(rows[1].containsKey('color'), isFalse);
    });

    test('previews checklists and markdown as one plain line', () {
      final rows = noteRows([
        NoteModel(title: 'A', content: '# Title\n\n**bold** text'),
        NoteModel(
          title: 'B',
          type: NoteType.checklist,
          checklistItems: [
            ChecklistItem(text: 'milk', isChecked: true),
            ChecklistItem(text: 'eggs'),
          ],
          updatedAt: DateTime(2000),
        ),
      ], itL10n);

      expect(rows[0]['sub'], 'Title bold text');
      expect(rows[1]['sub'], '☑ milk ☐ eggs');
    });

    test('caps the list', () {
      final notes = [for (var i = 0; i < maxNoteRows + 5; i++) NoteModel()];
      expect(noteRows(notes, itL10n), hasLength(maxNoteRows));
    });
  });

  group('taskRows', () {
    test('groups tasks to do by day, undated last, done ones left out', () {
      final rows = taskRows(
        [
          TaskModel(title: 'Later', dueDate: DateTime(2026, 11, 20)),
          TaskModel(title: 'Done', isCompleted: true),
          TaskModel(title: 'Undated'),
          TaskModel(title: 'Overdue', dueDate: DateTime(2026, 11, 10)),
          TaskModel(title: 'Timed', dueDate: DateTime(2026, 11, 12, 15, 30)),
        ],
        itL10n,
        now,
      );

      expect(titles(rows), [
        '# Tuesday 10 November',
        'Overdue',
        '# Thursday 12 November',
        'Timed',
        '# Friday 20 November',
        'Later',
        '# ${itL10n.tasksNoDateSection}',
        'Undated',
      ]);
      expect(rows[0]['day'], '2026-11-10');
      expect(rows[3]['sub'], '15:30');
      expect(rows[6].containsKey('day'), isFalse);
    });
  });

  group('calendarRows', () {
    test('lists the next days\' events and tasks, all-day first', () {
      final rows = calendarRows(
        [
          CalendarEventModel(
            id: 'meet',
            title: 'Meeting',
            startTime: DateTime(2026, 11, 12, 10),
            endTime: DateTime(2026, 11, 12, 11),
          ),
          CalendarEventModel(
            id: 'bday',
            title: 'Anna',
            isAllDay: true,
            isBirthday: true,
            recurrence: RecurrenceType.yearly,
            startTime: DateTime(1990, 11, 13),
            endTime: DateTime(1990, 11, 13),
          ),
          CalendarEventModel(
            title: 'Past',
            startTime: DateTime(2026, 11, 11),
            endTime: DateTime(2026, 11, 11),
          ),
          CalendarEventModel(
            title: 'Too far',
            startTime: DateTime(2026, 12, 30),
            endTime: DateTime(2026, 12, 30),
          ),
        ],
        [
          TaskModel(id: 't1', title: 'Call', dueDate: DateTime(2026, 11, 12)),
          TaskModel(
            title: 'Done',
            isCompleted: true,
            dueDate: DateTime(2026, 11, 12),
          ),
        ],
        itL10n,
        now,
      );

      expect(titles(rows), [
        '# Thursday 12 November',
        'Call',
        'Meeting',
        '# Friday 13 November',
        'Anna',
      ]);
      expect(rows[1]['kind'], 'task');
      expect(rows[1]['id'], 't1');
      expect(rows[1]['sub'], itL10n.calendarAllDay);
      expect(rows[2]['kind'], 'event');
      expect(rows[2]['sub'], '10:00 – 11:00');
      expect(rows[4]['day'], '2026-11-13');
      expect(rows[4]['color'], isA<int>());
    });
  });
}
