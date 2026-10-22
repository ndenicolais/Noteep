// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/utils/link_utils.dart';

void main() {
  group('normalizeUrl', () {
    test('adds https:// when the scheme is missing', () {
      expect(normalizeUrl('example.com'), 'https://example.com');
      expect(
        normalizeUrl('  www.example.com/a  '),
        'https://www.example.com/a',
      );
      expect(normalizeUrl('example.com:8080'), 'https://example.com:8080');
    });

    test('keeps allowed schemes', () {
      expect(normalizeUrl('http://example.com'), 'http://example.com');
      expect(normalizeUrl('mailto:a@b.it'), 'mailto:a@b.it');
      expect(normalizeUrl('tel:+39123'), 'tel:+39123');
    });

    test('rejects empty input and other schemes', () {
      expect(normalizeUrl('   '), isNull);
      expect(normalizeUrl('ftp://example.com'), isNull);
      expect(normalizeUrl('file:///etc/passwd'), isNull);
      expect(normalizeUrl('https://'), isNull);
    });
  });

  group('buildMarkdownLink', () {
    test('uses the url as label when text is empty', () {
      expect(
        buildMarkdownLink(' ', 'https://a.it'),
        '[https://a.it](https://a.it)',
      );
    });

    test('escapes brackets in text and parentheses/spaces in url', () {
      expect(
        buildMarkdownLink('a [b]', 'https://a.it/x (1)'),
        r'[a \[b\]](https://a.it/x%20%281%29)',
      );
    });
  });
}
