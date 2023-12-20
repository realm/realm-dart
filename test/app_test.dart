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
import 'dart:isolate';
import 'package:logging/logging.dart';
import 'package:test/expect.dart' hide throws;
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/native/realm_core.dart';
import 'test.dart';

void main() {
  setupTests();

  test('AppConfiguration can be initialized', () {
    Configuration.defaultRealmPath = path.join(Configuration.defaultStoragePath, Configuration.defaultRealmName);
    final defaultAppConfig = AppConfiguration('myapp');
    expect(defaultAppConfig.appId, 'myapp');
    expect(defaultAppConfig.baseFilePath.path, Configuration.defaultStoragePath);
    expect(defaultAppConfig.baseUrl, Uri.parse('https://realm.mongodb.com'));
    expect(defaultAppConfig.defaultRequestTimeout, const Duration(minutes: 1));
    expect(defaultAppConfig.metadataPersistenceMode, MetadataPersistenceMode.plaintext);

    final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: Directory.systemTemp,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      metadataPersistenceMode: MetadataPersistenceMode.disabled,
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );
    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseFilePath.path, Directory.systemTemp.path);
    expect(appConfig.baseUrl, Uri.parse('https://not_re.al'));
    expect(appConfig.defaultRequestTimeout, const Duration(seconds: 2));
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.disabled);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 1));
    expect(appConfig.httpClient, httpClient);
  });

  test('AppConfiguration can be created with defaults', () {
    final appConfig = AppConfiguration('myapp1');
    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseUrl, Uri.parse('https://realm.mongodb.com'));
    expect(appConfig.defaultRequestTimeout, const Duration(minutes: 1));
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.plaintext);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 2));
    expect(appConfig.httpClient, isNotNull);

    // Check that the app constructor works
    App(appConfig);
  });

  test('AppConfiguration can be created', () {
    final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: Directory.systemTemp,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      metadataPersistenceMode: MetadataPersistenceMode.encrypted,
      metadataEncryptionKey: base64.decode("ekey"),
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );

    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseFilePath.path, Directory.systemTemp.path);
    expect(appConfig.baseUrl, Uri.parse('https://not_re.al'));
    expect(appConfig.defaultRequestTimeout, const Duration(seconds: 2));
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.encrypted);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 1));
    expect(appConfig.httpClient, httpClient);

    // Check that the app constructor works
    App(appConfig);
  });

  test('App can be created', () async {
    final configuration = AppConfiguration(generateRandomString(10));
    final app = App(configuration);
    expect(app.id, configuration.appId);
  });

  baasTest('App log in', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
    expect(user.refreshToken, isNotEmpty);
    expect(user.accessToken, isNotEmpty);
  });

  test('Application get all users', () {
    final configuration = AppConfiguration(generateRandomString(10));
    final app = App(configuration);
    var users = app.users;
    expect(users.isEmpty, true);
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

  baasTest('App delete user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify${generateRandomEmail()}";
    const String strongPassword = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
    expect(user.state, UserState.loggedIn);

    await app.deleteUser(user);
    expect(user.state, UserState.removed);

    await expectLater(() => loginWithRetry(app, Credentials.emailPassword(username, strongPassword)), throws<AppException>("invalid username/password"));
  });

  baasTest('Call Atlas function that does not exist', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    await expectLater(user.functions.call('notExisitingFunction'), throws<AppException>("function not found: 'notExisitingFunction'"));
  });

  baasTest('Call Atlas function with no arguments', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    final dynamic response = await user.functions.call('userFuncNoArgs');
    expect(response, isNotNull);
  });

  baasTest('Call Atlas function on background isolate', (configuration) async {
    final app = App(configuration);
    final appId = app.id;
    expect(Isolate.run(
      () async {
        final app = App.getById(appId)!;
        final user = await app.logIn(Credentials.anonymous());
        await user.functions.call('userFuncNoArgs');
      },
    ), completes);
  });

  baasTest('Call Atlas function with one argument', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    const arg1 = 'Jhonatan';
    final dynamic response = await user.functions.call('userFuncOneArg', [arg1]);
    expect(response, isNotNull);
    final map = response as Map<String, dynamic>;
    expect(map['arg'], arg1);
  });

  baasTest('Call Atlas function with two arguments', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    const arg1 = 'Jhonatan';
    const arg2 = 'Michael';
    final dynamic response = await user.functions.call('userFuncTwoArgs', [arg1, arg2]);
    expect(response, isNotNull);
    final map = response as Map<String, dynamic>;
    expect(map['arg1'], arg1);
    expect(map['arg2'], arg2);
  });

  baasTest('Call Atlas function with two arguments but pass one', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    const arg1 = 'Jhonatan';
    final dynamic response = await user.functions.call('userFuncTwoArgs', [arg1]);
    expect(response, isNotNull);
    final map = response as Map<String, dynamic>;
    expect(map['arg1'], arg1);
    expect(map['arg2'], <String, dynamic>{'\$undefined': true});
  });

  baasTest('Call Atlas function with two Object arguments', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    final arg1 = Person("Jhonatan");
    final arg2 = Person('Michael');
    final dynamic response = await user.functions.call('userFuncTwoArgs', [arg1.toJson(), arg2.toJson()]);
    expect(response, isNotNull);
    final map = response as Map<String, dynamic>;
    final receivedPerson1 = PersonExt.fromJson(map['arg1'] as Map<String, dynamic>);
    final receivedPerson2 = PersonExt.fromJson(map['arg2'] as Map<String, dynamic>);
    expect(receivedPerson1.name, arg1.name);
    expect(receivedPerson2.name, arg2.name);
  });

  baasTest('App.reconnect', (appConfiguration) async {
    final app = App(appConfiguration);
    final realm = await getIntegrationRealm(app: app);
    final session = realm.syncSession;

    // TODO: We miss a way to force a disconnect. Once we implement GenericNetworkTransport
    // we can inject a fake HttpClient to toggle connectivity.
    // <-- force disconnect here
    session.pause(); // ensure we go to ConnectionState.disconnected immediately
    expect(session.connectionState, ConnectionState.disconnected);

    expectLater(
      session.connectionStateChanges.map((c) => c.current).distinct(),
      emitsInOrder(<ConnectionState>[
        ConnectionState.connecting,
        ConnectionState.connected,
      ]),
    );

    session.resume();
    app.reconnect(); // <-- this is not currently needed for this test to pass see above
  });

  baasTest('App switch to logout user throws', (configuration) async {
    final app = App(configuration);
    expect(app.currentUser, isNull);

    final user1 = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    await user1.logOut();

    final user2 = await app.logIn(Credentials.anonymous());
    expect(app.currentUser, user2);
    expect(
      () => app.switchUser(user1),
      throws<RealmException>("Switch user failed. User is no longer valid or is logged out"),
    );
  });

  baasTest('App get Base URL', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    await app.logIn(credentials);
    final baseUrl = app.getBaseUrl();
    expect(baseUrl, isNotNull);
    expect(baseUrl, configuration.baseUrl);
  });

  baasTest('App update Base URL', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    await app.logIn(credentials);
    final baseUrl = app.getBaseUrl();
    expect(baseUrl, isNotNull);
    // Set it to the same thing to confirm the function works, it's not actually going to update the location
    await app.updateBaseUrl(baseUrl!);
    final newBaseUrl = app.getBaseUrl();
    expect(newBaseUrl, isNotNull);
    expect(newBaseUrl, baseUrl);
  });

  test('bundleId is salted, hashed and encoded', () {
    final text = isFlutterPlatform ? "realm_tests" : "realm_dart";
    const salt = [82, 101, 97, 108, 109, 32, 105, 115, 32, 103, 114, 101, 97, 116];
    final expected = base64Encode(sha256.convert([...salt, ...utf8.encode(text)]).bytes);
    expect(realmCore.getBundleId(), expected);
  });

  test('app.getById without apps returns null', () {
    clearCachedApps();
    final app = App.getById('abc');
    expect(app, null);
  });

  test('app.logIn unsuccessful logIn attempt on background isolate', () {
    // This test was introduced due to: https://github.com/realm/realm-dart/issues/1467
    const appId = 'fake-app-id';
    App(AppConfiguration(appId, baseUrl: Uri.parse('https://this-is-a-fake-url.com')));
    expect(Isolate.run(
      () async {
        final app = App.getById(appId);
        await app!.logIn(Credentials.anonymous()); // <-- this line used to crash
      },
    ), throwsA(isA<AppException>()));
  });

  baasTest('app.logIn successful logIn on background isolate', (configuration) {
    // This test was introduced due to: https://github.com/realm/realm-dart/issues/1467
    final appId = configuration.appId;
    App(configuration);
    expect(Isolate.run(
      () async {
        final app = App.getById(appId);
        await app!.logIn(Credentials.anonymous()); // <-- this line used to crash
      },
    ), completes);
  });

  baasTest('app.getById with different baseUrl returns null', (appConfig) {
    final app = App(appConfig);
    expect(App.getById(app.id, baseUrl: Uri.parse('https://foo.bar')), null);
    expect(App.getById(app.id, baseUrl: appConfig.baseUrl), isNotNull);
  });

  baasTest('App(AppConfiguration) on background isolate logs warning', (appConfig) async {
    final receivePort = ReceivePort();
    await Isolate.spawn((args) {
      final logger = Logger.detached('foo');
      final sb = StringBuffer();
      logger.onRecord.listen((event) {
        sb.writeln('${event.level}: ${event.message}');
      });

      Realm.logger = logger;

      final sendPort = args[0];
      App(AppConfiguration('abc'));
      Isolate.exit(sendPort, sb.toString());
    }, [receivePort.sendPort]);

    final log = await receivePort.first as String;

    expect(log, contains('App constructor called on Isolate'));
  });
}

extension PersonExt on Person {
  static Person fromJson(Map<String, dynamic> json) => Person(json['name'] as String);
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};
}
