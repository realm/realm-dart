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
import 'realm_class.dart';
import './app.dart';

/// This class represents a `user` in an Atlas App Services application.
/// A user can log in to the server and, if access is granted, it is possible to synchronize the local Realm to MongoDB Atlas.
/// Moreover, synchronization is halted when the user is logged out. It is possible to persist a user. By retrieving a user, there is no need to log in again.
/// Persisting a user between sessions, the user's credentials are stored
/// locally on the device, and should be treated as sensitive data.
/// {@category Application}
class User {
  App? _app;
  final UserHandle _handle;

  /// The [App] with which the [User] is associated with.
  App get app {
    // The _app field may be null when we're retrieving a user from the session
    // rather than from the app.
    return _app ??= AppInternal.create(realmCore.userGetApp(_handle));
  }

  late final ApiKeyClient apiKeys = ApiKeyClient._(this);

  User._(this._handle, this._app);

  /// The current state of this [User].
  UserState get state {
    return realmCore.userGetState(this);
  }

  /// Get this [User]'s id on MongoDB Atlas.
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
  /// *Note: It is not possible to link two existing users of MongoDB Atlas. The provided credentials must not have been used by another user.*
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
  /// The user is logged out. Call [App.logIn] to log the user back in.
  loggedOut,

  /// The user is logged in, and any Realms associated with it are synchronizing with MongoDB Atlas.
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

/// A class exposing functionality for users to manage API keys from the client. It is always scoped
/// to a particular [User] and can only be accessed via [User.apiKeys]
class ApiKeyClient {
  final User _user;

  ApiKeyClient._(this._user);

  Future<ApiKey> create(String name) async {
    return realmCore.createApiKey(_user, name);
  }
}

/// A class representing an API key for a [User]. It can be used to represent the user when logging in
/// instead of their regular credentials. These keys are created or fetched through [User.apiKeys].
class ApiKey {
  /// The unique idenitifer for this [ApiKey].
  final ObjectId id;

  /// The name of this [ApiKey].
  final String name;

  /// The value of this [ApiKey]. This is only returned when the ApiKey is created via [ApiKeyClient.create].
  /// In all other cases, it'll be `null`.
  final String? value;

  /// A value indicating whether the ApiKey is enabled. If this is false, then the ApiKey cannot be used to
  /// authenticate the user.
  final bool isEnabled;

  ApiKey._({required this.id, required this.name, required this.value, required this.isEnabled});

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ApiKey && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

/// @nodoc
extension UserIdentityInternal on UserIdentity {
  static UserIdentity create(String identity, AuthProviderType provider) => UserIdentity._(identity, provider);
}

/// @nodoc
extension UserInternal on User {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
    _app?.keepAlive();
  }

  UserHandle get handle => _handle;

  static User create(UserHandle handle, [App? app]) => User._(handle, app);

  static ApiKey createApiKey({required ObjectId id, required String name, required String? value, required bool isEnabled}) =>
      ApiKey._(id: id, name: name, value: value, isEnabled: isEnabled);
}
