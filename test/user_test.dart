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
import 'dart:math';

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
    await user.logOut();
    expect(user.state, UserState.removed);
  });

  baasTest('User logout', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.state, UserState.loggedIn);
    await user.logOut();
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
    //singleWhere throws an exception if not found
    expect(user.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword), isA<UserIdentity>());
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
    final user1 = await app.logIn(Credentials.anonymous());

    expect(user1.state, UserState.loggedIn);
    expect(user1.identities.length, 1);
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous).provider, isNotNull);

    final authProvider = EmailPasswordAuthProvider(app);
    final username = "${generateRandomString(20)}@realm.io";
    final password = generateRandomString(8);
    await authProvider.registerUser(username, password);

    await user1.linkCredentials(Credentials.emailPassword(username, password));
    expect(user1.identities.length, 2);
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword).provider, isNotNull);
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous).provider, isNotNull);

    final user2 = await app.logIn(Credentials.emailPassword(username, password));
    expect(user1.id, equals(user2.id));
  }, appName: AppNames.autoConfirm);

  baasTest('User deviceId', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.deviceId, isNotNull);
    user.logOut();
    expect(user.deviceId, isNotNull);
  });

  baasTest('User provider', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    var user = await app.logIn(credentials);
    expect(user.provider, AuthProviderType.anonymous);

    user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.provider, AuthProviderType.emailPassword);
  });

  baasTest('User profile', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.profile.email, testUsername);
  });
}
