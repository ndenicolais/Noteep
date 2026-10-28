import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/constants/app_info.dart';
import 'package:noteep/core/constants/app_version.dart';
import 'package:noteep/screens/info_screen.dart';

import '../helpers/l10n.dart';

Future<void> _pump(WidgetTester tester, {Size size = const Size(400, 2000)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    const MaterialApp(
      locale: testLocale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
      home: InfoScreen(),
    ),
  );
}

void main() {
  testWidgets('shows identity, version, features, links and credits', (
    tester,
  ) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    expect(find.text('Noteep'), findsOneWidget);
    expect(find.text('Versione $appVersion'), findsOneWidget);
    expect(find.text('FUNZIONALITÀ'), findsOneWidget);
    expect(find.text('Codice sorgente'), findsOneWidget);
    expect(find.text('Realizzato da $developerName'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out without overflow on a narrow phone', (tester) async {
    await _pump(tester, size: const Size(320, 2400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the open source licenses page', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licenze open source'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
