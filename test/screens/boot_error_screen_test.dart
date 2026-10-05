import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/screens/boot_error_screen.dart';

void main() {
  testWidgets('shows the error message and retries on tap', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      BootErrorApp(error: Exception('boom'), onRetry: () => retries++),
    );

    expect(find.text('Impossibile avviare Noteep'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Riprova'));
    expect(retries, 1);
  });
}
