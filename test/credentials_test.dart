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

  test('Credentials email/password', () {
    final credentials = Credentials.emailPassword("test@email.com", "000000");
    expect(credentials.provider, AuthProviderType.emailPassword);
  });

  baasTest('Email/Password - register user confirmation throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    expect(() async {
      // For confirmationType = 'runConfirmationFunction' as it is by default
      // only usernames that contain 'realm_tests_do_autoverify' are confirmed.
      await authProvider.registerUser(username, strongPassword);
    }, throws<RealmException>("failed to confirm user"));
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
    expect(() async {
      await authProvider.registerUser(username, strongPassword);
    }, throws<RealmException>("name already in use"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user with weak/empty password throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    expect(() async {
      await authProvider.registerUser(username, "pwd");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
    expect(() async {
      await authProvider.registerUser(username, "");
    }, throws<RealmException>("password must be between 6 and 128 characters"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - register user with empty email throws', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    expect(() async {
      await authProvider.registerUser("", "password");
    }, throws<RealmException>("email invalid"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - confirm user token expired', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@hotmail.com";
    await authProvider.registerUser(username, strongPassword);
    expect(() async {
      await authProvider.confirmUser(
          "0e6340a446e68fe02a1af1b53c34d5f630b601ebf807d73d10a7fed5c2e996d87d04a683030377ac6058824d8555b24c1417de79019b40f1299aada7ef37fddc",
          "6268f7dd73fafea76b730fc9");
    }, throws<RealmException>("userpass token is expired or invalid"));
  }, appName: AppNames.emailConfirm);

  baasTest('Email/Password - confirm user token invalid', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@hotmail.com";
    await authProvider.registerUser(username, strongPassword);
    expect(() async {
      await authProvider.confirmUser("abc", "123");
    }, throws<RealmException>("invalid token data"));
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

    expect(() async {
      await authProvider.retryCustomConfirmationFunction(username);
    }, throws<RealmException>("already confirmed"));
  });

  baasTest('Email/Password - retry custom confirmation for not registered user', (configuration) async {
    final app = App(configuration);
    final authProvider = EmailPasswordAuthProvider(app);
    String username = "${generateRandomString(5)}@realm.io";
    expect(() async {
      await authProvider.retryCustomConfirmationFunction(username);
    }, throws<RealmException>("user not found"));
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
    expect(() async {
      await authProvider.resetPassword(username);
    }, throws<RealmException>("user not found"));
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
    expect(() async {
      await app.logIn(Credentials.emailPassword(username, strongPassword));
    }, throws<RealmException>("invalid username/password"));
  }, appName: AppNames.autoConfirm);

  baasTest('Email/Password - call reset password function with no additional arguments', (configuration) async {
    final app = App(configuration);
    String username = "${generateRandomString(5)}@realm.io";
    const String newPassword = "!@#!DQXQWD!223eda";
    final authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(username, strongPassword);
    expect(() async {
      // Calling this function with no additional arguments fails for the test
      // because of the specific implementation of resetFunc in the cloud.
      // resetFunc returns status 'fail' in case no other status is passed.
      await authProvider.callResetPasswordFunction(username, newPassword);
    }, throws<RealmException>("failed to reset password for user $username"));
  }, appName: AppNames.autoConfirm);

  baasTest('Facebook credentials - login', (configuration) async {
    final app = App(configuration);
    final payload =
        'EAARZCEokqpOMBALs6FuRh6lBW0OElbnCKurX5aWZArRsp6rimRU9Ei9HdHsULkamzjhGMLtAasGQw9tYEQfT452a4adckA7GVYTNhOzLRnwETDU2ouNKBZCGUkDLnQlKNJUf6RSZCaAKwhiCzozyfuAU2ynCyFmo00sftRlTEYnyq0cBUpyUvMSa3CGJD9eqKpZCjF3ZCv9wZDZD';
    final credentials = Credentials.facebook(payload);
    final user = await app.logIn(credentials);
    expect(user.state, UserState.loggedIn);
    expect(user.provider, AuthProviderType.facebook);
    expect(user.profile.name, "Dart CI Test User");
  });
}
