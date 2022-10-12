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

import 'package:cancellation_token/cancellation_token.dart';
import 'package:test/expect.dart';

import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Realm.beginWriteAsync starts write transaction', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();

    expect(transaction.isOpen, true);
  });

  test('Realm.beginWriteAsync with sync commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    transaction.commit();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync with async commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    await transaction.commitAsync();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWrite with sync commit persists changes', () {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = realm.beginWrite();
    realm.add(Person('John'));
    transaction.commit();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWrite with async commit persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = realm.beginWrite();
    realm.add(Person('John'));
    await transaction.commitAsync();

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync rollback undoes changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final transaction = await realm.beginWriteAsync();
    realm.add(Person('John'));
    transaction.rollback();

    expect(realm.all<Person>().length, 0);
  });

  test('Realm.writeAsync allows persists changes', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    await realm.writeAsync(() {
      realm.add(Person('John'));
    });

    expect(realm.all<Person>().length, 1);
  });

  test('Realm.beginWriteAsync when realm is closed undoes changes', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));

    await realm1.beginWriteAsync();
    realm1.add(Person('John'));
    realm1.close();

    expect(realm2.all<Person>().length, 0);
  });

  test("Realm.writeAsync with multiple transactions doesnt't deadlock", () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final t1 = await realm.beginWriteAsync();
    realm.add(Person('Marco'));

    final writeFuture = realm.writeAsync(() {
      realm.add(Person('Giovanni'));
    });

    await t1.commitAsync();
    await writeFuture;

    final people = realm.all<Person>();
    expect(people.length, 2);
    expect(people[0].name, 'Marco');
    expect(people[1].name, 'Giovanni');
  });

  test('Realm.writeAsync returns valid objects', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    final person = await realm.writeAsync(() {
      return realm.add(Person('John'));
    });

    expect(person.name, 'John');
  });

  test('Realm.writeAsync throws user exception', () async {
    final realm = getRealm(Configuration.local([Person.schema]));
    try {
      await realm.writeAsync(() {
        throw Exception('User exception');
      });
    } on Exception catch (e) {
      expect(e.toString(), 'Exception: User exception');
    }
  });

  test('Realm.writeAsync FIFO order ensured', () async {
    final acquisitionOrder = <int>[];
    final futures = <Future<void>>[];

    final realm = getRealm(Configuration.local([Person.schema]));

    for (var i = 0; i < 5; i++) {
      futures.add(realm.writeAsync(() {
        acquisitionOrder.add(i);
      }));
    }

    await Future.wait(futures);

    expect(acquisitionOrder, [0, 1, 2, 3, 4]);
  });

  test('Realm.beginWriteAsync with cancellation token', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));
    final t1 = realm1.beginWrite();

    final token = TimeoutCancellationToken(Duration(milliseconds: 1), timeoutException: CancelledException());

    await expectLater(realm2.beginWriteAsync(cancellationToken: token), throwsA(isA<CancelledException>()));

    t1.rollback();
  });

  test('Realm.writeAsync with cancellation token', () async {
    final realm1 = getRealm(Configuration.local([Person.schema]));
    final realm2 = getRealm(Configuration.local([Person.schema]));
    final t1 = realm1.beginWrite();

    final token = CancellationToken();
    Future<void>.delayed(Duration(milliseconds: 1)).then((value) => token.cancel());

    await expectLater(realm2.writeAsync(() {}, cancellationToken: token), throwsA(isA<CancelledException>()));

    t1.rollback();
  });

  test('Realm.beginWriteAsync when canceled after write lock obtained is a no-op', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    final transaction = await realm.beginWriteAsync(cancellationToken: token);
    token.cancel();

    expect(transaction.isOpen, true);
    expect(realm.isInTransaction, true);

    transaction.rollback();
  });

  test('Realm.writeAsync when canceled after write lock obtained rolls it back', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    await expectLater(
        realm.writeAsync(() {
          realm.add(Person('A'));
          token.cancel();
          realm.add(Person('B'));
        }, cancellationToken: token),
        throwsA(isA<CancelledException>()));

    expect(realm.all<Person>().length, 0);
    expect(realm.isInTransaction, false);
  });

  test('Realm.writeAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    token.cancel();

    await expectLater(realm.writeAsync(() {}, cancellationToken: token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, false);
  });

  test('Realm.beginWriteAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final token = CancellationToken();
    token.cancel();

    await expectLater(realm.beginWriteAsync(cancellationToken: token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, false);
  });

  test('Transaction.commitAsync with a canceled token throws', () async {
    final realm = getRealm(Configuration.local([Person.schema]));

    final transaction = await realm.beginWriteAsync();

    final token = CancellationToken();
    token.cancel();

    await expectLater(transaction.commitAsync(cancellationToken: token), throwsA(isA<CancelledException>()));
    expect(realm.isInTransaction, true);
  });
}
