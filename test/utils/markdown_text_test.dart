import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/utils/markdown_text.dart';

void main() {
  group('markdownToPlainText', () {
    test('plain text is unchanged', () {
      expect(
        markdownToPlainText('Buy milk\nCall Anna at 5'),
        'Buy milk\nCall Anna at 5',
      );
    });

    test('removes heading markers', () {
      expect(markdownToPlainText('## Plan\n# Title #'), 'Plan\nTitle');
      expect(markdownToPlainText('#hashtag'), '#hashtag');
    });

    test('removes emphasis, strikethrough and inline code', () {
      expect(
        markdownToPlainText(
          '**Friday** – near *Alfama*, __bold__ _it_ ~~old~~ `code`',
        ),
        'Friday – near Alfama, bold it old code',
      );
    });

    test('keeps underscores inside words and lone asterisks', () {
      expect(markdownToPlainText('my_var_name'), 'my_var_name');
      expect(markdownToPlainText('2 * 3 = 6'), '2 * 3 = 6');
    });

    test('turns list items into bullets and keeps task state', () {
      expect(
        markdownToPlainText('- one\n* two\n  + nested\n- [ ] todo\n- [x] done'),
        '• one\n• two\n  • nested\n• ☐ todo\n• ☑ done',
      );
      expect(markdownToPlainText('1. first'), '1. first');
    });

    test('removes quotes, rules and code fences', () {
      expect(
        markdownToPlainText('> Book it\n> > nested\n---\n```\nx = 1\n```'),
        'Book it\nnested\nx = 1',
      );
    });

    test('keeps the text of links and images', () {
      expect(
        markdownToPlainText(
          'See [the docs](https://a.b/c) and ![logo](l.png) or <https://x.y>',
        ),
        'See the docs and logo or https://x.y',
      );
    });

    test('keeps escaped characters literal', () {
      expect(
        markdownToPlainText(r'\*not italic\* and \# not a heading'),
        '*not italic* and # not a heading',
      );
      expect(markdownToPlainText(r'[a \] b](https://x.y)'), 'a ] b');
    });

    test('collapses runs of blank lines and trims', () {
      expect(markdownToPlainText('\n\nA\n\n\n\nB\n\n'), 'A\n\nB');
    });
  });
}
