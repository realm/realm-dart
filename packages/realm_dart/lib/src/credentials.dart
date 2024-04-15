// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';

import 'native/realm_core.dart';
import 'app.dart';
import 'user.dart';

/// An enum containing all authentication providers. These have to be enabled manually for the application before they can be used.
/// [Authentication Providers Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/#authentication-providers)
/// {@category Application}
enum AuthProviderType {
  /// For authenticating without credentials.
  anonymous(0),

  /// For authenticating without credentials using a new anonymous user.
  /// @nodoc
  _anonymousNoReuse(1),

  /// Authenticate with Facebook account.
  facebook(2),

  /// Authenticate with Google account
  google(3),

  /// Authenticate with Apple Id
  apple(4),

  /// For authenticating with JSON web token.
  jwt(5),

  /// For authenticating with an email and a password.
  emailPassword(6),

  /// For authenticating with custom function with payload argument.
  function(7),

  /// For authenticating with an API key.
  apiKey(8);

  const AuthProviderType(this._value);

  final int _value;
}

extension AuthProviderTypeInternal on AuthProviderType {
  static AuthProviderType getByValue(int value) {
    if (value == AuthProviderType._anonymousNoReuse._value) {
      return AuthProviderType.anonymous;
    }
    return AuthProviderType.values.firstWhere((v) => v._value == value);
  }
}

/// A class, representing the credentials used for authenticating a [User]
/// {@category Application}
class Credentials implements Finalizable {
  final CredentialsHandle _handle;

  /// Returns a [Credentials] object that can be used to authenticate an anonymous user.
  /// Setting [reuseCredentials] to `false` will create a new anonymous user, upon [App.logIn].
  /// [Anonymous Authentication Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/anonymous/#anonymous-authentication)
  Credentials.anonymous({bool reuseCredentials = true}) : _handle = CredentialsHandle.anonymous(reuseCredentials);

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an id token.
  Credentials.apple(String idToken) : _handle = CredentialsHandle.apple(idToken);

  /// Returns a [Credentials] object that can be used to authenticate a user with their email and password.
  /// A user can login with email and password only after they have registered their account and verified their
  /// email.
  /// [Email/Password Authentication Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/email-password/#email-password-authentication)
  Credentials.emailPassword(String email, String password) : _handle = CredentialsHandle.emailPassword(email, password);

  /// Returns a [Credentials] object that can be used to authenticate a user with a custom JWT.
  /// [Custom-JWT Authentication Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/custom-jwt/#custom-jwt-authentication)
  Credentials.jwt(String token) : _handle = CredentialsHandle.jwt(token);

  /// Returns a [Credentials] object that can be used to authenticate a user with a Facebook account.
  Credentials.facebook(String accessToken) : _handle = CredentialsHandle.facebook(accessToken);

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an authentication code.
  Credentials.googleAuthCode(String authCode) : _handle = CredentialsHandle.googleAuthCode(authCode);

  /// Returns a [Credentials] object that can be used to authenticate a user with a Google account using an id token.
  Credentials.googleIdToken(String idToken) : _handle = CredentialsHandle.googleIdToken(idToken);

  /// Returns a [Credentials] object that can be used to authenticate a user with a custom Function.
  /// [Custom Function Authentication Docs](https://www.mongodb.com/docs/atlas/app-services/authentication/custom-function/)
  Credentials.function(String payload) : _handle = CredentialsHandle.function(payload);

  /// Returns a [Credentials] object that can be used to authenticate a user with an API key.
  /// To generate an API key, use [ApiKeyClient.create] or the App Services web UI.
  Credentials.apiKey(String key) : _handle = CredentialsHandle.apiKey(key);

  AuthProviderType get provider => handle.providerType;
}

/// @nodoc
extension CredentialsInternal on Credentials {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  CredentialsHandle get handle => _handle;
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
    return app.handle.registerUser(email, password);
  }

  /// Confirms a user with the given token and token id. These are typically included in the registration email.
  Future<void> confirmUser(String token, String tokenId) {
    return app.handle.confirmUser(token, tokenId);
  }

  /// Resend the confirmation email for a user to the given email.
  Future<void> resendUserConfirmation(String email) {
    return app.handle.resendConfirmation(email);
  }

  /// Completes the reset password procedure by providing the desired new [password] using the
  /// password reset [token] and [tokenId] that were emailed to a user.
  Future<void> completeResetPassword(String password, String token, String tokenId) {
    return app.handle.completeResetPassword(password, token, tokenId);
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email) {
    return app.handle.requestResetPassword(email);
  }

  /// Calls the reset password function, configured on the server.
  Future<void> callResetPasswordFunction(String email, String password, {List<dynamic>? functionArgs}) {
    return app.handle.callResetPasswordFunction(email, password, functionArgs.convert(jsonEncode));
  }

  /// Retries the custom confirmation function on a user for a given email.
  Future<void> retryCustomConfirmationFunction(String email) {
    return app.handle.retryCustomConfirmationFunction(email);
  }
}

extension EmailPasswordAuthProviderInternal on EmailPasswordAuthProvider {
  @pragma('vm:never-inline')
  void keepAlive() {
    app.keepAlive();
  }

  static EmailPasswordAuthProvider create(App app) => EmailPasswordAuthProvider(app);
}
