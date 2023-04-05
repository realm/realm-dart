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

@Tags(['destructive'])
import 'dart:async';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

part 'destructive_schema_test.g.dart';

@RealmModel()
@MapTo("Card")
class _CardV1 {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;
}

@RealmModel()
@MapTo("Card")
class _CardV2 {
  @PrimaryKey()
  @MapTo('_id')
  late Uuid id;
}

// Destructive schema change causes the server to force the translator to restart.
// This means that the Flexible sync will be terminated and re-enabled.
// During this operation no other tests working with flexible sync could be executed.
// For this reason this test is relocated to a separate file,
// whichwill be executed at the end after all the other tests.
Future<void> main([List<String>? args]) async {
  await setupTests(args);

  baasTest('Realm can be deleted after destructive schema change (flexibleSync)', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final configV1 = Configuration.flexibleSync(user, [CardV1.schema]);
    final realmV1 = getRealm(configV1);
    realmV1.close();
    final configV2 = Configuration.flexibleSync(user, [CardV2.schema]);
    try {
      Realm(configV2);
    } catch (e) {
      expect(e, isA<RealmException>());
      String exceptionMessage = (e as RealmException).message;
      expect(exceptionMessage.contains("Error code: 2019 . Message: The following changes cannot be made in additive-only schema mode"), true);
      expect(exceptionMessage.contains("Property 'Card._id' has been changed from 'object id' to 'uuid'"), true);
      user.logOut(); // User logOut force the syncSession to be released.
      Realm.deleteRealm(configV2.path);
    }
  });

  test('Realm can be deleted after migration required error (local)', () async {
    final configV1 = Configuration.local([CardV1.schema]);
    final realmV1 = getRealm(configV1);
    realmV1.close();
    final configV2 = Configuration.local([CardV2.schema]);
    try {
      Realm(configV2);
    } catch (e) {
      print(e);
      expect(e, isA<RealmException>());
      String exceptionMessage = (e as RealmException).message;
      expect(exceptionMessage.contains("Error code: 2017 . Message: Migration is required due to the following errors"), true);
      expect(exceptionMessage.contains("Property 'Card._id' has been changed from 'object id' to 'uuid'"), true);
      Realm.deleteRealm(configV2.path);
    }
  });
}
