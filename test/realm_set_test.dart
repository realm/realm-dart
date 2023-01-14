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

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_set_test.g.dart';

/// When changing update also `setByType`
List<Type> supportedTypes = [bool, int, String, double, DateTime, ObjectId, Uuid];

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

  @Ignored()

  /// When changing update also `supportedTypes`
  Sets setByType(Type type) {
    switch (type) {
      case bool:
        return Sets(boolSet as RealmSet<bool>, [true, false]);
      case int:
        return Sets(intSet as RealmSet<int>, [-1, 0, 1]);
      case String:
        return Sets(stringSet as RealmSet<String>, ['Tesla', 'VW', 'Audi', 'Opel']);
      case double:
        return Sets(doubleSet as RealmSet<double>, [-1.1, 0.1, 1.1, 2.2, 3.3, 3.14]);
      case DateTime:
        return Sets(dateTimeSet as RealmSet<DateTime>, [DateTime(2023).toUtc(), DateTime(1981).toUtc()]);
      case ObjectId:
        return Sets(objectIdSet as RealmSet<ObjectId>, [ObjectId.fromTimestamp(DateTime(2023).toUtc()), ObjectId.fromTimestamp(DateTime(1981).toUtc())]);
        case Uuid:
        return Sets(uuidSet as RealmSet<Uuid>, [Uuid.fromString("12345678123456781234567812345678"), Uuid.fromString("82345678123456781234567812345678")]);
      default:
        throw RealmError("Unsupported type $type");
    }
  }

  @Ignored()
  List<Object?> values(Type type) {
    return setByType(type).values;
  }
}

class Sets {
  final RealmSet<Object?> set;
  final List<Object?> values;

  const Sets(this.set, this.values);
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  for (var type in supportedTypes) {
    test('RealmSet<$type> unmanged set add', () {
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

    test('RealmSet<$type> unmanged set remove', () {
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

    test('RealmSet<$type> unmanged set elementAt', () {
      final testSet = TestRealmSets(1);
      final set = testSet.setByType(type).set;
      final values = testSet.values(type);

      set.add(values.first);
      expect(set.length, equals(1));
      expect(set.elementAt(0), values.first);
    });

    test('RealmSet<$type> create', () {
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
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
      values = testSet.values(type);
      expect(set.length, equals(values.length));

      for (var value in values) {
        expect(set.contains(value), true);
      }
    });

    test('RealmSet<$type> contains', () {
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);

      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.setByType(type).set;
        set.add(values.first);
      });

      var set = testSet.setByType(type).set;
      values = testSet.values(type);

      expect(set.contains(values.first), true);
    });

    test('RealmSet<$type> remove', () {
      var config = Configuration.local([TestRealmSets.schema]);
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
      });

      expect(set.length, 0);
    });

    test('RealmSet<$type> length', () {
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
      var realm = getRealm(config);

      final testSet = TestRealmSets(1);
      var values = testSet.values(type);

      realm.write(() {
        realm.add(testSet);
        var set = testSet.setByType(type).set;
        set.add(values.first);
      });

      var set = testSet.setByType(type).set;

      expect(set.elementAt(0), values[0]);
    });

    test('RealmSet<$type> lookup', () {
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
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
      var config = Configuration.local([TestRealmSets.schema]);
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
        expect(values.contains(element), true);
      }
    });

    test('RealmSet<$type> notifications', () async {
      var config = Configuration.local([TestRealmSets.schema]);
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
  }
}
