// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

/// What a tapped Android home screen widget asks the app to do.
///
/// The widgets (`QuickActionWidgets.kt`) launch `MainActivity` with a
/// `noteep://new/<kind>` URI through `HomeWidgetLaunchIntent`.
enum HomeWidgetAction {
  newNote('note'),
  newTask('task'),
  newEvent('event');

  const HomeWidgetAction(this.path);

  final String path;

  Uri get uri => Uri(scheme: 'noteep', host: 'new', path: '/$path');

  /// The action encoded in [uri], or `null` for a missing or unknown one
  /// (e.g. the summary widget, which just opens the app).
  static HomeWidgetAction? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'noteep' || uri.host != 'new') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 1) return null;
    return values.where((a) => a.path == segments.single).firstOrNull;
  }
}
