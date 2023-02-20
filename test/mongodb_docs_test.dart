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

  late String? nullableStringProp;
  late bool? nullableBoolProp;
  late DateTime? nullableDateProp;
  late double? nullableDoubleProp;
  late ObjectId? nullableObjectIdProp;
  late Uuid? nullableUuidProp;
  late int? nullableIntProp;

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id.toString(),
        'stringProp': stringProp,
        'boolProp': boolProp,
        'dateProp': dateProp.toString(),
        'doubleProp': doubleProp,
        'objectIdProp': objectIdProp.toString(),
        'uuidProp': uuidProp.toString(),
        'intProp': intProp,
        'nullableStringProp': nullableStringProp ?? "null",
        'nullableBoolProp': nullableBoolProp ?? "null",
        'nullableDateProp': nullableDateProp?.toString() ?? "null",
        'nullableDoubleProp': nullableDoubleProp ?? "null",
        'nullableObjectIdProp': nullableObjectIdProp?.toString() ?? "null",
        'nullableUuidProp': nullableUuidProp?.toString() ?? "null",
        'nullableIntProp': nullableIntProp ?? "null",
      };

  static dynamic get schema => {
        "title": "AtlasDocAllTypes",
        "bsonType": "object",
        "required": ["_id", "stringProp", "boolProp", "dateProp", "doubleProp", "objectIdProp", "uuidProp", "intProp"],
        "properties": {
          "_id": {"bsonType": "objectId"},
          "stringProp": {"bsonType": "string"},
          "boolProp": {"bsonType": "bool"},
          "dateProp": {"bsonType": "date"},
          "doubleProp": {"bsonType": "double"},
          "objectIdProp": {"bsonType": "objectId"},
          "uuidProp": {"bsonType": "uuid"},
          "intProp": {"bsonType": "long"},
          "nullableStringProp": {"bsonType": "string"},
          "nullableBoolProp": {"bsonType": "bool"},
          "nullableDateProp": {"bsonType": "date"},
          "nullableDoubleProp": {"bsonType": "double"},
          "nullableObjectIdProp": {"bsonType": "objectId"},
          "nullableUuidProp": {"bsonType": "uuid"},
          "nullableIntProp": {"bsonType": "long"},
        }
      };
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.find();
    print(result);
  });

  baasTest('MongoDB client find one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, "AtlasDocAllTypes");
    dynamic result = await collection.findOne();
    print(result);
  });

  baasTest('MongoDB client insert one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, "AtlasDocAllTypes");

    dynamic result = await collection.insertOne(insertDocument: {
      "_id": ObjectId().toString(),
      "stringProp": "",
      "boolProp": "false",
      "dateProp": DateTime(0).toUtc().toString(),
      "doubleProp": "0",
      "objectIdProp": ObjectId().toString(),
      "uuidProp": Uuid.v4().toString(),
      "intProp": "0",
    });
    print(result);
  }, skip: true);
}

Future<User> loginToApp(AppConfiguration appConfiguration) async {
  final app = App(appConfiguration);
  final credentials = Credentials.anonymous();
  final user = await app.logIn(credentials);
  return user;
}

Future<MongoDBCollection> getMongoDbCollectionByName(User user, String collectionName) async {
  final mongodbClient = user.getMongoDBClient(serviceName: "BackingDB");
  final database = mongodbClient.getDatabase(getBaasDatabaseName(appName: AppNames.flexible));
  await createAtlasDocAllTypesSchema("BackingDB", collectionName, AtlasDocAllTypes.schema);
  final collection = database.getCollection(collectionName);
  await collection.deleteMany();
  return collection;
}

Future<void> createAtlasDocAllTypesSchema(String serviceName, String collectionName, dynamic schema) async {
  dynamic roles = {
    {
      "name": "default",
      "applyWhen": true,
      "insert": "true",
      "delete": "true",
      "search": "true",
    }
  };
  await createAtlasSchema(
    appName: AppNames.flexible,
    serviceName: "BackingDB",
    collectionName: collectionName,
    schema: schema,
    roles: roles,
  );
}
