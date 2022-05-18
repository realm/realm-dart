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

import 'dart:io';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Realm.syncSession throws on wrong configuration', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    expect(() => realm.syncSession, throws<RealmError>());
  });

  baasTest('Realm.syncSession returns on FLX configuration', (configuration) async {
    final realm = await getIntegrationRealm([Task.schema]);

    expect(realm.syncSession, isNotNull);
    expect(realm.syncSession.path, realm.config.path);
    expect(realm.syncSession, realm.syncSession);
  });

  baasTest('Realm.syncSession returns on FLX configuration', (configuration) async {
    final realm = await getIntegrationRealm([Task.schema]);

    expect(realm.syncSession, isNotNull);
    expect(realm.syncSession.path, realm.config.path);
    expect(realm.syncSession, realm.syncSession);
  });

  baasTest('SyncSession.user returns a valid user', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema]);
    final realm = getRealm(config);

    expect(realm.syncSession.user, user);
    expect(realm.syncSession.user.id, user.id);
  });

  baasTest('SyncSession when isolate is torn down does not crash', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema]);

    // Don't use getRealm because we want the Realm to survive
    final realm = Realm(config);

    expect(realm.syncSession, isNotNull);
  }, skip: 'crashes');

  Future<void> _validateSessionStates(Session session, {SessionState? sessionState, ConnectionState? connectionState}) async {
    if (sessionState != null) {
      expect(session.state.name, sessionState.name);
    }

    if (connectionState != null) {
      // The connection requires a bit of time to update its state
      await Future<void>.delayed(Duration(milliseconds: 100));
      expect(session.connectionState.name, connectionState.name);
    }
  }

  baasTest('SyncSession.pause/resume', (configuration) async {
    final realm = await getIntegrationRealm([Task.schema]);

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.active, connectionState: ConnectionState.connected);

    realm.syncSession.pause();

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.inactive, connectionState: ConnectionState.disconnected);

    realm.syncSession.resume();

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.active, connectionState: ConnectionState.connected);
  });

  baasTest('SyncSession.pause called multiple times is a no-op', (configuration) async {
    final realm = await getIntegrationRealm([Task.schema]);

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.active);

    realm.syncSession.pause();

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.inactive);

    // This should not do anything
    realm.syncSession.pause();

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.inactive);
  });

  baasTest('SyncSession.resume called multiple times is a no-op', (configuration) async {
    final realm = await getIntegrationRealm([Task.schema]);

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.active);

    realm.syncSession.resume();
    realm.syncSession.resume();

    await _validateSessionStates(realm.syncSession, sessionState: SessionState.active);
  });

  baasTest('SyncSession.user returns a valid user', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Task.schema], errorHandlerCallback: (sessionError) {
      print(sessionError.message);
    });
    final realm = getRealm(config);
    //realm.syncSession.raiseSessionError(realm.syncSession);
    expect(realm.syncSession.user.id, user.id);
  });
}
