import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/widgets/shared/empty_state.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows the action button and runs onAction', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: Icons.cloud_off,
          message: 'Errore',
          actionLabel: 'Riprova',
          onAction: () => taps++,
        ),
      ),
    );

    expect(find.byWidgetPredicate((w) => w is FilledButton), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    expect(taps, 1);
  });

  testWidgets('hides the action button without a label', (tester) async {
    await tester.pumpWidget(
      wrap(EmptyState(icon: Icons.note, message: 'Vuoto', onAction: () {})),
    );

    // byType matches exact types only, and tonalIcon builds a subclass.
    expect(find.byWidgetPredicate((w) => w is FilledButton), findsNothing);
  });
}
