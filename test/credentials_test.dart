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
    String emailPrefix = generateRandomString(5);
    String username = "$emailPrefix@bar.com"; // Usernames that don't contains 'realm_tests_do_autoverify' are not confirmed
    String password = "SWV23R#@T#VFQDV";
    expect(() async {
      await authProvider.registerUser(username, password);
    }, throws<RealmException>("failed to confirm user"));
  });

  baasTest('Email/Password - register user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String emailPrefix = generateRandomString(5);
    String username = "realm_tests_do_autoverify$emailPrefix@bar.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    final user = await app.logIn(Credentials.emailPassword(username, password));
    await app.logout(user);
    await app.removeUser(user);
    expect(user, isNotNull);
  });

  baasTest('Email/Password - register user twice throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String emailPrefix = generateRandomString(5);
    String username = "realm_tests_do_autoverify$emailPrefix@bar.com";
    String password = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, password);
    expect(() async {
      await authProvider.registerUser(username, password);
    }, throws<RealmException>("name already in use"));
  });

  baasTest('Email/Password - register user with weak/empty password throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String emailPrefix = generateRandomString(5);
    String username = "realm_tests_do_autoverify$emailPrefix@bar.com";
    expect(() async {
      await authProvider.registerUser(username, "pwd");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
    expect(() async {
      await authProvider.registerUser(username, "");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
  });

  baasTest('Email/Password - register user with empty email throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    expect(() async {
      await authProvider.registerUser("", "password");
    }, throws<RealmException>("email invalid"));
  });
}
