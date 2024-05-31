// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'ffi.dart';

import '../../credentials.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';
import 'to_native.dart';

import '../credentials_handle.dart' as intf;

class CredentialsHandle extends HandleBase<realm_app_credentials> implements intf.CredentialsHandle {
  CredentialsHandle(Pointer<realm_app_credentials> pointer) : super(pointer, 16);

  factory CredentialsHandle.anonymous(bool reuseCredentials) {
    return CredentialsHandle(realmLib.realm_app_credentials_new_anonymous(reuseCredentials));
  }

  factory CredentialsHandle.emailPassword(String email, String password) {
    return using((arena) {
      final emailPtr = email.toCharPtr(arena);
      final passwordPtr = password.toRealmString(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_email_password(emailPtr, passwordPtr.ref));
    });
  }

  factory CredentialsHandle.jwt(String token) {
    return using((arena) {
      final tokenPtr = token.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_jwt(tokenPtr));
    });
  }

  factory CredentialsHandle.apple(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_apple(idTokenPtr));
    });
  }

  factory CredentialsHandle.facebook(String accessToken) {
    return using((arena) {
      final accessTokenPtr = accessToken.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_facebook(accessTokenPtr));
    });
  }

  factory CredentialsHandle.googleIdToken(String idToken) {
    return using((arena) {
      final idTokenPtr = idToken.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_google_id_token(idTokenPtr));
    });
  }

  factory CredentialsHandle.googleAuthCode(String authCode) {
    return using((arena) {
      final authCodePtr = authCode.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_google_auth_code(authCodePtr));
    });
  }

  factory CredentialsHandle.function(String payload) {
    return using((arena) {
      final payloadPtr = payload.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_function(payloadPtr));
    });
  }

  factory CredentialsHandle.apiKey(String key) {
    return using((arena) {
      final keyPtr = key.toCharPtr(arena);
      return CredentialsHandle(realmLib.realm_app_credentials_new_api_key(keyPtr));
    });
  }

  AuthProviderType get providerType {
    final provider = realmLib.realm_auth_credentials_get_provider(pointer);
    return AuthProviderTypeInternal.getByValue(provider);
  }
}
