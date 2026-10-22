// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/theme/app_theme.dart';
import 'package:noteep/widgets/shared/action_tile.dart';
import 'package:noteep/widgets/shared/app_dialogs.dart';
import 'package:noteep/widgets/shared/item_card.dart';
import 'package:noteep/widgets/shared/section_header.dart';
import 'package:noteep/widgets/shared/tag_chip.dart';

void main() {
  final cs = AppTheme.light.colorScheme;

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)),
  );

  group('SectionHeader', () {
    testWidgets('is a primary-colored header for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const SectionHeader('Dati', icon: Icons.storage));

      expect(
        tester.getSemantics(find.text('Dati')),
        matchesSemantics(label: 'Dati', isHeader: true),
      );
      expect(tester.widget<Text>(find.text('Dati')).style?.color, cs.primary);
      expect(tester.widget<Icon>(find.byIcon(Icons.storage)).color, cs.primary);
      handle.dispose();
    });

    testWidgets('muted uses the outline color', (tester) async {
      await pump(tester, const SectionHeader('Altro', muted: true));
      expect(tester.widget<Text>(find.text('Altro')).style?.color, cs.outline);
    });
  });

  group('ActionTile', () {
    testWidgets('shows icon, subtitle and chevron, and taps', (tester) async {
      var taps = 0;
      await pump(
        tester,
        ActionTile(
          icon: Icons.upload,
          title: 'Esporta',
          subtitle: 'Scarica un file',
          onTap: () => taps++,
        ),
      );
      expect(find.text('Scarica un file'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Icons.upload)).color, cs.primary);

      await tester.tap(find.text('Esporta'));
      expect(taps, 1);
    });

    testWidgets('destructive paints icon and title with the error color', (
      tester,
    ) async {
      await pump(
        tester,
        ActionTile(
          icon: Icons.delete,
          title: 'Cancella',
          destructive: true,
          onTap: () {},
        ),
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.delete)).color, cs.error);
      expect(tester.widget<Text>(find.text('Cancella')).style?.color, cs.error);
    });

    testWidgets('a custom trailing replaces the chevron', (tester) async {
      await pump(
        tester,
        ActionTile(
          title: 'Layout',
          trailing: const Icon(Icons.grid_view),
          onTap: () {},
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });
  });

  testWidgets('ItemCardList lays out tappable ItemCards', (tester) async {
    final tapped = <int>[];
    await pump(
      tester,
      ItemCardList(
        itemCount: 3,
        itemBuilder:
            (_, i) =>
                ItemCard(title: Text('Riga $i'), onTap: () => tapped.add(i)),
      ),
    );
    expect(find.byType(Card), findsNWidgets(3));
    await tester.tap(find.text('Riga 2'));
    expect(tapped, [2]);
    expect(
      tester.getTopLeft(find.text('Riga 1')).dy,
      greaterThan(tester.getBottomLeft(find.text('Riga 0')).dy),
    );
  });

  testWidgets('TagChip dense uses smaller text', (tester) async {
    await pump(
      tester,
      const Column(children: [TagChip('lavoro', dense: true), TagChip('Dart')]),
    );
    final dense = tester.widget<Text>(find.text('lavoro')).style!.fontSize!;
    final regular = tester.widget<Text>(find.text('Dart')).style!.fontSize!;
    expect(dense, lessThan(regular));
  });

  group('dialogs', () {
    Future<T?> open<T>(
      WidgetTester tester,
      Future<T> Function(BuildContext) show,
    ) async {
      T? result;
      await pump(
        tester,
        Builder(
          builder:
              (context) => TextButton(
                onPressed: () async => result = await show(context),
                child: const Text('apri'),
              ),
        ),
      );
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('text input starts from initialValue', (tester) async {
      String? result;
      await pump(
        tester,
        Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () async =>
                        result = await showAppTextInputDialog(
                          context,
                          title: 'Rinomina',
                          hintText: 'Nome',
                          confirmLabel: 'Salva',
                          initialValue: 'vecchio',
                        ),
                child: const Text('apri'),
              ),
        ),
      );
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.text('vecchio'), findsOneWidget);

      await tester.enterText(find.byType(TextField), ' nuovo ');
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();
      expect(result, 'nuovo');
    });

    testWidgets('message dialog closes on OK', (tester) async {
      await open<void>(
        tester,
        (context) =>
            showAppMessageDialog(context, title: 'Info', message: 'Presto'),
      );
      expect(find.text('Presto'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Presto'), findsNothing);
    });
  });
}
