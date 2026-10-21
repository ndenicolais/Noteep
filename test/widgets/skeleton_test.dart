import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/providers/settings/ui_provider.dart';
import 'package:noteep/screens/home/notes_skeleton.dart';
import 'package:noteep/widgets/shared/fade_switcher.dart';
import 'package:noteep/widgets/shared/skeleton.dart';

Widget _app(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('SkeletonPulse', () {
    testWidgets('is announced as a single loading node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(const ListSkeleton()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.bySemanticsLabel('Caricamento…'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('pulses, unless animations are disabled', (tester) async {
      await tester.pumpWidget(_app(const ListSkeleton()));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(
        _app(const ListSkeleton(), disableAnimations: true),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  testWidgets('NotesSkeleton renders grid and list without overflow', (
    tester,
  ) async {
    for (final layout in HomeLayout.values) {
      await tester.pumpWidget(
        _app(NotesSkeleton(layout: layout), disableAnimations: true),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(SkeletonBox), findsWidgets);
    }
  });

  group('FadeSwitcher', () {
    testWidgets('cross-fades on key change and then drops the old child', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const FadeSwitcher(child: Text('a', key: ValueKey('a')))),
      );
      await tester.pumpWidget(
        _app(const FadeSwitcher(child: Text('b', key: ValueKey('b')))),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('switches instantly when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const FadeSwitcher(child: Text('a', key: ValueKey('a'))),
          disableAnimations: true,
        ),
      );
      await tester.pumpWidget(
        _app(
          const FadeSwitcher(child: Text('b', key: ValueKey('b'))),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);
    });
  });
}
