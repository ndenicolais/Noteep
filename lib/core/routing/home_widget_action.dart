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

/// Kind of item a list widget row opens.
enum HomeWidgetItemKind { note, task, event }

/// A row tapped in a list widget (`SummaryWidgets.kt`):
/// `noteep://open/<note|task|event>/<id>`.
class HomeWidgetOpenItem {
  const HomeWidgetOpenItem(this.kind, this.id);

  final HomeWidgetItemKind kind;
  final String id;

  Uri get uri =>
      Uri(scheme: 'noteep', host: 'open', pathSegments: [kind.name, id]);

  static HomeWidgetOpenItem? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'noteep' || uri.host != 'open') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments[1].isEmpty) return null;
    final kind =
        HomeWidgetItemKind.values
            .where((k) => k.name == segments[0])
            .firstOrNull;
    return kind == null ? null : HomeWidgetOpenItem(kind, segments[1]);
  }

  @override
  bool operator ==(Object other) =>
      other is HomeWidgetOpenItem && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// The header of a list widget, which opens its section:
/// `noteep://section/<notes|tasks|calendar>`.
enum HomeWidgetSection {
  notes,
  tasks,
  calendar;

  Uri get uri => Uri(scheme: 'noteep', host: 'section', path: '/$name');

  static HomeWidgetSection? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'noteep' || uri.host != 'section') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 1) return null;
    return values.where((s) => s.name == segments.single).firstOrNull;
  }
}
