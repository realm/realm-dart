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

import 'package:realm_dart/realm.dart';

import 'native/realm_core.dart';
import 'app.dart';
import 'credentials.dart';

/// The current state of a [User].
enum UserState{
  /// The user is logged in, and any Realms associated with it are synchronizing with MongoDB Realm.
  loogedIn,

  /// The user is logged out. Call LogInAsync(Credentials) with valid credentials to log the user back in.
  loggedOut,

  /// The user has been logged out and their local data has been removed.
  removed,
}

/// This class represents a user in a MongoDB Realm app.
/// A user can log in to the server and, if access is granted, it is possible to synchronize the local Realm to MongoDB.
/// Moreover, synchronization is halted when the user is logged out. It is possible to persist a user. By retrieving a user, there is no need to log in again.
/// Persisting a user between sessions, the user's credentials are stored
/// locally on the device, and should be treated as sensitive data.
/// {@category Application}
class User {
  final UserHandle _handle;

  /// The [App] with which the user is associated with.
  final App app;

  User._(this.app, this._handle);

  /// The custom user data associated with this user.
  ///
  /// The data is only refreshed when the user's access token is refreshed or when explicitly calling [refreshCustomData]
  dynamic get customData {
    final data = realmCore.userGetCustomData(this);
    return jsonDecode(data);
  }

  /// Re-fetch the user's custom data from the server.
  Future<dynamic> refreshCustomData() async {
    await realmCore.userRefreshCustomData(app, this);
    return customData;
  }

  /// Links this [User] with a new [User] identity represented by the given credentials.
  ///
  /// Linking a user with more credentials, mean the user can login either of these credentials. It also makes it possible to "upgrade" an anonymous user
  /// by linking it with e.g. Email/Password credentials.
  /// Note: It is not possible to link two existing users of MongoDB Realm. The provided credentials must not have been used by another user.
  Future<User> linkCredentials(Credentials credentials) async {
    final userHandle = await realmCore.userLinkCredentials(app, this, credentials);
    return UserInternal.create(app, userHandle);
  }

  /// The current state of this [User].
  UserState get state {
    final nativeState = realmCore.userGetState(this);
    if (!UserState.values.any((state) => state.index == nativeState)) {
      throw RealmError("Unknown user state $nativeState");
    }

    return UserState.values[nativeState];
  }
}

/// @nodoc
extension UserInternal on User {
  UserHandle get handle => _handle;

  static User create(App app, UserHandle handle) => User._(app, handle);
}
