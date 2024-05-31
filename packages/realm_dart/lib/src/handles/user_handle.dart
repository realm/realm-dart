// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';

import '../user.dart';
import 'app_handle.dart';
import 'credentials_handle.dart';
import 'handle_base.dart';

abstract interface class UserHandle extends HandleBase {
  AppHandle get app;
  UserState get state;
  String get id;
  List<UserIdentity> get identities;
  Future<void> logOut();
  String? get deviceId;
  UserProfile get profileData;
  String get refreshToken;
  String get accessToken;
  String get path;
  String? get customData;
  Future<UserHandle> linkCredentials(AppHandle app, CredentialsHandle credentials);
  Future<ApiKey> createApiKey(AppHandle app, String name);
  Future<ApiKey> fetchApiKey(AppHandle app, ObjectId id);
  Future<List<ApiKey>> fetchAllApiKeys(AppHandle app);
  Future<void> deleteApiKey(AppHandle app, ObjectId id);
  Future<void> disableApiKey(AppHandle app, ObjectId objectId);
  Future<void> enableApiKey(AppHandle app, ObjectId objectId);
  UserNotificationTokenHandle subscribeForNotifications(UserNotificationsController controller);
}

abstract interface class UserNotificationTokenHandle extends HandleBase {}
