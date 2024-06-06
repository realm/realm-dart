// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../credentials.dart';
import 'handle_base.dart';

import 'native/credentials_handle.dart' if (dart.library.js_interop) 'web/credentials_handle.dart' as impl;

abstract interface class CredentialsHandle extends HandleBase {
  factory CredentialsHandle.anonymous(bool reuseCredentials) = impl.CredentialsHandle.anonymous;
  
  factory CredentialsHandle.emailPassword(String email, String password) = impl.CredentialsHandle.emailPassword;

  factory CredentialsHandle.jwt(String token) = impl.CredentialsHandle.jwt;

  factory CredentialsHandle.apple(String idToken) = impl.CredentialsHandle.apple;

  factory CredentialsHandle.facebook(String accessToken) = impl.CredentialsHandle.facebook;

  factory CredentialsHandle.googleIdToken(String idToken) = impl.CredentialsHandle.googleIdToken;

  factory CredentialsHandle.googleAuthCode(String authCode) = impl.CredentialsHandle.googleAuthCode;

  factory CredentialsHandle.function(String payload) = impl.CredentialsHandle.function;

  factory CredentialsHandle.apiKey(String key) = impl.CredentialsHandle.apiKey;

  AuthProviderType get providerType;
}
