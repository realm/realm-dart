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
import '../lib/src/session.dart' show SessionInternal;
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Realm.syncSession throws on wrong configuration', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    expect(() => realm.syncSession, throws<RealmError>());
  });

  baasTest('Realm.syncSession returns on FLX configuration', (configuration) async {
    final realm = await getIntegrationRealm();

    expect(realm.syncSession, isNotNull);
    expect(realm.syncSession.realmPath, realm.config.path);
    expect(realm.syncSession, realm.syncSession);
  });

  baasTest('SyncSession.user returns a valid user', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema]);
    final realm = getRealm(config);

    expect(realm.syncSession.user, user);
    expect(realm.syncSession.user.id, user.id);
    expect(realm.syncSession.user.app.id, configuration.appId);
    expect(realm.syncSession.user.app.currentUser, user);
  });

  baasTest('SyncSession when isolate is torn down does not crash', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema]);

    // Don't use getRealm because we want the Realm to survive
    final realm = Realm(config);

    expect(realm.syncSession, isNotNull);
  }, skip: 'crashes');

  Future<void> validateSessionStates(String validationName, Session session,
      {SessionState? expectedSessionState, ConnectionState? expectedConnectionState}) async {
    if (expectedSessionState != null) {
      await waitForCondition(() => session.state.name == expectedSessionState.name,
          message: 'Expected ${session.state} to equal $expectedSessionState. Validation: $validationName', timeout: const Duration(seconds: 15));
    }

    if (expectedConnectionState != null) {
      await waitForCondition(() => session.connectionState.name == expectedConnectionState.name,
          message: 'Expected ${session.connectionState} to equal $expectedConnectionState. Validation: $validationName', timeout: const Duration(seconds: 15));
    }
  }

  baasTest('SyncSession.pause/resume', (configuration) async {
    final realm = await getIntegrationRealm();

    await validateSessionStates("Initial state", realm.syncSession,
        expectedSessionState: SessionState.active, expectedConnectionState: ConnectionState.connected);

    realm.syncSession.pause();

    await validateSessionStates("State after pause", realm.syncSession,
        expectedSessionState: SessionState.inactive, expectedConnectionState: ConnectionState.disconnected);

    realm.syncSession.resume();

    await validateSessionStates("State after resume", realm.syncSession,
        expectedSessionState: SessionState.active, expectedConnectionState: ConnectionState.connected);
  });

  baasTest('SyncSession.pause called multiple times is a no-op', (configuration) async {
    final realm = await getIntegrationRealm();

    await validateSessionStates("Initial state", realm.syncSession, expectedSessionState: SessionState.active);

    realm.syncSession.pause();

    await validateSessionStates("State after pause", realm.syncSession, expectedSessionState: SessionState.inactive);

    // This should not do anything
    realm.syncSession.pause();

    await validateSessionStates("State after second pause", realm.syncSession, expectedSessionState: SessionState.inactive);
  });

  baasTest('SyncSession.resume called multiple times is a no-op', (configuration) async {
    final realm = await getIntegrationRealm();

    await validateSessionStates("Initial state", realm.syncSession, expectedSessionState: SessionState.active);

    realm.syncSession.resume();
    realm.syncSession.resume();

    await validateSessionStates("State after resume called multiple times", realm.syncSession, expectedSessionState: SessionState.active);
  });

  baasTest('SyncSession.waitForUpload with no changes', (configuration) async {
    final realm = await getIntegrationRealm();

    await realm.syncSession.waitForUpload();

    // Call it multiple times to make sure it doesn't throw
    await realm.syncSession.waitForUpload();
  });

  baasTest('SyncSession.waitForDownload with no changes', (configuration) async {
    final realm = await getIntegrationRealm();

    await realm.syncSession.waitForDownload();

    // Call it multiple times to make sure it doesn't throw
    await realm.syncSession.waitForDownload();
  });

  baasTest('SyncSesison.waitForUpload with changes', (configuration) async {
    final differentiator = ObjectId();

    final realmA = await getIntegrationRealm(differentiator: differentiator);
    final realmB = await getIntegrationRealm(differentiator: differentiator);

    realmA.write(() {
      realmA.add(NullableTypes(ObjectId(), differentiator, stringProp: 'abc'));
    });

    await realmA.syncSession.waitForUpload();
    await realmB.syncSession.waitForDownload();

    expect(realmA.all<NullableTypes>().map((e) => e.stringProp), realmB.all<NullableTypes>().map((e) => e.stringProp));

    realmB.write(() {
      realmB.add(NullableTypes(ObjectId(), differentiator, stringProp: 'def'));
    });

    await realmB.syncSession.waitForUpload();
    await realmA.syncSession.waitForDownload();

    expect(realmA.all<NullableTypes>().map((e) => e.stringProp), realmB.all<NullableTypes>().map((e) => e.stringProp));
  });

  StreamProgressData subscribeToProgress(Realm realm, ProgressDirection direction, ProgressMode mode) {
    final data = StreamProgressData();
    final stream = realm.syncSession.getProgressStream(direction, mode);
    data.subscription = stream.listen((event) {
      expect(event.transferredBytes, greaterThanOrEqualTo(data.transferredBytes));
      if (data.transferableBytes != 0) {
        // We need to wait for the first event to store the total bytes we expect.
        if (mode == ProgressMode.forCurrentlyOutstandingWork) {
          // Transferable should not change after the first event
          expect(event.transferableBytes, data.transferableBytes);
        } else {
          // For indefinite progress, we expect the transferable bytes to not decrease
          expect(event.transferableBytes, greaterThanOrEqualTo(data.transferableBytes));
        }
      }

      data.transferredBytes = event.transferredBytes;
      data.transferableBytes = event.transferableBytes;
      data.callbacksInvoked++;
    });

    data.subscription.onDone(() {
      data.doneInvoked = true;
    });

    return data;
  }

  Future<void> validateData(StreamProgressData data, {bool expectDone = false}) async {
    // Wait a little since the last event is sent asynchronously
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(data.callbacksInvoked, greaterThan(0));
    expect(data.transferableBytes, greaterThan(0));
    expect(data.transferredBytes, greaterThan(0));
    if (expectDone) {
      expect(data.transferredBytes, data.transferableBytes);
    } else {
      expect(data.transferredBytes, lessThanOrEqualTo(data.transferableBytes));
    }
    expect(data.doneInvoked, expectDone);
  }

  baasTest('SyncSession.getProgressStream forCurrentlyOutstandingWork', (configuration) async {
    final differentiator = ObjectId();
    final realmA = await getIntegrationRealm(differentiator: differentiator);
    final realmB = await getIntegrationRealm(differentiator: differentiator);

    for (var i = 0; i < 10; i++) {
      realmA.write(() {
        realmA.add(NullableTypes(ObjectId(), differentiator, stringProp: generateRandomString(50)));
      });
    }

    final uploadData = subscribeToProgress(realmA, ProgressDirection.upload, ProgressMode.forCurrentlyOutstandingWork);

    await realmA.syncSession.waitForUpload();

    // Subscribe immediately after the upload to ensure we get the entire upload message as progress notifications
    final downloadData = subscribeToProgress(realmB, ProgressDirection.download, ProgressMode.forCurrentlyOutstandingWork);

    await validateData(uploadData, expectDone: true);

    await realmB.syncSession.waitForDownload();

    await validateData(downloadData, expectDone: true);

    await uploadData.subscription.cancel();
    await downloadData.subscription.cancel();
  });

  baasTest('SyncSession.getProgressStream reportIndefinitely', (configuration) async {
    final differentiator = ObjectId();
    final realmA = await getIntegrationRealm(differentiator: differentiator);
    final realmB = await getIntegrationRealm(differentiator: differentiator);

    for (var i = 0; i < 10; i++) {
      realmA.write(() {
        realmA.add(NullableTypes(ObjectId(), differentiator, stringProp: generateRandomString(50)));
      });
    }

    final uploadData = subscribeToProgress(realmA, ProgressDirection.upload, ProgressMode.reportIndefinitely);
    final downloadData = subscribeToProgress(realmB, ProgressDirection.download, ProgressMode.reportIndefinitely);

    await realmA.syncSession.waitForUpload();
    await validateData(uploadData);

    await realmB.syncSession.waitForDownload();
    await validateData(downloadData);

    // Snapshot the current state, then add a new object. We should receive more notifications
    final uploadSnapshot = StreamProgressData.snapshot(uploadData);
    final downloadSnapshot = StreamProgressData.snapshot(downloadData);

    realmA.write(() {
      realmA.add(NullableTypes(ObjectId(), differentiator, stringProp: generateRandomString(50)));
    });

    await realmA.syncSession.waitForUpload();
    await realmB.syncSession.waitForDownload();

    await validateData(uploadData);
    await validateData(downloadData);

    expect(uploadData.transferredBytes, greaterThan(uploadSnapshot.transferredBytes));
    expect(uploadData.transferableBytes, greaterThan(uploadSnapshot.transferableBytes));
    expect(uploadData.callbacksInvoked, greaterThan(uploadSnapshot.callbacksInvoked));

    expect(downloadData.transferredBytes, greaterThan(downloadSnapshot.transferredBytes));
    expect(downloadData.transferableBytes, greaterThan(downloadSnapshot.transferableBytes));
    expect(downloadData.callbacksInvoked, greaterThan(downloadSnapshot.callbacksInvoked));

    await uploadData.subscription.cancel();
    await downloadData.subscription.cancel();
  });

  baasTest('SyncSession test error handler', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema], syncErrorHandler: (syncError) {
      expect(syncError, isA<SyncSessionError>());
      final sessionError = syncError.as<SyncSessionError>();
      expect(sessionError.category, SyncErrorCategory.session);
      expect(sessionError.isFatal, false);
      expect(sessionError.code, SyncSessionErrorCode.badAuthentication);
      expect(sessionError.message, "Simulated session error");
    });

    final realm = getRealm(config);

    realm.syncSession.raiseError(SyncErrorCategory.session, SyncSessionErrorCode.badAuthentication.code, false);
  });

  baasTest('SyncSession test fatal error handler', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema], syncErrorHandler: (syncError) {
      expect(syncError, isA<SyncClientError>());
      final syncClientError = syncError.as<SyncClientError>();
      expect(syncClientError.category, SyncErrorCategory.client);
      expect(syncClientError.isFatal, true);
      expect(syncClientError.code, SyncClientErrorCode.badChangeset);
      expect(syncClientError.message, "Simulated client error");
    });
    final realm = getRealm(config);

    realm.syncSession.raiseError(SyncErrorCategory.client, SyncClientErrorCode.badChangeset.code, true);
  });

  baasTest('SyncSession.getConnectionStateStream', (configuration) async {
    final realm = await getIntegrationRealm();

    await validateSessionStates("Initial state", realm.syncSession,
        expectedSessionState: SessionState.active, expectedConnectionState: ConnectionState.connected);

    final states = <ConnectionStateChange>[];
    final stream = realm.syncSession.connectionStateChanges;
    final subscription = stream.listen((event) {
      states.add(event);
    });

    // Verify we get a notification when we pause the session
    realm.syncSession.pause();

    await validateSessionStates("State after pause", realm.syncSession,
        expectedSessionState: SessionState.inactive, expectedConnectionState: ConnectionState.disconnected);
    await waitForCondition(() => states.length == 1, timeout: const Duration(seconds: 15), message: 'expected 1 notification, got ${states.length}');

    expect(states[0].previous.name, ConnectionState.connected.name);
    expect(states[0].current.name, ConnectionState.disconnected.name);

    // When resuming, we should get two notifications - first we go to connecting, then connected
    realm.syncSession.resume();

    await validateSessionStates("State after resume", realm.syncSession,
        expectedSessionState: SessionState.active, expectedConnectionState: ConnectionState.connected);
    await waitForCondition(() => states.length == 3, timeout: const Duration(seconds: 15), message: 'expected 3 notifications, got ${states.length}');

    expect(states[1].previous.name, ConnectionState.disconnected.name);
    expect(states[1].current.name, ConnectionState.connecting.name);

    expect(states[2].previous.name, ConnectionState.connecting.name);
    expect(states[2].current.name, ConnectionState.connected.name);

    await subscription.cancel();
  });

  baasTest('SyncSession when Realm is closed gets closed as well', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema]);
    final realm = getRealm(config);

    final session = realm.syncSession;
    expect(() => session.state, returnsNormally);

    realm.close();

    expect(() => session.state, throws<RealmClosedError>());
  });

  for (SyncWebSocketErrorCode errorCode in SyncWebSocketErrorCode.values.where((v) => v != SyncWebSocketErrorCode.unknown)) {
    baasTest('Sync Web Socket Error ${errorCode.name}', (configuration) async {
      final app = App(configuration);
      final user = await getIntegrationUser(app);
      final config = Configuration.flexibleSync(
        user,
        [Task.schema],
        syncErrorHandler: (syncError) {
          expect(syncError, isA<SyncWebSocketError>());
          final sessionError = syncError.as<SyncWebSocketError>();
          expect(sessionError.category, SyncErrorCategory.webSocket);
          expect(sessionError.code, errorCode);
          expect(sessionError.message, "Simulated session error");
          expect(syncError.codeValue, errorCode.code);
        },
      );
      final realm = getRealm(config);
      realm.syncSession.raiseError(SyncErrorCategory.webSocket, errorCode.code, false);
    });
  }
}

class StreamProgressData {
  int transferredBytes;
  int transferableBytes;
  int callbacksInvoked;
  bool doneInvoked;
  late StreamSubscription<SyncProgress> subscription;

  StreamProgressData({this.transferableBytes = 0, this.transferredBytes = 0, this.callbacksInvoked = 0, this.doneInvoked = false});

  StreamProgressData.snapshot(StreamProgressData other)
      : this(
            transferableBytes: other.transferableBytes,
            callbacksInvoked: other.callbacksInvoked,
            doneInvoked: other.doneInvoked,
            transferredBytes: other.transferredBytes);
}
