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

import 'package:realm_dart/src/configuration.dart';
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

  Map<String, dynamic> toEJson() => <String, dynamic>{
        '_id': {"\$oid": id.toString()},
        'stringProp': stringProp,
        'boolProp': boolProp,
        'dateProp': {"\$date": dateProp.toIso8601String()},
        'doubleProp': doubleProp,
        'objectIdProp': {"\$oid": objectIdProp.toString()},
        'uuidProp': {"\$uuid": uuidProp.toString()},
        'intProp': intProp,
        'nullableStringProp': nullableStringProp,
        'nullableBoolProp': nullableBoolProp,
        'nullableDateProp': nullableDateProp == null ? null : {"\$date": nullableDateProp?.toIso8601String()},
        'nullableDoubleProp': nullableDoubleProp,
        'nullableObjectIdProp': nullableObjectIdProp == null ? null : {"\$oid": nullableObjectIdProp.toString()},
        'nullableUuidProp': nullableUuidProp == null ? null : {"\$uuid": nullableUuidProp.toString()},
        'nullableIntProp': nullableIntProp
      };
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.find();
    print(result);
  });

  baasTest('MongoDB client find one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.findOne();
    print(result);
  });

  baasTest('MongoDB client insert/delete many', (appConfiguration) async {
    int itemsCount = 3;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    String differentiator = generateRandomString(5);
    List<Map<String, dynamic>> inserts = _generateAtlasDocAllTypesObjects(itemsCount, differentiator: differentiator);
    dynamic inserted = await collection.insertMany(insertDocuments: inserts);
    expect(inserted["insertedIds"], inserts.map<dynamic>((item) => item["_id"]).toList());

    dynamic deleted = await collection.deleteMany(filter: {"stringProp": differentiator});
    expect(deleted["deletedCount"], {"\$numberInt": "$itemsCount"});
  });

  baasTest('MongoDB client insert/delete one', (appConfiguration) async {
    int itemsCount = 1;
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic eJson = _generateAtlasDocAllTypesObjects(itemsCount)[0];
    dynamic inserted = await collection.insertOne(insertDocument: eJson);
    expect(inserted["insertedId"], eJson["_id"]);

    dynamic deleted = await await collection.deleteOne(filter: eJson);
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
    final doc = AtlasDocAllTypes(ObjectId(), differentiator, false, DateTime.now().toUtc(), 0, ObjectId(), Uuid.v4(), 0);
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
    inserts.add(doc.toEJson());
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
