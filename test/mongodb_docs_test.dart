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

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('MongoDB client find', (configuration) async {
    final app = App(configuration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final mongodbClient = user.getMongoDBClient("BackingDB");
    final database = mongodbClient.getDatabase(getBaasDatabaseName(appName: AppNames.flexible));
    final collection = database.getCollection("Event");
    String result = await collection.findAsync("", limit: 100);
    print(result);
  });
}
