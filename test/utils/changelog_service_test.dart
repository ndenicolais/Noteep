import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/core/constants/changelog.dart';
import 'package:noteep/utils/changelog_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _entries = [
  ChangelogEntry(version: '1.2.0', bullets: ['c']),
  ChangelogEntry(version: '1.1.0', bullets: ['b']),
  ChangelogEntry(version: '1.0.0', bullets: ['a']),
];

Future<SharedPreferences> _prefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<List<String>> _pendingVersions(
  SharedPreferences prefs,
  String current,
) async {
  final pending = await ChangelogService.pendingEntries(
    prefs,
    current,
    entries: _entries,
  );
  return pending.map((e) => e.version).toList();
}

void main() {
  test('fresh install shows nothing and records the current version', () async {
    final prefs = await _prefs();

    expect(await _pendingVersions(prefs, '1.2.0'), isEmpty);
    expect(await _pendingVersions(prefs, '1.2.0'), isEmpty);
  });

  test('same version shows nothing', () async {
    final prefs = await _prefs({'last_seen_changelog_version': '1.2.0'});

    expect(await _pendingVersions(prefs, '1.2.0'), isEmpty);
  });

  test('update shows only the entries newer than the last seen', () async {
    final prefs = await _prefs({'last_seen_changelog_version': '1.0.0'});

    expect(await _pendingVersions(prefs, '1.2.0'), ['1.2.0', '1.1.0']);
    expect(await _pendingVersions(prefs, '1.2.0'), isEmpty);
  });

  test('unknown last seen version shows the whole history', () async {
    final prefs = await _prefs({'last_seen_changelog_version': '0.9.0'});

    expect(await _pendingVersions(prefs, '1.2.0'), ['1.2.0', '1.1.0', '1.0.0']);
  });
}
