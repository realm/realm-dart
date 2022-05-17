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

import 'dart:convert';
import 'dart:io';

import 'package:test/expect.dart';

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('AppConfiguration can be initialized', () {
    final defaultAppConfig = AppConfiguration('myapp');
    expect(defaultAppConfig.appId, 'myapp');
    expect(defaultAppConfig.baseFilePath.path, Configuration.filesPath);
    expect(defaultAppConfig.baseUrl, Uri.parse('https://realm.mongodb.com'));
    expect(defaultAppConfig.defaultRequestTimeout, const Duration(minutes: 1));
    expect(defaultAppConfig.logLevel, LogLevel.error);
    expect(defaultAppConfig.metadataPersistenceMode, MetadataPersistenceMode.plaintext);

    final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: Directory.systemTemp,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      localAppName: 'bar',
      localAppVersion: "1.0.0",
      metadataPersistenceMode: MetadataPersistenceMode.disabled,
      logLevel: LogLevel.info,
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );
    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseFilePath.path, Directory.systemTemp.path);
    expect(appConfig.baseUrl, Uri.parse('https://not_re.al'));
    expect(appConfig.defaultRequestTimeout, const Duration(seconds: 2));
    expect(appConfig.logLevel, LogLevel.info);
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.disabled);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 1));
    expect(appConfig.httpClient, httpClient);
  });
  
test('AppConfiguration can be created with defaults', () {
    final appConfig = AppConfiguration('myapp1');
    final app = App(appConfig);
    expect(app.configuration.appId, 'myapp1');
    expect(app.configuration.baseUrl, Uri.parse('https://realm.mongodb.com'));
    expect(app.configuration.defaultRequestTimeout, const Duration(minutes: 1));
    expect(app.configuration.logLevel, LogLevel.error);
    expect(app.configuration.metadataPersistenceMode, MetadataPersistenceMode.plaintext);
    expect(app.configuration.maxConnectionTimeout, const Duration(minutes: 2));
    expect(app.configuration.httpClient, isNotNull);
  });

  test('AppConfiguration can be created', () {
    final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: Directory.systemTemp,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      localAppName: 'bar',
      localAppVersion: "1.0.0",
      metadataPersistenceMode: MetadataPersistenceMode.encrypted,
      metadataEncryptionKey: base64.decode("ekey"),
      logLevel: LogLevel.info,
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );
    final app = App(appConfig);
    expect(app.configuration.appId, 'myapp1');
    expect(app.configuration.baseFilePath.path, Directory.systemTemp.path);
    expect(app.configuration.baseUrl, Uri.parse('https://not_re.al'));
    expect(app.configuration.defaultRequestTimeout, const Duration(seconds: 2));
    expect(app.configuration.logLevel, LogLevel.info);
    expect(app.configuration.metadataPersistenceMode, MetadataPersistenceMode.encrypted);
    expect(app.configuration.maxConnectionTimeout, const Duration(minutes: 1));
    expect(app.configuration.httpClient, httpClient);
  });

  test('App can be created', () async {
    final configuration = AppConfiguration(generateRandomString(10));
    final app = App(configuration);
    expect(app.configuration, configuration);
  });

  baasTest('App log in', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
  });

  test('Application get all users', () {
    final configuration = AppConfiguration(generateRandomString(10));
    final app = App(configuration);
    var users = app.users;
    expect(users.isEmpty, true);
  });

  baasTest('App log out user', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    expect(user.state, UserState.loggedIn);
    await user.logOut();
    expect(user.state, UserState.loggedOut);
  });

  baasTest('App remove user', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    expect(user.state, UserState.loggedIn);
    await app.removeUser(user);
    expect(user.state, UserState.removed);
  });

  baasTest('App log out anonymous user is marked as removed', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
    await user.logOut();
    expect(user.state, UserState.removed);
  });

  baasTest('App remove anonymous user', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
    await app.removeUser(user);
    expect(user.state, UserState.removed);
  });

  baasTest('App get current user', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    expect(app.currentUser, isNull);

    final user = await app.logIn(credentials);

    expect(app.currentUser, isNotNull);
    expect(app.currentUser, user);
  });

  baasTest('App switch user', (configuration) async {
    final app = App(configuration);
    expect(app.currentUser, isNull);

    final user1 = await app.logIn(Credentials.anonymous());
    expect(app.currentUser, user1);
    
    final user2 = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    expect(app.currentUser, user2);

    app.switchUser(user1);
    expect(app.currentUser, user1);
  });

  baasTest('App get users', (configuration) async {
    final app = App(configuration);
    expect(app.currentUser, isNull);
    expect(app.users.length, 0);

    final user = await app.logIn(Credentials.anonymous());
    final user1 = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(app.users, [user1, user]);
  });
}
