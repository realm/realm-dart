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

import 'dart:io';

import 'package:test/expect.dart';

import '../lib/realm.dart';
import '../lib/src/configuration.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  baasTest('Get subscriptions', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = (Configuration.flexibleSync(user, [Task.schema]) as FlexibleSyncConfiguration)..sessionStopPolicy = SessionStopPolicy.immediately;
    final realm = getRealm(configuration);

    expect(realm.subscriptions, isEmpty);

    final query = realm.all<Task>();

    realm.subscriptions!.update((mutableSet) {
      mutableSet.addOrUpdate(query);
    });

    expect(realm.subscriptions!.length, 1);

    realm.subscriptions!.update((mutableSubscriptions) {
      mutableSubscriptions.remove(query);
    });

    expect(realm.subscriptions, isEmpty);

    final name = 'a random name';
    realm.subscriptions!.update((mutableSubscriptions) {
      mutableSubscriptions.addOrUpdate(query, name: name);
    });

    expect(realm.subscriptions!.findByName(name), isNotNull);

    realm.subscriptions!.update((mutableSubscriptions) {
      mutableSubscriptions.removeByName(name);
    });

    expect(realm.subscriptions, isEmpty);
    // expect(realm.subscriptions!.findByName(name), isNull);

    realm.subscriptions!.waitForStateChange(SubscriptionSetState.complete);

    realm.close();
    app.logout(user);
  });
}
