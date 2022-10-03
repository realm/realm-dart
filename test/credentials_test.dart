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
  });

  test('Credentials email/password', () {
    final credentials = Credentials.emailPassword("test@email.com", "000000");
    expect(credentials.provider, AuthProviderType.emailPassword);
  });

  baasTest('Email/Password - register user confirmation throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    await expectLater(() {
      // For confirmationType = 'runConfirmationFunction' as it is by default
      // only usernames that contain 'realm_tests_do_autoverify' are confirmed.
      return authProvider.registerUser(username, strongPassword);
    }, throws<AppException>("failed to confirm user"));
  });

  baasTest('Email/Password - register user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify${generateRandomString(5)}@realm.io";
    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  });

  baasTest('Email/Password - register user auto confirm', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    // For application with name 'autoConfirm' and with confirmationType = 'auto'
    // all the usernames are automatically confirmed.

    await authProvider.registerUser(username, strongPassword);
    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user twice throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() => authProvider.registerUser(username, strongPassword), throws<AppException>("name already in use"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user with weak/empty password throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
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
    String username = "${generateRandomString(5)}@hotmail.com";
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
    String username = "${generateRandomString(5)}@hotmail.com";
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() => authProvider.confirmUser("abc", "123"), throws<AppException>("invalid token data"));
  }, appName: AppNames.emailConfirm);

  // The tests in this group are for manual testing, since they require interaction with mail box.
  // Please enter a valid data in the variables under comments.
  // Run test 1, then copy token and tokenId from mail box.
  // Set the variables with token details and then run test 2.
  // Go to the application and check whether the new registered user is confirmed.
  // Make sure the email haven't been already registered in apllication.
  group("Manual test: Email/Password - confirm user", () {
    // Enter a valid email that is not registered
    const String validUsername = "valid_email@mail.com";

    baasTest('Manual test 1. Register a valid user for email confirmation', (configuration) async {
      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.registerUser(validUsername, strongPassword);
    }, appName: AppNames.emailConfirm, skip: "It is a manual test");

    baasTest('Manual test 2. Take the recieved token from the email and confirm the user', (configuration) async {
      // Enter valid token and tokenId from the received email
      String token = "3a8bdfa28e147f38e531cf5aca93d452a11efc4fc9a81f00219b0cb29cfb93858f6b174123659a6ef47b58a2b80eac3b406d7803605c17ef44401ec6cf2c8fa6";
      String tokenId = "626934dcb4e7e5a0e2f1d85e";

      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.confirmUser(token, tokenId);
      final user = await loginWithRetry(app, Credentials.emailPassword(validUsername, strongPassword));
      expect(user, isNotNull);
    }, appName: AppNames.emailConfirm, skip: "Run this test manually after test 1 and after setting token and tokenId");
  });

  baasTest('Email/Password - retry custom confirmation function', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_pending_confirm_${generateRandomString(5)}@realm.io";
    await authProvider.registerUser(username, strongPassword);

    await authProvider.retryCustomConfirmationFunction(username);

    final user = await loginWithRetry(app, Credentials.emailPassword(username, strongPassword));
    expect(user, isNotNull);
  });

  baasTest('Email/Password - retry custom confirmation after user is confirmed', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "realm_tests_do_autoverify_${generateRandomString(5)}@realm.io";
    // Custom confirmation function confirms automatically username with 'realm_tests_do_autoverify'.
    await authProvider.registerUser(username, strongPassword);

    await expectLater(() => authProvider.retryCustomConfirmationFunction(username), throws<AppException>("already confirmed"));
  });

  baasTest('Email/Password - retry custom confirmation for not registered user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    await expectLater(() => authProvider.retryCustomConfirmationFunction(username), throws<AppException>("user not found"));
  });

  // The tests in this group are for manual testing, since they require interaction with mail box.
  // Please enter a valid data in the variables under comments.
  // Run test 1, then make sure you have recieved two emails.
  // Copy token and tokenId from the second email.
  // Set the variables with token details and then run test 2.
  // Go to the application and check whether the new registered user is confirmed.
  // Make sure the email haven't been already registered in apllication.
  group("Manual test: Email/Password - resend confirm", () {
    // Enter a valid email that is not registered
    const String validUsername = "valid_email@mail.com";
    baasTest('Manual test 1. Register a valid user and resend email confirmation', (configuration) async {
      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.registerUser(validUsername, strongPassword);
      await authProvider.resendUserConfirmation(validUsername);
    }, appName: AppNames.emailConfirm, skip: "It is a manual test");

    baasTest('Manual test 2. Take recieved token from any of both emails and confirm the user', (configuration) async {
      // Make sure you have recieved two emails.
      // Enter valid token and tokenId from the second received email
      String token = "3eb9e380e925075af761fbf36273ad32c5ad898e7cd5fc2e7cf5d0296c5850222ecb55d5d39601f95fc81a67f4b4ca1f7386bc6fef62a0b27498c3157332e155";
      String tokenId = "626b1977dbc08e4014bad1ec";

      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.confirmUser(token, tokenId);
      final user = await loginWithRetry(app, Credentials.emailPassword(validUsername, strongPassword));
      expect(user, isNotNull);
    }, appName: AppNames.emailConfirm, skip: "Run this test manually after test 1 and after setting token and tokenId");
  });

  baasTest('Email/Password - reset password of non-existent user throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    await expectLater(() => authProvider.resetPassword(username), throws<AppException>("user not found"));
  }, appName: AppNames.emailConfirm);

  // The tests in this group are for manual testing, since they require interaction with mail box.
  // Please enter a valid data in the variables under comments.
  // The email should be a valid and existing one in order you to be able to receive automatic emails.
  // Run first two steps (test 1 and test 2) to create and confirm the user.
  // Before running test 2 set the variables with token details received as link query parameters in the confirmation email.
  // Then run test 3, then make sure you have recieved an email with link for reset password.
  // Copy token and tokenId from the email link query parameters.
  // Set the variables with token details and then run test 4.
  // Test 4 will set the pasword and will login the user with the new password.
  group("Manual test: Email/Password - reset password", () {
    // Enter a valid email that is not registered
    const String validUsername = "valid_email@realm.io";

    baasTest('Manual test 1 (resetPassword). Register a valid user', (configuration) async {
      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.registerUser(validUsername, strongPassword);
    }, appName: AppNames.emailConfirm, skip: "It is a manual test");

    baasTest('Manual test 2 (resetPassword). Take recieved token from the received email and confirm the user', (configuration) async {
      // Enter valid token and tokenId from the received email
      String token = "3e23e2e689fe1fdbbb51d3c090a216a4195a4f0a004a578787618d9dd39c791f4169511ee3820e4b6fa2bfdc14430f1e58356223d78e3bed3c86042c3a91a4db";
      String tokenId = "6278cecd9106aa5b645999ba";

      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.confirmUser(token, tokenId);
      final user = await loginWithRetry(app, Credentials.emailPassword(validUsername, strongPassword));
      expect(user, isNotNull);
    }, appName: AppNames.emailConfirm, skip: "It is a manual test");

    baasTest('Manual test 3 (resetPassword). Reset user password email', (configuration) async {
      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      await authProvider.resetPassword(validUsername);
    }, appName: AppNames.emailConfirm, skip: "It is a manual test");

    baasTest('Manual test 4 (resetPassword). Take recieved token from the email and complete resetting new password', (configuration) async {
      // Make sure you have recieved an emails with hyperlink ResetPassword.
      // Find the token and tokenId in the query parameters of the link received in the email and enter them in the following variables.
      String token = "fb485146b15497209a9d1b67128ae29199cdff2c26f389e0ee5d52ae6bc4228e5738b29256eade976e24767804bfb4dc68198075e3a461cd4f73864901fb09be";
      String tokenId = "6272619334f5b3a770a7dc2c";

      final app = App(configuration);
      final authProvider = EmailPasswordAuthProvider(app);
      String newPassword = "RWE@#EDE";
      await authProvider.completeResetPassword(newPassword, token, tokenId);
      final user = await app.logIn(Credentials.emailPassword(validUsername, strongPassword));
      expect(user, isNotNull);
    }, appName: AppNames.emailConfirm, skip: "Run this test manually after test 1 and after setting token and tokenId");
  });

  baasTest('Email/Password - call reset password function and login with the new password', (configuration) async {
    final app = App(configuration);
    String username = "${generateRandomString(5)}@realm.io";
    const String newPassword = "!@#!DQXQWD!223eda";
    final authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(username, strongPassword);
    await authProvider.callResetPasswordFunction(username, newPassword, functionArgs: <dynamic>['success']);
    await app.logIn(Credentials.emailPassword(username, newPassword));
    await expectLater(() => app.logIn(Credentials.emailPassword(username, strongPassword)), throws<AppException>("invalid username/password"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - call reset password function with no additional arguments', (configuration) async {
    final app = App(configuration);
    String username = "${generateRandomString(5)}@realm.io";
    const String newPassword = "!@#!DQXQWD!223eda";
    final authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(username, strongPassword);
    await expectLater(() {
      // Calling this function with no additional arguments fails for the test
      // because of the specific implementation of resetFunc in the cloud.
      // resetFunc returns status 'fail' in case no other status is passed.
      return authProvider.callResetPasswordFunction(username, newPassword);
    }, throws<AppException>("failed to reset password for user $username"));
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
  ///   "email": "jwt_user@#r@D@realm.io",
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
    final username = "jwt_user@#r@D@realm.io";
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
    final user = await app.logIn(Credentials.emailPassword(username, strongPassword));
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
        "eyJraWQiOiIxIiwiYWxnIjoiUlMyNTYiLCJ0eXAiOiJKV1QifQ.eyJzdWIiOiI2MmYzODQwYjRhYzQzZjM4YTUwYjllMmIiLCJuYW1lIjp7ImZpcnN0TmFtZSI6IkpvaG4iLCJsYXN0TmFtZSI6IkRvZSJ9LCJlbWFpbCI6Imp3dF91c2VyQCNyQERAcmVhbG0uaW8iLCJnZW5kZXIiOiJtYWxlIiwiYmlydGhEYXkiOiIxOTk5LTEwLTExIiwibWluQWdlIjoiMTAiLCJtYXhBZ2UiOiI5MCIsImNvbXBhbnkiOiJSZWFsbSIsImlhdCI6MTY2MDE0NTA1NSwiZXhwIjo0ODEzNzQ1MDU1LCJhdWQiOiJtb25nb2RiLmNvbSIsImlzcyI6Imh0dHBzOi8vcmVhbG0uaW8ifQ.AHi4eh3wT9VifM0Hy07vVa2Sck8qlv4st71GaR5UFaytgDW7a-zhLRpPXYt6RX8mjzx6aCenbVr7-Cg8kKxL8XT5x-kmswse8FVtRXi-G5TU2C3AMuMTavP9KCMSpU6_IUfpF_i8kQbrke-YzfS5jflspyEgxHrHTcG0aRIRqBHAmu78er7t3MMv2tbScmipZv-QOXczhTBt0o2wk8iZ-qqTK2X6xb1wbhUS9YtY4oqmuE7n-I_1xah_yd4yF-aS3n13vT-nrm6aIdjwR_EVxAoekN9TTqs0WzpCjy2CcL-LO3RcepUCPQTGwKg9ObTFjJ2URw4FJ_BEA8EfpT_fBg";
    await user.linkCredentials(Credentials.jwt(token));

    UserIdentity jwtIdentity = user.identities.singleWhere((identity) => identity.provider == AuthProviderType.jwt);
    expect(jwtIdentity.provider, isNotNull);
    var jwtUserId = jwtIdentity.id;

    var jwtUser = await app.logIn(Credentials.jwt(token));

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
  }, appName: AppNames.autoConfirm);

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

  ///See test/README.md section 'Manually configure Facebook, Google and Apple authentication providers'"
  baasTest('Facebook credentials - login', (configuration) async {
    final app = App(configuration);
    final accessToken =
        'EAARZCEokqpOMBAKoIHgaG6bqY6LLseGHcQjYdoPhv9FdB89mkVZBWQFOmZCuVeuRfIa5cMtQANLpZBUQI0n4qb4TZCZCAI3vXZC9Oud2qRiieQDtXqE4abZBQJorcBMzECVfsDlus7hk63zW3XzuFCZAxF4BCdRZBHXlGXIzaHhFHhY72aU1apX0tC';
    final credentials = Credentials.facebook(accessToken);
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
    expect(user.provider, AuthProviderType.facebook);
    expect(user.profile.name, "Open Graph Test User");
  }, skip: "Manual test");

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
    String username = "${generateRandomString(5)}@realm.io";
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
}
