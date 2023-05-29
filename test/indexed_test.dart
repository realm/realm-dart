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

import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'package:test/test.dart' hide test;
import 'test.dart';

import '../lib/realm.dart';

part 'indexed_test.g.dart';

// Don't import our own test.dart here. It will break AOT compilation.
// We may use AOT compilation locally to manually run the performance
// tests in this file

@RealmModel()
class _WithIndexes {
  @Indexed()
  late int anInt;

  @Indexed()
  late bool aBool;

  @Indexed()
  late String string;

  @Indexed()
  late DateTime timestamp;

  @Indexed()
  late ObjectId objectId;

  @Indexed()
  late Uuid uuid;
}

@RealmModel()
class _NoIndexes {
  late int anInt;
  late bool aBool;
  late String string;
  late DateTime timestamp;
  late ObjectId objectId;
  late Uuid uuid;
}

typedef QueryBuilder<T, U> = RealmResults<T> Function(U value);

void main([List<String>? args]) {
  setupTests(args);

  test('Indexed faster', () {
    final config = Configuration.local([WithIndexes.schema, NoIndexes.schema]);
    Realm.deleteRealm(config.path);
    final realm = Realm(config);

    const max = 100000;
    final allIndexed = realm.all<WithIndexes>();
    final allNotIndexed = realm.all<NoIndexes>();

    expect(realm.all<WithIndexes>().length, 0);

    intFactory(int i) => i.hashCode;
    boolFactory(int i) => i % 2 == 0;
    stringFactory(int i) => '${i.hashCode} $i';
    timestampFactory(int i) => DateTime.fromMillisecondsSinceEpoch(i.hashCode);
    objectIdFactory(int i) => ObjectId.fromValues(i.hashCode * 1000000, i.hashCode, i);
    uuidFactory(int i) => Uuid.fromBytes(Uint8List(16).buffer..asByteData().setInt64(0, i.hashCode));

    final indexed = List.generate(
      max,
      (i) => WithIndexes(
        intFactory(i),
        boolFactory(i),
        stringFactory(i),
        timestampFactory(i),
        objectIdFactory(i),
        uuidFactory(i),
      ),
    );
    realm.write(() => realm.addAll(indexed));

    expect(allIndexed.length, max);

    final notIndexed = List.generate(
      max,
      (i) => NoIndexes(
        intFactory(i),
        boolFactory(i),
        stringFactory(i),
        timestampFactory(i),
        objectIdFactory(i),
        uuidFactory(i),
      ),
    );
    realm.write(() => realm.addAll(notIndexed));

    expect(allNotIndexed.length, max);

    // Inefficient, but fast enough for this test
    final searchOrder = (List.generate(max, (i) => i)..shuffle(Random(42))).take(1000).toList();

    QueryBuilder<T, U> builder<T extends RealmObject, U extends Object>(RealmResults<T> results, String fieldName) {
      return (U value) => results.query('$fieldName == \$0', [value]);
    }

    @pragma('vm:no-interrupts')
    Duration measureSpeed<T extends RealmObject, U extends Object>(
      RealmResults<T> results,
      String fieldName,
      U Function(int index) indexToValue,
    ) {
      final queryBuilder = builder(results, fieldName);
      final queries = searchOrder.map((i) => queryBuilder(indexToValue(i))).toList(); // pre-calculate queries
      final found = <T?>[];

      final sw = Stopwatch()..start();
      for (final q in queries) {
        found.add(q.singleOrNull); // evaluate query
      }
      final timing = sw.elapsed;

      // check that we found the right objects
      for (final f in found) {
        expect(f, isNotNull);
      }

      return timing;
    }

    void compareSpeed<U extends Object>(
      String fieldName,
      U Function(int index) indexToValue,
    ) {
      final lookupCount = searchOrder.length;

      display(Type type, Duration duration) {
        print('$lookupCount lookups of ${'$type'.padRight(12)} on ${fieldName.padRight(10)} : ${duration.inMicroseconds ~/ lookupCount} us/lookup');
      }

      final indexedTime = measureSpeed(allIndexed, fieldName, indexToValue);
      final notIndexedTime = measureSpeed(allNotIndexed, fieldName, indexToValue);
      try {
        // skip timestamp for now, as timestamps are not indexed properly it seems
        if (fieldName != 'timestamp') {
          expect(indexedTime, lessThan(notIndexedTime)); // indexed should be faster
        }
      } catch (_) {
        display(WithIndexes, indexedTime); // only display if test fails
        display(NoIndexes, notIndexedTime);
        rethrow; // rethrow to fail test
      }
    }

    compareSpeed('anInt', intFactory);
    compareSpeed('string', stringFactory);
    compareSpeed('timestamp', timestampFactory);
    compareSpeed('objectId', objectIdFactory);
    compareSpeed('uuid', uuidFactory);
  });
}
