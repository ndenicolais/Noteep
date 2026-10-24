import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/routing/home_widget_action.dart';

void main() {
  test('uri/parse round-trips every action', () {
    for (final a in HomeWidgetAction.values) {
      expect(HomeWidgetAction.parse(a.uri), a);
    }
  });

  test('matches the URIs the Android widgets launch with', () {
    // Keep in sync with QuickActionWidgets.kt.
    expect(
      HomeWidgetAction.parse(Uri.parse('noteep://new/note')),
      HomeWidgetAction.newNote,
    );
    expect(
      HomeWidgetAction.parse(Uri.parse('noteep://new/task')),
      HomeWidgetAction.newTask,
    );
    expect(
      HomeWidgetAction.parse(Uri.parse('noteep://new/event')),
      HomeWidgetAction.newEvent,
    );
  });

  test('missing or unknown URIs parse to null', () {
    for (final u in [
      null,
      Uri.parse(''),
      Uri.parse('noteep://new'),
      Uri.parse('noteep://new/'),
      Uri.parse('noteep://new/banana'),
      Uri.parse('noteep://new/note/extra'),
      Uri.parse('noteep://open/note'),
      Uri.parse('https://new/note'),
    ]) {
      expect(HomeWidgetAction.parse(u), isNull, reason: '$u');
    }
  });
}
