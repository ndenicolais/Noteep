// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialized in `main.dart` (overridden with the instance loaded by
/// `AppBootstrap`), used by every settings provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Initialize SharedPreferences before using this provider',
  );
});

/// Firestore instance used by the data notifiers; tests override it with a
/// `FakeFirebaseFirestore`.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// A [Notifier] holding a plain value that callers replace with [set]: the
/// `Notifier` counterpart of the legacy `StateProvider`.
class ValueStateNotifier<T> extends Notifier<T> {
  ValueStateNotifier(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// An immutable list of ids compared by content, so a provider exposing it
/// only notifies when items are added, removed or reordered — not when the
/// content of an item changes. Lists watch this and let each row watch its
/// own item (e.g. `noteByIdProvider`), so editing one item rebuilds one row.
@immutable
class IdList {
  IdList(Iterable<String> ids) : ids = List.unmodifiable(ids);

  final List<String> ids;

  int get length => ids.length;
  bool get isEmpty => ids.isEmpty;
  bool get isNotEmpty => ids.isNotEmpty;
  String operator [](int index) => ids[index];

  @override
  bool operator ==(Object other) =>
      other is IdList && listEquals(other.ids, ids);

  @override
  int get hashCode => Object.hashAll(ids);
}

typedef ValueStateProvider<T> = NotifierProvider<ValueStateNotifier<T>, T>;

/// Declares a [ValueStateProvider] starting at [initial].
ValueStateProvider<T> valueStateProvider<T>(T initial) =>
    NotifierProvider<ValueStateNotifier<T>, T>(
      () => ValueStateNotifier<T>(initial),
    );
