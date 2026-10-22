import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/widgets/shared/note_hero.dart';

import '../helpers/l10n.dart';

void main() {
  Widget app({bool disableAnimations = false}) {
    return MaterialApp(
      locale: testLocale,
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationsDelegates,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: child!,
          ),
      home: Scaffold(
        body: Builder(
          builder:
              (context) => Center(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => const NoteHero(
                                noteId: 'n1',
                                color: Colors.amber,
                                isPage: true,
                                child: Scaffold(body: Text('editor')),
                              ),
                        ),
                      ),
                  child: const NoteHero(
                    noteId: 'n1',
                    color: Colors.blue,
                    isPage: false,
                    child: SizedBox(
                      width: 120,
                      height: 80,
                      child: Card(child: Text('card')),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  /// The shuttle clips the page content with rounded corners.
  Finder inFlight() =>
      find.ancestor(of: find.text('editor'), matching: find.byType(ClipRRect));

  testWidgets('card grows into the editor and back without errors', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(inFlight(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(inFlight(), findsNothing);
    expect(find.text('editor'), findsOneWidget);

    Navigator.pop(tester.element(find.text('editor')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(inFlight(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no flight when animations are disabled', (tester) async {
    await tester.pumpWidget(app(disableAnimations: true));
    await tester.tap(find.text('card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(inFlight(), findsNothing);
  });

  test('tags match by note id regardless of color', () {
    expect(
      const NoteHeroTag('a', Colors.red),
      const NoteHeroTag('a', Colors.blue),
    );
    expect(
      const NoteHeroTag('a', Colors.red) == const NoteHeroTag('b', Colors.red),
      isFalse,
    );
  });
}
