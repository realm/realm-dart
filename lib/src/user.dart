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
  late final MongoDBClient _mongodbClient;

  /// Gets an [ApiKeyClient] instance that exposes functionality for managing
  /// user API keys.
  /// [API Keys Authentication Docs](https://docs.mongodb.com/realm/authentication/api-key/)
  ApiKeyClient get apiKeys {
    _ensureLoggedIn('access API keys');
    _ensureCanAccessAPIKeys();

    return _apiKeys;
  }

  /// Gets a [FunctionsClient] instance that exposes functionality for calling remote Atlas Functions.
  /// A [FunctionsClient] instance scoped to this [User].
  /// [Atlas Functions Docs](https://docs.mongodb.com/realm/functions/)
  FunctionsClient get functions {
    _ensureLoggedIn('access API keys');

    return _functions;
  }

  /// Gets a [MongoDBClient] instance for accessing documents in an Atlas App Service database.
  ///
  /// Requires [serviceName] - the name of the service as configured on the server.
  MongoDBClient getMongoDBClient({required String serviceName}) {
    _ensureLoggedIn('access mongo DB');

    _mongodbClient = MongoDBClient._(this, serviceName);
    return _mongodbClient;
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
  AuthProviderType get provider {
    return realmCore.userGetAuthProviderType(this);
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

  void _ensureCanAccessAPIKeys() {
    if (provider == AuthProviderType.apiKey) {
      throw RealmError('Users logged in with API key cannot manage API keys');
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
///
/// {@category Atlas App Services}
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
///
/// {@category Atlas App Services}
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

/// The remote MongoClient used for working with data in MongoDB remotely via Realm.
///
/// {@category Atlas App Services}
class MongoDBClient {
  final User _user;
  final String _serviceName;

  /// Gets the name of the remote MongoDB service for this client.
  String get serviceName => _serviceName;

  MongoDBClient._(this._user, this._serviceName);

  /// Gets a [MongoDBDatabase] instance for the given database name.
  MongoDBDatabase getDatabase(String databseName) {
    return MongoDBDatabase._(this, databseName);
  }
}

/// A class representing a remote MongoDB database.
///
/// {@category Atlas App Services}
class MongoDBDatabase {
  final String _databaseName;
  final MongoDBClient _client;

  /// Gets the [MongoDBClient] that manages this database.
  MongoDBClient get client => _client;

  /// Gets the name of the database.
  String get databaseName => _databaseName;

  MongoDBDatabase._(this._client, this._databaseName);

  /// Gets a collection from the database.
  MongoDBCollection getCollection(String collectionName) {
    return MongoDBCollection._(this, collectionName);
  }
}

/// A class representing a remote MongoDB collections.
///
/// {@category Atlas App Services}
class MongoDBCollection {
  MongoDBDatabase _database;
  final String _collectionName;
  late MongoDBCollectionHandle _handle;

  /// Gets the [MongoDBDatabase] this collection belongs to.
  MongoDBDatabase get database => _database;

  /// Gets the name of the collection.
  String get collectionName => _collectionName;

  MongoDBCollection._(this._database, this._collectionName)
      : _handle = realmCore.mongodbGetCollection(_database._client._user, _database._client.serviceName, _database._databaseName, _collectionName);

  /// Finds the all documents in the collection up to [limit].
  /// The result is a string with EJson containing an array with the documents that match the find criteria.
  /// See also [db.collection.find](https://docs.mongodb.com/manual/reference/method/db.collection.find/) documentation.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will be returned.
  /// The [sort] is a document describing the sort criteria. If not specified, the order of the returned documents is not guaranteed.
  /// The [projection] is a document describing the fields to return for all matching documents. If not specified, all fields are returned.
  /// The [limit] is the maximum number of documents to return. If not specified, all documents in the collection are returned.
  Future<dynamic> find({
    Object? filter,
    Object? sort,
    Object? projection,
    int? limit,
  }) async {
    final result = await realmCore.mongoDBFind(
      this,
      filter: _nullOrJsonEncode(filter),
      sort: _nullOrJsonEncode(sort),
      projection: _nullOrJsonEncode(projection),
      limit: limit,
    );
    return jsonDecode(result);
  }

  /// Finds the first document in the collection that satisfies the query criteria.
  /// The result is a string with EJson containing the first document that matches the find criteria.
  /// See also [db.collection.findOne](https://docs.mongodb.com/manual/reference/method/db.collection.findOne/) documentation.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will match the request.
  /// The [sort] is a document describing the sort criteria. If not specified, the order of the documents is not guaranteed.
  /// The [projection] is a document describing the fields to return for the matching document. If not specified, all fields are returned.
  Future<dynamic> findOne({
    Object? filter,
    Object? sort,
    Object? projection,
  }) async {
    final result =
        await realmCore.mongoDBFindOne(this, filter: _nullOrJsonEncode(filter), sort: _nullOrJsonEncode(sort), projection: _nullOrJsonEncode(projection));
    return jsonDecode(result);
  }

  /// Finds and delete the first document in the collection that satisfies the query criteria.
  /// The result is a string with EJson containing the first document that matches the find criteria.
  /// See also [db.collection.findOneAndDelete](https://docs.mongodb.com/manual/reference/method/db.collection.findOneAndDelete/) documentation.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will match the request.
  /// The [sort] is a document describing the sort criteria. If not specified, the order of the documents is not guaranteed.
  /// The [projection] is a document describing the fields to return for the matching document. If not specified, all fields are returned.
  Future<dynamic> findOneAndDelete({
    required Object filter,
    Object? sort,
    Object? projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    final result = await realmCore.mongoDBFindOneAndDelete(
      this,
      filter: _nullOrJsonEncode(filter),
      sort: _nullOrJsonEncode(sort),
      projection: _nullOrJsonEncode(projection),
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
    return jsonDecode(result);
  }

  /// Finds and replaces the first document in the collection that satisfies the query criteria.
  /// The result is a string with EJson containing the first document that matches the find criteria.
  /// See also [db.collection.findOneAndReplace](https://docs.mongodb.com/manual/reference/method/db.collection.findOneAndReplace/) documentation.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will match the request.
  /// The replacement document [replacementDoc] cannot contain update operator expressions.
  /// The [sort] is a document describing the sort criteria. If not specified, the order of the documents is not guaranteed.
  /// The [projection] is a document describing the fields to return for the matching document. If not specified, all fields are returned.
  /// If [upsert] is `true` the replace should insert a document if no documents match the [filter]. Defaults to `false`.
  /// If [returnNewDocument] is `true` the replacement document will be returned as a result. If set to `false` the original document
  /// before the replace is returned. Defaults to `false`.
  Future<dynamic> findOneAndReplace({
    required Object filter,
    required Object replacementDoc,
    Object? sort,
    Object? projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    final result = await realmCore.mongoDBFindOneAndReplace(
      this,
      filter: jsonEncode(filter),
      replacementDoc: jsonEncode(replacementDoc),
      sort: _nullOrJsonEncode(sort),
      projection: _nullOrJsonEncode(projection),
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
    return jsonDecode(result);
  }

  /// Finds and update the first document in the collection that satisfies the query criteria.
  /// The result is a string with EJson containing the first document that matches the find criteria.
  /// See also [db.collection.findOneAndReplace](https://docs.mongodb.com/manual/reference/method/db.collection.findOneAndReplace/) documentation.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will match the request.
  /// The document describing the update [updateDocument] can only contain [update operator expressions](https://docs.mongodb.com/manual/reference/operator/update/#id1).
  /// The [sort] is a document describing the sort criteria. If not specified, the order of the documents is not guaranteed.
  /// The [projection] is a document describing the fields to return for the matching document. If not specified, all fields are returned.
  /// If [upsert] is `true` the update should insert a document if no documents match the [filter]. Defaults to `false`.
  /// If [returnNewDocument] is `true` the new updated document will be returned as a result. If set to `false` the original document
  /// before the update is returned. Defaults to `false`.
  Future<dynamic> findOneAndUpdate({
    required Object filter,
    required Object updateDocument,
    Object? sort,
    Object? projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    final result = await realmCore.mongoDBFindOneAndUpdate(
      this,
      filter: jsonEncode(filter),
      updateDocument: jsonEncode(updateDocument),
      sort: _nullOrJsonEncode(sort),
      projection: _nullOrJsonEncode(projection),
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
    return jsonDecode(result);
  }

  /// Inserts the provided [insertDocument] in the collection.
  /// The result contains the `_id` of the inserted document.
  /// See also [db.collection.insertOne](https://docs.mongodb.com/manual/reference/method/db.collection.insertOne/) documentation.
  Future<dynamic> insertOne({required Object insertDocument}) async {
    final result = await realmCore.mongoDBInsertOne(this, insertDocument: jsonEncode(insertDocument));
    return jsonDecode(result);
  }

  /// Inserts one or more [insertDocuments] in the collection.
  /// The result contains the `_id`s of the inserted documents.
  /// See also [db.collection.insertMany](https://docs.mongodb.com/manual/reference/method/db.collection.insertMany/) documentation.
  Future<dynamic> insertMany({required Object insertDocuments}) async {
    final result = await realmCore.mongoDBInsertMany(this, insertDocuments: jsonEncode(insertDocuments));
    return jsonDecode(result);
  }

  /// Updates a single [updateDocument] in the collection according to the specified arguments.
  /// The result contains information about the number of matched and updated documents, as well as the `_id` of the
  /// upserted document if [upsert] was set to `true` and the operation resulted in an upsert.
  /// See also [db.collection.updateOne](https://docs.mongodb.com/manual/reference/method/db.collection.updateOne/) documentation.
  ///
  /// The [filter] is the document describing the selection criteria of the update. If not specified, the first document in the
  /// collection will be updated. Can only contain [query selector expressions](https://docs.mongodb.com/manual/reference/operator/query/#query-selectors)
  /// The [updateDocument] can only contain [update operator expressions](https://docs.mongodb.com/manual/reference/operator/update/#id1).
  /// If [upsert] is `true` the update should insert a document if no documents match the [filter]. Defaults to `false`.
  Future<dynamic> updateOne({required Object filter, required Object updateDocument, bool upsert = false}) async {
    final result = await realmCore.mongoDBUpdateOne(this, filter: jsonEncode(filter), updateDocument: jsonEncode(updateDocument), upsert: upsert);
    return jsonDecode(result);
  }

  /// Updates one or more [updateDocuments] in the collection according to the specified arguments.
  /// The result contains information about the number of matched and updated documents, as well as the `_id`s of the
  /// upserted documents if [upsert] was set to `true` and the operation resulted in an upsert.
  /// See also [db.collection.updateMany](https://docs.mongodb.com/manual/reference/method/db.collection.updateMany/) documentation.
  ///
  /// The [filter] is the document describing the selection criteria of the update. If not specified, the first document in the
  /// collection will be updated. Can only contain [query selector expressions](https://docs.mongodb.com/manual/reference/operator/query/#query-selectors)
  /// The [updateDocuments] can only contain [update operator expressions](https://docs.mongodb.com/manual/reference/operator/update/#id1).
  /// If [upsert] is `true` the update should insert the documents if no documents match the [filter]. Defaults to `false`.
  Future<dynamic> updateMany({required Object filter, required Object updateDocuments, bool upsert = false}) async {
    final result = await realmCore.mongoDBUpdateMany(this, filter: jsonEncode(filter), updateDocuments: jsonEncode(updateDocuments), upsert: upsert);
    return jsonDecode(result);
  }

  /// Removes a single document from a collection. If no documents match the [filter], the collection is not modified.
  /// The result contains contains the number of deleted documents.
  /// See also [db.collection.deleteOne](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/) documentation.
  ///
  /// The [filter] is a document describing the deletion criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If not specified, the first document in the collection will be deleted.
  Future<dynamic> deleteOne({Object? filter}) async {
    final result = await realmCore.mongoDBDeleteOne(this, filter: _nullOrJsonEncode(filter));
    return jsonDecode(result);
  }

  /// Removes one or more documents from a collection. If no documents match the [filter], the collection is not modified.
  /// The result contains contains the number of deleted documents.
  /// See also [db.collection.deleteMany](https://docs.mongodb.com/manual/reference/method/db.collection.deleteMany/) documentation.
  ///
  /// The [filter] is a document describing the deletion criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If not specified, all documents in the collection will be deleted.
  Future<dynamic> deleteMany({Object? filter}) async {
    final result = await realmCore.mongoDBDeleteMany(this, filter: _nullOrJsonEncode(filter));
    return jsonDecode(result);
  }

  /// Counts the number of documents in the collection that match the provided [filter] and up to [limit].
  /// The result is the number of documents that match the [filter] and[limit] criteria.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will be counted.
  /// The [limit] is the maximum number of documents to count. If not specified, all documents in the collection are counted.
  Future<dynamic> count({Object? filter, int limit = 0}) async {
    final result = await realmCore.mongoDBCount(this, filter: _nullOrJsonEncode(filter), limit: limit);
    return jsonDecode(result);
  }

  /// Executes an aggregation on the collection and returns the results as a bson array
  /// containing the documents that match the [filter].
  /// See also [db.collection.aggregation](https://docs.mongodb.com/manual/reference/method/db.collection.aggregation/) documentation.
  Future<dynamic> aggregate({Object? filter}) async {
    final result = await realmCore.mongoDBAggregate(this, filter: _nullOrJsonEncode(filter));
    return jsonDecode(result);
  }

  String? _nullOrJsonEncode(Object? value) {
    if (value == null) return null;
    return jsonEncode(value);
  }
}

/// @nodoc
extension MongoDBCollectionInternal on MongoDBCollection {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  MongoDBCollectionHandle get handle => _handle;
}
