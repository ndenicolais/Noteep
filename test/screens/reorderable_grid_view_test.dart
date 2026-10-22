import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/models/note_model.dart';
import 'package:noteep/providers/notes_provider.dart';
import 'package:noteep/screens/home/home_layout_utils.dart';
import 'package:noteep/screens/home/reorderable_grid_view.dart';
import 'package:noteep/widgets/note_card.dart';

import '../helpers/l10n.dart';

void main() {
  group('masonryColumnLength', () {
    test('deals items round-robin across columns', () {
      expect(
        [for (var c = 0; c < 2; c++) masonryColumnLength(5, 2, c)],
        [3, 2],
      );
      expect(
        [for (var c = 0; c < 3; c++) masonryColumnLength(7, 3, c)],
        [3, 2, 2],
      );
    });

    test('columns beyond the item count are empty', () {
      expect(masonryColumnLength(1, 3, 1), 0);
      expect(masonryColumnLength(0, 2, 0), 0);
    });
  });

  group('ReorderableGridView', () {
    // 400 px wide → 2 columns (see gridColumns).
    Future<void> pump(
      WidgetTester tester,
      List<NoteModel> notes, {
      void Function(int, int)? onReorder,
    }) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesByIdProvider.overrideWithValue({
              for (final n in notes) n.id: n,
            }),
          ],
          child: MaterialApp(
            locale: testLocale,
            supportedLocales: testSupportedLocales,
            localizationsDelegates: testLocalizationsDelegates,
            home: Scaffold(
              body: ReorderableGridView(
                noteIds: [for (final n in notes) n.id],
                onReorder: onReorder ?? (_, __) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    final notes = [
      NoteModel(title: 'A', content: 'corta'),
      NoteModel(title: 'B', content: List.filled(8, 'riga lunga').join('\n')),
      NoteModel(title: 'C', content: 'corta'),
      NoteModel(title: 'D', content: 'corta'),
    ];

    testWidgets('cards keep their natural height in independent columns', (
      tester,
    ) async {
      await pump(tester, notes);
      expect(tester.takeException(), isNull);

      Rect card(String title) => tester.getRect(
        find.ancestor(of: find.text(title), matching: find.byType(NoteCard)),
      );

      // Round-robin: A, C left column; B, D right column.
      expect(card('A').left, lessThan(card('B').left));
      expect(card('C').left, card('A').left);
      expect(card('D').left, card('B').left);

      // Natural heights: the long note is taller than the short ones…
      expect(card('B').height, greaterThan(card('A').height * 2));
      // …and C sits right under A instead of waiting for B's row to end.
      expect(card('C').top, lessThan(card('B').bottom));
      expect(card('D').top, greaterThan(card('B').bottom));
    });

    testWidgets('dragging a card onto another reports global indices', (
      tester,
    ) async {
      final calls = <(int, int)>[];
      await pump(tester, notes, onReorder: (f, t) => calls.add((f, t)));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('A')),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getCenter(find.text('D')));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(calls, [(0, 3)]);
    });
  });
}
