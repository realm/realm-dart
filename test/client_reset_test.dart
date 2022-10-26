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
            manualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(onManualResetFallback.future, throws<ClientResetError>());
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
            manualResetFallback: (clientResetError) => onManualResetFallback.completeError(clientResetError),
          ));

      final realm = await Realm.open(config);
      await realm.syncSession.waitForUpload();

      await triggerClientReset(realm);

      await expectLater(onManualResetFallback.future, throws<ClientResetError>());
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
          afterRecoveryCallback: afterRecoveryCallback,
          manualResetFallback: manualResetFallback,
        ),
    DiscardUnsyncedChangesHandler: (
            {BeforeResetCallback? beforeResetCallback,
            AfterResetCallback? afterRecoveryCallback,
            AfterResetCallback? afterDiscardCallback,
            ClientResetCallback? manualResetFallback}) =>
        DiscardUnsyncedChangesHandler(
          beforeResetCallback: beforeResetCallback,
          afterDiscardCallback: afterDiscardCallback,
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
