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
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';

import '../lib/realm.dart';
import '../lib/src/native/realm_core.dart';
import '../lib/src/subscription.dart';
import 'test.dart';

@isTest
void testSubscriptions(String name, FutureOr<void> Function(Realm) tester) async {
  baasTest(name, (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final configuration = Configuration.flexibleSync(user, [Task.schema, Schedule.schema]);
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

    final oids = <ObjectId>{};
    const max = 1000;
    subscriptions.update((mutableSubscriptions) {
      oids.addAll([
        for (int i = 0; i < max; ++i) mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [newOid()])).id
      ]);
    });
    expect(oids.length, max); // no collisions
    expect(subscriptions.length, max);

    for (final sub in subscriptions) {
      expect(sub.id, isIn(oids));
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
    final query = realm.query<Schedule>('tasks.@count > 10');

    subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(query);
    });

    expect(() async => await subscriptions.waitForSynchronization(), throws<RealmException>());
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

    final pathY = path.join(temporaryDir.path, "Y.realm");
    final realmY = getRealm(Configuration.flexibleSync(userY, [Task.schema], path: pathY));

    realmX.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmX.all<Task>());
    });
    
    await realmX.subscriptions.waitForSynchronization();

    final objectId = ObjectId();
    realmX.write(() => realmX.add(Task(objectId)));

    realmY.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realmY.all<Task>());
    });
    
    await realmY.subscriptions.waitForSynchronization();

    await realmX.syncSession.waitForUpload();
    await realmX.syncSession.waitForDownload();
    
    await realmY.syncSession.waitForUpload();
    await realmY.syncSession.waitForDownload();

    await Future<void>.delayed(Duration(seconds: 2));

    waitForCondition(() {
      final task = realmY.find<Task>(objectId);  
      return task != null;
    });

    final task = realmY.find<Task>(objectId);
    expect(task, isNotNull);
  }); //, skip: "This test is super flaky. Disabling for now."
}
