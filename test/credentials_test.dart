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

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  const String strongPassword = "SWV23R#@T#VFQDV";

  await setupTests(args);

  test('Credentials anonymous', () {
    final credentials = Credentials.anonymous();
    expect(credentials.provider, AuthProviderType.anonymous);
  });

  baasTest('Anonymous - new user', (configuration) async {
    final app = App(configuration);
    final user1 = await app.logIn(Credentials.anonymous());
    final user2 = await app.logIn(Credentials.anonymous());
    final user3 = await app.logIn(Credentials.anonymous(reuseCredentials: false));

    expect(user1, user2);
    expect(user1, isNot(user3));
    expect(user1.provider, AuthProviderType.anonymous);
    expect(user3.provider, AuthProviderType.anonymous);
  });

  test('Credentials email/password', () {
    final credentials = Credentials.emailPassword("test@email.com", "000000");
    expect(credentials.provider, AuthProviderType.emailPassword);
  });

  baasTest('Email/Password - register user confirmation throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await expectLater(() {
      // For confirmationType = 'runConfirmationFunction' as it is by default
      // only usernames that contain 'realm_tests_do_autoverify' are confirmed.
      return authProvider.registerUser(username, strongPassword);
    }, throws<AppException>("failed to confirm user"));
  });

  baasTest('Email/Password - register user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify${generateRandomEmail()}";
    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  });

  baasTest('Email/Password - register user auto confirm', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    // For application with name 'autoConfirm' and with confirmationType = 'auto'
    // all the usernames are automatically confirmed.

    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user twice throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() => authProvider.registerUser(username, strongPassword), throws<AppException>("name already in use"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user with weak/empty password throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await expectLater(() => authProvider.registerUser(username, "pwd"), throws<AppException>("password must be between 6 and 128 characters"));
    await expectLater(() => authProvider.registerUser(username, ""), throws<AppException>("password must be between 6 and 128 characters"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user with empty email throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    await expectLater(() => authProvider.registerUser("", "password"), throws<AppException>("email invalid"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - confirm user token expired', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await authProvider.registerUser(username, strongPassword);
    await expectLater(
        () => authProvider.confirmUser(
            "0e6340a446e68fe02a1af1b53c34d5f630b601ebf807d73d10a7fed5c2e996d87d04a683030377ac6058824d8555b24c1417de79019b40f1299aada7ef37fddc",
            "6268f7dd73fafea76b730fc9"),
        throws<AppException>("userpass token is expired or invalid"));
  }, appName: AppNames.emailConfirm);

  baasTest('Email/Password - confirm user token invalid', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() => authProvider.confirmUser("abc", "123"), throws<AppException>("invalid token data"));
  }, appName: AppNames.emailConfirm);

  baasTest('Email/Password - retry custom confirmation function', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_pending_confirm_${generateRandomEmail()}";
    await authProvider.registerUser(username, strongPassword);

    await authProvider.retryCustomConfirmationFunction(username);

    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  });

  baasTest('Email/Password - retry custom confirmation after user is confirmed', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify_${generateRandomEmail()}";
    // Custom confirmation function confirms automatically username with 'realm_tests_do_autoverify'.
    await authProvider.registerUser(username, strongPassword);

    await expectLater(() => authProvider.retryCustomConfirmationFunction(username), throws<AppException>("already confirmed"));
  });

  baasTest('Email/Password - retry custom confirmation for not registered user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await expectLater(() => authProvider.retryCustomConfirmationFunction(username), throws<AppException>("user not found"));
  });

  baasTest('Email/Password - reset password of non-existent user throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = generateRandomEmail();
    await expectLater(() => authProvider.resetPassword(username), throws<AppException>("user not found"));
  }, appName: AppNames.emailConfirm);

  baasTest('Email/Password - call reset password function and login with the new password', (configuration) async {
    final app = App(configuration);
    String username = generateRandomEmail();
    const String newPassword = "!@#!DQXQWD!223eda";
    final authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(username, strongPassword);
    await authProvider.callResetPasswordFunction(username, newPassword, functionArgs: <dynamic>['success']);
    await app.logIn(Credentials.emailPassword(username, newPassword));
    await expectLater(() => app.logIn(Credentials.emailPassword(username, strongPassword)), throws<AppException>("invalid username/password"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - call reset password function with no additional arguments', (configuration) async {
    final app = App(configuration);
    String username = generateRandomEmail();
    const String newPassword = "!@#!DQXQWD!223eda";
    final authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() async {
      // Calling this function with no additional arguments fails for the test
      // because of the specific implementation of resetFunc in the cloud.
      // resetFunc returns status 'fail' in case no other status is passed.
      return await authProvider.callResetPasswordFunction(username, newPassword);
    }, throws<AppException>('failed to reset password for user "$username"'));
  }, appName: AppNames.autoConfirm);

  /// JWT Payload data
  /// {
  ///    "sub": "62f394e9bcb9fee0c9aecb76",  //User.identities.id: If it is a new id the user is created, if it is an existing id the user and profile are updated.
  ///    "name": {
  ///      "firstName": "John",
  ///      "lastName": "Doe"
  ///    },
  ///    "email": "JWT_privatekey_validated_user@realm.io",
  ///    "gender": "male",
  ///    "birthDay": "1999-10-11",
  ///    "minAge": "10",
  ///    "maxAge": "90",
  ///    "company": "Realm",
  ///    "iat": 1660145686,
  ///    "exp": 4813745686, //100 years after Aug 2022
  ///    "aud": "mongodb.com",
  ///    "iss": "https://realm.io"
  /// }
  /// JWT with private key validation is configured in flexible app wich is used by the tests by default.
  baasTest('JWT validation by specified public key  - login', (configuration) async {
    final app = App(configuration);
    String username = "JWT_privatekey_validated_user@realm.io";
    String userId = "62f394e9bcb9fee0c9aecb76";
    var token =
        "eyJraWQiOiIxIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiI2MmYzOTRlOWJjYjlmZWUwYzlhZWNiNzYiLCJuYW1lIjp7ImZpcnN0TmFtZSI6IkpvaG4iLCJsYXN0TmFtZSI6IkRvZSJ9LCJlbWFpbCI6IkpXVF9wcml2YXRla2V5X3ZhbGlkYXRlZF91c2VyQHJlYWxtLmlvIiwiZ2VuZGVyIjoibWFsZSIsImJpcnRoRGF5IjoiMTk5OS0xMC0xMSIsIm1pbkFnZSI6IjEwIiwibWF4QWdlIjoiOTAiLCJjb21wYW55IjoiUmVhbG0iLCJpYXQiOjE2NjAxNDU2ODYsImV4cCI6NDgxMzc0NTY4NiwiYXVkIjoibW9uZ29kYi5jb20iLCJpc3MiOiJodHRwczovL3JlYWxtLmlvIn0.NAy60d4zpzRyJayO9qa6i7T3Yui4vrEJNK5FYhlQGAPCCKmPpBBrPZnOH2QwTsE1sW5jr9EsUPix6PLIauSY4nE-s4JrFb9Yu1QmhzYiXAzzyRK_yJOLmrOujqnWb57Z1KvZo5CsUafTgB5-mbs4t4-udIZEubEgr7sgH51rHK7F1r7EArwT3Fbx-EjPDTN1cWn4945Hku6wk0WgdXwVg6TEaNtT0RrEegw9t63sW1UvOYsgXpHfCePGH8VRX7yYYqu1xBnS1S1ZHNgGNZp3t8pu4lod6jHho0dPetAq9oMSmUP9H2uiKkwqFmWC_bVEjTxX4bGSbLGKZQRkiOn38w";
    final credentials = Credentials.jwt(token);
    final user = await app.logIn(credentials);

    expect(user.state, UserState.loggedIn);
    expect(user.identities[0].id, userId);
    expect(user.provider, AuthProviderType.jwt);
    expect(user.profile.email, username);
    expect(user.profile.name, username);
    expect(user.profile.gender, "male");
    expect(user.profile.birthDay, "1999-10-11");
    expect(user.profile.minAge, "10");
    expect(user.profile.maxAge, "90");
    expect(user.profile.firstName, "John");
    expect(user.profile.lastName, "Doe");
    expect(user.profile["company"], "Realm");
  });

  /// JWT Payload data
  /// {
  ///   "sub": "62f3840b4ac43f38a50b9e2b", //User.identities.id of the existing user realm-test@realm.io
  ///   "name": {
  ///     "firstName": "John",
  ///     "lastName": "Doe"
  ///   },
  ///   "email": "realm_tests_do_autoverify_jwt_user@realm.io",
  ///   "gender": "male",
  ///   "birthDay": "1999-10-11",
  ///   "minAge": "10",
  ///   "maxAge": "90",
  ///   "company": "Realm",
  ///   "iat": 1660145055,
  ///   "exp": 4813745055, //100 years after Aug 2022
  ///   "aud": "mongodb.com",
  ///   "iss": "https://realm.io"
  /// }
  baasTest('JWT - login with existing user and edit profile', (configuration) async {
    final app = App(configuration);
    const username = "realm_tests_do_autoverify_jwt_user@realm.io";
    final authProvider = EmailPasswordAuthProvider(app);
    // Always register jwt_user@#r@D@realm.io as a new user.
    try {
      await authProvider.registerUser(username, strongPassword);
    } on AppException catch (e) {
      {
        if (e.message.contains("name already in use")) {
          // If the user exists, delete it and register a new one with the same name and empty profile
          final user1 = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
          await app.deleteUser(user1);
          await authProvider.registerUser(username, strongPassword);
        }
      }
    }
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    UserIdentity emailIdentity = user.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword);
    expect(emailIdentity.provider, isNotNull);
    var userId = emailIdentity.id;

    expect(user.state, UserState.loggedIn);
    expect(user.provider, AuthProviderType.emailPassword);
    expect(user.profile.email, username);
    expect(user.profile.name, isNull);
    expect(user.profile.gender, isNull);
    expect(user.profile.birthDay, isNull);
    expect(user.profile.minAge, isNull);
    expect(user.profile.maxAge, isNull);
    expect(user.profile.firstName, isNull);
    expect(user.profile.lastName, isNull);
    expect(user.profile["company"], isNull);

    var token =
        "eyJraWQiOiIxIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiI2MmYzODQwYjRhYzQzZjM4YTUwYjllMmIiLCJuYW1lIjp7ImZpcnN0TmFtZSI6IkpvaG4iLCJsYXN0TmFtZSI6IkRvZSJ9LCJlbWFpbCI6InJlYWxtX3Rlc3RzX2RvX2F1dG92ZXJpZnlfand0X3VzZXJAcmVhbG0uaW8iLCJnZW5kZXIiOiJtYWxlIiwiYmlydGhEYXkiOiIxOTk5LTEwLTExIiwibWluQWdlIjoiMTAiLCJtYXhBZ2UiOiI5MCIsImNvbXBhbnkiOiJSZWFsbSIsImlhdCI6MTY4MDI4MDg3NSwiZXhwIjo0ODMzODgwODc1LCJhdWQiOiJtb25nb2RiLmNvbSIsImlzcyI6Imh0dHBzOi8vcmVhbG0uaW8ifQ.Wc-jGXtVqLSCmRP644Uocm1B2nE4DQtRMhDeIyZWa1NNGZrI62o6g8MguUePTqCw0Qc4fn7gdE98JAHrblT2ZtdHnnNjaUQ8p1EikkKzS6h_GgWjUv4hIAEHtwAPbxVJGXQcwBCoDtBknLMxn9pErjI9xJyqM9B7T7RAELQDH4vNlEUN1KrZQATU5PQGPqjWVxWqt3T3WaNlvyHC2L4pfddhwocEu0ALHux2CZy4ixnUJ3CYqh3Lka5saxWa1djhcy4Uku4fsA948sduwQF1UdI4mjQN0gwNIODQVb9HjaSSZh3nuUCDocB2VokmBczT1WGgVRAVbDlmyGKf6BvRjg";
    await user.linkCredentials(Credentials.jwt(token));

    UserIdentity jwtIdentity = user.identities.singleWhere((identity) => identity.provider == AuthProviderType.jwt);
    expect(jwtIdentity.provider, isNotNull);
    var jwtUserId = jwtIdentity.id;

    var jwtUser = await loginWithRetry(app, Credentials.jwt(token));

    expect(jwtUser.state, UserState.loggedIn);
    expect(jwtUser.identities.singleWhere((identity) => identity.provider == AuthProviderType.jwt).id, jwtUserId);
    expect(jwtUser.identities.singleWhere((identity) => identity.provider == AuthProviderType.emailPassword).id, userId);
    expect(jwtUser.provider, AuthProviderType.jwt);
    expect(jwtUser.profile.email, username);
    expect(jwtUser.profile.name, username);
    expect(jwtUser.profile.gender, "male");
    expect(jwtUser.profile.birthDay, "1999-10-11");
    expect(jwtUser.profile.minAge, "10");
    expect(jwtUser.profile.maxAge, "90");
    expect(jwtUser.profile.firstName, "John");
    expect(jwtUser.profile.lastName, "Doe");
    expect(jwtUser.profile["company"], "Realm");
  });

  /// Token signed with private key different than the one configured in Atlas 'flexible' app JWT authentication provider
  /// JWT Payload data
  /// {
  ///  "sub": "62f396888af8720b373ff06a",
  ///  "email": "wong_signiture_key@realm.io",
  ///  "iat": 1660142215,
  ///  "exp": 4813742215, //100 years after Aug 2022
  ///  "aud": "mongodb.com",
  ///  "iss": "https://realm.io"
  /// }
  baasTest('JWT with wrong signiture key - login fails', (configuration) async {
    final app = App(configuration);
    var token =
        "eyJraWQiOiIxIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiI2MmYzOTY4ODhhZjg3MjBiMzczZmYwNmEiLCJlbWFpbCI6Indvbmdfc2lnbml0dXJlX2tleUByZWFsbS5pbyIsImlhdCI6MTY2MDE0MjIxNSwiZXhwIjo0ODEzNzQyMjE1LCJhdWQiOiJtb25nb2RiLmNvbSIsImlzcyI6Imh0dHBzOi8vcmVhbG0uaW8ifQ.Af--ZUCL_KC7lAhrD_d1lq91O7qVwu7GqXifwxKojkLCkbjmAER9K2Xa7BPO8xNstFeX8m9uBo4BCD5B6XmngSmyCj5OZWdiG5LTR_uhA3MnpqcV3Vu40K4Yx8XrjPuCL39xVPnEfPKLGz5TjEcMLa8xMPqo51byX0q3mR2eSS4w1A7c5TiTNuQ23_SCO8aK95SyXwuUmU4mH0iR4sHPtf64WyoAXkx8w5twXExzky1_h473CwtAERdMsBhwz1YzFKP0kxU31pg5SRciF5Ly66sK1fSPTMQPuVdS_wKvAYll8_trWnWS83M3_PWs4UxzOdjSpoK0uqhN-_IC38YOGg";
    final credentials = Credentials.jwt(token);
    await expectLater(() => app.logIn(credentials), throws<AppException>("crypto/rsa: verification error"));
  });

  baasTest('Facebook credentials - invalid or expired token', (configuration) async {
    final app = App(configuration);
    final accessToken = 'invalid or expired token';
    final credentials = Credentials.facebook(accessToken);
    await expectLater(() => app.logIn(credentials), throws<AppException>("error fetching info from OAuth2 provider"));
  });

  baasTest('Function credentials - wrong payload', (configuration) {
    final payload = 'Wrong EJSON format';
    expect(() => Credentials.function(payload), throws<RealmException>("parse error"));
  });

  baasTest('Function credentials - login with new user', (configuration) async {
    final app = App(configuration);
    var userId = ObjectId().toString();
    String username = generateRandomEmail();
    final payload = '{"username":"$username","userId":"$userId"}';
    final credentials = Credentials.function(payload);
    final user = await app.logIn(credentials);
    expect(user.identities[0].id, userId);
    expect(user.provider, AuthProviderType.function);
    expect(user.identities[0].provider, AuthProviderType.function);
  });

  baasTest('Function credentials - login with existing user', (configuration) async {
    final app = App(configuration);
    var userId = ObjectId().toString();
    final payload = '{"userId":"$userId"}';

    final credentials = Credentials.function(payload);
    final user = await app.logIn(credentials);
    expect(user.identities[0].id, userId);
    expect(user.provider, AuthProviderType.function);
    user.logOut();

    final sameUser = await app.logIn(credentials);
    expect(sameUser.id, user.id);

    expect(sameUser.identities[0].id, userId);
    expect(sameUser.provider, AuthProviderType.function);
  });

  test('Credentials providers', () {
    expect(Credentials.anonymous().provider, AuthProviderType.anonymous);
    expect(Credentials.anonymous(reuseCredentials: false).provider, AuthProviderType.anonymous);
    expect(Credentials.apiKey("").provider, AuthProviderType.apiKey);
    expect(Credentials.apple("").provider, AuthProviderType.apple);
    expect(Credentials.emailPassword("", "").provider, AuthProviderType.emailPassword);
    expect(Credentials.facebook("").provider, AuthProviderType.facebook);
    expect(Credentials.function("{}").provider, AuthProviderType.function);
    expect(Credentials.googleAuthCode("").provider, AuthProviderType.google);
    expect(Credentials.googleIdToken("").provider, AuthProviderType.google);
    expect(Credentials.jwt("").provider, AuthProviderType.jwt);
  });
}
