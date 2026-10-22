// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:url_launcher/url_launcher.dart';

/// Schemes a note link is allowed to open; anything else (e.g. `file:`,
/// `intent:`, `javascript:`) is ignored.
const _allowedSchemes = {'http', 'https', 'mailto', 'tel'};

/// Adds `https://` when [input] has no scheme (`example.com` →
/// `https://example.com`). Returns `null` for an empty or unusable URL.
String? normalizeUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  // `host:port` (no `//`) is not a scheme, unless it is mailto:/tel:.
  final hasScheme = RegExp(
    r'^([a-zA-Z][a-zA-Z0-9+.-]*://|mailto:|tel:)',
    caseSensitive: false,
  ).hasMatch(trimmed);
  final candidate = hasScheme ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(candidate);
  if (uri == null || !_allowedSchemes.contains(uri.scheme.toLowerCase())) {
    return null;
  }
  if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isEmpty) {
    return null;
  }
  return candidate;
}

/// Builds `[text](url)`, escaping the characters that would break the
/// Markdown syntax. An empty [text] shows the URL itself.
String buildMarkdownLink(String text, String url) {
  final label = (text.trim().isEmpty ? url : text.trim())
      .replaceAll(r'\', r'\\')
      .replaceAll('[', r'\[')
      .replaceAll(']', r'\]');
  final target = url
      .replaceAll(' ', '%20')
      .replaceAll('(', '%28')
      .replaceAll(')', '%29');
  return '[$label]($target)';
}

/// Opens [href] in the external app that handles it (browser, mail, dialer).
/// Returns `false` when the scheme is not allowed or nothing can open it.
Future<bool> openExternalLink(String href) async {
  final uri = Uri.tryParse(href.trim());
  if (uri == null || !_allowedSchemes.contains(uri.scheme.toLowerCase())) {
    return false;
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
