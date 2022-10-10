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
    expect(user1, user2);
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

  baasTest('User.apiKeys.create creates and reveals value', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final apiKey = await user.apiKeys.create('my-api-key');

    expect(apiKey.isEnabled, true);
    expect(apiKey.name, 'my-api-key');
    expect(apiKey.value, isNotNull);
    expect(apiKey.id, isNot(ObjectId.fromValues(0, 0, 0)));
  });

  baasTest('User.apiKeys.create with invalid name returns error', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    await expectLater(
        () => user.apiKeys.create('Spaces are not allowed'),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('can only contain ASCII letters, numbers, underscores, and hyphens'))
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))
            .having((e) => e.statusCode, 'statusCode', 400)));
  });

  baasTest('User.apiKeys.create with duplicate name returns error', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    await user.apiKeys.create('my-api-key');
    await expectLater(
        () => user.apiKeys.create('my-api-key'),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('API key with name already exists'))
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))
            .having((e) => e.statusCode, 'statusCode', 409)));
  });

  baasTest('User.apiKeys.fetch with non existent returns null', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.fetch(ObjectId());
    expect(key, isNull);
  });

  void expectApiKey(ApiKey? fetched, ApiKey expected) {
    expect(fetched, isNotNull);
    expect(fetched!.id, expected.id);
    expect(fetched.isEnabled, expected.isEnabled);
    expect(fetched.name, expected.name);
    expect(fetched.value, isNull);
  }

  baasTest('User.apiKeys.fetch with existent returns result', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final apiKey = await user.apiKeys.create('my-api-key');

    final refetched = await user.apiKeys.fetch(apiKey.id);

    expectApiKey(refetched, apiKey);
  });

  baasTest('User.apiKeys.fetchAll with no keys returns empty', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final apiKeys = await user.apiKeys.fetchAll();

    expect(apiKeys.length, 0);
  });

  baasTest('User.apiKeys.fetchAll with one key returns it', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final original = await user.apiKeys.create('my-api-key');

    final apiKeys = await user.apiKeys.fetchAll();

    expect(apiKeys.length, 1);
    expect(apiKeys.single, original);
  });

  baasTest('User.apiKeys.fetchAll with multiple keys returns all', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final original = <ApiKey>[];
    for (var i = 0; i < 5; i++) {
      original.add(await user.apiKeys.create('my-api-key-$i'));
    }

    final fetched = await user.apiKeys.fetchAll();

    for (var i = 0; i < 5; i++) {
      expectApiKey(fetched[i], original[i]);
    }
  });

  baasTest('User.apiKeys.delete with non-existent key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('key');

    await user.apiKeys.delete(ObjectId());

    final allKeys = await user.apiKeys.fetchAll();
    expect(allKeys.length, 1);
    expectApiKey(allKeys.single, key);
  });

  baasTest('User.apiKeys.delete with existent key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final toDelete = await user.apiKeys.create('to-delete');
    final toRemain = await user.apiKeys.create('to-remain');

    await user.apiKeys.delete(toDelete.id);

    final fetched = await user.apiKeys.fetch(toDelete.id);
    expect(fetched, isNull);

    final allKeys = await user.apiKeys.fetchAll();
    expect(allKeys.length, 1);
    expectApiKey(allKeys.single, toRemain);
  });

  baasTest('User.apiKeys.disable with non-existent throws', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    await expectLater(
        () => user.apiKeys.disable(ObjectId()),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains("doesn't exist"))
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest('User.apiKeys.enable with non-existent throws', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    await expectLater(
        () => user.apiKeys.enable(ObjectId()),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains("doesn't exist"))
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest('User.apiKeys.enable when enabled is a no-op', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('my-key');

    expect(key.isEnabled, true);

    await user.apiKeys.enable(key.id);

    final fetched = await user.apiKeys.fetch(key.id);

    expect(fetched!.isEnabled, true);
  });

  baasTest('User.apiKeys.disable when disabled is a no-op', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('my-key');

    expect(key.isEnabled, true);

    await user.apiKeys.disable(key.id);

    final fetched = await user.apiKeys.fetch(key.id);
    expect(fetched!.isEnabled, false);

    await user.apiKeys.disable(key.id);

    final refetched = await user.apiKeys.fetch(key.id);
    expect(refetched!.isEnabled, false);
  });

  baasTest('User.apiKeys.disable disables key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final first = await user.apiKeys.create('first');
    final second = await user.apiKeys.create('second');

    expect(first.isEnabled, true);
    expect(second.isEnabled, true);

    await user.apiKeys.disable(first.id);

    final fetched = await user.apiKeys.fetchAll();
    expect(fetched[0].id, first.id);
    expect(fetched[0].isEnabled, false);

    expect(fetched[1].id, second.id);
    expect(fetched[1].isEnabled, true);
  });

  baasTest('User.apiKeys.enable reenables key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final first = await user.apiKeys.create('first');
    final second = await user.apiKeys.create('second');

    expect(first.isEnabled, true);
    expect(second.isEnabled, true);

    await user.apiKeys.disable(first.id);

    final fetched = await user.apiKeys.fetchAll();
    expect(fetched[0].id, first.id);
    expect(fetched[0].isEnabled, false);

    expect(fetched[1].id, second.id);
    expect(fetched[1].isEnabled, true);

    await user.apiKeys.enable(first.id);

    final refetched = await user.apiKeys.fetchAll();
    expect(refetched[0].id, first.id);
    expect(refetched[0].isEnabled, true);

    expect(refetched[1].id, second.id);
    expect(refetched[1].isEnabled, true);
  });

  baasTest('User.apiKeys can login with generated key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('my-key');
    final credentials = Credentials.apiKey(key.value!);

    final apiKeyUser = await app.logIn(credentials);
    expect(apiKeyUser.provider, AuthProviderType.apiKey);
    expect(apiKeyUser.id, user.id);
    expect(apiKeyUser.refreshToken, isNot(user.refreshToken));
  });

  baasTest('User.apiKeys can login with reenabled key', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('my-key');

    await user.apiKeys.disable(key.id);

    final credentials = Credentials.apiKey(key.value!);

    await expectLater(
        () => app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('invalid API key'))
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));

    await user.apiKeys.enable(key.id);

    final apiKeyUser = await app.logIn(credentials);
    expect(apiKeyUser.provider, AuthProviderType.apiKey);
    expect(apiKeyUser.id, user.id);
    expect(apiKeyUser.refreshToken, isNot(user.refreshToken));
  });

  baasTest("User.apiKeys can't login with deleted key", (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final key = await user.apiKeys.create('my-key');

    await user.apiKeys.delete(key.id);

    final credentials = Credentials.apiKey(key.value!);

    await expectLater(
        () => app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', contains('invalid API key'))
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });

  baasTest("User.apiKeys when user is logged out throws", (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    await user.logOut();

    expect(() => user.apiKeys, throws<RealmError>('User must be logged in to access API keys'));
  });

  baasTest("User.apiKeys.anyMethod when user is logged out throws", (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

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

  baasTest("Credentials.apiKey user cannot access API keys", (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final apiKey = await user.apiKeys.create('my-key');

    final apiKeyUser = await app.logIn(Credentials.apiKey(apiKey.value!));

    expect(() => apiKeyUser.apiKeys, throws<RealmError>('Users logged in with API key cannot manage API keys'));
  });

  baasTest("Credentials.apiKey with server-generated can login user", (configuration) async {
    final app = App(configuration);

    final apiKey = await createServerApiKey(app, ObjectId().toString());
    final credentials = Credentials.apiKey(apiKey);

    final apiKeyUser = await app.logIn(credentials);

    expect(apiKeyUser.provider, AuthProviderType.apiKey);
    expect(apiKeyUser.state, UserState.loggedIn);
  });

  baasTest("Credentials.apiKey with disabled server api key throws an error", (configuration) async {
    final app = App(configuration);

    final apiKey = await createServerApiKey(app, ObjectId().toString(), enabled: false);
    final credentials = Credentials.apiKey(apiKey);

    await expectLater(
        () async => await app.logIn(credentials),
        throwsA(isA<AppException>()
            .having((e) => e.message, 'message', 'invalid API key')
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.linkToServerLogs, 'linkToServerLogs', contains('logs?co_id='))));
  });
}
