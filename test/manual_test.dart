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

@TestOn('browser') // This file only contain manual tests

import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';
import 'test.dart';

void main() {
  const String strongPassword = "SWV23R#@T#VFQDV";

  setupTests();

  // The tests in this group are for manual testing, since they require interaction with mail box.
  group('Manual tests', () {
    // Please enter a valid data in the variables under comments.
    // Run test 1, then copy token and tokenId from mail box.
    // Set the variables with token details and then run test 2.
    // Go to the application and check whether the new registered user is confirmed.
    // Make sure the email haven't been already registered in application.
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

    // The tests in this group are for manual testing, since they require interaction with mail box.
    // Please enter a valid data in the variables under comments.
    // Run test 1, then make sure you have received two emails.
    // Copy token and tokenId from the second email.
    // Set the variables with token details and then run test 2.
    // Go to the application and check whether the new registered user is confirmed.
    // Make sure the email haven't been already registered in application.
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

    // The tests in this group are for manual testing, since they require interaction with mail box.
    // Please enter a valid data in the variables under comments.
    // The email should be a valid and existing one in order you to be able to receive automatic emails.
    // Run first two steps (test 1 and test 2) to create and confirm the user.
    // Before running test 2 set the variables with token details received as link query parameters in the confirmation email.
    // Then run test 3, then make sure you have received an email with link for reset password.
    // Copy token and tokenId from the email link query parameters.
    // Set the variables with token details and then run test 4.
    // Test 4 will set the password and will login the user with the new password.
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

    ///See test/README.md section 'Manually configure Facebook, Google and Apple authentication providers'"
    baasTest('Facebook credentials - login', (configuration) async {
      final app = App(configuration);
      final accessToken =
          'EAARZCEokqpOMBAKoIHgaG6bqY6LLseGHcQjYdoPhv9FdB89mkVZBWQFOmZCuVeuRfIa5cMtQANLpZBUQI0n4qb4TZCZCAI3vXZC9Oud2qRiieQDtXqE4abZBQJorcBMzECVfsDlus7hk63zW3XzuFCZAxF4BCdRZBHXlGXIzaHhFHhY72aU1apX0tC';
      final credentials = Credentials.facebook(accessToken);
      final user = await app.logIn(credentials);
      expect(user.state, UserState.loggedIn);
      expect(user.identities[0].provider, AuthProviderType.facebook);
      expect(user.profile.name, "Open Graph Test User");
    }, skip: "Manual test");
  }, skip: "Manual tests");
}
