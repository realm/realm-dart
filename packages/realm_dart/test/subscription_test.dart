// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/expect.dart' hide throws;

import 'package:realm_dart/realm.dart';
import 'package:realm_dart/src/handles/realm_core.dart';
import 'package:realm_dart/src/subscription.dart';
import 'test.dart';

void main() {
  setupTests();

  test('Get subscriptions throws on wrong configuration', () {
    final config = Configuration.local([Task.schema]);
    final realm = getRealm(config);
    expect(() => realm.subscriptions, throws<RealmError>());
  });

  baasTest('SubscriptionSet.state/waitForSynchronization', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;
    await subscriptions.waitForSynchronization();
    expect(subscriptions.state, SubscriptionSetState.complete);
  });

  baasTest('SubscriptionSet.state/waitForSynchronization canceled', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;
    final cancellationToken = CancellationToken();
    final waitFuture = subscriptions.waitForSynchronization(cancellationToken);
    cancellationToken.cancel();
    expect(() async => await waitFuture, throwsA(isA<CancelledException>()));
  });

  baasTest('SubscriptionSet.version', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.add', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });
    expect(subscriptions, isNotEmpty);
    expect(subscriptions.find(query), isNotNull);
  });

  baasTest('MutableSubscriptionSet.add named', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      s = mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions, isNotEmpty);
    expect(subscriptions.findByName(name), s);
  });

  baasTest('SubscriptionSet.find', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    expect(subscriptions.find(query), isNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });
    expect(subscriptions.find(query), isNotNull);
  });

  baasTest('SubscriptionSet.find return match, even if named', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;
    final query = realm.all<Task>();

    expect(subscriptions.find(query), isNull);

    late Subscription s;
    subscriptions.update((mutableSubscriptions) {
      s = mutableSubscriptions.add(query, name: 'foobar');
    });
    expect(subscriptions.find(query), s);
  });

  baasTest('SubscriptionSet.findByName', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    const name = 'some name';
    expect(subscriptions.findByName(name), isNull);

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: name);
    });
    expect(subscriptions.findByName(name), isNotNull);
  });

  baasTest('MutableSubscriptionSet.remove', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.removeByQuery', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.removeByName', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.removeAll', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('SubscriptionSet.elementAt', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.elementAt', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    subscriptions.update((mutableSubscriptions) {
      final s = mutableSubscriptions.add(realm.all<Task>());
      expect(mutableSubscriptions[0], isNotNull);
      expect(s, isNotNull);
      expect(mutableSubscriptions.state, SubscriptionSetState.pending); // not _uncommitted!
      expect(mutableSubscriptions[0], s);
    });
  });

  baasTest('MutableSubscriptionSet.add double-add throws', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.add with update flag', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.add multiple queries for same class', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.add same name, different classes', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    expect(
        () => subscriptions.update((mutableSubscriptions) {
              mutableSubscriptions.add(realm.all<Task>(), name: 'same');
              mutableSubscriptions.add(realm.all<Schedule>(), name: 'same');
            }),
        throws<RealmException>());
  });

  baasTest('MutableSubscriptionSet.add same name, different classes, with update flag', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    late Subscription subscription;
    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Task>(), name: 'same');
      subscription = mutableSubscriptions.add(realm.all<Schedule>(), name: 'same', update: true);
    });

    expect(subscriptions.length, 1);
    expect(subscriptions[0], subscription); // last added wins
  });

  baasTest('MutableSubscriptionSet.add same query, different classes', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.add illegal query', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptions = realm.subscriptions;

    // Illegal query for subscription:
    final query = realm.query<Schedule>('tasks.@count > 10 SORT(id ASC)');

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });

    expect(() async => await subscriptions.waitForSynchronization(), throws<RealmException>("invalid RQL"));
  });

  baasTest('MutableSubscriptionSet.remove same query, different classes', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('MutableSubscriptionSet.removeByType', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('Get subscriptions', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('Subscription properties roundtrip', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

    final realmX = getRealm(Configuration.flexibleSync(userX, getSyncSchema()));
    final objectId = ObjectId();

    realmX.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmX.query<Task>(r'_id == $0', [objectId]));
    });
    await realmX.subscriptions.waitForSynchronization();
    realmX.write(() => realmX.add(Task(objectId)));
    await realmX.syncSession.waitForUpload();

    final realmY = getRealm(Configuration.flexibleSync(userY, getSyncSchema()));
    realmY.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmY.query<Task>(r'_id == $0', [objectId]));
    });
    await realmY.subscriptions.waitForSynchronization();
    await realmY.syncSession.waitForDownload();
    final task = realmY.find<Task>(objectId);
    expect(task, isNotNull);
  });

  baasTest('Writing before subscribe', (configuration) async {
    final user = await getIntegrationUser(appConfig: configuration);

    final config = Configuration.flexibleSync(user, getSyncSchema());

    final realm = getRealm(config);
    expect(() => realm.write(() => realm.add(Task(ObjectId()))), throws<RealmException>("no flexible sync subscription has been created"));
  });

  baasTest('Filter realm data using query subscription', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
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

  baasTest('Subscriptions when realm is closed gets closed as well', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);

    final subscriptions = realm.subscriptions;
    expect(() => subscriptions.state, returnsNormally);

    realm.close();
    expect(() => subscriptions.state, throws<RealmClosedError>());
  });

  baasTest('SyncSessionErrorCode.compensatingWrite', (configuration) async {
    late SyncError compensatingWriteError;
    final productNamePrefix = generateRandomString(4);
    final user = await getIntegrationUser(appConfig: configuration);
    final config = Configuration.flexibleSync(user, getSyncSchema(), syncErrorHandler: (syncError) {
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
    final sessionError = compensatingWriteError as CompensatingWriteError;
    expect(sessionError.message, startsWith('Client attempted a write that is not allowed'));
    expect(sessionError.compensatingWrites, isNotNull);
    final writeReason = sessionError.compensatingWrites!.first;
    expect(writeReason, isNotNull);
    expect(writeReason.objectType, "Product");
    expect(writeReason.reason, 'write to ObjectID("$productId") in table "${writeReason.objectType}" not allowed; object is outside of the current query view');
    expect(writeReason.primaryKey.value, productId);
  });

  baasTest('Flexible sync subscribe/unsubscribe API', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final prefix = generateRandomString(4);
    final byTestRun = "name BEGINSWITH '$prefix'";
    final query = realm.query<Event>(byTestRun);
    await query.subscribe();

    // Write new data and upload
    realm.write(() {
      realm.addAll([
        Event(ObjectId(), name: "$prefix NPM Event", isCompleted: true, durationInMinutes: 30),
        Event(ObjectId(), name: "$prefix NPM Meeting", isCompleted: false, durationInMinutes: 10),
        Event(ObjectId(), name: "$prefix Some other event", isCompleted: true, durationInMinutes: 15),
      ]);
    });
    expect(query.length, 3);
    await realm.syncSession.waitForUpload();

    // Remove all the data from realm file after synchronization completes
    realm.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.clear());
    await realm.subscriptions.waitForSynchronization();
    expect(query.length, 0);

    // Subscribing will download only the objects with names containing 'NPM'
    final subscribedByName = await realm.query<Event>('$byTestRun AND name CONTAINS \$0', ["NPM"]).subscribe();
    expect(subscribedByName.length, 2);

    // Adding subscription by duration on top of downloaded objects by name
    // will remove the objects, which don't match duration < 20, from the local realm
    final subscribedByNameAndDuration = await subscribedByName.query(r'durationInMinutes < $0', [20]).subscribe();
    expect(subscribedByNameAndDuration.length, 1);
    expect(subscribedByNameAndDuration[0].durationInMinutes, 10);
    expect(subscribedByNameAndDuration[0].name, contains("NPM"));

    // Query local realm by duration
    final filteredByDuration = realm.query<Event>("$byTestRun AND durationInMinutes < \$0", [20]);
    expect(filteredByDuration.length, 1); // duration 10 only, because there is subscription by name containing 'NPM' and duration < 20

    // Subscribing only by duration will download all objects with duration < 20 independent on the name
    final subscribedByDuration = await filteredByDuration.subscribe();
    expect(subscribedByDuration.length, 2); // duration 10 and 15, because all objects with durations < 20 are downloaded
  });

  test("Using flexible sync subscribe API for local realm throws", () async {
    final config = Configuration.local([Event.schema]);
    final realm = getRealm(config);
    await expectLater(
        () => realm.all<Event>().subscribe(), throws<RealmError>("subscriptions is only valid on Realms opened with a FlexibleSyncConfiguration"));
    expect(() => realm.all<Event>().unsubscribe(), throws<RealmError>("unsubscribe is only allowed on Realms opened with a FlexibleSyncConfiguration"));
  });

  baasTest('Flexible sync subscribe API - duplicated subscription', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptionName1 = "sub1";
    final subscriptionName2 = "sub2";
    final query1 = realm.all<Event>();
    final query2 = realm.query<Event>("name = \$0", ["some name"]);

    await query1.subscribe(name: subscriptionName1);
    expect(realm.subscriptions.version, 1);
    expect(realm.subscriptions.length, 1);

    //Replace subscription with query2 using the same name and update flag
    await query2.subscribe(name: subscriptionName1, update: true);
    expect(realm.subscriptions.length, 1);
    expect(realm.subscriptions.findByName(subscriptionName1), isNotNull);

    //Subscribe for the same query2 with different name
    await query2.subscribe(name: subscriptionName2);
    expect(realm.subscriptions.length, 2);
    expect(realm.subscriptions.findByName(subscriptionName1), isNotNull);
    expect(realm.subscriptions.findByName(subscriptionName2), isNotNull);

    //Add query subscription with the same name and update=false throws
    await expectLater(() => query1.subscribe(name: subscriptionName2), throws<RealmException>("Duplicate subscription with name: $subscriptionName2"));
  });

  baasTest('Flexible sync subscribe/unsubscribe and removeAllUnnamed', (config) async {
    final realm = await getIntegrationRealm(appConfig: config);
    final subscriptionName1 = "sub1";
    final subscriptionName2 = "sub2";
    final query = realm.all<Event>();
    final queryFiltered = realm.query<Event>("name='x'");

    final unnamedResults = await query.subscribe(); // +1 unnamed subscription
    await query.subscribe(); // +0 subscription already exists
    await realm.all<Event>().subscribe(); // +0 subscription already exists
    await queryFiltered.subscribe(); // +1 unnamed subscription
    final namedResults1 = await query.subscribe(name: subscriptionName1); // +1 named subscription
    final namedResults2 = await query.subscribe(name: subscriptionName2); // +1 named subscription
    expect(realm.subscriptions.length, 4);

    expect(query.unsubscribe(), isFalse); // -0 (query is not a subscription)
    expect(realm.subscriptions.length, 4);

    expect(unnamedResults.unsubscribe(), isTrue); // -1 unnamed subscription on query
    expect(realm.subscriptions.length, 3);
    expect(realm.subscriptions.find(queryFiltered), isNotNull);
    expect(realm.subscriptions.findByName(subscriptionName1), isNotNull);
    expect(realm.subscriptions.findByName(subscriptionName2), isNotNull);

    realm.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.clear(unnamedOnly: true)); // -1 unnamed subscription on queryFiltered

    expect(realm.subscriptions.length, 2);
    expect(realm.subscriptions.findByName(subscriptionName1), isNotNull);
    expect(realm.subscriptions.findByName(subscriptionName2), isNotNull);

    expect(namedResults1.unsubscribe(), isTrue); // -1 named subscription sub1
    expect(realm.subscriptions.length, 1);
    expect(realm.subscriptions.findByName(subscriptionName2), isNotNull);

    expect(namedResults2.unsubscribe(), isTrue); // -1 named subscription
    expect(realm.subscriptions.length, 0);
  });

  baasTest('Flexible sync subscribe/unsubscribe API wait for download', (configuration) async {
    int count = 2;
    RealmResults<Product> query = await _getQueryToSubscribeForDownload(configuration, count);
    final results = await query.subscribe(waitForSyncMode: WaitForSyncMode.never);
    expect(results.length, 0); // didn't wait for downloading because of WaitForSyncMode.never

    final second = await query.subscribe(waitForSyncMode: WaitForSyncMode.always);
    expect(second.length, count); // product_1 and product_21
  });

  baasTest('Flexible sync subscribe/unsubscribe cancellation token', (configuration) async {
    RealmResults<Product> query = await _getQueryToSubscribeForDownload(configuration, 3);

    // Wait Always if timeout expired
    final timeoutCancellationToken = TimeoutCancellationToken(Duration(microseconds: 0));
    await expectLater(
      () async => await query.subscribe(waitForSyncMode: WaitForSyncMode.always, cancellationToken: timeoutCancellationToken),
      throwsA(isA<TimeoutException>()),
    );

    // Wait Always but cancel berfore
    final cancellationToken = CancellationToken();
    cancellationToken.cancel();
    await expectLater(
      query.subscribe(waitForSyncMode: WaitForSyncMode.always, cancellationToken: cancellationToken),
      throwsA(isA<CancelledException>()),
    );

    // Wait Never but cancel before
    final cancellationToken1 = CancellationToken();
    cancellationToken1.cancel();
    await expectLater(
      query.subscribe(waitForSyncMode: WaitForSyncMode.never, cancellationToken: cancellationToken1),
      throwsA(isA<CancelledException>()),
    );

    // Wait Always but cancel after
    final cancellationToken2 = CancellationToken();
    final subFuture = query.subscribe(waitForSyncMode: WaitForSyncMode.always, cancellationToken: cancellationToken2);
    cancellationToken2.cancel();

    expect(
      () async => await subFuture,
      throwsA(isA<CancelledException>()),
    );
  });
}

Future<RealmResults<Product>> _getQueryToSubscribeForDownload(AppConfiguration configuration, int takeCount) async {
  final prefix = generateRandomString(4);
  final byTestRun = "name BEGINSWITH '$prefix'";
  App app = App(configuration);
  final userA = await app.logIn(Credentials.anonymous(reuseCredentials: false));
  final configA = Configuration.flexibleSync(userA, getSyncSchema());
  final realmA = getRealm(configA);
  await realmA.query<Product>(byTestRun).subscribe();
  List<String> names = [];
  realmA.write(() {
    for (var i = 0; i < 20; i++) {
      final name = "${prefix}_${i + 1}";
      names.add(name);
      realmA.add(Product(ObjectId(), name));
    }
  });
  await realmA.syncSession.waitForUpload();
  realmA.close();

  final userB = await app.logIn(Credentials.anonymous(reuseCredentials: false));
  final configB = Configuration.flexibleSync(userB, getSyncSchema());
  final realmB = getRealm(configB);
  final query = realmB.query<Product>('$byTestRun AND name IN \$0', [names.take(takeCount)]);

  return query;
}
