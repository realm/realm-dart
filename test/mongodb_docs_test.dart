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

import 'package:test/test.dart';

import '../lib/realm.dart';
import 'test.dart';

class AtlasDocAllTypes {
  late ObjectId id;
  late String stringProp;
  late bool boolProp;
  late DateTime dateProp;
  late double doubleProp;
  late ObjectId objectIdProp;
  late Uuid uuidProp;
  late int intProp;

  String? nullableStringProp;
  bool? nullableBoolProp;
  DateTime? nullableDateProp;
  double? nullableDoubleProp;
  ObjectId? nullableObjectIdProp;
  Uuid? nullableUuidProp;
  int? nullableIntProp;

  AtlasDocAllTypes(this.id, this.stringProp, this.boolProp, this.dateProp, this.doubleProp, this.objectIdProp, this.uuidProp, this.intProp);

  static AtlasDocAllTypes fromJson(Map<String, dynamic> json) => AtlasDocAllTypes(
      json['_id'] as ObjectId,
      json['stringProp'] as String,
      json['boolProp'] as bool,
      json['dateProp'] as DateTime,
      json['doubleProp'] as double,
      json['objectIdProp'] as ObjectId,
      json['uuidProp'] as Uuid,
      json['intProp'] as int)
    ..nullableStringProp = json['nullableStringProp'] as String?
    ..nullableBoolProp = json['nullableBoolProp'] as bool?
    ..nullableDateProp = json['nullableDateProp'] as DateTime?
    ..nullableDoubleProp = json['nullableDoubleProp'] as double?
    ..nullableObjectIdProp = json['nullableObjectIdProp'] as ObjectId?
    ..nullableUuidProp = json['nullableUuidProp'] as Uuid?
    ..nullableIntProp = json['nullableIntProp'] as int?;

  Map<String, dynamic> toEJson() => convertToEJson({
        '_id': id,
        'stringProp': stringProp,
        'boolProp': boolProp,
        'dateProp': dateProp,
        'doubleProp': doubleProp,
        'objectIdProp': objectIdProp,
        'uuidProp': uuidProp,
        'intProp': intProp,
        'nullableStringProp': nullableStringProp,
        'nullableBoolProp': nullableBoolProp,
        'nullableDateProp': nullableDateProp,
        'nullableDoubleProp': nullableDoubleProp,
        'nullableObjectIdProp': nullableObjectIdProp,
        'nullableUuidProp': nullableUuidProp,
        'nullableIntProp': nullableIntProp
      });
}

Map<String, dynamic> convertToEJson(Map<String, Object?> fields) {
  return fields.map<String, dynamic>((key, value) => MapEntry<String, dynamic>(key, getFieldEJsonValue(value)));
}

