// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/handles/realm_core.dart';

import 'test.dart';
import 'utils/platform_util.dart';

void main() {
  setupTests();

  test('AppConfiguration can be initialized', () {
    Configuration.defaultRealmPath = path.join(Configuration.defaultStoragePath, Configuration.defaultRealmName);
    final defaultAppConfig = AppConfiguration('myapp');
    expect(defaultAppConfig.appId, 'myapp');
    expect(defaultAppConfig.baseFilePath, Configuration.defaultStoragePath);
    expect(defaultAppConfig.baseUrl, Uri.parse('https://services.cloud.mongodb.com'));
    expect(defaultAppConfig.defaultRequestTimeout, const Duration(minutes: 1));
    expect(defaultAppConfig.metadataPersistenceMode, MetadataPersistenceMode.plaintext);

    final httpClient = Client();
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: platformUtil.systemTempPath,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      metadataPersistenceMode: MetadataPersistenceMode.disabled,
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );
    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseFilePath, platformUtil.systemTempPath);
    expect(appConfig.baseUrl, Uri.parse('https://not_re.al'));
    expect(appConfig.defaultRequestTimeout, const Duration(seconds: 2));
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.disabled);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 1));
    expect(appConfig.httpClient, httpClient);
  });

  test('AppConfiguration can be created with defaults', () {
    final appConfig = AppConfiguration('myapp1');
    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseUrl, Uri.parse('https://services.cloud.mongodb.com'));
    expect(appConfig.defaultRequestTimeout, const Duration(minutes: 1));
    expect(appConfig.metadataPersistenceMode, MetadataPersistenceMode.plaintext);
    expect(appConfig.maxConnectionTimeout, const Duration(minutes: 2));
    expect(appConfig.httpClient, isNotNull);

    // Check that the app constructor works
    App(appConfig);
  });

  test('AppConfiguration can be created', () {
    final httpClient = Client();
    final appConfig = AppConfiguration(
      'myapp1',
      baseFilePath: platformUtil.systemTempPath,
      baseUrl: Uri.parse('https://not_re.al'),
      defaultRequestTimeout: const Duration(seconds: 2),
      metadataPersistenceMode: MetadataPersistenceMode.encrypted,
      metadataEncryptionKey: base64.decode("ekey"),
      maxConnectionTimeout: const Duration(minutes: 1),
      httpClient: httpClient,
    );

    expect(appConfig.appId, 'myapp1');
    expect(appConfig.baseFilePath, platformUtil.systemTempPath);
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

  test('AppConfiguration.baseUrl points to the correct value', () {
    final configuration = AppConfiguration('abc');
    expect(configuration.baseUrl, Uri.parse('https://services.cloud.mongodb.com'));
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
    expect(app.users, {user1, user});
  });

  baasTest('App delete user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = getAutoverifiedEmail();
    const String strongPassword = "SWV23R#@T#VFQDV";
    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
    expect(user.state, UserState.loggedIn);

    await app.deleteUser(user);
    expect(user.state, UserState.removed);

    await expectLater(
      () => loginWithRetry(app, Credentials.emailPassword(username, strongPassword)),
      throwsA(isA<AppException>()
          .having((e) => e.message, 'message', equals('unauthorized'))
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))),
    );
  });

  baasTest('Call Atlas function that does not exist', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());
    await expectLater(user.functions.call('notExisitingFunction'), throws<AppException>("function not found"));
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
      throws<RealmException>("User is no longer valid or is logged out"),
    );
  });

  baasTest('App get Base URL', (configuration) async {
    final app = App(configuration);
    expect(app.baseUrl, configuration.baseUrl);
  });

  baasTest('App update Base URL', (appConfig) async {
    final config = await baasHelper!.getAppConfig(customBaseUrl: 'https://services.cloud.mongodb.com');
    final app = App(config);
    expect(app.baseUrl, Uri.parse('https://services.cloud.mongodb.com'));
    // Set it to the same thing to confirm the function works, it's not actually going to update the location
    await app.updateBaseUrl(Uri.parse(baasHelper!.baseUrl));
    expect(app.baseUrl, appConfig.baseUrl);
    expect(app.baseUrl, isNot(Uri.parse('https://services.cloud.mongodb.com')));
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
    Realm.logger.setLogLevel(LogLevel.warn);

    final sb = StringBuffer();
    Realm.logger.onRecord.listen((event) {
      sb.writeln('${event.category} ${event.level}: ${event.message}');
    });

    await Isolate.run(() {
      App(AppConfiguration('abc'));
    });

    final log = sb.toString();

    expect(log, contains('App constructor called on Isolate'));
  });

  test('AppConfiguration(empty-id) throws', () {
    expect(() => AppConfiguration(''), throwsA(isA<RealmException>()));
  });

  baasTest('AppConfiguration.syncTimeouts are passed correctly to Core', (appConfig) async {
    Realm.logger.setLogLevel(LogLevel.debug);
    final buffer = StringBuffer();
    final sub = Realm.logger.onRecord.listen((r) => buffer.writeln('[${r.category}] ${r.level}: ${r.message}'));

    final customConfig = AppConfiguration(appConfig.appId,
        baseUrl: appConfig.baseUrl,
        baseFilePath: appConfig.baseFilePath,
        defaultRequestTimeout: appConfig.defaultRequestTimeout,
        syncTimeoutOptions: SyncTimeoutOptions(
            connectTimeout: Duration(milliseconds: 1234),
            connectionLingerTime: Duration(milliseconds: 3456),
            pingKeepAlivePeriod: Duration(milliseconds: 5678),
            pongKeepAliveTimeout: Duration(milliseconds: 7890),
            fastReconnectLimit: Duration(milliseconds: 9012)));

    final realm = await getIntegrationRealm(appConfig: customConfig);
    await realm.syncSession.waitForDownload();

    final log = buffer.toString();
    expect(log, contains('Config param: connect_timeout = 1234 ms'));
    expect(log, contains('Config param: connection_linger_time = 3456 ms'));
    expect(log, contains('Config param: ping_keepalive_period = 5678 ms'));
    expect(log, contains('Config param: pong_keepalive_timeout = 7890 ms'));
    expect(log, contains('Config param: fast_reconnect_limit = 9012 ms'));

    await sub.cancel();
  });
}

extension PersonExt on Person {
  static Person fromJson(Map<String, dynamic> json) => Person(json['name'] as String);
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name};
}
