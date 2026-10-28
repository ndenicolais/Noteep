// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

/// Plain-text version of a note's Markdown [source], for previews that show
/// the text without rendering it (note cards, notification body, link sheet).
///
/// Removes the syntax and keeps the words: headings, emphasis, strikethrough,
/// inline code and code fences, quotes, rules, links and images (their text
/// stays). List items become `• `. Escaped characters (`\*`) stay literal,
/// and underscores inside words (`snake_case`) are not emphasis.
String markdownToPlainText(String source) {
  // Escaped characters become NUL-delimited placeholders, so the rules below
  // do not see them, and are restored at the end.
  final escapes = <String>[];
  var text = source.replaceAllMapped(_escaped, (m) {
    escapes.add(m[1]!);
    return '\u0000${escapes.length - 1}\u0000';
  });

  final lines = <String>[];
  for (var line in text.split('\n')) {
    if (_fence.hasMatch(line) || _rule.hasMatch(line)) continue;
    line = line.replaceFirst(_heading, '').replaceFirst(_closingHashes, '');
    while (_quote.hasMatch(line)) {
      line = line.replaceFirst(_quote, '');
    }
    line = line.replaceFirstMapped(
      _bullet,
      (m) => '${m[1]}• ${m[2] == null ? '' : (m[2] == ' ' ? '☐ ' : '☑ ')}',
    );
    lines.add(line);
  }
  text = lines.join('\n').replaceAll(_blankLines, '\n\n');

  text = text
      .replaceAllMapped(_image, (m) => m[1]!)
      .replaceAllMapped(_link, (m) => m[1]!)
      .replaceAllMapped(_autolink, (m) => m[1]!)
      .replaceAllMapped(_code, (m) => m[1]!)
      .replaceAllMapped(_strong, (m) => m[2]!)
      .replaceAllMapped(_strike, (m) => m[1]!)
      .replaceAllMapped(_emphasisStar, (m) => m[1]!)
      .replaceAllMapped(_emphasisUnderscore, (m) => '${m[1]}${m[2]}');

  return text
      .replaceAllMapped(_placeholder, (m) => escapes[int.parse(m[1]!)])
      .trim();
}

final _placeholder = RegExp('\u0000(\\d+)\u0000');
final _escaped = RegExp(r'\\([\\`*_{}\[\]()#+\-.!>~|])');

final _fence = RegExp(r'^\s*(```|~~~)');
final _rule = RegExp(r'^\s{0,3}([-*_])(\s*\1){2,}\s*$');
final _heading = RegExp(r'^\s{0,3}#{1,6}\s+');
final _closingHashes = RegExp(r'\s+#+\s*$');
final _quote = RegExp(r'^\s{0,3}>\s?');
final _bullet = RegExp(r'^(\s*)[-*+]\s+(?:\[([ xX])\]\s+)?');
final _blankLines = RegExp(r'\n{3,}');

final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
final _link = RegExp(r'\[([^\]]+)\]\([^)]*\)');
final _autolink = RegExp(r'<((?:https?|mailto):[^>\s]+)>');
final _code = RegExp(r'`([^`]+)`');
final _strong = RegExp(r'(\*\*|__)(?=\S)(.+?)(?<=\S)\1');
final _strike = RegExp(r'~~(?=\S)(.+?)(?<=\S)~~');
final _emphasisStar = RegExp(r'\*(?=\S)([^*\n]+?)(?<=\S)\*');
final _emphasisUnderscore = RegExp(r'(^|[^\w])_(?=\S)([^_\n]+?)(?<=\S)_(?!\w)');
