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
import 'dart:ffi';

import 'native/realm_core.dart';
import 'app.dart';
import 'user.dart';

/// An enum containing all authentication providers. These have to be enabled manually for the application before they can be used.
/// [Authentication Providers Docs](https://docs.mongodb.com/realm/authentication/providers/)
/// {@category Application}
enum AuthProviderType {
  /// For authenticating without credentials.
  anonymous,

  /// For authenticating without credentials using a new anonymous user.
  anonymousNoReuse,

  /// Authenticate with Apple Id
  apple,

  /// Authenticate with Facebook account.
  facebook,

  /// Authenticate with Google account
  google,

  /// For authenticating with JSON web token.
  jwt,

  /// For authenticating with an email and a password.
  emailPassword,

  /// For authenticating with custom function with payload argument.
  function,

  /// For authenticating with an API key.
  apiKey,
}

/// A class, representing the credentials used for authenticating a [User]
/// {@category Application}
class Credentials implements Finalizable {
  final RealmAppCredentialsHandle _handle;
  final AuthProviderType provider;

  /// Returns a [Credentials] object that can be used to authenticate an anonymous user.
  /// Setting [reuseCredentials] to [false] will create a new anonymous user, upon [App.logIn].
  /// [Anonymous Authentication Docs](https://docs.mongodb.com/realm/authentication/anonymous)
  Credentials.anonymous({bool reuseCredentials = true})
      : _handle = realmCore.createAppCredentialsAnonymous(reuseCredentials),
        provider = reuseCredentials ? AuthProviderType.anonymous : AuthProviderType.anonymousNoReuse;

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an id token.
  Credentials.apple(String idToken)
      : _handle = realmCore.createAppCredentialsApple(idToken),
        provider = AuthProviderType.apple;

  /// Returns a [Credentials] object that can be used to authenticate a user with their email and password.
  /// A user can login with email and password only after they have registered their account and verified their
  /// email.
  /// [Email/Password Authentication Docs](https://docs.mongodb.com/realm/authentication/email-password)
  Credentials.emailPassword(String email, String password)
      : _handle = realmCore.createAppCredentialsEmailPassword(email, password),
        provider = AuthProviderType.emailPassword;

  /// Returns a [Credentials] object that can be used to authenticate a user with a custom JWT.
  /// [Custom-JWT Authentication Docs](https://docs.mongodb.com/realm/authentication/custom-jwt)
  Credentials.jwt(String token)
      : _handle = realmCore.createAppCredentialsJwt(token),
        provider = AuthProviderType.jwt;

  /// Returns a [Credentials] object that can be used to authenticate a user with a Facebook account.
  Credentials.facebook(String accessToken)
      : _handle = realmCore.createAppCredentialsFacebook(accessToken),
        provider = AuthProviderType.facebook;

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an authentication code.
  Credentials.googleAuthCode(String authCode)
      : _handle = realmCore.createAppCredentialsGoogleAuthCode(authCode),
        provider = AuthProviderType.google;

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an id token.
  Credentials.googleIdToken(String idToken)
      : _handle = realmCore.createAppCredentialsGoogleIdToken(idToken),
        provider = AuthProviderType.google;

  /// Returns a [Credentials] object that can be used to authenticate a user with a custom Function.
  /// [Custom Function Authentication Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/custom-function/)
  Credentials.function(String payload)
      : _handle = realmCore.createAppCredentialsFunction(payload),
        provider = AuthProviderType.function;

  /// Returns a [Credentials] object that can be used to authenticate a user with an API key.
  /// To generate an API key, use [ApiKeyClient.create] or the App Services web UI.
  Credentials.apiKey(String key)
      : _handle = realmCore.createAppCredentialsApiKey(key),
        provider = AuthProviderType.apiKey;
}

/// @nodoc
extension CredentialsInternal on Credentials {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  RealmAppCredentialsHandle get handle => _handle;
}

/// A class, encapsulating functionality for users, logged in with [Credentials.emailPassword()].
/// It is always scoped to a particular app.
/// {@category Application}
class EmailPasswordAuthProvider implements Finalizable {
  final App app;

  /// Create a new EmailPasswordAuthProvider for the [app]
  EmailPasswordAuthProvider(this.app);

  /// Registers a new user with the given email and password.
  /// The [email] to register with. This will be the user's username and, if user confirmation is enabled, this will be the address for
  /// the confirmation email.
  /// The [password] to associate with the email. The password must be between 6 and 128 characters long.
  ///
  /// Successful completion indicates that the user has been created on the server and can now be logged in with [Credentials.emailPassword()].
  Future<void> registerUser(String email, String password) async {
    return realmCore.appEmailPasswordRegisterUser(app, email, password);
  }

  /// Confirms a user with the given token and token id. These are typically included in the registration email.
  Future<void> confirmUser(String token, String tokenId) {
    return realmCore.emailPasswordConfirmUser(app, token, tokenId);
  }

  /// Resend the confirmation email for a user to the given email.
  Future<void> resendUserConfirmation(String email) {
    return realmCore.emailPasswordResendUserConfirmation(app, email);
  }

  /// Completes the reset password procedure by providing the desired new [password] using the
  /// password reset [token] and [tokenId] that were emailed to a user.
  Future<void> completeResetPassword(String password, String token, String tokenId) {
    return realmCore.emailPasswordCompleteResetPassword(app, password, token, tokenId);
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) {
    return realmCore.emailPasswordResetPassword(app, email);
  }

  /// Calls the reset password function, configured on the server.
  Future<void> callResetPasswordFunction(String email, String password, {List<dynamic>? functionArgs}) {
    return realmCore.emailPasswordCallResetPasswordFunction(app, email, password, functionArgs != null ? jsonEncode(functionArgs) : null);
  }

  /// Retries the custom confirmation function on a user for a given email.
  Future<void> retryCustomConfirmationFunction(String email) {
    return realmCore.emailPasswordRetryCustomConfirmationFunction(app, email);
  }
}

extension EmailPasswordAuthProviderInternal on EmailPasswordAuthProvider {
  @pragma('vm:never-inline')
  void keepAlive() {
    app.keepAlive();
  }

  static EmailPasswordAuthProvider create(App app) => EmailPasswordAuthProvider(app);
}
