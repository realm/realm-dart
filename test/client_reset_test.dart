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

import 'package:collection/collection.dart';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import '../lib/src/configuration.dart' show ClientResetHandlerInternal, ClientResyncModeInternal, BeforeResetCallback, AfterResetCallback, ClientResetCallback;
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

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((syncError) {
        resetCompleter.complete(syncError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await triggerClientReset(realm);

    final error = await resetCompleter.future;
    expect(error.message, contains('Bad client file identifier'));
  });

  baasTest('ManualRecoveryHandler with async callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    int timeTakenForManualReset = 0;
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((syncError) async {
        final startDateTime = DateTime.now();
        await Future<void>.delayed(Duration(seconds: 2));
        final endDateTime = DateTime.now();
        timeTakenForManualReset = endDateTime.difference(startDateTime).inSeconds;
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await triggerClientReset(realm);
    await waitForCondition(() => timeTakenForManualReset > 0, timeout: Duration(seconds: 15));

    expect(timeTakenForManualReset, greaterThanOrEqualTo(2));
  });

  baasTest('Initiate resetRealm on ManualRecoveryHandler callback', (appConfig) async {
    final app = App(appConfig);
    final user = await getAnonymousUser(app);

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.complete(clientResetError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.then((ClientResetError clientResetError) {
      realm.close();
      clientResetError.resetRealm(app, config.path);
    });

    await triggerClientReset(realm);

    await resetRealmFuture;
    expect(File(config.path).existsSync(), isFalse);
  });

  baasTest('Initiate resetRealm on ManualRecoveryHandler callback fails when Realm in use', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final resetCompleter = Completer<ClientResetError>();
    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: ManualRecoveryHandler((clientResetError) {
        resetCompleter.complete(clientResetError);
      }),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    final resetRealmFuture = resetCompleter.future.then(
      (ClientResetError clientResetError) => clientResetError.resetRealm(app, config.path),
    );

    await triggerClientReset(realm);

    await expectLater(resetRealmFuture, throws<RealmException>("An error occurred while deleting Realm fulle. Check if the file is in use"));
    expect(File(config.path).existsSync(), isTrue);
  }, skip: !Platform.isWindows);

  for (Type clientResetHandlerType in [
    RecoverOrDiscardUnsyncedChangesHandler,
    RecoverUnsyncedChangesHandler,
    DiscardUnsyncedChangesHandler,
  ]) {
    baasTest('$clientResetHandlerType.manualResetFallback invoked when throw an error on Before Callback', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<ClientResetError>();
      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            beforeResetCallback: (beforeFrozen) => throw Exception("This fails!"),
            manualResetFallback: (clientResetError) => onManualResetFallback.complete(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(await onManualResetFallback.future, isA<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.manualResetFallback invoked when throw an error on After Callbacks', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onManualResetFallback = Completer<ClientResetError>();
      void afterResetCallback(Realm beforeFrozen, Realm after) {
        throw Exception("This fails!");
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            afterRecoveryCallback: clientResetHandlerType != DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            afterDiscardCallback: clientResetHandlerType == DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            manualResetFallback: (clientResetError) => onManualResetFallback.complete(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(await onManualResetFallback.future, isA<ClientResetError>());
    });

    baasTest('$clientResetHandlerType.Before and After callbacks are invoked', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onBeforeCompleter = Completer<void>();
      final onAfterCompleter = Completer<void>();
      void afterResetCallback(Realm beforeFrozen, Realm after) {
        onAfterCompleter.complete();
      }

      final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            beforeResetCallback: (beforeFrozen) => onBeforeCompleter.complete(),
            afterRecoveryCallback: clientResetHandlerType != DiscardUnsyncedChangesHandler ? afterResetCallback : null,
            afterDiscardCallback: clientResetHandlerType == DiscardUnsyncedChangesHandler ? afterResetCallback : null,
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await onBeforeCompleter.future;
      await onAfterCompleter.future;
    });

    if (clientResetHandlerType != RecoverUnsyncedChangesHandler) {
      baasTest('$clientResetHandlerType notifications for deleted local data', (appConfig) async {
        final app = App(appConfig);
        final user = await getIntegrationUser(app);
        int beforeResetCallbackOccured = 0;
        int afterDiscardCallbackOccured = 0;
        int afterRecoveryCallbackOccured = 0;
        final onAfterCompleter = Completer<void>();

        final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
            clientResetHandler: Creator.create(
              clientResetHandlerType,
              beforeResetCallback: (beforeFrozen) => beforeResetCallbackOccured++,
              afterRecoveryCallback: (beforeFrozen, after) {
                afterRecoveryCallbackOccured++;
              },
              afterDiscardCallback: (beforeFrozen, after) {
                afterDiscardCallbackOccured++;
                onAfterCompleter.complete();
              },
              manualResetFallback: (clientResetError) => onAfterCompleter.completeError(clientResetError),
            ));

        final realm = await Realm.open(config);
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
        await onAfterCompleter.future;
        await waitForCondition(() => notifications.length == 2, timeout: Duration(seconds: 3));

        expect(beforeResetCallbackOccured, 1);
        expect(afterDiscardCallbackOccured, 1);
        expect(afterRecoveryCallbackOccured, 0);

        await subscription.cancel();
        expect(notifications.firstWhere((n) => n.deleted.isNotEmpty), isNotNull);
      });
    }

    baasTest('$clientResetHandlerType check data before and after recovery or discard', (appConfig) async {
      final app = App(appConfig);
      final user = await getIntegrationUser(app);

      final onAfterCompleter = Completer<void>();
      final syncedProduct = Product(ObjectId(), "always synced");
      final maybeProduct = Product(ObjectId(), "maybe synced");
      comparer(Product p1, Product p2) => p1.id == p2.id;

      final config = Configuration.flexibleSync(user, [Product.schema],
          clientResetHandler: Creator.create(
            clientResetHandlerType,
            beforeResetCallback: (beforeFrozen) {
              _checkPproducts(beforeFrozen, comparer, expectedList: [syncedProduct, maybeProduct]);
            },
            afterRecoveryCallback: (beforeFrozen, after) {
              _checkPproducts(beforeFrozen, comparer, expectedList: [syncedProduct, maybeProduct]);
              _checkPproducts(after, comparer, expectedList: [syncedProduct, maybeProduct]);
              onAfterCompleter.complete();
            },
            afterDiscardCallback: (beforeFrozen, after) {
              _checkPproducts(beforeFrozen, comparer, expectedList: [syncedProduct, maybeProduct]);
              _checkPproducts(after, comparer, expectedList: [syncedProduct], notExpectedList: [maybeProduct]);
              onAfterCompleter.complete();
            },
            manualResetFallback: (clientResetError) => onAfterCompleter.completeError(clientResetError),
          ));

      final realm = await Realm.open(config);
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
      await onAfterCompleter.future;
    });
  }

  baasTest('AfterDiscard callbacks is invoked for RecoverOrDiscardUnsyncedChangesHandler', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);

    final onBeforeCompleter = Completer<void>();
    final onAfterCompleter = Completer<void>();
    bool recovery = false;
    bool discard = false;

    final config = Configuration.flexibleSync(user, [Task.schema, Schedule.schema],
        clientResetHandler: RecoverOrDiscardUnsyncedChangesHandler(
          beforeResetCallback: (beforeFrozen) => onBeforeCompleter.complete(),
          afterRecoveryCallback: (Realm beforeFrozen, Realm after) {
            onAfterCompleter.complete();
            recovery = true;
          },
          afterDiscardCallback: (Realm beforeFrozen, Realm after) {
            onAfterCompleter.complete();
            discard = true;
          },
        ));

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();

    await disableAutomaticRecovery();
    await triggerClientReset(realm);

    await onBeforeCompleter.future;
    await onAfterCompleter.future;
    expect(recovery, isFalse);
    expect(discard, isTrue);
  });

  baasTest('Async BeforeResetCallback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int beforeResetCallbackOccured = 0;
    int afterResetCallbackOccured = 0;
    final onAfterCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: DiscardUnsyncedChangesHandler(
        beforeResetCallback: (beforeFrozen) async {
          await Future<void>.delayed(Duration(seconds: 1));
          beforeResetCallbackOccured++;
        },
        afterResetCallback: (beforeFrozen, after) {
          if (beforeResetCallbackOccured == 0) {
            onAfterCompleter.completeError(Exception("BeforeResetCallback is still not completed"));
          }
          afterResetCallbackOccured++;
          onAfterCompleter.complete();
        },
      ),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();
    await triggerClientReset(realm);

    await onAfterCompleter.future;
    expect(afterResetCallbackOccured, 1);
    expect(beforeResetCallbackOccured, 1);
  });

  baasTest('Async AfterResetCallback and ManualResetFallback', (appConfig) async {
    final app = App(appConfig);
    final user = await getIntegrationUser(app);
    int beforeResetCallbackOccured = 0;
    int afterResetCallbackOccured = 0;
    int manualResetFallbacKOccured = 0;
    final manualResetFallbacKCompleter = Completer<void>();

    final config = Configuration.flexibleSync(
      user,
      [Task.schema, Schedule.schema],
      clientResetHandler: DiscardUnsyncedChangesHandler(
        beforeResetCallback: (beforeFrozen) {
          beforeResetCallbackOccured++;
        },
        afterResetCallback: (beforeFrozen, after) async {
          await Future<void>.delayed(Duration(seconds: 1));
          afterResetCallbackOccured++;
          throw Exception("Cause manualResetFallback");
        },
        manualResetFallback: (clientResetError) {
          manualResetFallbacKOccured++;
          if (afterResetCallbackOccured == 0) {
            manualResetFallbacKCompleter.completeError(Exception("AfterResetCallback is still not completed"));
          }
          manualResetFallbacKCompleter.complete();
        },
      ),
    );

    final realm = await Realm.open(config);
    await realm.syncSession.waitForUpload();
    await triggerClientReset(realm);

    await manualResetFallbacKCompleter.future;
    expect(manualResetFallbacKOccured, 1);
    expect(afterResetCallbackOccured, 1);
    expect(beforeResetCallbackOccured, 1);
  });

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
      afterResetCallback: (beforeFrozen, after) {
        try {
          _checkPproducts(beforeFrozen, comparer, expectedList: [task0Id, task1Id], notExpectedList: [task2Id, task3Id]);
          _checkPproducts(after, comparer, expectedList: [task0Id, task1Id], notExpectedList: [task2Id]);
          afterRecoverCompleterA.complete();
        } catch (e) {
          afterRecoverCompleterA.completeError(e);
        }
      },
    ));

    final configB = Configuration.flexibleSync(userB, [Schedule.schema, Task.schema], clientResetHandler: RecoverUnsyncedChangesHandler(
      afterResetCallback: (beforeFrozen, after) {
        try {
          _checkPproducts(beforeFrozen, comparer, expectedList: [task0Id, task1Id, task2Id, task3Id]);
          _checkPproducts(after, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
          afterRecoverCompleterB.complete();
        } catch (e) {
          afterRecoverCompleterB.completeError(e);
        }
      },
    ));

    final realmA = await _syncReamlForUser<Task>(configA, [Task(task0Id), Task(task1Id), Task(task2Id)]);
    final realmB = await _syncReamlForUser<Task>(configB);

    realmA.syncSession.pause();
    realmB.syncSession.pause();
    realmA.write(() {
      final task2 = realmA.find<Task>(task2Id);
      realmA.delete<Task>(task2!);
    });

    realmB.write(() => realmB.add<Task>(Task(task3Id)));

    await triggerClientReset(realmA);
    await realmA.syncSession.waitForUpload();
    await afterRecoverCompleterA.future;

    await triggerClientReset(realmB, restartSession: false);
    realmB.syncSession.resume();
    await realmB.syncSession.waitForUpload();
    await afterRecoverCompleterB.future;

    await realmA.syncSession.waitForDownload();

    _checkPproducts(realmA, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
    _checkPproducts(realmB, comparer, expectedList: [task0Id, task1Id, task3Id], notExpectedList: [task2Id]);
  });
}

