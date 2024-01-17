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

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_set_test.g.dart';

class _NullableBool {}

class _NullableInt {}

class _NullableString {}

class _NullableDouble {}

class _NullableDateTime {}

class _NullableObjectId {}

class _NullableUuid {}

class _NullableObjects {}

class _NullableUint8List {}

/// When changing update also `setByType`
List<Type> supportedTypes = [
  bool,
  int,
  String,
  double,
  DateTime,
  ObjectId,
  Uuid,
  RealmValue,
  RealmObject,
  Uint8List,
  _NullableBool,
  _NullableInt,
  _NullableString,
  _NullableDouble,
  _NullableDateTime,
  _NullableObjectId,
  _NullableUuid,
  _NullableUint8List
];

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
  late String? color;
}

@RealmModel()
class _TestRealmSets {
  @PrimaryKey()
  late int key;

  late Set<bool> boolSet;
  late Set<int> intSet;
  late Set<String> stringSet;
  late Set<double> doubleSet;
  late Set<DateTime> dateTimeSet;
  late Set<ObjectId> objectIdSet;
  late Set<Uuid> uuidSet;
  late Set<RealmValue> mixedSet;
  late Set<_Car> objectsSet;
  late Set<Uint8List> binarySet;

  late Set<bool?> nullableBoolSet;
  late Set<int?> nullableIntSet;
  late Set<String?> nullableStringSet;
  late Set<double?> nullableDoubleSet;
  late Set<DateTime?> nullableDateTimeSet;
  late Set<ObjectId?> nullableObjectIdSet;
  late Set<Uuid?> nullableUuidSet;
  late Set<Uint8List?> nullableBinarySet;

  /// When changing update also `supportedTypes`
  Sets setByType(Type type) {
    switch (type) {
      case bool:
        return Sets(boolSet as RealmSet<bool>, [true, false]);
      case int:
        return Sets(intSet as RealmSet<int>, [-1, 0, 1]);
      case String:
        return Sets(stringSet as RealmSet<String>, ['Tesla', 'VW', 'Audi']);
      case double:
        return Sets(doubleSet as RealmSet<double>, [-1.1, 0.1, 1.1, 2.2, 3.3, 3.14]);
      case DateTime:
        return Sets(dateTimeSet as RealmSet<DateTime>, [DateTime(2023).toUtc(), DateTime(1981).toUtc()]);
      case ObjectId:
        return Sets(objectIdSet as RealmSet<ObjectId>, [ObjectId.fromTimestamp(DateTime(2023).toUtc()), ObjectId.fromTimestamp(DateTime(1981).toUtc())]);
      case Uuid:
        return Sets(uuidSet as RealmSet<Uuid>, [Uuid.fromString("12345678123456781234567812345678"), Uuid.fromString("82345678123456781234567812345678")]);
      case Uint8List:
        return Sets(binarySet as RealmSet<Uint8List>, [
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([3, 2, 1])
        ]);
      case RealmValue:
        return Sets(mixedSet as RealmSet<RealmValue>, [RealmValue.nullValue(), RealmValue.int(1), RealmValue.realmObject(Car("Tesla"))],
            (realm, value) => realm.find<Car>((value as Car).make));
      case RealmObject:
        return Sets(objectsSet as RealmSet<Car>, [Car("Tesla"), Car("VW"), Car("Audi")], (realm, value) => realm.find<Car>((value as Car).make));
      case _NullableBool:
        return Sets(nullableBoolSet as RealmSet<bool?>, [...setByType(bool).values, null]);
      case _NullableInt:
        return Sets(nullableIntSet as RealmSet<int?>, [...setByType(int).values, null]);
      case _NullableString:
        return Sets(nullableStringSet as RealmSet<String?>, [...setByType(String).values, null]);
      case _NullableDouble:
        return Sets(nullableDoubleSet as RealmSet<double?>, [...setByType(double).values, null]);
      case _NullableDateTime:
        return Sets(nullableDateTimeSet as RealmSet<DateTime?>, [...setByType(DateTime).values, null]);
      case _NullableObjectId:
        return Sets(nullableObjectIdSet as RealmSet<ObjectId?>, [...setByType(ObjectId).values, null]);
      case _NullableUuid:
        return Sets(nullableUuidSet as RealmSet<Uuid?>, [...setByType(Uuid).values, null]);
      case _NullableUint8List:
        return Sets(nullableBinarySet as RealmSet<Uint8List?>, [...setByType(Uint8List).values, null]);
      default:
        throw RealmError("Unsupported type $type");
    }
  }

