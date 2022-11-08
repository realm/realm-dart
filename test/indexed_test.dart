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
import 'package:test/test.dart';

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
  late String string;

  @Indexed()
  late bool aBool;

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
  late String string;
  late bool aBool;
  late DateTime timestamp;
  late ObjectId objectId;
  late Uuid uuid;
}

typedef QueryBuilder<T, U> = RealmResults<T> Function(U value);

Future<void> main([List<String>? args]) async {
  test('Indexed faster', () {
    final config = Configuration.local([WithIndexes.schema, NoIndexes.schema]);
    print('Opening realm: ${config.path}');

    final realm = Realm(config);

    intFactory(int i) => i; // .hashCode; //.hashCode * max + i;
    boolFactory(int i) => i % 2 == 0;
    stringFactory(int i) => '${intFactory(i)} $i';
    timestampFactory(int i) => DateTime.fromMillisecondsSinceEpoch(intFactory(i));
    objectIdFactory(int i) => ObjectId.fromValues(intFactory(i), i, i);
    uuidFactory(int i) => Uuid.fromBytes(Uint8List(16).buffer..asByteData().setInt64(0, intFactory(i)));

    const max = 600000;
    if (realm.all<WithIndexes>().length != max) {
      realm.write(() => realm.deleteAll<WithIndexes>());
      print('Inserting $max WithIndexes objects');

      final indexed = List.generate(
        max,
        (i) => WithIndexes(
          intFactory(i),
          stringFactory(i),
          boolFactory(i),
          timestampFactory(i),
          objectIdFactory(i),
          uuidFactory(i),
        ),
      );

      realm.write(() => realm.addAll(indexed));
    }

    if (realm.all<NoIndexes>().length != max) {
      realm.write(() => realm.deleteAll<NoIndexes>());
      print('Inserting $max NoIndexes objects');

      final notIndexed = List.generate(
        max,
        (i) => NoIndexes(
          intFactory(i),
          stringFactory(i),
          boolFactory(i),
          timestampFactory(i),
          objectIdFactory(i),
          uuidFactory(i),
        ),
      );

      realm.write(() => realm.addAll(notIndexed));
    }

    print('Inserts done');

    // Inefficient, but fast enough for this test
    final searchOrder = (List.generate(max, (i) => i)..shuffle(Random(42))).take(1000).toList();

    QueryBuilder<T, U> builder<T extends RealmObject, U>(String fieldName) {
      return (U value) => realm.query<T>('$fieldName == \$0', [value]);
    }

    @pragma('vm:no-interrupts')
    Duration measureSpeed<T extends RealmObject, U>(
      String fieldName,
      U Function(int index) indexToValue,
    ) {
      final queryBuilder = builder<T, U>(fieldName);
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

      final notIndexedTime = measureSpeed<NoIndexes, U>(fieldName, indexToValue);
      display(NoIndexes, notIndexedTime);
      final indexedTime = measureSpeed<WithIndexes, U>(fieldName, indexToValue);
      display(WithIndexes, indexedTime); // only display if test fails
    }

    print('Starting lookups on $max objects');
    compareSpeed<int>('anInt', intFactory);
    compareSpeed<String>('string', stringFactory);
    compareSpeed<DateTime>('timestamp', timestampFactory);
    compareSpeed<ObjectId>('objectId', objectIdFactory);
    compareSpeed<Uuid>('uuid', uuidFactory);
  });
}
