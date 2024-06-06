// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/configuration.dart' show ClientResetHandlerInternal, ClientResyncModeInternal;
import 'test.dart';

const defaultWaitTimeout = Duration(seconds: 300);

void main() {
  setupTests();

  baasTest("Configuration.flexibleSync set recoverOrDiscard as a default resync mode", (appConfiguration) async {
    final user = await getIntegrationUser(appConfig: appConfiguration);
    expect(
        Configuration.flexibleSync(
          user,
          getSyncSchema(),
          clientResetHandler: ManualRecoveryHandler((syncError) {}),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.manual);
    expect(
        Configuration.flexibleSync(
          user,
          getSyncSchema(),
          clientResetHandler: const DiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.discardLocal);
    expect(
        Configuration.flexibleSync(
          user,
          getSyncSchema(),
          clientResetHandler: const RecoverUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recover);

    expect(
        Configuration.flexibleSync(
          user,
          getSyncSchema(),
          clientResetHandler: const RecoverOrDiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recoverOrDiscard);

    expect(Configuration.flexibleSync(user, getSyncSchema()).clientResetHandler.clientResyncMode, ClientResyncModeInternal.recoverOrDiscard);
  });

  baasTest('ManualRecoveryHandler error is reported in callback', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);

    final resetCompleter = Completer<void>();
    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: ManualRecoveryHandler((syncError) {
        resetCompleter.completeError(syncError);
      }),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();

    await baasHelper!.triggerClientReset(realm);
    final clientResetFuture = resetCompleter.future.wait(defaultWaitTimeout, "ManualRecoveryHandler is not reported.");
    await expectLater(clientResetFuture, throws<ClientResetError>('Bad client file identifier'));
  });

  baasTest('Initiate resetRealm after ManualRecoveryHandler callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getAnonymousUser(app);

    final resetCompleter = Completer<void>();
    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.completeError(clientResetError);
      }),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.onError((error, stackTrace) {
      final clientResetError = error as ClientResetError;
      realm.close();
      clientResetError.resetRealm();
    }, test: (error) => error is ClientResetError);

    await baasHelper!.triggerClientReset(realm);

    await resetRealmFuture.wait(defaultWaitTimeout, "ManualRecoveryHandler is not reported.");

    expect(Realm.existsSync(config.path), isFalse);
  });

  baasTest('Initiate resetRealm after ManualRecoveryHandler callback fails when Realm is opened', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);

    final resetCompleter = Completer<bool>();
    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.completeError(clientResetError);
      }),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.onError((error, stackTrace) {
      final clientResetError = error as ClientResetError;
      return clientResetError.resetRealm();
    }, test: (error) => error is ClientResetError);

    await baasHelper!.triggerClientReset(realm);

    expect(await resetRealmFuture.timeout(defaultWaitTimeout), !Platform.isWindows);
    expect(Realm.existsSync(config.path), Platform.isWindows); // posix and windows semantics are different
  });

  for (Type clientResetHandlerType in [
    RecoverOrDiscardUnsyncedChangesHandler,
    RecoverUnsyncedChangesHandler,
    DiscardUnsyncedChangesHandler,
  ]) {
    baasTest('$clientResetHandlerType.onManualResetFallback invoked when throw in onBeforeReset', (appConfig) async {
      final user = await getIntegrationUser(appConfig: appConfig);

      final onManualResetFallback = Completer<void>();
      final config = Configuration.flexibleSync(user, getSyncSchema(),
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) => throw Exception("This fails!"),
            onManualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await baasHelper!.triggerClientReset(realm);

      final clientResetFuture = onManualResetFallback.future.wait(defaultWaitTimeout, "onManualResetFallback is not reported.");
      await expectLater(
          clientResetFuture,
          throwsA(isA<ClientResetError>().having((e) => e.innerError?.toString(), 'innerError', 'Exception: This fails!').having((e) => e.toString(), 'message',
              "ClientResetError message: A fatal error occurred during client reset: 'User-provided callback failed', inner error: 'Exception: This fails!'")));
    });

    baasTest('$clientResetHandlerType.onManualResetFallback invoked when throw in onAfterReset', (appConfig) async {
      final user = await getIntegrationUser(appConfig: appConfig);

      final onManualResetFallback = Completer<void>();
      void onAfterReset(Realm beforeResetRealm, Realm afterResetRealm) {
        throw Exception("This fails too!");
      }

      final config = Configuration.flexibleSync(user, getSyncSchema(),
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onAfterRecovery: clientResetHandlerType != DiscardUnsyncedChangesHandler ? onAfterReset : null,
            onAfterDiscard: clientResetHandlerType != RecoverUnsyncedChangesHandler ? onAfterReset : null,
            onManualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await baasHelper!.triggerClientReset(realm);

      final clientResetFuture = onManualResetFallback.future.wait(defaultWaitTimeout, "onManualResetFallback is not reported.");
      await expectLater(
          clientResetFuture,
          throwsA(isA<ClientResetError>().having((e) => e.innerError?.toString(), 'innerError', 'Exception: This fails too!').having(
              (e) => e.toString(),
              'message',
              "ClientResetError message: A fatal error occurred during client reset: 'User-provided callback failed', inner error: 'Exception: This fails too!'")));
    });

    baasTest('$clientResetHandlerType.onBeforeReset and onAfterReset are invoked', (appConfig) async {
      final user = await getIntegrationUser(appConfig: appConfig);

      final onBeforeCompleter = Completer<void>();
      final onAfterCompleter = Completer<void>();
      void onAfterReset(Realm beforeResetRealm, Realm afterResetRealm) {
        onAfterCompleter.complete();
      }

      final config = Configuration.flexibleSync(user, getSyncSchema(),
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) => onBeforeCompleter.complete(),
            onAfterRecovery: clientResetHandlerType != DiscardUnsyncedChangesHandler ? onAfterReset : null,
            onAfterDiscard: clientResetHandlerType != RecoverUnsyncedChangesHandler ? onAfterReset : null,
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await baasHelper!.triggerClientReset(realm);

      await onBeforeCompleter.future.timeout(defaultWaitTimeout, onTimeout: () => throw TimeoutException("onBeforeReset is not reported"));
      await onAfterCompleter.future.timeout(defaultWaitTimeout, onTimeout: () => throw TimeoutException("onAfterReset is not reported."));
    });

    if (clientResetHandlerType != RecoverUnsyncedChangesHandler) {
      final baasAppName = AppName.flexible;
      final shouldDisableAutoRecoveryForApp = clientResetHandlerType == RecoverOrDiscardUnsyncedChangesHandler;
      baasTest('$clientResetHandlerType notifications for deleted local data when DiscardUnsynced', appName: baasAppName, (appConfig) async {
        try {
          final user = await getIntegrationUser(appConfig: appConfig);
          int onBeforeResetOccurred = 0;
          int onAfterDiscardOccurred = 0;
          int onAfterRecoveryOccurred = 0;
          final onAfterCompleter = Completer<void>();

          final config = Configuration.flexibleSync(user, getSyncSchema(),
              clientResetHandler: Creator.create(
                clientResetHandlerType,
                onBeforeReset: (beforeResetRealm) => onBeforeResetOccurred++,
                onAfterRecovery: (beforeResetRealm, afterResetRealm) {
                  onAfterRecoveryOccurred++;
                },
                onAfterDiscard: (beforeResetRealm, afterResetRealm) {
                  onAfterDiscardOccurred++;
                  onAfterCompleter.complete();
                },
                onManualResetFallback: (clientResetError) => onAfterCompleter.completeError(clientResetError),
              ));

          final realm = await getRealmAsync(config);
          await realm.syncSession.waitForUpload();
          final objectId = ObjectId();
          final addedObjectId = ObjectId();
          final query = realm.query<Task>(r'_id IN $0', [
            [objectId, addedObjectId]
          ]);
          realm.subscriptions.update((mutableSubscriptions) {
            mutableSubscriptions.add(query);
          });
          await realm.subscriptions.waitForSynchronization();
          await realm.syncSession.waitForDownload();
          final tasksCount = query.length;

          realm.syncSession.pause();

          realm.write(() => realm.add(Task(addedObjectId)));
          expect(tasksCount, lessThan(query.length));

          final notifications = <RealmResultsChanges>[];
          final subscription = query.changes.listen((event) {
            notifications.add(event);
          });

          await waitForCondition(() => notifications.length == 1, timeout: Duration(seconds: 3));
          if (shouldDisableAutoRecoveryForApp) {
            await baasHelper!.disableAutoRecoveryForApp(baasAppName);
          }
          await baasHelper!.triggerClientReset(realm, restartSession: false);
          realm.syncSession.resume();
          await onAfterCompleter.future.wait(defaultWaitTimeout, "Neither onAfterDiscard nor onManualResetFallback is reported.");

          await waitForCondition(() => notifications.length == 2, timeout: Duration(seconds: 3));

          expect(onBeforeResetOccurred, 1);
          expect(onAfterDiscardOccurred, 1);
          expect(onAfterRecoveryOccurred, 0);

          await subscription.cancel();
          expect(notifications.firstWhere((n) => n.deleted.isNotEmpty), isNotNull);
        } finally {
          if (shouldDisableAutoRecoveryForApp) {
            await baasHelper!.enableAutoRecoveryForApp(baasAppName);
          }
        }
      });
    }

    baasTest('$clientResetHandlerType check data in beforeResetRealm realm and after realm when recover or discard', (appConfig) async {
      final user = await getIntegrationUser(appConfig: appConfig);

      final onAfterCompleter = Completer<void>();

      final syncedId = ObjectId();
      final maybeId = ObjectId();

      comparer(Product p1, ObjectId expectedId) => p1.id == expectedId;

      final config = Configuration.flexibleSync(user, getSyncSchema(),
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedId, maybeId]);
            },
            onAfterRecovery: (beforeResetRealm, afterResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedId, maybeId]);
              _checkProducts(afterResetRealm, comparer, expectedList: [syncedId, maybeId]);
              onAfterCompleter.complete();
            },
            onAfterDiscard: (beforeResetRealm, afterResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedId, maybeId]);
              _checkProducts(afterResetRealm, comparer, expectedList: [syncedId], notExpectedList: [maybeId]);
              onAfterCompleter.complete();
            },
            onManualResetFallback: (clientResetError) => onAfterCompleter.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      realm.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm.query<Product>(r'_id IN $0', [
          [syncedId, maybeId]
        ]));
      });
      await realm.subscriptions.waitForSynchronization();

      realm.write(() => realm.add(Product(syncedId, "always synced")));
      await realm.syncSession.waitForUpload();

      realm.syncSession.pause();
      realm.write(() => realm.add(Product(maybeId, "maybe synced")));

      await baasHelper!.triggerClientReset(realm, restartSession: false);
      realm.syncSession.resume();
      await onAfterCompleter.future.wait(defaultWaitTimeout, "Neither onAfterDiscard, onAfterDiscard nor onManualResetFallback is reported.");
    });
  }

  {
    final baasAppName = AppName.flexible;
    baasTest('Disabled server recovery - onAfterDiscard callback is invoked for RecoverOrDiscardUnsyncedChangesHandler', appName: baasAppName,
        (appConfig) async {
      final user = await getIntegrationUser(appConfig: appConfig);

      final onBeforeCompleter = Completer<void>();
      final onAfterCompleter = Completer<void>();
      bool recovery = false;
      bool discard = false;

      final config = Configuration.flexibleSync(user, getSyncSchema(),
          clientResetHandler: RecoverOrDiscardUnsyncedChangesHandler(
            onBeforeReset: (beforeResetRealm) => onBeforeCompleter.complete(),
            onAfterRecovery: (Realm beforeResetRealm, Realm afterResetRealm) {
              onAfterCompleter.complete();
              recovery = true;
            },
            onAfterDiscard: (Realm beforeResetRealm, Realm afterResetRealm) {
              onAfterCompleter.complete();
              discard = true;
            },
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await baasHelper!.disableAutoRecoveryForApp(baasAppName);
      try {
        await baasHelper!.triggerClientReset(realm);

        await onBeforeCompleter.future.wait(defaultWaitTimeout, "onBeforeReset is not reported.");
        await onAfterCompleter.future.wait(defaultWaitTimeout, "Neither onAfterRecovery nor onAfterDiscard is reported.");

        expect(recovery, isFalse);
        expect(discard, isTrue);
      } finally {
        await baasHelper!.enableAutoRecoveryForApp(baasAppName);
      }
    });
  }

  baasTest('onAfterReset is reported after async onBeforeReset completes', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);
    int onBeforeResetOccurred = 0;
    int onAfterResetOccurred = 0;
    final onAfterCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: DiscardUnsyncedChangesHandler(
        onBeforeReset: (beforeResetRealm) async {
          await Future<void>.delayed(Duration(seconds: 1));
          onBeforeResetOccurred++;
        },
        onAfterReset: (beforeResetRealm, afterResetRealm) {
          if (onBeforeResetOccurred == 0) {
            onAfterCompleter.completeError(Exception("BeforeResetCallback is still not completed"));
          }
          onAfterResetOccurred++;
          onAfterCompleter.complete();
        },
      ),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();
    await baasHelper!.triggerClientReset(realm);

    await onAfterCompleter.future.wait(defaultWaitTimeout, "onAfterReset is not reported.");

    expect(onAfterResetOccurred, 1);
    expect(onBeforeResetOccurred, 1);
  });

  baasTest('onManualResetFallback is reported after async onAfterReset throws', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);
    int onBeforeResetOccurred = 0;
    int onAfterResetOccurred = 0;
    int manualResetFallbackOccurred = 0;
    final manualResetFallbackCompleter = Completer<void>();

    late ClientResetError clientResetErrorOnManualFallback;
    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: DiscardUnsyncedChangesHandler(
        onBeforeReset: (beforeResetRealm) {
          onBeforeResetOccurred++;
        },
        onAfterReset: (beforeResetRealm, afterResetRealm) async {
          await Future<void>.delayed(Duration(seconds: 1));
          onAfterResetOccurred++;
          throw Exception("Cause onManualResetFallback");
        },
        onManualResetFallback: (clientResetError) {
          manualResetFallbackOccurred++;
          clientResetErrorOnManualFallback = clientResetError;
          if (onAfterResetOccurred == 0) {
            manualResetFallbackCompleter.completeError(Exception("AfterResetCallback is still not completed when onManualResetFallback starts."));
          }
          manualResetFallbackCompleter.complete();
        },
      ),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();
    await baasHelper!.triggerClientReset(realm);

    await manualResetFallbackCompleter.future.wait(defaultWaitTimeout, "onManualResetFallback is not reported.");

    expect(manualResetFallbackOccurred, 1);
    expect(onAfterResetOccurred, 1);
    expect(onBeforeResetOccurred, 1);

    expect(clientResetErrorOnManualFallback.message, isNotEmpty);
    expect(clientResetErrorOnManualFallback.innerError, isNotNull);
    expect(clientResetErrorOnManualFallback.innerError.toString(), 'Exception: Cause onManualResetFallback');
  });

  // 1. userA adds [task0, task1, task2] and syncs it, then disconnects
  // 2. userB starts and downloads the same tasks, then disconnects
  // 3. While offline, userA deletes task2 while userB inserts task3
  // 4. A client reset is triggered on the server
  // 5. userA goes online and uploads the changes
  // 6. only now userB goes online, downloads and merges the changes. userB will have [task0, task1, task3]
  // 7. userA will also have [task0, task1, task3]
  baasTest('RecoverUnsyncedChangesHandler integration test with two users', (appConfig) async {
    final app = App(appConfig);
    final afterRecoverCompleterA = Completer<void>();
    final afterRecoverCompleterB = Completer<void>();

    final userA = await getAnonymousUser(app);
    final userB = await getAnonymousUser(app);
    final task0Id = ObjectId();
    final task1Id = ObjectId();
    final task2Id = ObjectId();
    final task3Id = ObjectId();
    List<ObjectId> filterByIds = [task0Id, task1Id, task2Id, task3Id];
    comparer(Task t1, ObjectId id) => t1.id == id;

    final configA = Configuration.flexibleSync(userA, getSyncSchema(), clientResetHandler: RecoverUnsyncedChangesHandler(
      onAfterReset: (beforeResetRealm, afterResetRealm) {
        try {
          _checkProducts(beforeResetRealm, comparer, expectedList: [task0Id, task1Id], notExpectedList: [task2Id, task3Id]);
          _checkProducts(afterResetRealm, comparer, expectedList: [task0Id, task1Id], notExpectedList: [task2Id]);
          afterRecoverCompleterA.complete();
        } catch (e) {
          afterRecoverCompleterA.completeError(e);
        }
      },
    ));

    final configB = Configuration.flexibleSync(userB, getSyncSchema(), clientResetHandler: RecoverUnsyncedChangesHandler(
      onAfterReset: (beforeResetRealm, afterResetRealm) {
        try {
          _checkProducts(beforeResetRealm, comparer, expectedList: [task0Id, task1Id, task2Id, task3Id]);
          _checkProducts(afterResetRealm, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
          afterRecoverCompleterB.complete();
        } catch (e) {
          afterRecoverCompleterB.completeError(e);
        }
      },
    ));

    final realmA = await _syncRealmForUser<Task>(configA, filterByIds, [Task(task0Id), Task(task1Id), Task(task2Id)]);
    final realmB = await _syncRealmForUser<Task>(configB, filterByIds);

    realmA.syncSession.pause();
    realmB.syncSession.pause();
    realmA.write(() {
      final task2 = realmA.find<Task>(task2Id);
      realmA.delete<Task>(task2!);
    });

    realmB.write(() => realmB.add<Task>(Task(task3Id)));

    await baasHelper!.triggerClientReset(realmA);
    await realmA.syncSession.waitForUpload();
    await afterRecoverCompleterA.future.wait(defaultWaitTimeout, "onAfterReset for realmA is not reported.");

    await baasHelper!.triggerClientReset(realmB, restartSession: false);
    realmB.syncSession.resume();
    await realmB.syncSession.waitForUpload();
    await afterRecoverCompleterB.future.wait(defaultWaitTimeout, "onAfterReset for realmB is not reported.");

    await realmA.syncSession.waitForDownload();

    _checkProducts(realmA, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
    _checkProducts(realmB, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
  });

  baasTest('ClientResetError details are received', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);

    final resetCompleter = Completer<void>();
    late ClientResetError clientResetError;
    final config = Configuration.flexibleSync(
      user,
      getSyncSchema(),
      clientResetHandler: ManualRecoveryHandler((syncError) {
        clientResetError = syncError;
        resetCompleter.complete();
      }),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();

    await baasHelper!.triggerClientReset(realm);
    await resetCompleter.future.wait(defaultWaitTimeout, "ClientResetError is not reported.");

    expect(clientResetError.message, isNotEmpty);
    expect(clientResetError.backupFilePath, isNotEmpty);
  });
}

Future<Realm> _syncRealmForUser<T extends RealmObject>(FlexibleSyncConfiguration config, List<ObjectId> filterByIds, [List<T>? items]) async {
  final realm = getRealm(config);
  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add<T>(realm.query<T>(r'_id IN $0', [filterByIds]));
  });
  await realm.subscriptions.waitForSynchronization();

  if (items != null) {
    realm.write(() => realm.deleteAll<T>());
    realm.write(() => realm.addAll<T>(items));
    await realm.syncSession.waitForUpload();
  }
  await realm.syncSession.waitForDownload();
  return realm;
}

