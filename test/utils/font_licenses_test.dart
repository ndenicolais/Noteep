import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/utils/app_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled font has its OFL text on the licenses page', () async {
    AppBootstrap.registerFontLicenses();
    // A second call (Retry after a failed startup) must not add duplicates.
    AppBootstrap.registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final fonts = [for (final (family, _) in AppBootstrap.fontLicenses) family];

    for (final family in fonts) {
      final matches = entries.where((e) => e.packages.contains(family));
      expect(matches, hasLength(1), reason: family);
      final text = matches.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
      expect(text, contains('Copyright'));
    }
  });
}
