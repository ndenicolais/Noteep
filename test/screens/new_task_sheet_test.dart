// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/screens/tasks/new_task_sheet.dart';
import '../helpers/l10n.dart';

void main() {
  /// Opens the sheet; the returned getter reads its result once closed.
  Future<NewTaskDraft? Function()> open(
    WidgetTester tester, {
    bool starred = false,
  }) async {
    NewTaskDraft? draft;
    await tester.pumpWidget(
      MaterialApp(
        locale: testLocale,
        supportedLocales: testSupportedLocales,
        localizationsDelegates: testLocalizationsDelegates,
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed: () async {
                  draft = await showNewTaskSheet(
                    context,
                    defaultTime: const TimeOfDay(hour: 9, minute: 0),
                    starred: starred,
                  );
                },
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => draft;
  }

  testWidgets('save is disabled until a title is typed', (tester) async {
    await open(tester);
    final save = find.widgetWithText(TextButton, itL10n.commonSave);
    expect(tester.widget<TextButton>(save).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.pump();
    expect(tester.widget<TextButton>(save).onPressed, isNotNull);
  });

  testWidgets('returns title, details and star', (tester) async {
    final result = await open(tester, starred: true);

    await tester.enterText(find.byType(TextField), ' Buy milk ');
    await tester.tap(find.byTooltip(itL10n.tasksAddDetails));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Two bottles');
    await tester.tap(find.widgetWithText(TextButton, itL10n.commonSave));
    await tester.pumpAndSettle();

    final draft = result();
    expect(draft, isNotNull);
    expect(draft!.title, 'Buy milk');
    expect(draft.description, 'Two bottles');
    expect(draft.due, isNull);
    expect(draft.starred, isTrue);
  });
}