Future<Realm> _syncReamlForUser<T extends RealmObject>(FlexibleSyncConfiguration config, [List<T>? items]) async {
  final realm = Realm(config);
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

void _checkPproducts<T extends RealmObject, O extends Object?>(Realm realmToSearch, bool Function(T, O) truePredicate,
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
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        RecoverOrDiscardUnsyncedChangesHandler(
            beforeResetCallback: beforeResetCallback,
            afterRecoveryCallback: afterRecoveryCallback,
            afterDiscardCallback: afterDiscardCallback,
            manualResetFallback: manualResetFallback),
    RecoverUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        RecoverUnsyncedChangesHandler(
          beforeResetCallback: beforeResetCallback,
          afterResetCallback: afterRecoveryCallback,
          manualResetFallback: manualResetFallback,
        ),
    DiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        DiscardUnsyncedChangesHandler(
          beforeResetCallback: beforeResetCallback,
          afterResetCallback: afterDiscardCallback,
          manualResetFallback: manualResetFallback,
        ),
  };
  static ClientResetHandler create(Type type,
      {BeforeResetCallback? beforeResetCallback,
      AfterResetCallback? afterRecoveryCallback,
      AfterResetCallback? afterDiscardCallback,
      ClientResetCallback? manualResetFallback}) {
    return _constructors[type]!(
        beforeResetCallback: beforeResetCallback,
        afterRecoveryCallback: afterRecoveryCallback,
        afterDiscardCallback: afterDiscardCallback,
        manualResetFallback: manualResetFallback);
  }
}
