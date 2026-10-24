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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/providers/auth_provider.dart';
import 'package:noteep/providers/core_providers.dart';

/// Points the data notifiers at [db] for user [uid], bypassing Firebase
/// Auth and the real Firestore instance.
List<Override> firestoreOverrides(
  FirebaseFirestore db, {
  String uid = 'test-uid',
}) => [
  firestoreProvider.overrideWithValue(db),
  currentUidProvider.overrideWithValue(uid),
];

/// A [ProviderContainer] using [firestoreOverrides], disposed at the end of
/// the test.
ProviderContainer createTestContainer(
  FirebaseFirestore db, {
  String uid = 'test-uid',
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: [...firestoreOverrides(db, uid: uid), ...overrides],
  );
  addTearDown(container.dispose);
  return container;
}
