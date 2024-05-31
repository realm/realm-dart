// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../credentials_handle.dart' as intf;

class CredentialsHandle implements intf.CredentialsHandle {
  factory CredentialsHandle.anonymous(bool reuseCredentials) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.emailPassword(String email, String password) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.jwt(String token) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.apple(String idToken) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.facebook(String accessToken) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.googleIdToken(String idToken) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.googleAuthCode(String authCode) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.function(String payload) => throw UnsupportedError('web not supported');

  factory CredentialsHandle.apiKey(String key) => throw UnsupportedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
