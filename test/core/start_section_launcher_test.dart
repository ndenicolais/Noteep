import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/app_router.dart';
import 'package:noteep/core/routing/start_section_launcher.dart';
import 'package:noteep/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<List<RouteSettings>> pump(
    WidgetTester tester, {
    String? stored,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (stored != null) 'start_section': stored,
    });
    final prefs = await SharedPreferences.getInstance();
    final pushed = <RouteSettings>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          onGenerateRoute: (s) {
            pushed.add(s);
            return MaterialPageRoute(
              settings: s,
              builder: (_) => Scaffold(body: Text('opened ${s.name}')),
            );
          },
          home: const StartSectionLauncher(
            child: Scaffold(body: Text('notes')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return pushed;
  }

  testWidgets('stays on Notes by default', (tester) async {
    final pushed = await pump(tester);
    expect(pushed, isEmpty);
    expect(find.text('notes'), findsOneWidget);
  });

  testWidgets('opens the chosen section without a transition', (tester) async {
    final pushed = await pump(tester, stored: 'calendar');
    expect(pushed.single.name, AppRoutes.calendar);
    expect(pushed.single.arguments, same(AppRouter.noTransition));
    expect(find.text('opened ${AppRoutes.calendar}'), findsOneWidget);

    // Back returns to Notes.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('notes'), findsOneWidget);
  });

  testWidgets('opens Tasks when chosen', (tester) async {
    final pushed = await pump(tester, stored: 'tasks');
    expect(pushed.single.name, AppRoutes.tasks);
  });

  testWidgets('a stale stored value falls back to Notes', (tester) async {
    final pushed = await pump(tester, stored: 'trash');
    expect(pushed, isEmpty);
  });

  test('section routes honor the no-transition argument', () {
    final animated =
        AppRouter.onGenerateRoute(const RouteSettings(name: AppRoutes.tasks))
            as FadeThroughPageRoute;
    final instant =
        AppRouter.onGenerateRoute(
              const RouteSettings(
                name: AppRoutes.tasks,
                arguments: AppRouter.noTransition,
              ),
            )
            as FadeThroughPageRoute;
    expect(animated.transitionDuration, const Duration(milliseconds: 300));
    expect(instant.transitionDuration, Duration.zero);
    expect(instant.reverseTransitionDuration, isNot(Duration.zero));
  });
}
