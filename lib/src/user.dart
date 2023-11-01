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

/// This class represents a `user` in an [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) application.
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

  late final ApiKeyClient _apiKeys = ApiKeyClient._(this);
  late final FunctionsClient _functions = FunctionsClient._(this);

  /// Gets an [ApiKeyClient] instance that exposes functionality for managing
  /// user API keys.
  /// [API Keys Authentication Docs](https://docs.mongodb.com/realm/authentication/api-key/)
  ApiKeyClient get apiKeys {
    _ensureLoggedIn('access API keys');

    return _apiKeys;
  }

  /// Gets a [FunctionsClient] instance that exposes functionality for calling remote Atlas Functions.
  /// A [FunctionsClient] instance scoped to this [User].
  /// [Atlas Functions Docs](https://docs.mongodb.com/realm/functions/)
  FunctionsClient get functions {
    _ensureLoggedIn('access API keys');

    return _functions;
  }

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
  @Deprecated("Get the auth provider from the user identity.")
  AuthProviderType get provider {
    return identities.first.provider;
  }

  /// Gets the profile information for this [User].
  UserProfile get profile {
    return realmCore.userGetProfileData(this);
  }

  /// Gets the refresh token for this [User]. This is the user's credential for
  /// accessing [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) and should be treated as sensitive data.
  String get refreshToken {
    return realmCore.userGetRefreshToken(this);
  }

  /// Gets the access token for this [User]. This is the user's credential for
  /// accessing [Atlas App Services](https://www.mongodb.com/docs/atlas/app-services/) and should be treated as sensitive data.
  String get accessToken {
    return realmCore.userGetAccessToken(this);
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

  void _ensureLoggedIn([String clarification = 'perform this action']) {
    if (state != UserState.loggedIn) {
      throw RealmError('User must be logged in to $clarification');
    }
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

  /// Creates a new API key with the given name. The value of the returned key
  /// must be persisted as this is the only time it is available.
  Future<ApiKey> create(String name) async {
    _user._ensureLoggedIn('create an API key');

    return realmCore.createApiKey(_user, name);
  }

  /// Fetches a specific API key by id.
  Future<ApiKey?> fetch(ObjectId id) {
    _user._ensureLoggedIn('fetch an API key');

    return realmCore.fetchApiKey(_user, id).handle404();
  }

  /// Fetches all API keys associated with the user.
  Future<List<ApiKey>> fetchAll() async {
    _user._ensureLoggedIn('fetch all API keys');

    return realmCore.fetchAllApiKeys(_user);
  }

  /// Deletes a specific API key by id.
  Future<void> delete(ObjectId objectId) {
    _user._ensureLoggedIn('delete an API key');

    return realmCore.deleteApiKey(_user, objectId).handle404();
  }

  /// Disables an API key by id.
  Future<void> disable(ObjectId objectId) {
    _user._ensureLoggedIn('disable an API key');

    return realmCore.disableApiKey(_user, objectId).handle404(id: objectId);
  }

  /// Enables an API key by id.
  Future<void> enable(ObjectId objectId) {
    _user._ensureLoggedIn('enable an API key');

    return realmCore.enableApiKey(_user, objectId).handle404(id: objectId);
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

  ApiKey._(this.id, this.name, this.value, this.isEnabled);

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ApiKey && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

/// A class exposing functionality for calling remote Atlas Functions.
class FunctionsClient {
  final User _user;

  FunctionsClient._(this._user);

  /// Calls a remote function with the supplied arguments.
  /// @name The name of the Atlas function to call.
  /// @functionArgs - Arguments that will be sent to the Atlas function. They have to be json serializable values.
  Future<dynamic> call(String name, [List<Object?> functionArgs = const []]) async {
    _user._ensureLoggedIn('call Atlas function');
    final args = jsonEncode(functionArgs);
    final response = await realmCore.callAppFunction(_user.app, _user, name, args);
    return jsonDecode(response);
  }
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

  static ApiKey createApiKey(ObjectId id, String name, String? value, bool isEnabled) => ApiKey._(id, name, value, isEnabled);
}

extension on Future<void> {
  Future<void> handle404({ObjectId? id}) async {
    try {
      await this;
    } on AppException catch (e) {
      if (e.statusCode == 404) {
        // If we have an id, we can provide a more specific error message. Otherwise, we ignore the exception
        if (id != null) {
          throw AppInternal.createException("Failed to execute operation because ApiKey with Id: $id doesn't exist.", e.linkToServerLogs, 404);
        }

        return;
      }

      rethrow;
    }
  }
}

extension on Future<ApiKey> {
  Future<ApiKey?> handle404() async {
    try {
      return await this;
    } on AppException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }
}
