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

import 'package:test/expect.dart';

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  baasTest('User logout anon user is marked as removed', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    expect(user.state, UserState.loggedIn);
    await user.logout();
    expect(user.state, UserState.removed);
  });

  baasTest('User logout', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.state, UserState.loggedIn);
    await user.logout();
    expect(user.state, UserState.loggedOut);
  });

  baasTest('User get id', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.id, isNotEmpty);
  });

  baasTest('User get identities', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.identities.any((identity) => identity.provider == AuthProviderType.emailPassword), isTrue);
  });

  baasTest('User get customdata', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.customData, isNull);
  });

  baasTest('User refresh customdata', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    final dynamic data = await user.refreshCustomData();
    expect(data, isNull);
  });

  baasTest('User link credentials', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
  
    expect(user.state, UserState.loggedIn);
    expect(user.identities.length, 1);
    expect(user.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous).provider, isNotNull);

    final authProvider = EmailPasswordAuthProvider(app);
    final username = "${generateRandomString(20)}@realm.io";
    final password = generateRandomString(8);
    await authProvider.registerUser(username, password);

    await user.linkCredentials(Credentials.emailPassword(username, password));
    expect(user.identities.length, 2);
    expect(user.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword).provider, isNotNull);
    expect(user.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous).provider, isNotNull);
  }, appName: AppNames.autoConfirm, skip: "Blocked on https://github.com/realm/realm-core/issues/5467");
}
