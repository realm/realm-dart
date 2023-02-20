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

import 'dart:ffi';

import '../lib/realm.dart';
import 'test.dart';

part 'mongodb_docs_test.g.dart';

@RealmModel()
class _AtlasDocAllTypes {
  @MapTo("_id")
  @PrimaryKey()
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
}


Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    await createAllTypesSchema(user);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, AtlasDocAllTypes.schema.name);
    dynamic result = await collection.find();
    print(result);
  });

  baasTest('MongoDB client find one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, AtlasDocAllTypes.schema.name);
    dynamic result = await collection.findOne();
    print(result);
  });

  baasTest('MongoDB client insert one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    await createAllTypesSchema(user);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, AtlasDocAllTypes.schema.name);
    final emptyItem = AtlasDocAllTypes(ObjectId(), '', false, DateTime(0).toUtc(), 0, ObjectId(), Uuid.v4(), 0);

    dynamic result = await collection.insertOne(insertDocument: emptyItem.toJson());
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
  final collection = database.getCollection(collectionName);
  await collection.deleteMany();
  return collection;
}

Future<void> createAllTypesSchema(User user) async {
  final configuration = Configuration.flexibleSync(user, [AtlasDocAllTypes.schema]);
  final realm = getRealm(configuration);
  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add(realm.all<AtlasDocAllTypes>());
  });
  await realm.subscriptions.waitForSynchronization();
  final emptyItem = AtlasDocAllTypes(ObjectId(), '', false, DateTime(0).toUtc(), 0, ObjectId(), Uuid.v4(), 0);
  realm.write(() {
    realm.add(emptyItem);
    realm.delete(emptyItem);
  });
  await realm.syncSession.waitForUpload();
}

extension AtlasDocAllTypesJ on AtlasDocAllTypes {
  static AtlasDocAllTypes fromJson(Map<String, dynamic> json) => AtlasDocAllTypes(
        json['_id'] as ObjectId,
        json['stringProp'] as String,
        json['boolProp'] as bool,
        json['dateProp'] as DateTime,
        json['doubleProp'] as double,
        json['objectIdProp'] as ObjectId,
        json['uuidProp'] as Uuid,
        json['intProp'] as int,
        nullableStringProp: json['nullableStringProp'] as String?,
        nullableBoolProp: json['nullableBoolProp'] as bool?,
        nullableDateProp: json['nullableDateProp'] as DateTime?,
        nullableDoubleProp: json['nullableDoubleProp'] as double?,
        nullableObjectIdProp: json['nullableObjectIdProp'] as ObjectId?,
        nullableUuidProp: json['nullableUuidProp'] as Uuid?,
        nullableIntProp: json['nullableIntProp'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id.toString(),
        'stringProp': stringProp,
        'boolProp': boolProp,
        'dateProp': dateProp.toString(),
        'doubleProp': doubleProp,
        'objectIdProp': objectIdProp.toString(),
        'uuidProp': uuidProp.toString(),
        'intProp': intProp,
        'nullableStringProp': nullableStringProp,
        'nullableBoolProp': nullableBoolProp,
        'nullableDateProp': nullableDateProp?.toString(),
        'nullableDoubleProp': nullableDoubleProp,
        'nullableObjectIdProp': nullableObjectIdProp?.toString(),
        'nullableUuidProp': nullableUuidProp?.toString(),
        'nullableIntProp': nullableIntProp,
      };
}