  List<Object?> values(Type type) {
    return setByType(type).values;
  }

  List<Object?> getValuesOrManagedValues(Realm realm, Type type) {
    Sets set = setByType(type);
    if (!set.values.any((element) => element is RealmObject || element is RealmValue)) {
      return set.values;
    }

    return set.values.map<Object?>((value) {
      if (value is RealmValue && value.value is! RealmObject) {
        return value;
      }

      return _getManagedValue(set, realm, value);
    }).toList();
  }

  Object? _getManagedValue(Sets set, Realm realm, Object? value) {
    if (value is RealmValue) {
      return RealmValue.from(_getManagedValue(set, realm, value.value));
    }

    RealmObject? realmValue = set.getRealmObject!(realm, value as RealmObject);
    return realmValue;
  }
}

class Sets {
  final RealmSet<Object?> set;
  final List<Object?> values;
  RealmObject? Function(Realm realm, RealmObject value)? getRealmObject = (realm, value) => value;

  Sets(this.set, this.values, [this.getRealmObject]);
}

void main() {
  setupTests();

  for (var type in supportedTypes) {
    test('RealmSet<$type> unmanaged set add', () {
      final testSet = TestRealmSets(1);
      final set = testSet.setByType(type).set;
      final values = testSet.values(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> unmanaged set remove', () {
      final testSet = TestRealmSets(1);
      final set = testSet.setByType(type).set;
      final values = testSet.values(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.contains(values.first), true);

      set.remove(values.first);
      expect(set.length, equals(0));
      expect(set.contains(values.first), false);
    });

    test('RealmSet<$type>.elementAt on an unmanaged RealmSet', () {
      final testSet = TestRealmSets(1);
      final set = testSet.setByType(type).set;
      final values = testSet.values(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.elementAt(0), values.first);
    });

    test('RealmSet<$type> creation', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);

      realm.write(() {
        realm.add(testSet);
      });

      expect(realm.find<TestRealmSets>(1), isNotNull);

      testSet = realm.find<TestRealmSets>(1)!;
      var set = testSet.setByType(type).set;

      expect(set.length, equals(0));
    });

    test('RealmSet<$type> create from unmanaged', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      for (var value in values) {
        set.add(value);
      }

      realm.write(() {
        realm.add(testSet);
      });

      testSet = realm.find<TestRealmSets>(1)!;
      set = testSet.setByType(type).set;
      expect(set.length, equals(values.length));
      values = testSet.getValuesOrManagedValues(realm, type);

      for (var value in values) {
        expect(set.contains(value), true);
      }
    });

    test('RealmSet<$type> contains', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.setByType(type).set;

      expect(set.contains(values.first), false);

      realm.write(() {
        set.add(values.first);
      });

      testSet = realm.find<TestRealmSets>(1)!;
      set = testSet.setByType(type).set;
      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> add', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);

      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.setByType(type).set;
        expect(set.add(values.first), true);

        //adding an already existing value is a no operation
        expect(set.add(values.first), false);
      });

      var set = testSet.setByType(type).set;
      // values = testSet.values(type);
      values = testSet.getValuesOrManagedValues(realm, type);

      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> remove', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);

      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.length, 1);

      realm.write(() {
        expect(set.remove(values.first), true);

        //removing a value not in the set should return false.
        expect(set.remove(values.first), false);
      });

      expect(set.length, 0);
    });

    test('RealmSet<$type> length', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      expect(set.length, 0);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.length, 1);

      realm.write(() {
        for (var value in values) {
          set.add(value);
        }
      });

      expect(set.length, values.length);
    });

    test('RealmSet<$type> elementAt', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.setByType(type).set;
        set.add(values.first);
      });

      var set = testSet.setByType(type).set;

      expect(() => set.elementAt(-1), throws<RealmException>("Index out of range"));
      expect(() => set.elementAt(800), throws<RealmException>("Error getting value at index 800"));
      expect(set.elementAt(0), values[0]);
    });

    test('RealmSet<$type> lookup', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      realm.write(() {
        realm.add(testSet);
      });

      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      expect(set.lookup(values.first), null);

      realm.write(() {
        set.add(values.first);
      });

      expect(set.lookup(values.first), values.first);
    });

    test('RealmSet<$type> toSet', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var set = testSet.setByType(type).set;
      var values = testSet.values(type);
      set.add(values.first);

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.setByType(type).set;

      final newSet = set.toSet();
      expect(newSet != set, true);
      newSet.add(values[1]);
      expect(newSet.length, 2);
      expect(set.length, 1);
    });

    test('RealmSet<$type> clear', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.setByType(type).set;
        for (var value in values) {
          set.add(value);
        }
      });

      var set = testSet.setByType(type).set;

      expect(set.length, values.length);

      realm.write(() {
        set.clear();
      });

      expect(set.length, 0);
    });

    test('RealmSet<$type> iterator', () {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      var set = testSet.setByType(type).set;
      var values = testSet.values(type);

      for (var value in values) {
        set.add(value);
      }

      realm.write(() {
        realm.add(testSet);
      });

      set = testSet.setByType(type).set;
      expect(set.length, equals(values.length));

      for (var element in set) {
        if (element is Uint8List) {
          expect(values.any((e) => (e as Uint8List).equals(element)), true);
        } else {
          expect(values.contains(element), true);
        }
      }
    });

    test('RealmSet<$type> notifications', () async {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      realm.write(() => realm.add(testSet));

      var set = testSet.setByType(type).set;
      var values = testSet.setByType(type).values;

      var state = 0;
      final maxSate = 2;
      final subscription = set.changes.listen((changes) {
        if (state == 0) {
          expect(changes.inserted.isEmpty, true);
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted.isEmpty, true);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        } else if (state == 1) {
          expect(changes.inserted, [0]); //new object at index 0
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted.isEmpty, true);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        } else if (state == 2) {
          expect(changes.inserted.isEmpty, true); //new object at index 0
          expect(changes.modified.isEmpty, true);
          expect(changes.deleted, [0]);
          expect(changes.newModified.isEmpty, true);
          expect(changes.moved.isEmpty, true);
        }
        state++;
      });

      await Future<void>.delayed(Duration(milliseconds: 20));
      realm.write(() {
        set.add(values.first);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));
      realm.write(() {
        set.remove(values.first);
      });

      expect(state, maxSate);

      await Future<void>.delayed(Duration(milliseconds: 20));
      subscription.cancel();

      await Future<void>.delayed(Duration(milliseconds: 20));
    });

    test('RealmSet<$type>.isCleared notifications', () async {
      var config = Configuration.local([TestRealmSets.schema, Car.schema]);
      var realm = getRealm(config);

      var testSet = TestRealmSets(1);
      realm.write(() => realm.add(testSet));

      var set = testSet.setByType(type).set;
      var values = testSet.setByType(type).values;
      realm.write(() {
        set.add(values.first);
      });

      expectLater(
          set.changes,
          emitsInOrder(<Matcher>[
            isA<RealmSetChanges<Object?>>().having((changes) => changes.inserted, 'inserted', <int>[]), // always an empty event on subscription
            isA<RealmSetChanges<Object?>>().having((changes) => changes.isCleared, 'isCleared', true),
          ]));
      realm.write(() => set.clear());
    });

    test('RealmSet<$type> basic operations on unmanaged sets', () {
      var testSet = TestRealmSets(1);
      var set = testSet.setByType(type).set;
      var values = testSet.setByType(type).values;

      set.add(values.first);
      expect(set.contains(values.first), true);
      expect(set.length, 1);

      set.add(values.first);
      expect(set.contains(values.first), true);
      expect(set.length, 1);

      expect(set.elementAt(0), values.first);

      set.add(values.elementAt(0));
      set.add(values.elementAt(1));
      expect(set.contains(values.elementAt(0)), true);
      expect(set.contains(values.elementAt(1)), true);
      expect(set.length, 2);

      set.remove(values.elementAt(0));
      expect(set.contains(values.elementAt(0)), false);
      expect(set.length, 1);
      set.remove(values.elementAt(1));
      expect(set.contains(values.elementAt(1)), false);
      expect(set.length, 0);
    });
  }

  test('RealmSet<RealmObject> deleteMany', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    var testSet = TestRealmSets(1)..objectsSet.addAll([Car("Tesla"), Car("Audi")]);

    realm.write(() {
      realm.add(testSet);
    });

    expect(realm.find<TestRealmSets>(1), isNotNull);

    testSet = realm.find<TestRealmSets>(1)!;
    expect(testSet.objectsSet.length, 2);
    expect(realm.all<Car>().length, 2);

    realm.write(() {
      realm.deleteMany(testSet.objectsSet);
    });

    expect(testSet.objectsSet.length, 0);
    expect(realm.all<Car>().length, 0);
  });

  test('UnmanagedRealmSet<RealmObject> deleteMany', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    var testSet = TestRealmSets(1);
    var unmanagedSet = testSet.objectsSet;

    realm.write(() {
      realm.add(testSet);
      testSet.objectsSet.addAll([Car("Tesla"), Car("Audi")]);
    });

    var cars = realm.all<Car>();
    unmanagedSet.addAll([...cars]);

    realm.write(() {
      realm.deleteMany(unmanagedSet);
    });

    cars = realm.all<Car>();
    expect(cars.length, 0);
  });

  test('RealmSet<RealmObject> add a set of already managed objects', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.addAll([Car("Tesla"), Car("Audi")]);
    });

    var testSet = TestRealmSets(1)..objectsSet.addAll(realm.all<Car>());

    realm.write(() {
      realm.add(testSet);
    });

    expect(realm.find<TestRealmSets>(1), isNotNull);

    testSet = realm.find<TestRealmSets>(1)!;
    expect(testSet.objectsSet.length, 2);
    expect(realm.all<Car>().length, 2);
    expect(testSet.objectsSet.first.make, "Tesla");
  });

  test('RealmSet of RealmObjects/RealmValue', () {
    final config = Configuration.local([TestRealmSets.schema, Car.schema]);
    final realm = getRealm(config);

    final cars = [Car("Tesla"), Car("Audi")];
    var testSet = TestRealmSets(1)
      ..objectsSet.addAll(cars)
      ..mixedSet.addAll(cars.map(RealmValue.from));

    realm.write(() {
      realm.add(testSet);
    });

    expect(testSet.objectsSet, cars);
    expect(testSet.mixedSet.map((m) => m.as<Car>()), cars);
    expect(testSet.objectsSet.map((c) => c.make), ['Tesla', 'Audi']);
    expect(testSet.mixedSet.map((m) => m.as<Car>().make), ['Tesla', 'Audi']);
  });

  test('RealmSet.asResults()', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final cars = [Car("Tesla"), Car("Audi")];
    final testSets = TestRealmSets(1)..objectsSet.addAll(cars);

    expect(() => testSets.objectsSet.asResults(), throwsStateError); // unmanaged set

    realm.write(() {
      realm.add(testSets);
    });

    expect(testSets.objectsSet.asResults(), cars);
  });

  test('RealmSet.asResults().isCleared notifications', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final cars = [Car("Tesla"), Car("Audi")];
    final testSets = TestRealmSets(1)..objectsSet.addAll(cars);

    realm.write(() {
      realm.add(testSets);
    });
    final carsResult = testSets.objectsSet.asResults();
    expectLater(
        carsResult.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges<Object?>>().having((changes) => changes.inserted, 'inserted', <int>[]), // always an empty event on subscription
          isA<RealmResultsChanges<Object?>>().having((changes) => changes.results.isEmpty, 'isCleared', true),
        ]));
    realm.write(() => testSets.objectsSet.clear());
  });

  test('Set.freeze freezes the set', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final liveCars = realm.write(() {
      return realm.add(TestRealmSets(1, objectsSet: {
        Car('Tesla'),
      }));
    }).objectsSet;

    final frozenCars = freezeSet(liveCars);

    expect(frozenCars.length, 1);
    expect(frozenCars.isFrozen, true);
    expect(frozenCars.realm.isFrozen, true);
    expect(frozenCars.first.isFrozen, true);

    realm.write(() {
      liveCars.add(Car('Audi'));
    });

    expect(liveCars.length, 2);
    expect(frozenCars.length, 1);
    expect(frozenCars.single.make, 'Tesla');
  });

  test("FrozenSet.changes throws", () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(TestRealmSets(1, objectsSet: {
        Car("Tesla"),
        Car("Audi"),
      }));
    });

    final frozenBools = freezeSet(realm.all<TestRealmSets>().single.boolSet);

    expect(() => frozenBools.changes, throws<RealmStateError>('Set is frozen and cannot emit changes'));
  });

  test('UnmanagedSet.freeze throws', () {
    final set = TestRealmSets(1);

    expect(() => set.boolSet.freeze(), throws<RealmStateError>("Unmanaged sets can't be frozen"));
  });

  test('RealmSet.changes - await for with yield ', () async {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final cars = realm.write(() {
      return realm.add(TestRealmSets(1, objectsSet: {
        Car('Tesla'),
      }));
    }).objectsSet;

    final wait = const Duration(seconds: 1);

    Stream<bool> trueWaitFalse() async* {
      yield true;
      await Future<void>.delayed(wait);
      yield false; // nothing has happened in the meantime
    }

    // ignore: prefer_function_declarations_over_variables
    final awaitForWithYield = () async* {
      await for (final c in cars.changes) {
        yield c;
      }
    };

    int count = 0;
    await for (final c in awaitForWithYield().map((_) => trueWaitFalse()).switchLatest()) {
      if (!c) break; // saw false after waiting
      ++count; // saw true due to new event from changes
      if (count > 1) fail('Should only receive one event');
    }
  });

  test('Query on RealmSet with IN-operator', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final cars = [Car("Tesla"), Car("Ford"), Car("Audi")];
    final testSets = TestRealmSets(1)..objectsSet.addAll(cars);

    realm.write(() {
      realm.add(testSets);
    });
    final result = testSets.objectsSet.query(r'make IN $0', [
      ['Tesla', 'Audi']
    ]);
    expect(result.length, 2);
  });

  test('Query on RealmSet allows null in arguments', () {
    var config = Configuration.local([TestRealmSets.schema, Car.schema]);
    var realm = getRealm(config);

    final cars = [Car("Tesla", color: "black"), Car("Ford"), Car("Audi")];
    final testSets = TestRealmSets(1)..objectsSet.addAll(cars);

    realm.write(() {
      realm.add(testSets);
    });
    var result = testSets.objectsSet.query(r'color = $0', [null]);
    expect(result.length, 2);
  });
}
