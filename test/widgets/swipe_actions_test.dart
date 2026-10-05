import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/widgets/shared/swipe_actions.dart';

void main() {
  late List<String> triggered;
  late bool visible;

  setUp(() {
    triggered = [];
    visible = true;
  });

  Widget build() {
    return MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder:
              (context, setState) => ListView(
                children: [
                  if (visible)
                    SwipeActions(
                      id: 'item',
                      start: SwipeAction(
                        icon: Icons.check,
                        label: 'Completa',
                        color: Colors.green,
                        removesItem: false,
                        onTriggered: () => triggered.add('start'),
                      ),
                      end: SwipeAction(
                        icon: Icons.delete,
                        label: 'Cestino',
                        color: Colors.red,
                        // Mirrors the optimistic notifier update that drops
                        // the item from the list right away.
                        onTriggered: () {
                          triggered.add('end');
                          setState(() => visible = false);
                        },
                      ),
                      child: const ListTile(title: Text('Row')),
                    ),
                ],
              ),
        ),
      ),
    );
  }

  testWidgets('swiping right runs start and keeps the row', (tester) async {
    await tester.pumpWidget(build());

    await tester.fling(find.text('Row'), const Offset(500, 0), 1000);
    await tester.pumpAndSettle();

    expect(triggered, ['start']);
    expect(find.text('Row'), findsOneWidget);
  });

  testWidgets('swiping left runs end and removes the row', (tester) async {
    await tester.pumpWidget(build());

    await tester.fling(find.text('Row'), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(triggered, ['end']);
    expect(find.text('Row'), findsNothing);
  });
}
