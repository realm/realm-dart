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

// ignore_for_file: unused_local_variable, avoid_relative_lib_imports

import 'dart:io';
import 'dart:math';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  _assertSchemaExists(Realm realm, SchemaObject expected) {
    final foundSchema = realm.schema.singleWhere((e) => e.name == expected.name);
    expect(foundSchema.properties.length, expected.properties.length);

    for (final prop in foundSchema.properties) {
      final expectedProp = expected.properties.singleWhere((e) => e.name == prop.name);
      expect(prop.collectionType, expectedProp.collectionType);
      expect(prop.linkTarget, expectedProp.linkTarget);
      expect(prop.optional, expectedProp.optional);
      expect(prop.primaryKey, expectedProp.primaryKey);
      expect(prop.propertyType, expectedProp.propertyType);
    }
  }

  test('schema is read from disk', () {
    final config = Configuration([Car.schema, Dog.schema, Person.schema, AllTypes.schema, LinksClass.schema]);
    getRealm(config).close();

    final dynamicConfig = Configuration([]);
    final realm = getRealm(dynamicConfig);

    expect(realm.schema.length, 5);

    _assertSchemaExists(realm, Car.schema);
    _assertSchemaExists(realm, Dog.schema);
    _assertSchemaExists(realm, Person.schema);
    _assertSchemaExists(realm, AllTypes.schema);
    _assertSchemaExists(realm, LinksClass.schema);
  });

  test('dynamic is always the same', () {
    final config = Configuration([Car.schema]);
    final realm = getRealm(config);

    final dynamic1 = realm.dynamic;
    final dynamic2 = realm.dynamic;

    expect(dynamic1, same(dynamic2));
  });

  for (var isDynamic in [true, false]) {
    Realm getDynamicRealm(Realm original) {
      if (isDynamic) {
        original.close();
        return getRealm(Configuration([]));
      }

      return original;
    }

    group('Realm.dynamic when isDynamic=$isDynamic', () {
      test('all returns empty collection', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        final realm = getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars.length, 0);
      });

      test('all returns non-empty collection', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(Car('Honda'));
        });

        final realm = getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars.length, 1);

        final car = allCars[0];
        expect(car.dynamic.get<String>('make'), 'Honda');
      });

      test('all throws for non-existent type', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = getDynamicRealm(staticRealm);

        expect(() => dynamicRealm.dynamic.all('i-dont-exist'), throws<RealmException>("Object type i-dont-exist not configured in the current Realm's schema"));
      });

      test('all can follow links', () {
        final config = Configuration([LinksClass.schema]);
        final staticRealm = getRealm(config);

        final id1 = Uuid.v4();
        final id2 = Uuid.v4();
        final id3 = Uuid.v4();

        staticRealm.write(() {
          final obj1 = staticRealm.add(LinksClass(id1));
          final obj2 = staticRealm.add(LinksClass(id2));
          final obj3 = staticRealm.add(LinksClass(id3));

          obj1.link = obj2;
          obj2.link = obj3;

          obj1.list.addAll([obj1, obj2, obj3]);
        });

        final dynamicRealm = getDynamicRealm(staticRealm);

        final objects = dynamicRealm.dynamic.all(LinksClass.schema.name);
        final obj1 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id1);
        final obj2 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id2);
        final obj3 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id3);

        expect(obj1.dynamic.get<RealmObject>('link'), obj2);
        expect(obj2.dynamic.get<RealmObject>('link'), obj3);

        final list = obj1.dynamic.getList<RealmObject>('list');

        expect(list[0], obj1);
        expect(list[1], obj2);
        expect(list[2], obj3);
      });

      test('all can be filtered', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        staticRealm.write(() {
          staticRealm.add(Car('Honda'));
          staticRealm.add(Car('Hyundai'));
          staticRealm.add(Car('Suzuki'));
          staticRealm.add(Car('Toyota'));
        });

        final dynamicRealm = getDynamicRealm(staticRealm);

        final carsWithH = dynamicRealm.dynamic.all(Car.schema.name).query('make BEGINSWITH "H"');
        expect(carsWithH.length, 2);
      });

      test('find can find by primary key', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        staticRealm.write(() {
          staticRealm.add(Car('Honda'));
          staticRealm.add(Car('Hyundai'));
        });

        final dynamicRealm = getDynamicRealm(staticRealm);

        final car = dynamicRealm.dynamic.find(Car.schema.name, 'Honda');
        expect(car, isNotNull);
        expect(car!.dynamic.get<String>('make'), 'Honda');

        final nonExistent = dynamicRealm.dynamic.find(Car.schema.name, 'i-dont-exist');
        expect(nonExistent, isNull);
      });

      test('find fails to find non-existent type', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = getDynamicRealm(staticRealm);

        expect(() => dynamicRealm.dynamic.find('i-dont-exist', 'i-dont-exist'),
            throws<RealmException>("Object type i-dont-exist not configured in the current Realm's schema"));
      });
    });

    group('RealmObject.dynamic when isDynamic=$isDynamic', () {});
  }

  test('RealmObject.dynamic.get can get all property types', () {
    final config = Configuration([AllTypes.schema]);
    final staticRealm = getRealm(config);

    final objectId = ObjectId();
    final uuid = Uuid.v4();
    final date = DateTime.now();

    staticRealm.write(() {
      staticRealm.add(AllTypes('abc', true, date, 123.456, objectId, uuid, 123));
      staticRealm.add(AllTypes('', false, DateTime(0), 0, objectId, uuid, 0,
          nullableStringProp: 'def',
          nullableBoolProp: true,
          nullableDateProp: date,
          nullableDoubleProp: 999.999,
          nullableObjectIdProp: objectId,
          nullableUuidProp: uuid));
    });

    for (var obj in staticRealm.all<AllTypes>()) {
      expect(obj.dynamic.get<String>('stringProp'), obj.stringProp);
      expect(obj.dynamic.get('stringProp'), obj.stringProp);
      expect(obj.dynamic.getNullable<String>('nullableStringProp'), obj.nullableStringProp);
      expect(obj.dynamic.getNullable('nullableStringProp'), obj.nullableStringProp);

      expect(obj.dynamic.get<bool>('boolProp'), obj.boolProp);
      expect(obj.dynamic.get('boolProp'), obj.boolProp);
      expect(obj.dynamic.getNullable<bool>('nullableBoolProp'), obj.nullableBoolProp);
      expect(obj.dynamic.getNullable('nullableBoolProp'), obj.nullableBoolProp);

      expect(obj.dynamic.get<DateTime>('dateProp'), obj.dateProp);
      expect(obj.dynamic.get('dateProp'), obj.dateProp);
      expect(obj.dynamic.getNullable<DateTime>('nullableDateProp'), obj.nullableDateProp);
      expect(obj.dynamic.getNullable('nullableDateProp'), obj.nullableDateProp);

      expect(obj.dynamic.get<double>('doubleProp'), obj.doubleProp);
      expect(obj.dynamic.get('doubleProp'), obj.doubleProp);
      expect(obj.dynamic.getNullable<double>('nullableDoubleProp'), obj.nullableDoubleProp);
      expect(obj.dynamic.getNullable('nullableDoubleProp'), obj.nullableDoubleProp);

      expect(obj.dynamic.get<ObjectId>('objectIdProp'), obj.objectIdProp);
      expect(obj.dynamic.get('objectIdProp'), obj.objectIdProp);
      expect(obj.dynamic.getNullable<ObjectId>('nullableObjectIdProp'), obj.nullableObjectIdProp);
      expect(obj.dynamic.getNullable('nullableObjectIdProp'), obj.nullableObjectIdProp);

      expect(obj.dynamic.get<Uuid>('uuidProp'), obj.uuidProp);
      expect(obj.dynamic.get('uuidProp'), obj.uuidProp);
      expect(obj.dynamic.getNullable<Uuid>('nullableUuidProp'), obj.nullableUuidProp);
      expect(obj.dynamic.getNullable('nullableUuidProp'), obj.nullableUuidProp);

      expect(obj.dynamic.get<int>('intProp'), obj.intProp);
      expect(obj.dynamic.get('intProp'), obj.intProp);
      expect(obj.dynamic.getNullable<int>('nullableIntProp'), obj.nullableIntProp);
      expect(obj.dynamic.getNullable('nullableIntProp'), obj.nullableIntProp);
    }
  });
}
