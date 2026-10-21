import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/notification_target.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/models/task_model.dart';

void main() {
  group('NotificationTarget payload', () {
    test('encode/parse round-trips every type', () {
      for (final t in [
        const NotificationTarget.note('n1'),
        const NotificationTarget.task('t-1'),
        const NotificationTarget.event('e:with:colons'),
      ]) {
        expect(NotificationTarget.parse(t.encode()), t);
      }
    });

    test('malformed or legacy payloads parse to null', () {
      for (final p in [null, '', 'note', 'note:', ':id', 'banana:id']) {
        expect(NotificationTarget.parse(p), isNull, reason: '$p');
      }
    });
  });

  group('NotificationTarget.resolve', () {
    final note = NoteModel(id: 'n1');
    final trashed = NoteModel(id: 'n2', deletedAt: DateTime(2026));
    final task = TaskModel(id: 't1');
    final event = CalendarEventModel(
      id: 'e1',
      startTime: DateTime(2026),
      endTime: DateTime(2026),
    );

    Object? resolve(NotificationTarget t) =>
        t.resolve(notes: [note, trashed], tasks: [task], events: [event]);

    test('finds the item of the matching type', () {
      expect(resolve(const NotificationTarget.note('n1')), same(note));
      expect(resolve(const NotificationTarget.task('t1')), same(task));
      expect(resolve(const NotificationTarget.event('e1')), same(event));
    });

    test('ignores trashed, missing and other-type items', () {
      expect(resolve(const NotificationTarget.note('n2')), isNull);
      expect(resolve(const NotificationTarget.note('nope')), isNull);
      expect(resolve(const NotificationTarget.task('n1')), isNull);
    });
  });
}
