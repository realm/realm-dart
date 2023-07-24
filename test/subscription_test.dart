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
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:test/expect.dart' hide throws;

import '../lib/realm.dart';
import '../lib/src/configuration.dart';
import '../lib/src/native/realm_core.dart';
import '../lib/src/subscription.dart';
import 'test.dart';

@isTest
void testSubscriptions(String name, FutureOr<void> Function(Realm) testFunc) async {
  baasTest(name, (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [
      Task.schema,
      Schedule.schema,
      Event.schema,
    ])
      ..sessionStopPolicy = SessionStopPolicy.immediately;
    final realm = getRealm(configuration);
    await testFunc(realm);
  });
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Get subscriptions throws on wrong configuration', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    expect(() => realm.subscriptions, throws<RealmError>());
  });

  testSubscriptions('SubscriptionSet.state/waitForSynchronization', (realm) async {
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

  testSubscriptions('MutableSubscriptionSet.add named', (realm) {
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      s = mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions, isNotEmpty);
    expect(subscriptions.findByName(name), s);
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

  testSubscriptions('SubscriptionSet.find return match, even if named', (realm) {
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    expect(subscriptions.find(query), isNull);

    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      s = mutableSubscriptions.add(query, name: 'foobar');
    });
    expect(subscriptions.find(query), s);
  });

  testSubscriptions('SubscriptionSet.findByName', (realm) {
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

    final s = subscriptions[0];

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.remove(s);
    });
    expect(subscriptions, isEmpty);
  });

  testSubscriptions('MutableSubscriptionSet.removeByQuery', (realm) {
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

  testSubscriptions('MutableSubscriptionSet.removeByName', (realm) {
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
      expect(subscriptions[index], subscriptions[index]);
      expect(s, subscriptions[index]);
      ++index;
    }

    expect(() => subscriptions[-1], throws<RangeError>());
    expect(() => subscriptions[1000], throws<RangeError>());
  });

  testSubscriptions('MutableSubscriptionSet.elementAt', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      final s = mutableSubscriptions.add(realm.all<Task>());
      expect(mutableSubscriptions[0], isNotNull);
      expect(s, isNotNull);
      expect(mutableSubscriptions.state, SubscriptionSetState.pending); // not _uncommitted!
      expect(mutableSubscriptions[0], s);
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

  testSubscriptions('MutableSubscriptionSet.add multiple queries for same class', (realm) {
    final subscriptions = realm.subscriptions;
    final random = Random.secure();

    Uint8List randomBytes(int n) {
      final Uint8List randomList = Uint8List(n);
      for (int i = 0; i < randomList.length; i++) {
        randomList[i] = random.nextInt(255);
      }
      return randomList;
    }

    ObjectId newOid() => ObjectId.fromBytes(randomBytes(12));

    final objectIds = <ObjectId>{};
    const max = 1000;
    subscriptions.update((mutableSubscriptions) {
      objectIds.addAll([
        for (int i = 0; i < max; ++i) mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [newOid()])).id
      ]);
    });
    expect(objectIds.length, max); // no collisions
    expect(subscriptions.length, max);

    for (final sub in subscriptions) {
      expect(sub.id, isIn(objectIds));
    }
  });

  testSubscriptions('MutableSubscriptionSet.add same name, different classes', (realm) {
    final subscriptions = realm.subscriptions;

    expect(
        () => subscriptions.update((mutableSubscriptions) {
              mutableSubscriptions.add(realm.all<Task>(), name: 'same');
              mutableSubscriptions.add(realm.all<Schedule>(), name: 'same');
            }),
        throws<RealmException>());
  });

  testSubscriptions('MutableSubscriptionSet.add same name, different classes, with update flag', (realm) {
    final subscriptions = realm.subscriptions;

    late Subscription subscription;
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: 'same');
      subscription = mutableSubscriptions.add(realm.all<Schedule>(), name: 'same', update: true);
    });

    expect(subscriptions.length, 1);
    expect(subscriptions[0], subscription); // last added wins
  });

  testSubscriptions('MutableSubscriptionSet.add same query, different classes', (realm) {
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
      mutableSubscriptions.add(realm.all<Schedule>());
    });

    expect(subscriptions.length, 2);
    for (final s in subscriptions) {
      expect(s.queryString, contains('TRUEPREDICATE'));
    }
  });

  testSubscriptions('MutableSubscriptionSet.add illegal query', (realm) async {
    final subscriptions = realm.subscriptions;

    // Illegal query for subscription:
    final query = realm.query<Schedule>('tasks.@count > 10 SORT(id ASC)');

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });

    expect(() async => await subscriptions.waitForSynchronization(), throws<RealmException>("invalid RQL"));
  });

  testSubscriptions('MutableSubscriptionSet.remove same query, different classes', (realm) {
    final subscriptions = realm.subscriptions;

    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>());
      s = mutableSubscriptions.add(realm.all<Schedule>());
    });

    expect(subscriptions.length, 2);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByQuery(realm.all<Task>());
    });

    expect(subscriptions, [s]);
  });

  testSubscriptions('MutableSubscriptionSet.removeByType', (realm) {
    final subscriptions = realm.subscriptions;

    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]));
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]));
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]));
      s = mutableSubscriptions.add(realm.all<Schedule>());
    });

    expect(subscriptions.length, 4);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByType<Task>();
    });

    expect(subscriptions, [s]);
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

  testSubscriptions('Subscription properties roundtrip', (realm) async {
    final subscriptions = realm.subscriptions;

    final before = DateTime.now().toUtc();

    late ObjectId oid;
    subscriptions.update((mutableSubscriptions) {
      oid = mutableSubscriptions.add(realm.all<Task>(), name: 'foobar').id;
    });

    await subscriptions.waitForSynchronization();

    final after = DateTime.now().toUtc();
    var s = subscriptions[0];

    expect(s.id, oid);
    expect(s.name, 'foobar');
    expect(s.objectClassName, 'Task');
    expect(s.queryString, contains('TRUEPREDICATE'));
    expect(s.createdAt.isAfter(before), isTrue);
    expect(s.createdAt.isBefore(after), isTrue);
    expect(s.createdAt, s.updatedAt);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [ObjectId()]), name: 'foobar', update: true);
    });

    s = subscriptions[0]; // Needed in order to refresh properties!
    expect(s.createdAt.isBefore(s.updatedAt), isTrue);
  });

  baasTest('flexible sync roundtrip', (appConfigurationX) async {
    final appX = App(appConfigurationX);

    realmCore.clearCachedApps();
    final temporaryDir = await Directory.systemTemp.createTemp('realm_test_flexible_sync_roundtrip_');
    final appConfigurationY = AppConfiguration(
      appConfigurationX.appId,
      baseUrl: appConfigurationX.baseUrl,
      baseFilePath: temporaryDir,
    );
    final appY = App(appConfigurationY);

    final credentials = Credentials.anonymous();
    final userX = await appX.logIn(credentials);
    final userY = await appY.logIn(credentials);

    final realmX = getRealm(Configuration.flexibleSync(userX, [Task.schema]));
    final realmY = getRealm(Configuration.flexibleSync(userY, [Task.schema]));

    realmX.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmX.all<Task>());
    });

    final objectId = ObjectId();
    realmX.write(() => realmX.add(Task(objectId)));

    realmY.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmY.all<Task>());
    });

    await realmX.subscriptions.waitForSynchronization();
    await realmY.subscriptions.waitForSynchronization();

    await realmX.syncSession.waitForUpload();
    await realmY.syncSession.waitForDownload();

    final task = realmY.find<Task>(objectId);
    expect(task, isNotNull);
  });

  baasTest('Writing before subscribe', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final config = Configuration.flexibleSync(
      user,
      [Task.schema],
    );

    final realm = getRealm(config);
    expect(() => realm.write(() => realm.add(Task(ObjectId()))), throws<RealmException>("no flexible sync subscription has been created"));
  });

  testSubscriptions('Filter realm data using query subscription', (realm) async {
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

    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeByQuery(realm.all<Event>());
      mutableSubscriptions.add(realm.query<Event>(r'name BEGINSWITH $0 AND isCompleted == $1 AND durationInMinutes > $2', ["NPMG", true, 20]), name: "filter");
    });

    await realm.subscriptions.waitForSynchronization();
    await realm.syncSession.waitForDownload();

    var filtered = realm.query<Event>(realm.subscriptions.findByName("filter")!.queryString);
    var all = realm.all<Event>();
    expect(filtered, isNotEmpty);
    expect(filtered.length, all.length);
  });

  baasTest('Subscriptions when realm is closed gets closed as well', (configuration) async {
    final app = App(configuration);
    final user = await getIntegrationUser(app);

    final config = Configuration.flexibleSync(user, [Task.schema]);
    final realm = getRealm(config);

    final subscriptions = realm.subscriptions;
    expect(() => subscriptions.state, returnsNormally);

    realm.close();
    expect(() => subscriptions.state, throws<RealmClosedError>());
  });

  baasTest('SyncSessionErrorCode.compensatingWrite', (configuration) async {
    late SyncError compensatingWriteError;
    final productNamePrefix = generateRandomString(4);
    final app = App(configuration);
    final user = await getIntegrationUser(app);
    final config = Configuration.flexibleSync(user, [Product.schema], syncErrorHandler: (syncError) {
      compensatingWriteError = syncError;
    });
    final realm = getRealm(config);
    final query = realm.query<Product>(r'name BEGINSWITH $0', [productNamePrefix]);
    realm.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.add(query));
    await realm.subscriptions.waitForSynchronization();

    final productId = ObjectId();
    realm.write(() => realm.add(Product(productId, "doesn't match subscription")));
    await realm.syncSession.waitForUpload();

    expect(compensatingWriteError, isA<CompensatingWriteError>());
    final sessionError = compensatingWriteError.as<CompensatingWriteError>();
    expect(sessionError.category, SyncErrorCategory.session);
    expect(sessionError.code, SyncSessionErrorCode.compensatingWrite);
    expect(sessionError.message!.startsWith('Client attempted a write that is disallowed by permissions, or modifies an object outside the current query'),
        isTrue);
    expect(sessionError.detailedMessage, isNotEmpty);
    expect(sessionError.message == sessionError.detailedMessage, isFalse);
    expect(sessionError.compensatingWrites, isNotNull);
    final writeReason = sessionError.compensatingWrites!.first;
    expect(writeReason, isNotNull);
    expect(writeReason.objectType, "Product");
    expect(writeReason.reason, 'write to "$productId" in table "${writeReason.objectType}" not allowed; object is outside of the current query view');
    expect(writeReason.primaryKey.value, productId);
  });

  testSubscriptions('Flexible sync subscribe/unsubscribe API', (realm) async {
    final name = generateRandomString(4);
    final query = await realm.query<Event>(r"name BEGINSWITH $0", [name]).subscribe();

    realm.write(() {
      realm.addAll([
        Event(ObjectId(), name: "$name NPM Event", isCompleted: true, durationInMinutes: 30),
        Event(ObjectId(), name: "$name NPM Meeting", isCompleted: false, durationInMinutes: 10),
        Event(ObjectId(), name: "$name Some other event", isCompleted: true, durationInMinutes: 60),
      ]);
    });

    expect(realm.subscriptions.length, 1);
    expect(query.length, 3);

    query.unsubscribe();
    expect(realm.subscriptions.length, 0);

    final namedQuery =
        await realm.query<Event>(r'name BEGINSWITH $0 AND isCompleted == $1 AND durationInMinutes > $2', ["$name NPM", true, 20]).subscribe(name: "filter");

    expect(realm.subscriptions.length, 1);
    expect(namedQuery.length, 1);
  });

  test("Use Flexible sync subscribe API for local realm", () async {
    final config = Configuration.local([Event.schema]);
    final realm = getRealm(config);
    await expectLater(
        () => realm.all<Event>().subscribe(), throws<RealmError>("subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration"));
    await expectLater(
        () => realm.all<Event>().unsubscribe(), throws<RealmError>("subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration"));
  });

  testSubscriptions('Flexible sync subscribe API duplicate subscription', (realm) async {
    final subscriptionName = "sub1";
    final subscriptionNewName = "sub2";
    final query1 = realm.all<Event>();
    final query2 = realm.query<Event>("name = 'some name'");

    await query1.subscribe(name: subscriptionName);
    expect(realm.subscriptions.length, 1);

    //Subscribe for the same query with the same name using update flag
    await query1.subscribe(name: subscriptionName, update: true);
    expect(realm.subscriptions.length, 1);

    //Replace query subscription with the same name using update flag
    await query2.subscribe(name: subscriptionName, update: true);
    expect(realm.subscriptions.length, 1);

    //Subscribe for the same query with different name
    await query2.subscribe(name: subscriptionNewName);
    expect(realm.subscriptions.length, 2);

    //Add query subscription with the same name throws
    await expectLater(() => query1.subscribe(name: subscriptionNewName), throws<RealmException>("Duplicate subscription with name: $subscriptionNewName"));
  });

  testSubscriptions('Flexible sync subscribe API unnamed subscriptions', (realm) async {
    final query = realm.all<Event>();
    query.subscribe();
    expect(realm.subscriptions.length, 1);

    //Subscribe for the same query doesn't add new subscription
    await realm.all<Event>().subscribe();
    expect(realm.subscriptions.length, 1);

    //Subscribe for the same query instance doesn't add new subscription
    query.subscribe();
    expect(realm.subscriptions.length, 1);

    await realm.query<Event>("name = 'some name'").subscribe();
    expect(realm.subscriptions.length, 2);
  });

  testSubscriptions('Flexible sync subscribe/unsubscribe API removeUnnamed', (realm) async {
    final subscriptionName = "sub1";
    final query = realm.all<Event>();

    void subscribeTwice() async {
      //Create named and unnamed subscriptions for the same query
      await query.subscribe();
      await query.subscribe(name: subscriptionName);
      expect(realm.subscriptions.length, 2);
    }

    subscribeTwice();

    //Remove unnamed subscription
    query.unsubscribe();
    expect(realm.subscriptions.length, 1);

    //removeUnnamed does nothing, since only named subscription exists
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeUnnamed();
    });
    expect(realm.subscriptions.length, 1);

    //Remove named subscription
    query.unsubscribe(name: subscriptionName);
    expect(realm.subscriptions.length, 0);

    subscribeTwice();

    //Remove named subscription
    query.unsubscribe(name: subscriptionName);
    expect(realm.subscriptions.length, 1);

    //Remove unnamed subscription
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.removeUnnamed();
    });
    expect(realm.subscriptions.length, 0);
  });

  baasTest('Flexible sync subscribe/unsubscribe API wait for download', (configuration) async {
    final productNamePrefix = generateRandomString(10);
    App app = App(configuration);
    final user = await app.logIn(Credentials.anonymous(reuseCredentials: false));
    final config = Configuration.flexibleSync(user, [Product.schema]);
    final realm = getRealm(config);
    await realm.query<Product>(r'name BEGINSWITH $0', [productNamePrefix]).subscribe();
    realm.write(() {
      for (var i = 0; i < 20; i++) {
        realm.add(Product(ObjectId(), "${productNamePrefix}_${i + 1}"));
      }
    });
    await realm.syncSession.waitForUpload();
    realm.close();

    final user1 = await app.logIn(Credentials.anonymous(reuseCredentials: false));
    final config1 = Configuration.flexibleSync(user1, [Product.schema]);
    final realm1 = getRealm(config1);
    final query = realm1.query<Product>(r'name BEGINSWITH $0', ["${productNamePrefix}_1"]);
    final results = await query.subscribe(waitForSyncMode: WaitForSyncMode.never);
    expect(results.length, 0);

    final first = await query.subscribe(waitForSyncMode: WaitForSyncMode.always, timeout: Duration(milliseconds: 1));
    expect(first.length, 0);

    final second = await query.subscribe(waitForSyncMode: WaitForSyncMode.always);
    expect(second.length, 10);
  });
}
