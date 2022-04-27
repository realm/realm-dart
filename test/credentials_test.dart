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

  await setupBaas(appName: "func", confirmationType: "runConfirmationFunction");
  await setupBaas(appName: "auto", confirmationType: "autoConfirm");
  await setupBaas(appName: "email", confirmationType: "sendConfirmationEmail");
  await setupTests(args, doSetupBaas: false);

  test('Credentials anonymous', () {
    final credentials = Credentials.anonymous();
    expect(credentials.provider, AuthProviderType.anonymous);
  });

  test('Credentials email/password', () {
    final credentials = Credentials.emailPassword("test@email.com", "000000");
    expect(credentials.provider, AuthProviderType.emailPassword);
  });

  baasTest('Email/Password - register user confirmation throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@bar.com";
    String password = "SWV23R#@T#VFQDV";
    expect(() async {
      // For application with name 'func' and with confirmationType = 'runConfirmationFunction'
      // only usernames that contain 'realm_tests_do_autoverify' are confirmed.
      await authProvider.registerUser(username, password);
    }, throws<RealmException>("failed to confirm user"));
  }, appName: "func");

  baasTest('Email/Password - register user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify${generateRandomString(5)}@bar.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    final user = await app.logIn(Credentials.emailPassword(username, password));
    await app.logout(user);
    await app.removeUser(user);
    expect(user, isNotNull);
  }, appName: "func");

  baasTest('Email/Password - register user auto confirm', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@bar.com";
    String password = "SWV23R#@T#VFQDV";
    // For application with name 'auto' and with confirmationType = 'autoConfirm'
    // all the usernames are automatically confirmed.
    await authProvider.registerUser(username, password);
  }, appName: "auto");


  baasTest('Email/Password - register user twice throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@bar.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    expect(() async {
      await authProvider.registerUser(username, password);
    }, throws<RealmException>("name already in use"));
  }, appName: "auto");

  baasTest('Email/Password - register user with weak/empty password throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@bar.com";
    expect(() async {
      await authProvider.registerUser(username, "pwd");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
    expect(() async {
      await authProvider.registerUser(username, "");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
  }, appName: "auto");

  baasTest('Email/Password - register user with empty email throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    expect(() async {
      await authProvider.registerUser("", "password");
    }, throws<RealmException>("email invalid"));
  }, appName: "auto");

  baasTest('Email/Password - confirm user token expired', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@hotmail.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    expect(() async {
      await authProvider.confirmUser(
          "0e6340a446e68fe02a1af1b53c34d5f630b601ebf807d73d10a7fed5c2e996d87d04a683030377ac6058824d8555b24c1417de79019b40f1299aada7ef37fddc",
          "6268f7dd73fafea76b730fc9");
    }, throws<RealmException>("userpass token is expired or invalid"));
  }, appName: "email");

  baasTest('Email/Password - confirm user token invalid', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@hotmail.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    expect(() async {
      await authProvider.confirmUser("abc", "123");
    }, throws<RealmException>("invalid token data"));
  }, appName: "email");
}
