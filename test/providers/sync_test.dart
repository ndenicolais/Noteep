// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteep/providers/sync_provider.dart';
import 'package:noteep/widgets/sync_status_listener.dart';

class _ListNotifier extends StateNotifier<List<int>>
    with FirestoreListMutations<int> {
  _ListNotifier(this.syncStatus) : super([]);

  @override
  final SyncStatusNotifier? syncStatus;

  @override
  final FirebaseFirestore db = FakeFirebaseFirestore();

  int reloads = 0;

  @override
  Future<void> reload() async => reloads++;
}

void main() {
  late SyncStatusNotifier sync;
  late _ListNotifier notifier;

  const grace = Duration(milliseconds: 20);
  late Duration defaultGrace;

  setUp(() {
    sync = SyncStatusNotifier();
    notifier = _ListNotifier(sync);
    defaultGrace = FirestoreListMutations.writeGrace;
    FirestoreListMutations.writeGrace = grace;
  });

  tearDown(() => FirestoreListMutations.writeGrace = defaultGrace);

  group('FirestoreListMutations.mutate', () {
    test('acknowledged write completes without queueing', () async {
      await notifier.mutate((c) => [...c, 1], () async {});
      expect(notifier.state, [1]);
      expect(sync.state.queued, 0);
    });

    test('write failing within the grace period rolls back', () async {
      await expectLater(
        notifier.mutate((c) => [...c, 1], () async => throw StateError('x')),
        throwsStateError,
      );
      expect(notifier.state, isEmpty);
      expect(sync.state.queued, 0);
    });

    test('slow write returns after the grace period and is queued', () async {
      final server = Completer<void>();
      await notifier.mutate((c) => [...c, 1], () => server.future);
      expect(notifier.state, [1]);
      expect(sync.state.queued, 1);

      server.complete();
      await pumpEventQueue();
      expect(sync.state.queued, 0);
      expect(sync.state.failures, 0);
      expect(notifier.reloads, 0);
    });

    test('queued write rejected later counts a failure and reloads', () async {
      final server = Completer<void>();
      await notifier.mutate((c) => [...c, 1], () => server.future);

      server.completeError(StateError('permission-denied'));
      await pumpEventQueue();
      expect(sync.state.queued, 0);
      expect(sync.state.failures, 1);
      expect(notifier.reloads, 1);
    });

    test('commitInChunks splits ops into batches of 500', () async {
      final col = notifier.db.collection('c');
      await notifier.commitInChunks([
        for (var i = 0; i < 1201; i++)
          (WriteBatch b) => b.set(col.doc('$i'), {'i': i}),
      ]);
      expect((await col.get()).docs, hasLength(1201));
    });
  });

  group('SyncStatusListener', () {
    Future<ProviderContainer> pump(WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            builder: (context, child) => SyncStatusListener(child: child!),
            home: const Scaffold(body: SizedBox()),
          ),
        ),
      );
      return container;
    }

    testWidgets('banner shows while writes are queued', (tester) async {
      final container = await pump(tester);
      final server = Completer<void>();
      container.read(syncStatusProvider.notifier).track(server.future);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsOneWidget);

      server.complete();
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsNothing);
    });

    testWidgets('rejected queued write shows a SnackBar', (tester) async {
      final container = await pump(tester);
      final server = Completer<void>();
      container.read(syncStatusProvider.notifier).track(server.future);
      await tester.pumpAndSettle();

      server.completeError(StateError('x'));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsNothing);
      expect(
        find.text(
          'Una modifica non è stata sincronizzata ed è stata annullata.',
        ),
        findsOneWidget,
      );
    });
  });
}