void _checkProducts<T extends RealmObject, O extends Object?>(Realm realm, bool Function(T, ObjectId) truePredicate,
    {required List<ObjectId> expectedList, List<ObjectId>? notExpectedList}) {
  final all = realm.all<T>();
  for (var expected in expectedList) {
    if (!all.any((p) => truePredicate(p, expected))) {
      throw Exception("Expected realm object does not exist");
    }
  }
  if (notExpectedList != null) {
    for (var notExpected in notExpectedList) {
      if (all.any((p) => truePredicate(p, notExpected))) {
        throw Exception("Not expected realm object exists");
      }
    }
  }
}

class Creator {
  static final _constructors = {
    RecoverOrDiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? onBeforeReset,
            AfterResetCallback? onAfterRecovery,
            AfterResetCallback? onAfterDiscard,
            ClientResetCallback? onManualResetFallback}) =>
        RecoverOrDiscardUnsyncedChangesHandler(
            onBeforeReset: onBeforeReset, onAfterRecovery: onAfterRecovery, onAfterDiscard: onAfterDiscard, onManualResetFallback: onManualResetFallback),
    RecoverUnsyncedChangesHandler: (
            {BeforeResetCallback? onBeforeReset,
            AfterResetCallback? onAfterRecovery,
            AfterResetCallback? onAfterDiscard,
            ClientResetCallback? onManualResetFallback}) =>
        RecoverUnsyncedChangesHandler(
          onBeforeReset: onBeforeReset,
          onAfterReset: onAfterRecovery,
          onManualResetFallback: onManualResetFallback,
        ),
    DiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? onBeforeReset,
            AfterResetCallback? onAfterRecovery,
            AfterResetCallback? onAfterDiscard,
            ClientResetCallback? onManualResetFallback}) =>
        DiscardUnsyncedChangesHandler(
          onBeforeReset: onBeforeReset,
          onAfterReset: onAfterDiscard,
          onManualResetFallback: onManualResetFallback,
        ),
  };
  static ClientResetHandler create(Type type,
      {BeforeResetCallback? onBeforeReset,
      AfterResetCallback? onAfterRecovery,
      AfterResetCallback? onAfterDiscard,
      ClientResetCallback? onManualResetFallback}) {
    return _constructors[type]!(
        onBeforeReset: onBeforeReset, onAfterRecovery: onAfterRecovery, onAfterDiscard: onAfterDiscard, onManualResetFallback: onManualResetFallback);
  }
}

extension on Future<void> {
  Future<void> wait(Duration duration, [String message = "Timeout waiting a future to complete."]) {
    return timeout(duration, onTimeout: () => throw TimeoutException(message));
  }
}
