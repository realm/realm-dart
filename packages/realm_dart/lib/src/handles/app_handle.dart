// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../../realm.dart';

import 'credentials_handle.dart';
import 'user_handle.dart';

import 'native/app_handle.dart' if (dart.library.js_interop) 'web/app_handle.dart' as impl;

abstract interface class AppHandle {
  factory AppHandle.from(AppConfiguration configuration) = impl.AppHandle.from;
  static AppHandle? get(String id, String? baseUrl) => impl.AppHandle.get(id, baseUrl);

  String get id;

  UserHandle? get currentUser;
  List<UserHandle> get users;
  Future<UserHandle> logIn(CredentialsHandle credentials);
  Future<void> removeUser(UserHandle user);
  void switchUser(UserHandle user);
  Future<void> refreshCustomData(UserHandle user);

  void reconnect();
  String get baseUrl;
  Future<void> updateBaseUrl(Uri? baseUrl);

  Future<void> registerUser(String email, String password);
  Future<void> confirmUser(String token, String tokenId);
  Future<void> resendConfirmation(String email);

  Future<void> completeResetPassword(String password, String token, String tokenId);
  Future<void> requestResetPassword(String email);
  Future<void> callResetPasswordFunction(String email, String password, String? argsAsJSON);
  Future<void> retryCustomConfirmationFunction(String email);
  Future<void> deleteUser(UserHandle user);
  bool resetRealm(String realmPath);
  Future<String> callAppFunction(UserHandle user, String functionName, String? argsAsJSON);
}
