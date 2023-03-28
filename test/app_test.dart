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

import 'package:logging/logging.dart';
import 'package:test/expect.dart' hide throws;
import 'package:path/path.dart' as path;

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

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
      localAppName: 'bar',
      localAppVersion: "1.0.0",
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
      localAppName: 'bar',
      localAppVersion: "1.0.0",
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

  baasTest('Realm.logger', (configuration) async {
    final oldLogger = Realm.logger;
    try {
      Realm.logger = Logger.detached(generateRandomString(10))..level = RealmLogLevel.all;
      configuration = AppConfiguration(
        configuration.appId,
        baseFilePath: configuration.baseFilePath,
        baseUrl: configuration.baseUrl,
      );

      await testLogger(
        configuration,
        Realm.logger,
        maxExpectedCounts: {
          // No problems expected!
          RealmLogLevel.fatal: 0,
          RealmLogLevel.error: 0,
          RealmLogLevel.warn: 0,
        },
        minExpectedCounts: {
          // these are set low (roughly half of what was seen when test was created),
          // so that changes to core are less likely to break the test
          RealmLogLevel.trace: 10,
          RealmLogLevel.debug: 20,
          RealmLogLevel.detail: 2,
          RealmLogLevel.info: 1,
        },
      );
    } finally {
      Realm.logger = oldLogger; // re-instate previous
    }
  });

  baasTest('Change Realm.logger level at runtime', (configuration) async {
    final oldLogger = Realm.logger;
    try {
      int count = 0;
      Realm.logger = RealmLogger(
          level: RealmLogLevel.off,
          onRecord: (event) {
            count++;
            expect(event.level, Realm.logger.level);
            expect(count, 1); // Occurs only once because of the last error
            print("${event.level}: ${event.message}");
          });

      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      String username = "realm_tests_do_autoverify${generateRandomEmail()}";
      const String strongPassword = "SWV23R#@T#VFQDV";
      await authProvider.registerUser(username, strongPassword);
      final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
      await app.deleteUser(user);

      Realm.logger.level = RealmLogLevel.error;

      await expectLater(() => app.logIn(Credentials.emailPassword(username, strongPassword)), throws<AppException>("invalid username/password"));
    } finally {
      Realm.logger = oldLogger;
    }
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
    await expectLater(user.functions.call('noFunc'), throws<AppException>("function not found: 'noFunc'"));
  });

  baasTest('Call Atlas function with no arguments', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    final dynamic response = await user.functions.call('userFuncNoArgs');
    expect(response, isNotNull);
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
    final receivedPerson1 = PersonJ.fromJson(map['arg1'] as Map<String, dynamic>);
    final receivedPerson2 = PersonJ.fromJson(map['arg2'] as Map<String, dynamic>);
    expect(receivedPerson1.name, arg1.name);
    expect(receivedPerson2.name, arg2.name);
  });

  baasTest('App.reconnect', (appConfiguration) async {
    final app = App(appConfiguration);

    final user = await app.logIn(Credentials.anonymous());
    final configuration = Configuration.flexibleSync(user, [Task.schema]);
    final realm = getRealm(configuration);
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
      throws<RealmException>("Switch user failed. Error code: 4101 . Message: User is no longer valid or is logged out"),
    );
  });
}

Future<void> testLogger(
  AppConfiguration configuration,
  Logger logger, {
  Map<Level, int> minExpectedCounts = const {},
  Map<Level, int> maxExpectedCounts = const {},
}) async {
  // To see the trace, add this:
  /*
  logger.onRecord.listen((event) {
    print('${event.sequenceNumber} ${event.level} ${event.message}');
  });
  */

  // Setup
  clearCachedApps();
  final app = App(configuration);
  final realm = await getIntegrationRealm(app: app);

  // Prepare to capture trace
  final messages = <Level, List<String>>{};
  logger.onRecord.listen((r) {
    if (messages[r.level] == null) {
      messages[r.level] = [];
    }

    messages[r.level]!.add(r.message);
  });

  // Trigger trace
  await realm.syncSession.waitForDownload();

  // Check count of various levels
  for (final e in messages.entries) {
    expect(e.value.length, lessThanOrEqualTo(maxExpectedCounts[e.key] ?? maxInt), reason: 'Unexpected number of ${e.key} messages:\n  ${e.value.join("\n  ")}');
    expect(e.value.length, greaterThanOrEqualTo(minExpectedCounts[e.key] ?? minInt),
        reason: 'Unexpected number of ${e.key} messages:\n  ${e.value.join("\n  ")}');
  }
}

extension PersonJ on Person {
  static Person fromJson(Map<String, dynamic> json) => Person(json['name'] as String);
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};
}
