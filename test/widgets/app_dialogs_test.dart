import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/widgets/shared/app_dialogs.dart';

import '../helpers/l10n.dart';

void main() {
  late bool? result;

  setUp(() => result = null);

  Widget build({bool destructive = false}) {
    return MaterialApp(
      locale: testLocale,
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  result = await showAppConfirmDialog(
                    context,
                    title: 'Titolo',
                    message: 'Messaggio',
                    confirmLabel: 'Conferma',
                    destructive: destructive,
                  );
                },
                child: const Text('open'),
              ),
        ),
      ),
    );
  }

  testWidgets('confirm resolves to true', (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Titolo'), findsOneWidget);
    expect(find.text('Messaggio'), findsOneWidget);
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('cancel resolves to false', (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('barrier dismiss resolves to false', (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('destructive uses a filled confirm button', (tester) async {
    await tester.pumpWidget(build(destructive: true));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.text('Conferma'),
        matching: find.byType(FilledButton),
      ),
      findsOneWidget,
    );
  });
}
