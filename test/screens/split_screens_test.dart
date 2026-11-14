// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:noteep/models/calendar_model.dart';
import 'package:noteep/models/task_model.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:noteep/screens/auth/login_validators.dart';
import 'package:noteep/screens/calendar/calendar_event_details_section.dart';
import 'package:noteep/screens/tasks/task_sorting.dart';
import 'package:noteep/utils/recurrence.dart';
import 'package:noteep/widgets/shared/app_dialogs.dart';

import '../helpers/l10n.dart';

/// Logic and widgets extracted from the former monolithic screens.
void main() {
  group('login validators', () {
    test('email', () {
      expect(validateEmail(itL10n, null), isNotNull);
      expect(validateEmail(itL10n, '   '), 'Inserisci la tua email.');
      expect(validateEmail(itL10n, 'nope'), 'Formato email non valido.');
      expect(validateEmail(itL10n, ' a@b.it '), isNull);
    });

    test('password and confirmation', () {
      expect(validatePassword(itL10n, ''), 'Inserisci la password.');
      expect(validatePassword(itL10n, '12345'), 'Minimo 6 caratteri.');
      expect(validatePassword(itL10n, '123456'), isNull);
      expect(validatePasswordConfirmation(itL10n, 'abc', 'abd'), isNotNull);
      expect(validatePasswordConfirmation(itL10n, 'abc', 'abc'), isNull);
    });
  });

  group('sortTasksForDisplay', () {
    TaskModel t(String id, int created, {bool done = false, int? updated}) =>
        TaskModel(
          id: id,
          isCompleted: done,
          createdAt: DateTime(2026, 1, created),
          updatedAt: DateTime(2026, 1, updated ?? created),
        );

    final tasks = [
      t('a', 1),
      t('b', 3, done: true),
      t('c', 2, updated: 9),
      t('d', 4, done: true),
    ];
    List<String> ids(List<TaskModel> l) => [for (final x in l) x.id];

    test('splits active/completed and orders each group', () {
      final newest = sortTasksForDisplay(tasks, SortOrder.createdNewest);
      expect(ids(newest.active), ['c', 'a']);
      expect(ids(newest.completed), ['d', 'b']);

      final oldest = sortTasksForDisplay(tasks, SortOrder.createdOldest);
      expect(ids(oldest.active), ['a', 'c']);

      final modified = sortTasksForDisplay(tasks, SortOrder.modifiedNewest);
      expect(ids(modified.active), ['c', 'a']);
    });

    test('puts pinned tasks first in each group', () {
      final withPins = [
        t('a', 1),
        t('b', 2).copyWith(isPinned: true),
        t('c', 3),
        t('d', 4, done: true),
        t('e', 5, done: true).copyWith(isPinned: true),
      ];
      final sorted = sortTasksForDisplay(withPins, SortOrder.createdOldest);
      expect(ids(sorted.active), ['b', 'a', 'c']);
      expect(ids(sorted.completed), ['e', 'd']);
    });

    test('does not mutate the input', () {
      sortTasksForDisplay(tasks, SortOrder.createdNewest);
      expect(ids(tasks), ['a', 'b', 'c', 'd']);
    });

    test('groupTasksByDay splits by due day, undated last', () {
      TaskModel due(String id, DateTime? d, {bool pinned = false}) =>
          TaskModel(id: id, dueDate: d, isPinned: pinned);
      final groups = groupTasksByDay([
        due('none', null),
        due('late', DateTime(2026, 3, 2, 18)),
        due('day', DateTime(2026, 3, 2)),
        due('first', DateTime(2026, 3, 1, 9)),
        due('early', DateTime(2026, 3, 2, 8)),
        due('pin', DateTime(2026, 3, 2), pinned: true),
      ]);
      expect(
        [for (final g in groups) g.day],
        [DateTime(2026, 3, 1), DateTime(2026, 3, 2), null],
      );
      expect(
        [for (final g in groups) ids(g.tasks)],
        [
          ['first'],
          ['pin', 'early', 'late', 'day'],
          ['none'],
        ],
      );
    });
  });

  group('showAppTextInputDialog', () {
    late String? result;

    Future<void> open(WidgetTester tester) async {
      result = 'unset';
      await tester.pumpWidget(
        MaterialApp(
          locale: testLocale,
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationsDelegates,
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () async {
                    result = await showAppTextInputDialog(
                      context,
                      title: 'Nuovo Elenco',
                      hintText: 'Nome elenco',
                      confirmLabel: 'Crea',
                    );
                  },
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('returns the trimmed text on confirm or submit', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), '  Spesa  ');
      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();
      expect(result, 'Spesa');

      await open(tester);
      await tester.enterText(find.byType(TextField), 'Lavoro');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, 'Lavoro');
    });

    testWidgets('empty text or cancel resolve to null', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();
      expect(result, isNull);

      await open(tester);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('CalendarEventDetailsSection', () {
    setUpAll(() => initializeDateFormatting('it'));

    testWidgets('toggles and recurrence report the updated event', (
      tester,
    ) async {
      var event = CalendarEventModel(
        startTime: DateTime(2026, 10, 21, 9),
        endTime: DateTime(2026, 10, 21, 10),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: testLocale,
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, setState) => SingleChildScrollView(
                    child: CalendarEventDetailsSection(
                      event: event,
                      allDayAlertMinutes: 9 * 60,
                      dayBeforeAlertMinutes: 9 * 60,
                      locationField: const SizedBox.shrink(),
                      onPickDateTime: () {},
                      onPickEndTime: () {},
                      onClearEndTime:
                          () => setState(
                            () =>
                                event = event.copyWith(
                                  endTime: event.startTime,
                                ),
                          ),
                      onChanged: (e) => setState(() => event = e),
                    ),
                  ),
            ),
          ),
        ),
      );
      expect(find.text('09:00 – 10:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);

      await tester.tap(find.byTooltip('Rimuovi ora di fine'));
      await tester.pump();
      expect(event.hasEndTime, isFalse);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('Nessuna'), findsOneWidget);

      await tester.tap(find.text('Compleanno'));
      await tester.pump();
      expect(event.isBirthday, isTrue);
      // A birthday becomes a yearly all-day event alerting the day before
      // and on the day, shown in its color (banner + checkbox).
      expect(event.isAllDay, isTrue);
      expect(event.recurrence, RecurrenceType.yearly);
      expect(event.alertDayBefore && event.alertSameDay, isTrue);
      expect(find.text('Compleanno'), findsNWidgets(2));
      // Subtitle switches too, and the end time row is hidden.
      expect(find.text('Tutto il giorno'), findsNWidgets(2));
      expect(find.text('Ora di fine'), findsNothing);

      // Name day replaces birthday.
      await tester.ensureVisible(find.text('Onomastico'));
      await tester.tap(find.text('Onomastico'));
      await tester.pump();
      expect(event.isNameDay, isTrue);
      expect(event.isBirthday, isFalse);

      // Back to a timed event: starts without an end.
      await tester.ensureVisible(find.text('Tutto il giorno').last);
      await tester.tap(find.text('Tutto il giorno').last);
      await tester.pump();
      expect(event.isAllDay, isFalse);
      expect(event.hasEndTime, isFalse);

      await tester.ensureVisible(find.text('Ricorrenza'));
      await tester.tap(find.text('Ricorrenza'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(RecurrenceType.weekly.label(itL10n)));
      await tester.pumpAndSettle();
      expect(event.recurrence, RecurrenceType.weekly);
    });
  });
}
