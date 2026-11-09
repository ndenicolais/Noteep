// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/screens/auth/login_widgets.dart';
import 'package:noteep/screens/privacy_policy_screen.dart';

import '../helpers/l10n.dart';

void main() {
  testWidgets('shows the age notice and opens the privacy policy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: testLocale,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: Scaffold(body: Center(child: LoginPrivacyNotice())),
      ),
    );

    expect(find.text(itL10n.loginPrivacyNotice), findsOneWidget);
    await tester.tap(find.text(itL10n.infoPrivacyOpen));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });
}
