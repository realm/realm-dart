// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';

import 'package:realm_dart/realm.dart';

import 'test.dart';

void main() {
  setupTests();

  baasTest('User logout anon user is marked as removed', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.anonymous());
    expect(user.state, UserState.loggedIn);
    await user.logOut();
    expect(user.state, UserState.removed);
  });

  baasTest('User logout', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.state, UserState.loggedIn);
    await user.logOut();
    expect(user.state, UserState.loggedOut);
  });

  baasTest('User get id', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.id, isNotEmpty);
  });

  baasTest('User get identities', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    //singleWhere throws an exception if not found
    expect(user.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword), isA<UserIdentity>());
  });

  baasTest('User get customdata', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.customData, isNull);
  });

  baasTest('User refresh customdata', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    final dynamic data = await user.refreshCustomData();
    expect(data, isNull);
  });

  baasTest('User link credentials', (configuration) async {
    final app = await getApp(configuration);
    final user1 = await getAnonymousUser(app);

    expect(user1.state, UserState.loggedIn);
    expect(user1.identities.length, 1);
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous), isA<UserIdentity>());

    final authProvider = EmailPasswordAuthProvider(app);
    final username = getAutoverifiedEmail();
    final password = generateRandomString(8);
    await authProvider.registerUser(username, password);

    await user1.linkCredentials(Credentials.emailPassword(username, password));
    expect(user1.identities.length, 2);
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword), isA<UserIdentity>());
    expect(user1.identities.singleWhere((identity) => identity.provider == AuthProviderType.anonymous), isA<UserIdentity>());

    final user2 = await app.logIn(Credentials.emailPassword(username, password));
    expect(user1, user2);
  });

  baasTest('User deviceId', (configuration) async {
    final app = await getApp(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    expect(user.deviceId, isNotNull);
    user.logOut();
    expect(user.deviceId, isNotNull);
  });

  baasTest('User profile', (configuration) async {
    final app = await getApp(configuration);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    expect(user.profile.email, testUsername);
  });

  Future<ApiKey> createAndVerifyApiKey(User user, String name) async {
    final result = await user.apiKeys.create(name);
    await waitForConditionWithResult<ApiKey?>(() => user.apiKeys.fetch(result.id), (fetched) => fetched != null, timeout: Duration(seconds: 15));
    return result;
  }

  Future<void> enableAndVerifyApiKey(User user, ObjectId keyId) async {
    await user.apiKeys.enable(keyId);
    await waitForConditionWithResult<ApiKey?>(() => user.apiKeys.fetch(keyId), (fetched) => fetched!.isEnabled, timeout: Duration(seconds: 15));
  }

  Future<void> disableAndVerifyApiKey(User user, ObjectId keyId) async {
    await user.apiKeys.disable(keyId);
    await waitForConditionWithResult<ApiKey?>(() => user.apiKeys.fetch(keyId), (fetched) => !fetched!.isEnabled, timeout: Duration(seconds: 15));
  }

  Future<void> deleteAndVerifyApiKey(User user, ObjectId keyId) async {
    await user.apiKeys.delete(keyId);
    await waitForConditionWithResult<ApiKey?>(() => user.apiKeys.fetch(keyId), (fetched) => fetched == null, timeout: Duration(seconds: 15));
  }

  baasTest('User.apiKeys.create creates and reveals value', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    final apiKey = await createAndVerifyApiKey(user, 'my-api-key');

    expect(apiKey.isEnabled, true);
    expect(apiKey.name, 'my-api-key');
    expect(apiKey.value, isNotNull);
    expect(apiKey.id, isNot(ObjectId.fromValues(0, 0, 0)));
  });

  baasTest('User.apiKeys.create on background isolate', (configuration) async {
    // This test is to ensure that the API key creation works on a background isolate.
    // It was introduced due to: https://github.com/realm/realm-dart/issues/1467
    await getIntegrationUser(appConfig: configuration);
    final appId = configuration.appId;
    expect(Isolate.run(() async {
      final app = App.getById(appId)!;
      final user = app.currentUser!;
      await createAndVerifyApiKey(user, 'my-api-key'); // <-- this would crash before the fix
    }), completes);
  });

  baasTest('User.apiKeys.create with invalid name returns error', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    await expectLater(
        () => user.apiKeys.create('Spaces are not allowed'),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('can only contain ASCII letters, numbers, underscores, and hyphens'))
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))
            .having((e) => e.statusCode, 'statusCode', 400)));
  });

  baasTest('User.apiKeys.create with duplicate name returns error', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    await user.apiKeys.create('my-api-key');
    await expectLater(
        () => user.apiKeys.create('my-api-key'),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('API key with name already exists'))
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))
            .having((e) => e.statusCode, 'statusCode', 409)));
  });

  baasTest('User.apiKeys.fetch with non existent returns null', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final key = await user.apiKeys.fetch(ObjectId());
    expect(key, isNull);
  });

  void expectApiKey(ApiKey? fetched, ApiKey expected, [bool created = false]) {
    expect(fetched, isNotNull);
    expect(fetched!.id, expected.id);
    expect(fetched.isEnabled, expected.isEnabled);
    expect(fetched.name, expected.name);
    expect(fetched.value, isNull);
  }

  baasTest('User.apiKeys.fetch with existent returns result', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    final apiKey = await createAndVerifyApiKey(user, 'my-api-key');

    final refetched = await user.apiKeys.fetch(apiKey.id);

    expectApiKey(refetched, apiKey);
  });

  baasTest('User.apiKeys.fetchAll with no keys returns empty', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    final apiKeys = await user.apiKeys.fetchAll();

    expect(apiKeys, isEmpty);
  });

  baasTest('User.apiKeys.fetchAll from background isolate', (configuration) async {
    // This test is to ensure that the API key creation works on a background isolate.
    // It was introduced due to: https://github.com/realm/realm-dart/issues/1467
    await getIntegrationUser(appConfig: configuration);
    final appId = configuration.appId;
    expect(Isolate.run(() async {
      final app = App.getById(appId)!;
      final user = app.currentUser!;
      user.apiKeys.fetchAll(); // <-- this would crash before the fix
    }), completes);
  });

  baasTest('User.apiKeys.fetchAll with one key returns it', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final original = await createAndVerifyApiKey(user, 'my-api-key');

    final apiKeys = await user.apiKeys.fetchAll();

    expect(apiKeys, hasLength(1));
    expectApiKey(apiKeys.single, original);
  });

  baasTest('User.apiKeys.fetchAll with multiple keys returns all', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final original = <ApiKey>[];
    for (var i = 0; i < 5; i++) {
      original.add(await createAndVerifyApiKey(user, 'my-api-key-$i'));
    }

    final fetched = await user.apiKeys.fetchAll();

    for (var i = 0; i < 5; i++) {
      final fetchedKey = fetched.singleWhere((key) => key.id == original[i].id);
      expectApiKey(fetchedKey, original[i]);
    }
  });

  baasTest('User.apiKeys.delete with non-existent key', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final key = await createAndVerifyApiKey(user, 'key');

    await user.apiKeys.delete(ObjectId());

    final allKeys = await user.apiKeys.fetchAll();
    expect(allKeys, hasLength(1));
    expectApiKey(allKeys.single, key);
  });

  baasTest('User.apiKeys.delete with existent key', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final toDelete = await createAndVerifyApiKey(user, 'to-delete');
    final toRemain = await createAndVerifyApiKey(user, 'to-remain');

    await deleteAndVerifyApiKey(user, toDelete.id);

    final fetched = await user.apiKeys.fetch(toDelete.id);
    expect(fetched, isNull);

    final allKeys = await user.apiKeys.fetchAll();
    expect(allKeys, hasLength(1));
    expectApiKey(allKeys.single, toRemain);
  });

  baasTest('User.apiKeys.disable with non-existent throws', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    await expectLater(
        () => user.apiKeys.disable(ObjectId()),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains("doesn't exist"))
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest('User.apiKeys.enable with non-existent throws', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    await expectLater(
        () => user.apiKeys.enable(ObjectId()),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains("doesn't exist"))
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest('User.apiKeys.enable when enabled is a no-op', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final key = await createAndVerifyApiKey(user, 'my-key');

    expect(key.isEnabled, true);

    await user.apiKeys.enable(key.id);

    final fetched = await user.apiKeys.fetch(key.id);

    expect(fetched!.isEnabled, true);
  });

  baasTest('User.apiKeys.disable when disabled is a no-op', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final key = await createAndVerifyApiKey(user, 'my-key');

    expect(key.isEnabled, true);

    await disableAndVerifyApiKey(user, key.id);

    final fetched = await user.apiKeys.fetch(key.id);
    expect(fetched!.isEnabled, false);

    await user.apiKeys.disable(key.id);

    final refetched = await user.apiKeys.fetch(key.id);
    expect(refetched!.isEnabled, false);
  });

  baasTest('User.apiKeys.disable disables key', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final first = await createAndVerifyApiKey(user, 'first');
    final second = await createAndVerifyApiKey(user, 'second');

    expect(first.isEnabled, true);
    expect(second.isEnabled, true);

    await disableAndVerifyApiKey(user, first.id);

    final fetched = await user.apiKeys.fetchAll();

    final fetchedFirst = fetched.singleWhere((key) => key.id == first.id);
    expect(fetchedFirst.isEnabled, false);

    final fetchedSecond = fetched.singleWhere((key) => key.id == second.id);
    expect(fetchedSecond.isEnabled, true);
  });

  baasTest('User.apiKeys.enable reenables key', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final first = await createAndVerifyApiKey(user, 'first');
    final second = await createAndVerifyApiKey(user, 'second');

    expect(first.isEnabled, true);
    expect(second.isEnabled, true);

    await disableAndVerifyApiKey(user, first.id);

    final fetched = await user.apiKeys.fetchAll();

    final fetchedFirst = fetched.singleWhere((key) => key.id == first.id);
    expect(fetchedFirst.isEnabled, false);

    final fetchedSecond = fetched.singleWhere((key) => key.id == second.id);
    expect(fetchedSecond.isEnabled, true);

    await enableAndVerifyApiKey(user, first.id);

    final refetched = await user.apiKeys.fetchAll();

    final refetchedFirst = refetched.singleWhere((k) => k.id == first.id);
    expect(refetchedFirst.isEnabled, true);

    final refetchedSecond = refetched.singleWhere((k) => k.id == second.id);
    expect(refetchedSecond.isEnabled, true);
  });

  baasTest('User.apiKeys can login with generated key', (configuration) async {
    final app = await getApp(configuration);
    final user = await getIntegrationUser(app: app);

    final key = await createAndVerifyApiKey(user, 'my-key');

    final credentials = Credentials.apiKey(key.value!);

    final apiKeyUser = await app.logIn(credentials);
    expect(apiKeyUser.id, user.id);
  });

  baasTest('User.apiKeys can login with reenabled key', (configuration) async {
    final app = await getApp(configuration);
    final user = await getIntegrationUser(app: app);

    final key = await createAndVerifyApiKey(user, 'my-key');

    await disableAndVerifyApiKey(user, key.id);

    final credentials = Credentials.apiKey(key.value!);

    await expectLater(
        () => app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', equals('unauthorized'))
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));

    await enableAndVerifyApiKey(user, key.id);

    final apiKeyUser = await app.logIn(credentials);
    expect(apiKeyUser.id, user.id);
  });

  baasTest("User.apiKeys can't login with deleted key", (configuration) async {
    final app = await getApp(configuration);
    final user = await getIntegrationUser(app: app);

    final key = await createAndVerifyApiKey(user, 'my-key');

    await deleteAndVerifyApiKey(user, key.id);

    final credentials = Credentials.apiKey(key.value!);

    await expectLater(
        () => app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', equals('unauthorized'))
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest("User.apiKeys when user is logged out throws", (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);
    await user.logOut();

    expect(() => user.apiKeys, throws<RealmError>('User must be logged in to access API keys'));
  });

  baasTest("User.apiKeys.anyMethod when user is logged out throws", (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    // Store in a temp variable as accessing the property will throw
    final apiKeys = user.apiKeys;
    await user.logOut();

    await expectLater(() => apiKeys.create('foo'), throws<RealmError>('User must be logged in to create an API key'));
    await expectLater(() => apiKeys.delete(ObjectId()), throws<RealmError>('User must be logged in to delete an API key'));
    await expectLater(() => apiKeys.disable(ObjectId()), throws<RealmError>('User must be logged in to disable an API key'));
    await expectLater(() => apiKeys.enable(ObjectId()), throws<RealmError>('User must be logged in to enable an API key'));
    await expectLater(() => apiKeys.fetch(ObjectId()), throws<RealmError>('User must be logged in to fetch an API key'));
    await expectLater(() => apiKeys.fetchAll(), throws<RealmError>('User must be logged in to fetch all API keys'));
  });

  baasTest("Credentials.apiKey with server-generated can login user", (configuration) async {
    final app = await getApp(configuration);

    final apiKey = await baasHelper!.createServerApiKey(app, ObjectId().toString());
    final credentials = Credentials.apiKey(apiKey);

    final apiKeyUser = await app.logIn(credentials);

    expect(apiKeyUser.state, UserState.loggedIn);
  });

  baasTest("Credentials.apiKey with disabled server api key throws an error", (configuration) async {
    final app = await getApp(configuration);

    final apiKey = await baasHelper!.createServerApiKey(app, ObjectId().toString(), enabled: false);
    final credentials = Credentials.apiKey(apiKey);

    await expectLater(
        () async => await app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', 'unauthorized')
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest('User.logOut raises changes', (appConfig) async {
    final user = await getIntegrationUser(appConfig: appConfig);

    expect(user.state, UserState.loggedIn);

    final completer = Completer<UserChanges>();
    final subscription = user.changes.listen((event) {
      completer.complete(event);
    });

    await user.logOut();

    expect(user.state, UserState.loggedOut);

    final changeEvent = await completer.future.timeout(Duration(seconds: 15));
    expect(changeEvent.user, user);
    expect(changeEvent.user.state, UserState.loggedOut);

    await subscription.cancel();
  });
}
