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

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    await createSapmpleData(user);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, Event.schema.name);
    dynamic result = await collection.find();
    print(result);
  });

  baasTest('MongoDB client find one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, Event.schema.name);
    dynamic result = await collection.findOne();
    print(result);
  });

  baasTest('MongoDB client insert one', (appConfiguration) async {
    User user = await loginToApp(appConfiguration);
    MongoDBCollection collection = await getMongoDbCollectionByName(user, "MongoDocs");
    dynamic result = await collection.insertOne(insertDocument: {"documentName": "doc1"});
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
  return collection;
}

Future<void> createSapmpleData(User user) async {
  final configuration = Configuration.flexibleSync(user, [
    Task.schema,
    Schedule.schema,
    Event.schema,
  ]);
  final realm = getRealm(configuration);
  realm.subscriptions.update((mutableSubscriptions) {
    mutableSubscriptions.add(realm.all<Event>());
  });
  await realm.subscriptions.waitForSynchronization();

  realm.write(() {
    realm.addAll([
      Event(ObjectId(), name: "NPMG Event", isCompleted: true, durationInMinutes: 30),
      Event(ObjectId(), name: "NPMG Meeting", isCompleted: false, durationInMinutes: 10),
      Event(ObjectId(), name: "Some other event", isCompleted: true, durationInMinutes: 60),
    ]);
  });

  await realm.syncSession.waitForUpload();
}