dynamic getFieldEJsonValue(Object? object) {
  if (object == null) {
    return null;
  }
  if (object is String?) {
    return object.toString();
  } else if (object is double?) {
    double d = (object as double);
    int i = d.ceil();
    return {"\$numberDouble": d == i ? i.toString() : d.toString()};
  } else if (object is int?) {
    return {"\$numberInt": object.toString()};
  } else if (object is bool?) {
    return object;
  } else if (object is ObjectId?) {
    return {"\$oid": object.toString()};
  } else if (object is Uuid?) {
    return {
      "\$binary": {"base64": base64.encode((object as Uuid).bytes.asUint8List()), "subType": "04"}
    };
  } else if (object is DateTime?) {
    return {
      "\$date": {"\$numberLong": (object as DateTime).millisecondsSinceEpoch.toString()}
    };
  }
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find with empty filter returns all', (appConfiguration) async {
    int itemsCount = 2;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    String differentiator = generateRandomString(5);
    List<Map<String, dynamic>> inserts = _generateAtlasDocAllTypesObjects(itemsCount, differentiator: differentiator);
    await collection.insertMany(insertDocuments: inserts);

    dynamic found = await collection.find();
    expect((found as List).length, itemsCount);
    expect(found, inserts);

    dynamic deleted = await collection.deleteMany(filter: {"stringProp": differentiator});
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});
  });

  baasTest('MongoDB client find one with empty filter returns first', (appConfiguration) async {
    int itemsCount = 3;
    String differentiator = generateRandomString(5);
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    List<Map<String, dynamic>> inserts = _generateAtlasDocAllTypesObjects(itemsCount, differentiator: differentiator);
    await collection.insertMany(insertDocuments: inserts);

    dynamic found = await collection.findOne();
    expect(found, inserts.first);

    dynamic deleted = await collection.deleteMany(filter: {"stringProp": differentiator});
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});
  });

  baasTest('MongoDB client insert/find/delete one', (appConfiguration) async {
    int itemsCount = 1;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic eJson = _generateAtlasDocAllTypesObjects(itemsCount)[0];

    dynamic inserted = await collection.insertOne(insertDocument: eJson);
    expect(inserted["insertedId"], eJson["_id"]);

    dynamic found = await collection.findOne(filter: eJson);
    expect(found, eJson);

    dynamic deleted = await await collection.deleteOne(filter: eJson);
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});

    dynamic foundDeleted = await collection.findOne(filter: eJson);
    expect(foundDeleted, null);
  });

  baasTest('MongoDB client insert/find/delete many', (appConfiguration) async {
    int itemsCount = 3;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    String differentiator = generateRandomString(5);
    dynamic filterByString = {"stringProp": differentiator};
    List<Map<String, dynamic>> inserts = _generateAtlasDocAllTypesObjects(itemsCount, differentiator: differentiator);
    dynamic inserted = await collection.insertMany(insertDocuments: inserts);
    expect(inserted["insertedIds"], inserts.map<dynamic>((item) => item["_id"]).toList());

    dynamic found = await collection.find(filter: filterByString, sort: {"intProp": 1});
    expect((found as List).length, itemsCount);
    expect(found, inserts);

    dynamic deleted = await collection.deleteMany(filter: filterByString);
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});

    dynamic foundDeleted = await collection.find(filter: filterByString);
    expect(foundDeleted, jsonDecode("[]"));
  });

  baasTest('MongoDB client projection and filter with OR', (appConfiguration) async {
    int itemsCount = 3;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    String differentiator = generateRandomString(5);
    dynamic filterByString = {"stringProp": differentiator};
    List<Map<String, dynamic>> inserts = _generateAtlasDocAllTypesObjects(itemsCount, differentiator: differentiator);
    dynamic inserted = await collection.insertMany(insertDocuments: inserts);

    dynamic foundIds = await collection.find(filter: filterByString, projection: {
      "_id": 1,
      'stringProp': 0,
      'boolProp': 0,
      'dateProp': 0,
      'doubleProp': 0,
      'objectIdProp': 0,
      'uuidProp': 0,
      'intProp': 0,
      'nullableStringProp': 0,
      'nullableBoolProp': 0,
      'nullableDateProp': 0,
      'nullableDoubleProp': 0,
      'nullableObjectIdProp': 0,
      'nullableUuidProp': 0,
      'nullableIntProp': 0
    });
    expect((foundIds as List).length, itemsCount);

    dynamic found = await collection.find(filter: {"\$or": foundIds}, sort: {"intProp": 1}, limit: itemsCount);
    expect((found as List).length, inserts.length);
    expect(found, inserts);

    dynamic deleted = await collection.deleteMany(filter: {"\$or": foundIds});
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});
  });

  baasTest('MongoDB client delete all - no filter', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.deleteMany();
    print(result);
  });
  baasTest('MongoDB client delete all with empty filter', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.deleteMany(filter: jsonDecode("{ }"));
    print(result);
  });

  baasTest('MongoDB delete with a filter that matches no documents deletes nothing', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.deleteMany(filter: {
      "_id": {"\$oid": "64183477ff7f6e95f608784a"}
    });
    print(result);
  });
}

List<Map<String, dynamic>> _generateAtlasDocAllTypesObjects(int count, {String? differentiator}) {
  List<Map<String, dynamic>> inserts = [];
  differentiator = differentiator ?? generateRandomString(5);
  for (var i = 0; i < count; i++) {
    final doc = AtlasDocAllTypes(ObjectId(), differentiator, false, DateTime.now().toUtc(), 0, ObjectId(), Uuid.v4(), i);
    if (i % 2 == 0) {
      doc
        ..nullableStringProp = "nullable$differentiator$i"
        ..nullableBoolProp = true
        ..nullableDateProp = DateTime.now().toUtc()
        ..nullableDoubleProp = 10.1 + i
        ..nullableObjectIdProp = ObjectId()
        ..nullableUuidProp = Uuid.v4()
        ..nullableIntProp = i;
    }
    var eJson = doc.toEJson();
    inserts.add(eJson);
  }
  return inserts;
}

Future<User> loginToApp(AppConfiguration appConfiguration) async {
  final app = App(appConfiguration);
  final credentials = Credentials.anonymous();
  final user = await app.logIn(credentials);
  return user;
}

MongoDBCollection getMongoDbCollectionByName(User user, String collectionName) {
  final mongodbClient = user.getMongoDBClient(serviceName: "BackingDB");
  final database = mongodbClient.getDatabase(getBaasDatabaseName(appName: AppNames.flexible));
  final collection = database.getCollection(collectionName);
  return collection;
}
