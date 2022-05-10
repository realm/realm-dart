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
    final configuration = FlexibleSyncConfiguration(user, [Task.schema])..sessionStopPolicy = SessionStopPolicy.immediately;
    final realm = getRealm(configuration);
    await tester(realm);
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

  testSubscriptions('SubscriptionSet.state', (realm) async {
    final subscriptions = realm.subscriptions;
    await subscriptions.waitForSynchronization();
    expect(subscriptions.state, SubscriptionSetState.complete);
  });

  testSubscriptions('SubscriptionSet.version', (realm) async {
    final subscriptions = realm.subscriptions;
    expect(subscriptions.version, 0);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
    });

    expect(subscriptions.length, 1);
    expect(subscriptions.version, 1);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
    });

    expect(subscriptions.length, 0);
    expect(subscriptions.version, 2);
  });

  testSubscriptions('MutableSubscriptionSet.add', (realm) {
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });
    expect(subscriptions, isNotEmpty);
    expect(subscriptions.find(query), isNotNull);
  });

  testSubscriptions('MutableSubscriptionSet.add (named)', (realm) {
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions, isNotEmpty);
    expect(subscriptions.findByName(name), isNotNull);
  });

  testSubscriptions('SubscriptionSet.find', (realm) {
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    expect(subscriptions.find(query), isNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });
    expect(subscriptions.find(query), isNotNull);
  });

  testSubscriptions('SubscriptionSet.find (named)', (realm) {
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    expect(subscriptions.findByName(name), isNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions.findByName(name), isNotNull);
  });

  testSubscriptions('MutableSubscriptionSet.remove', (realm) {
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });
    expect(subscriptions, isNotEmpty);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByQuery(query);
    });
    expect(subscriptions, isEmpty);
  });

  testSubscriptions('MutableSubscriptionSet.remove (named)', (realm) {
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions, isNotEmpty);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByName(name);
    });
    expect(subscriptions, isEmpty);
  });

  testSubscriptions('MutableSubscriptionSet.removeAll', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]));
      mutableSubscriptions.add(realm.all<Task>());
    });
    expect(subscriptions.length, 2);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
    });
    expect(subscriptions, isEmpty);
  });

  testSubscriptions('SubscriptionSet.elementAt', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]));
      mutableSubscriptions.add(realm.all<Task>());
    });
    expect(subscriptions.length, 2);

    int index = 0;
    for (final s in subscriptions) {
      expect(s, s);
      expect(subscriptions[index], isNotNull);
      /* TODO: Not posible yet
      expect(subscriptions[index], subscriptions[index]);
      expect(s, subscriptions[index]);
      */
      ++index;
    }
  });

  testSubscriptions('MutableSubscriptionSet.elementAt', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      final s = mutableSubscriptions.add(realm.all<Task>());
      expect(mutableSubscriptions[0], isNotNull);
      expect(s, isNotNull);
      expect(mutableSubscriptions.state, SubscriptionSetState.uncommitted);
      // expect(mutableSubscriptions[0], s); // TODO: Not posible yet
    });
  });

  testSubscriptions('MutableSubscriptionSet.add double-add throws', (realm) {
    final subscriptions = realm.subscriptions;

    // Adding same unnamed query twice without requesting an update will just de-duplicate
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
      mutableSubscriptions.add(realm.all<Task>());
    });
    expect(subscriptions.length, 1);

    // Okay to add same query under different names, not de-duplicated
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: 'foo');
      mutableSubscriptions.add(realm.all<Task>(), name: 'bar');
    });
    expect(subscriptions.length, 3);

    // Cannot add different queries under same name, unless the second
    // can update the first.
    expect(() {
      subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm.all<Task>(), name: 'same');
        mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]), name: 'same');
      });
    }, throws<RealmException>('Duplicate subscription'));
  });

  testSubscriptions('MutableSubscriptionSet.add with update flag', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
      mutableSubscriptions.add(realm.all<Task>(), update: true);
    });

    expect(subscriptions.length, 1);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: 'same');
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]), name: 'same', update: true);
    });

    expect(subscriptions.length, 2);
  });

  testSubscriptions('Get subscriptions', (realm) async {
    final subscriptions = realm.subscriptions;

    expect(subscriptions, isEmpty);

    final query = realm.all<Task>();

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });

    expect(subscriptions.length, 1);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByQuery(query);
    });

    expect(subscriptions, isEmpty);

    const name = 'a random name';
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query, name: name);
    });

    expect(subscriptions.findByName(name), isNotNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByName(name);
    });

    expect(subscriptions, isEmpty);
    expect(realm.subscriptions.findByName(name), isNull);

    await subscriptions.waitForSynchronization();
  });
}
