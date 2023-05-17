////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:io';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import '../lib/src/configuration.dart' show ClientResetHandlerInternal, ClientResyncModeInternal;
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest("Configuration.flexibleSync set recoverOrDiscard as a default resync mode", (appConfiguration) async {
    final app = App(appConfiguration);
    final user = await getIntegrationUser(app);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: ManualRecoveryHandler((syncError) {}),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.manual);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const DiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.discardLocal);
    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const RecoverUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recover);

    expect(
        Configuration.flexibleSync(
          user,
          [Task.schema, Schedule.schema],
          clientResetHandler: const RecoverOrDiscardUnsyncedChangesHandler(),
        ).clientResetHandler.clientResyncMode,
        ClientResyncModeInternal.recoverOrDiscard);

    expect(Configuration.flexibleSync(user, [Task.schema, Schedule.schema]).clientResetHandler.clientResyncMode, ClientResyncModeInternal.recoverOrDiscard);
  });

  baasTest('ManualRecoveryHandler error is reported in callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<void>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((syncError) {
        resetCompleter.completeError(syncError);
      }),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();

    await triggerClientReset(realm);
    final clientResetFuture = waitFutureWithTimeout(resetCompleter.future, timeoutError: "ManualRecoveryHandler is not reported.");
    await expectLater(clientResetFuture, throws<ClientResetError>('Bad client file identifier'));
  });

  baasTest('Initiate resetRealm after ManualRecoveryHandler callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getAnonymousUser(app);

    final resetCompleter = Completer<void>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
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

    await triggerClientReset(realm);

    await waitFutureWithTimeout(resetRealmFuture, timeoutError: "ManualRecoveryHandler is not reported.");

    expect(File(config.path).existsSync(), isFalse);
  });

  baasTest('Initiate resetRealm after ManualRecoveryHandler callback fails when Realm is opened', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<bool>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
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

    await triggerClientReset(realm);

    expect(await resetRealmFuture.timeout(const Duration(seconds: 300)), !Platform.isWindows);
    expect(File(config.path).existsSync(), Platform.isWindows); // posix and windows semantics are different
  });

  for (Type clientResetHandlerType in [
    RecoverOrDiscardUnsyncedChangesHandler,
    RecoverUnsyncedChangesHandler,
    DiscardUnsyncedChangesHandler,
  ]) {
    baasTest('$clientResetHandlerType.onManualResetFallback invoked when throw in onBeforeReset', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<void>();
      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) => throw Exception("This fails!"),
            onManualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      final clientResetFuture = waitFutureWithTimeout(onManualResetFallback.future, timeoutError: "onManualResetFallback is not reported.");
      await expectLater(clientResetFuture, throws<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.onManualResetFallback invoked when throw in onAfterReset', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<void>();
      void onAfterReset(Realm beforeResetRealm, Realm afterResetRealm) {
        throw Exception("This fails!");
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onAfterRecovery: clientResetHandlerType != DiscardUnsyncedChangesHandler ? onAfterReset : null,
            onAfterDiscard: clientResetHandlerType != RecoverUnsyncedChangesHandler ? onAfterReset : null,
            onManualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      final clientResetFuture = waitFutureWithTimeout(onManualResetFallback.future, timeoutError: "onManualResetFallback is not reported.");
      await expectLater(clientResetFuture, throws<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.onBeforeReset and onAfterReset are invoked', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onBeforeCompleter = Completer<void>();
      final onAfterCompleter = Completer<void>();
      void onAfterReset(Realm beforeResetRealm, Realm afterResetRealm) {
        onAfterCompleter.complete();
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) => onBeforeCompleter.complete(),
            onAfterRecovery: clientResetHandlerType != DiscardUnsyncedChangesHandler ? onAfterReset : null,
            onAfterDiscard: clientResetHandlerType != RecoverUnsyncedChangesHandler ? onAfterReset : null,
          ));

      final realm = await getRealmAsync(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await waitFutureWithTimeout(onBeforeCompleter.future, timeoutError: "onBeforeReset is not reported.");
      await waitFutureWithTimeout(onAfterCompleter.future, timeoutError: "onAfterReset is not reported.");
    });

    if (clientResetHandlerType != RecoverUnsyncedChangesHandler) {
      baasTest('$clientResetHandlerType notifications for deleted local data when DiscardUnsynced', (appConfig) async {
        final app = App(appConfig);
        final user = await getIntegrationUser(app);
        int onBeforeResetOccurred = 0;
        int onAfterDiscardOccurred = 0;
        int onAfterRecoveryOccurred = 0;
        final onAfterCompleter = Completer<void>();

        final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
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

        realm.subscriptions.update((mutableSubscriptions) {
          mutableSubscriptions.add(realm.all<Task>());
        });
        await realm.subscriptions.waitForSynchronization();
        await realm.syncSession.waitForDownload();
        final tasksCount = realm.all<Task>().length;

        realm.syncSession.pause();

        realm.write(() => realm.add(Task(ObjectId())));
        expect(tasksCount, lessThan(realm.all<Task>().length));

        final notifications = <RealmResultsChanges>[];
        final subscription = realm.all<Task>().changes.listen((event) {
          notifications.add(event);
        });

        await waitForCondition(() => notifications.length == 1, timeout: Duration(seconds: 3));
        if (clientResetHandlerType == RecoverOrDiscardUnsyncedChangesHandler) {
          await disableAutomaticRecovery();
        }
        await triggerClientReset(realm, restartSession: false);
        realm.syncSession.resume();
        await waitFutureWithTimeout(onAfterCompleter.future, timeoutError: "Neither onAfterDiscard nor onManualResetFallback is reported.");

        await waitForCondition(() => notifications.length == 2, timeout: Duration(seconds: 3));

        expect(onBeforeResetOccurred, 1);
        expect(onAfterDiscardOccurred, 1);
        expect(onAfterRecoveryOccurred, 0);

        await subscription.cancel();
        expect(notifications.firstWhere((n) => n.deleted.isNotEmpty), isNotNull);
      });
    }

    baasTest('$clientResetHandlerType check data in beforeResetRealm realm and after realm when recover or discard', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onAfterCompleter = Completer<void>();
      final syncedProduct = Product(ObjectId(), "always synced");
      final maybeProduct = Product(ObjectId(), "maybe synced");
      comparer(Product p1, Product p2) => p1.id == p2.id;

      final config = Configuration.flexibleSync(user, [Product.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            onBeforeReset: (beforeResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedProduct, maybeProduct]);
            },
            onAfterRecovery: (beforeResetRealm, afterResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedProduct, maybeProduct]);
              _checkProducts(afterResetRealm, comparer, expectedList: [syncedProduct, maybeProduct]);
              onAfterCompleter.complete();
            },
            onAfterDiscard: (beforeResetRealm, afterResetRealm) {
              _checkProducts(beforeResetRealm, comparer, expectedList: [syncedProduct, maybeProduct]);
              _checkProducts(afterResetRealm, comparer, expectedList: [syncedProduct], notExpectedList: [maybeProduct]);
              onAfterCompleter.complete();
            },
            onManualResetFallback: (clientResetError) => onAfterCompleter.completeError(clientResetError),
          ));

      final realm = await getRealmAsync(config);
      realm.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm.all<Product>());
      });
      await realm.subscriptions.waitForSynchronization();

      realm.write(() => realm.add(syncedProduct));
      await realm.syncSession.waitForUpload();

      realm.syncSession.pause();
      realm.write(() => realm.add(maybeProduct));

      await triggerClientReset(realm, restartSession: false);
      realm.syncSession.resume();
      await waitFutureWithTimeout(onAfterCompleter.future, timeoutError: "Neither onAfterDiscard, onAfterDiscard nor onManualResetFallback is reported.");
    });
  }

  baasTest('Disabled server recovery - onAfterDiscard callback is invoked for RecoverOrDiscardUnsyncedChangesHandler', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final onBeforeCompleter = Completer<void>();
    final onAfterCompleter = Completer<void>();
    bool recovery = false;
    bool discard = false;

    final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
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

    await disableAutomaticRecovery();
    await triggerClientReset(realm);

    await waitFutureWithTimeout(onBeforeCompleter.future, timeoutError: "onBeforeReset is not reported.");
    await waitFutureWithTimeout(onAfterCompleter.future, timeoutError: "Neither onAfterRecovery nor onAfterDiscard is reported.");

    expect(recovery, isFalse);
    expect(discard, isTrue);
  });

  baasTest('onAfterReset is reported after async onBeforeReset completes', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int onBeforeResetOccurred = 0;
    int onAfterResetOccurred = 0;
    final onAfterCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
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
    await triggerClientReset(realm);

    await waitFutureWithTimeout(onAfterCompleter.future, timeoutError: "onAfterReset is not reported.");

    expect(onAfterResetOccurred, 1);
    expect(onBeforeResetOccurred, 1);
  });

  baasTest('onManualResetFallback is reported after async onAfterReset throws', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int onBeforeResetOccurred = 0;
    int onAfterResetOccurred = 0;
    int manualResetFallbackOccurred = 0;
    final manualResetFallbackCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
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
          if (onAfterResetOccurred == 0) {
            manualResetFallbackCompleter.completeError(Exception("AfterResetCallback is still not completed when onManualResetFallback starts."));
          }
          manualResetFallbackCompleter.complete();
        },
      ),
    );

    final realm = await getRealmAsync(config);
    await realm.syncSession.waitForUpload();
    await triggerClientReset(realm);

    await waitFutureWithTimeout(manualResetFallbackCompleter.future, timeoutError: "onManualResetFallback is not reported.");

    expect(manualResetFallbackOccurred, 1);
    expect(onAfterResetOccurred, 1);
    expect(onBeforeResetOccurred, 1);
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

    comparer(Task t1, ObjectId id) => t1.id == id;

    final configA = Configuration.flexibleSync(userA, [Task.schema], clientResetHandler: RecoverUnsyncedChangesHandler(
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

    final configB = Configuration.flexibleSync(userB, [Schedule.schema, Task.schema], clientResetHandler: RecoverUnsyncedChangesHandler(
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

    final realmA = await _syncRealmForUser<Task>(configA, [Task(task0Id), Task(task1Id), Task(task2Id)]);
    final realmB = await _syncRealmForUser<Task>(configB);

    realmA.syncSession.pause();
    realmB.syncSession.pause();
    realmA.write(() {
      final task2 = realmA.find<Task>(task2Id);
      realmA.delete<Task>(task2!);
    });

    realmB.write(() => realmB.add<Task>(Task(task3Id)));

    await triggerClientReset(realmA);
    await realmA.syncSession.waitForUpload();
    await waitFutureWithTimeout(afterRecoverCompleterA.future, timeoutError: "onAfterReset for realmA is not reported.");

    await triggerClientReset(realmB, restartSession: false);
    realmB.syncSession.resume();
    await realmB.syncSession.waitForUpload();
    await waitFutureWithTimeout(afterRecoverCompleterB.future, timeoutError: "onAfterReset for realmB is not reported.");

    await realmA.syncSession.waitForDownload();

    _checkProducts(realmA, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
    _checkProducts(realmB, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
  });
}

Future<Realm> _syncRealmForUser<T extends RealmObject>(FlexibleSyncConfiguration config, [List<T>? items]) async {
  final realm = getRealm(config);
  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add<T>(realm.all<T>());
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

void _checkProducts<T extends RealmObject, O extends Object?>(Realm realmToSearch, bool Function(T, O) truePredicate,
    {required List<O> expectedList, List<O>? notExpectedList}) {
  final all = realmToSearch.all<T>();
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

Future<void> triggerClientReset(Realm realm, {bool restartSession = true}) async {
  final config = realm.config;
  if (config is! FlexibleSyncConfiguration) {
    throw RealmError('This should only be invoked for sync realms');
  }

  final session = realm.syncSession;
  if (restartSession) {
    session.pause();
  }

  final userId = config.user.id;
  final appId = baasApps.values.firstWhere((element) => element.clientAppId == config.user.app.id).appId;

  final result = await config.user.functions.call('triggerClientResetOnSyncServer', [userId, appId]) as Map<String, dynamic>;
  expect(result['status'], 'success');

  if (restartSession) {
    session.resume();
  }
}
