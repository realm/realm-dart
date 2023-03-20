////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

/// The remote MongoClient used for working with data in MongoDB remotely via Realm.
///
/// {@category Atlas App Services}
class MongoDBClient {
  final User _user;
  final String _serviceName;

  /// Gets the name of the remote MongoDB service for this client.
  String get serviceName => _serviceName;

  /// Gets the [User] for this client.
  User get user => _user;

  MongoDBClient(this._user, this._serviceName);

  /// Gets a [MongoDBDatabase] instance for the given database name.
  MongoDBDatabase getDatabase(String databseName) {
    return MongoDBDatabase._(this, databseName);
  }
}

/// A class representing a remote MongoDB database.
///
/// {@category Atlas App Services}
class MongoDBDatabase {
  final String _mame;
  final MongoDBClient _client;

  /// Gets the [MongoDBClient] that manages this database.
  MongoDBClient get client => _client;

  /// Gets the name of the database.
  String get name => _mame;

  MongoDBDatabase._(this._client, this._mame);

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
  final String _name;
  final User _user;

  /// Gets the [MongoDBDatabase] this collection belongs to.
  MongoDBDatabase get database => _database;

  /// Gets the name of the collection.
  String get name => _name;

  MongoDBCollection._(this._database, this._name) : _user = _database.client.user;

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
    dynamic filter,
    dynamic sort,
    dynamic projection,
    int? limit,
  }) async {
    return await _mongoDBFunctionCall(
      "find",
      filter: filter,
      sort: sort,
      projection: projection,
      limit: limit,
    );
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
    dynamic filter,
    dynamic sort,
    dynamic projection,
  }) async {
    return await _mongoDBFunctionCall(
      "findOne",
      filter: filter,
      sort: sort,
      projection: projection,
    );
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
    required dynamic filter,
    dynamic sort,
    dynamic projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    return await _mongoDBFunctionCall(
      "findOneAndDelete",
      filter: filter,
      sort: sort,
      projection: projection,
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
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
    required dynamic filter,
    required dynamic replacementDoc,
    dynamic sort,
    dynamic projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    return await _mongoDBFunctionCall(
      "findOneAndReplace",
      filter: filter,
      updateDocument: replacementDoc,
      sort: sort,
      projection: projection,
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
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
    required dynamic filter,
    required dynamic updateDocument,
    dynamic sort,
    dynamic projection,
    bool? upsert,
    bool? returnNewDocument,
  }) async {
    return await _mongoDBFunctionCall(
      "findOneAndUpdate",
      filter: filter,
      updateDocument: updateDocument,
      sort: sort,
      projection: projection,
      upsert: upsert,
      returnNewDocument: returnNewDocument,
    );
  }

  /// Inserts the provided [insertDocument] in the collection.
  /// The result contains the `_id` of the inserted document.
  /// See also [db.collection.insertOne](https://docs.mongodb.com/manual/reference/method/db.collection.insertOne/) documentation.
  Future<dynamic> insertOne({required dynamic insertDocument}) async {
    return await _mongoDBFunctionCall("insertOne", insertDocument: insertDocument);
  }

  /// Inserts one or more [insertDocuments] in the collection.
  /// The result contains the `_id`s of the inserted documents.
  /// See also [db.collection.insertMany](https://docs.mongodb.com/manual/reference/method/db.collection.insertMany/) documentation.
  Future<dynamic> insertMany({required dynamic insertDocuments}) async {
    return await _mongoDBFunctionCall("insertMany", insertDocuments: insertDocuments);
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
  Future<dynamic> updateOne({required dynamic filter, required dynamic updateDocument, bool upsert = false}) async {
    return await _mongoDBFunctionCall("updateOne", filter: filter, updateDocument: updateDocument, upsert: upsert);
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
  Future<dynamic> updateMany({required dynamic filter, required dynamic updateDocuments, bool upsert = false}) async {
    return await _mongoDBFunctionCall("updateMany", filter: filter, updateDocument: updateDocuments, upsert: upsert);
  }

  /// Removes a single document from a collection. If no documents match the [filter], the collection is not modified.
  /// The result contains contains the number of deleted documents.
  /// See also [db.collection.deleteOne](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/) documentation.
  ///
  /// The [filter] is a document describing the deletion criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If not specified, the first document in the collection will be deleted.
  Future<dynamic> deleteOne({dynamic filter}) async {
    return await _mongoDBFunctionCall("deleteOne", filter: filter);
  }

  /// Removes one or more documents from a collection.
  /// If no documents match the [filter], the collection is not modified.
  /// If the [filter] is not specified or set to `"{ }"`, all documents in the collection will be deleted.
  /// The result contains the number of deleted documents.
  /// See also [db.collection.deleteMany](https://docs.mongodb.com/manual/reference/method/db.collection.deleteMany/) documentation.
  ///
  /// The [filter] is a document describing the deletion criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  Future<dynamic> deleteMany({dynamic filter}) async {
    return await _mongoDBFunctionCall("deleteMany", filter: filter ?? jsonDecode("{ }"));
  }

  /// Counts the number of documents in the collection that match the provided [filter] and up to [limit].
  /// The result is the number of documents that match the [filter] and[limit] criteria.
  ///
  /// The [filter] is a document describing the find criteria using [query operators](https://docs.mongodb.com/manual/reference/operator/query/).
  /// If the [filter] is not specified, all documents in the collection will be counted.
  /// The [limit] is the maximum number of documents to count. If not specified, all documents in the collection are counted.
  Future<dynamic> count({dynamic filter, int limit = 0}) async {
    return await _mongoDBFunctionCall("count", filter: filter, limit: limit);
  }

  /// Executes an aggregation pipeline on the collection and returns the results as a bson array.
  /// Documents describing the different pipeline stages using [pipeline expressions](https://docs.mongodb.com/manual/core/aggregation-pipeline/#pipeline-expressions).
  /// See also [aggregation](https://docs.mongodb.com/manual/aggregation/) documentation.
  Future<dynamic> aggregate({dynamic pipeline}) async {
    return await _mongoDBFunctionCall("aggregate", pipeline: pipeline);
  }

  Future<dynamic> _mongoDBFunctionCall(String functionName,
      {Object? filter,
      Object? insertDocuments,
      Object? insertDocument,
      Object? updateDocument,
      Object? sort,
      Object? projection,
      Object? pipeline,
      int? limit,
      bool? upsert,
      bool? returnNewDocument}) async {
    dynamic jsonArguments = {
      "database": database.name,
      "collection": name,
      "query": filter,
      "sort": sort,
      "project": projection,
      "document": insertDocument,
      "documents": insertDocuments,
      "update": updateDocument,
      "pipeline": pipeline,
      "limit": limit,
      "upsert": upsert,
      "returnNewDocument": returnNewDocument
    };
    String args = joinDynamics(jsonArguments);
    final response = await realmCore.callAppFunction(_user.app, _user, functionName, args, serviceName: _database.client._serviceName);
    return jsonDecode(response);
  }

  String joinDynamics(dynamic json) {
    final Map<dynamic, dynamic> jsonMap = (json as Map<dynamic, dynamic>);
    jsonMap.removeWhere((dynamic key, dynamic value) => value == null);
    return "[${jsonEncode(jsonMap)}]";
  }
}
