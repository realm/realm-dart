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

import 'native/realm_core.dart';
import 'app.dart';
import 'credentials.dart';
import 'realm_class.dart';

/// This class represents a `user` in a MongoDB Realm app.
/// A user can log in to the server and, if access is granted, it is possible to synchronize the local Realm to MongoDB.
/// Moreover, synchronization is halted when the user is logged out. It is possible to persist a user. By retrieving a user, there is no need to log in again.
/// Persisting a user between sessions, the user's credentials are stored
/// locally on the device, and should be treated as sensitive data.
/// {@category Application}
class User {
  final UserHandle _handle;

  /// The [App] with which the [User] is associated with.
  final App app;

  User._(this.app, this._handle);

  /// The current state of this [User].
  UserState get state {
    return realmCore.userGetState(this);
  }

  /// Get this [User]'s id on MongoDB Realm.
  String get id {
    return realmCore.userGetId(this);
  }

  /// Gets a collection of all identities associated with this [User].
  List<UserIdentity> get identities {
    return realmCore.userGetIdentities(this);
  }

  /// Removes the [User]'s local credentials. This will also close any associated Sessions.
  Future<void> logOut() async {
    return await realmCore.userLogOut(this);
  }

  /// Gets an unique identifier for the current device.
  String? get deviceId {
    return realmCore.userGetDeviceId(this);
  }

  /// Gets the [AuthProviderType] this [User] is currently logged in with.
  AuthProviderType get provider {
    return realmCore.userGetAuthProviderType(this);
  }

  /// Gets the profile information for this [User].
  UserProfile get profile {
    return realmCore.userGetProfileData(this);
  }

  /// The custom user data associated with this [User].
  dynamic get customData {
    final data = realmCore.userGetCustomData(this);
    if (data == null) {
      return null;
    }

    return jsonDecode(data);
  }

  /// Refreshes the custom data for a this [User].
  Future<dynamic> refreshCustomData() async {
    await realmCore.userRefreshCustomData(app, this);
    return customData;
  }

  /// Links this [User] with a new `User` identity represented by the given credentials.
  ///
  /// Linking a user with more credentials, mean the user can login either of these credentials. It also makes it possible to "upgrade" an anonymous user
  /// by linking it with e.g. Email/Password credentials.
  /// *Note: It is not possible to link two existing users of MongoDB Realm. The provided credentials must not have been used by another user.*
  ///
  /// The following snippet shows how to associate an email and password with an anonymous user allowing them to login on a different device.
  /// ```dart
  ///  final app = App(configuration);
  ///  final user = await app.logIn(Credentials.anonymous());
  ///
  ///  // This step is only needed for email password auth - a password record must exist before you can link a user to it.
  ///  final authProvider = EmailPasswordAuthProvider(app);
  ///  await authProvider.registerUser("username", "password");
  ///
  ///  await user.linkCredentials(Credentials.emailPassword("username", "password"));
  /// ```
  Future<User> linkCredentials(Credentials credentials) async {
    final userHandle = await realmCore.userLinkCredentials(app, this, credentials);
    return UserInternal.create(userHandle, app);
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    return realmCore.userEquals(this, other);
  }
}

/// The current state of a [User].
enum UserState {
  /// The user is logged out. Call [App.login] to log the user back in.
  loggedOut,

  /// The user is logged in, and any Realms associated with it are synchronizing with MongoDB Realm.
  loggedIn,

  /// The user has been logged out and their local data has been removed.
  removed,
}

/// The user identity associated with a [User]
class UserIdentity {
  /// The unique identifier for this [UserIdentity].
  final String id;

  /// The [AuthProviderType] defining this identity.
  final AuthProviderType provider;

  const UserIdentity._(this.id, this.provider);
}

/// A class containing profile information about [User].
class UserProfile {
  final Map<String, dynamic> _data;

  /// Gets the name of the [User].
  String? get name => _data["name"] as String?;

  /// Gets the first name of the [User].
  String? get firstName => _data["firstName"] as String?;

  /// Gets the last name of the [User].
  String? get lastName => _data["lastName"] as String?;

  /// Gets the email of the [User].
  String? get email => _data["email"] as String?;

  /// Gets the gender of the [User].
  String? get gender => _data["gender"] as String?;

  /// Gets the birthday of the user.
  String? get birthDay => _data["birthDay"] as String?;

  /// Gets the minimum age of the [User].
  String? get minAge => _data["minAge"] as String?;

  /// Gets the maximum age of the [User].
  String? get maxAge => _data["maxAge"] as String?;

  /// Gets the url for the [User]'s profile picture.
  String? get pictureUrl => _data["pictureUrl"] as String?;

  /// Gets a profile property of the [User].
  dynamic operator [](String property) => _data[property];

  const UserProfile(this._data);
}

/// @nodoc
extension UserIdentityInternal on UserIdentity {
  static UserIdentity create(String identity, AuthProviderType provider) => UserIdentity._(identity, provider);
}

/// @nodoc
extension UserInternal on User {
  UserHandle get handle => _handle;

  static User create(UserHandle handle, [App? app]) {
    app ??= AppInternal.create(realmCore.userGetApp(handle));

    return User._(app, handle);
  }
}
