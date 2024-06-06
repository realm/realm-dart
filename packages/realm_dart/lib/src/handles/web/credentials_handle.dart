// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../credentials_handle.dart' as intf;
import 'handle_base.dart';

class CredentialsHandle  extends HandleBase implements intf.CredentialsHandle {
  factory CredentialsHandle.anonymous(bool reuseCredentials) => webNotSupported();

  factory CredentialsHandle.emailPassword(String email, String password) => webNotSupported();

  factory CredentialsHandle.jwt(String token) => webNotSupported();

  factory CredentialsHandle.apple(String idToken) => webNotSupported();

  factory CredentialsHandle.facebook(String accessToken) => webNotSupported();

  factory CredentialsHandle.googleIdToken(String idToken) => webNotSupported();

  factory CredentialsHandle.googleAuthCode(String authCode) => webNotSupported();

  factory CredentialsHandle.function(String payload) => webNotSupported();

  factory CredentialsHandle.apiKey(String key) => webNotSupported();
}
