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

import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:test/expect.dart';

import '../lib/realm.dart';
import '../lib/src/configuration.dart';
import 'test.dart';

@isTest
void testSubscriptions(String name, FutureOr<void> Function(Realm) tester) async {
  baasTest(name, (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = (Configuration.flexibleSync(user, [Task.schema]) as FlexibleSyncConfiguration)..sessionStopPolicy = SessionStopPolicy.immediately;
    final realm = getRealm(configuration);
    try {
      await tester(realm);
    } finally {
      realm.close();
    }
  });
}

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Get subscriptions throws on wrong configuration', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    expect(() => realm.subscriptions, throws<RealmError>());
  });

  testSubscriptions('SubscriptionSet.state', (realm) {
    expect(realm.subscriptions.state, SubscriptionSetState.uncommitted);
  });

  testSubscriptions('SubscriptionSet.version', (realm) async {
    final subscriptions = realm.subscriptions;
    expect(subscriptions.version, 0);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.addOrUpdate(realm.all<Task>());
    });

    expect(subscriptions.length, 1);
    expect(subscriptions.version, 1);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeAll();
    });

    expect(subscriptions.length, 0);
    expect(subscriptions.version, 2);
  });

  testSubscriptions('Get subscriptions', (realm) async {
    final subscriptions = realm.subscriptions;

    expect(subscriptions, isEmpty);

    final query = realm.all<Task>();

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.addOrUpdate(query);
    });

    expect(subscriptions.length, 1);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.remove(query);
    });

    expect(subscriptions, isEmpty);

    final name = 'a random name';
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.addOrUpdate(query, name: name);
    });

    expect(subscriptions.findByName(name), isNotNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByName(name);
    });

    expect(subscriptions, isEmpty);
    // expect(realm.subscriptions!.findByName(name), isNull); // TODO

    await subscriptions.waitForStateChange(SubscriptionSetState.complete);
  });
}
