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

  final date = DateTime.now().toUtc();
  final objectId = ObjectId();
  final uuid = Uuid.v4();

  AllTypes _getPopulatedAllTypes() => AllTypes('abc', true, date, -123.456, objectId, uuid, -987,
      nullableStringProp: 'def',
      nullableBoolProp: true,
      nullableDateProp: date,
      nullableDoubleProp: -123.456,
      nullableObjectIdProp: objectId,
      nullableUuidProp: uuid,
      nullableIntProp: 123);

  AllTypes _getEmptyAllTypes() => AllTypes('', false, DateTime(0).toUtc(), 0, objectId, uuid, 0);

  AllCollections _getPopulatedAllCollections() => AllCollections(
      strings: ['abc', 'def'],
      bools: [true, false],
      dates: [date, DateTime(0).toUtc()],
      doubles: [-123.456, 555.666],
      objectIds: [objectId, objectId],
      uuids: [uuid, uuid],
      ints: [-987, 123]);

  void _validateDynamic(RealmObject actual, AllTypes expected) {
    expect(actual.dynamic.get<String>('stringProp'), expected.stringProp);
    expect(actual.dynamic.get('stringProp'), expected.stringProp);
    expect(actual.dynamic.getNullable<String>('nullableStringProp'), expected.nullableStringProp);
    expect(actual.dynamic.getNullable('nullableStringProp'), expected.nullableStringProp);

    expect(actual.dynamic.get<bool>('boolProp'), expected.boolProp);
    expect(actual.dynamic.get('boolProp'), expected.boolProp);
    expect(actual.dynamic.getNullable<bool>('nullableBoolProp'), expected.nullableBoolProp);
    expect(actual.dynamic.getNullable('nullableBoolProp'), expected.nullableBoolProp);

    expect(actual.dynamic.get<DateTime>('dateProp'), expected.dateProp);
    expect(actual.dynamic.get('dateProp'), expected.dateProp);
    expect(actual.dynamic.getNullable<DateTime>('nullableDateProp'), expected.nullableDateProp);
    expect(actual.dynamic.getNullable('nullableDateProp'), expected.nullableDateProp);

    expect(actual.dynamic.get<double>('doubleProp'), expected.doubleProp);
    expect(actual.dynamic.get('doubleProp'), expected.doubleProp);
    expect(actual.dynamic.getNullable<double>('nullableDoubleProp'), expected.nullableDoubleProp);
    expect(actual.dynamic.getNullable('nullableDoubleProp'), expected.nullableDoubleProp);

    expect(actual.dynamic.get<ObjectId>('objectIdProp'), expected.objectIdProp);
    expect(actual.dynamic.get('objectIdProp'), expected.objectIdProp);
    expect(actual.dynamic.getNullable<ObjectId>('nullableObjectIdProp'), expected.nullableObjectIdProp);
    expect(actual.dynamic.getNullable('nullableObjectIdProp'), expected.nullableObjectIdProp);

    expect(actual.dynamic.get<Uuid>('uuidProp'), expected.uuidProp);
    expect(actual.dynamic.get('uuidProp'), expected.uuidProp);
    expect(actual.dynamic.getNullable<Uuid>('nullableUuidProp'), expected.nullableUuidProp);
    expect(actual.dynamic.getNullable('nullableUuidProp'), expected.nullableUuidProp);

    expect(actual.dynamic.get<int>('intProp'), expected.intProp);
    expect(actual.dynamic.get('intProp'), expected.intProp);
    expect(actual.dynamic.getNullable<int>('nullableIntProp'), expected.nullableIntProp);
    expect(actual.dynamic.getNullable('nullableIntProp'), expected.nullableIntProp);
  }

  void _validateDynamicLists(RealmObject actual, AllCollections expected) {
    expect(actual.dynamic.getList<String>('strings'), expected.strings);
    expect(actual.dynamic.getList('strings'), expected.strings);

    expect(actual.dynamic.getList<bool>('bools'), expected.bools);
    expect(actual.dynamic.getList('bools'), expected.bools);

    expect(actual.dynamic.getList<DateTime>('dates'), expected.dates);
    expect(actual.dynamic.getList('dates'), expected.dates);

    expect(actual.dynamic.getList<double>('doubles'), expected.doubles);
    expect(actual.dynamic.getList('doubles'), expected.doubles);

    expect(actual.dynamic.getList<ObjectId>('objectIds'), expected.objectIds);
    expect(actual.dynamic.getList('objectIds'), expected.objectIds);

    expect(actual.dynamic.getList<Uuid>('uuids'), expected.uuids);
    expect(actual.dynamic.getList('uuids'), expected.uuids);

    expect(actual.dynamic.getList<int>('ints'), expected.ints);
    expect(actual.dynamic.getList('ints'), expected.ints);
  }

  for (var isDynamic in [true, false]) {
    Realm _getDynamicRealm(Realm original) {
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

        final realm = _getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars.length, 0);
      });

      test('all returns non-empty collection', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(Car('Honda'));
        });

        final realm = _getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars.length, 1);

        final car = allCars[0];
        expect(car.dynamic.get<String>('make'), 'Honda');
      });

      test('all throws for non-existent type', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = _getDynamicRealm(staticRealm);

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

        final dynamicRealm = _getDynamicRealm(staticRealm);

        final objects = dynamicRealm.dynamic.all(LinksClass.schema.name);
        final obj1 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id1);
        final obj2 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id2);
        final obj3 = objects.singleWhere((o) => o.dynamic.get<Uuid>('id') == id3);

        expect(obj1.dynamic.getNullable<RealmObject>('link'), obj2);
        expect(obj2.dynamic.getNullable<RealmObject>('link'), obj3);

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

        final dynamicRealm = _getDynamicRealm(staticRealm);

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

        final dynamicRealm = _getDynamicRealm(staticRealm);

        final car = dynamicRealm.dynamic.find(Car.schema.name, 'Honda');
        expect(car, isNotNull);
        expect(car!.dynamic.get<String>('make'), 'Honda');

        final nonExistent = dynamicRealm.dynamic.find(Car.schema.name, 'i-dont-exist');
        expect(nonExistent, isNull);
      });

      test('find fails to find non-existent type', () {
        final config = Configuration([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = _getDynamicRealm(staticRealm);

        expect(() => dynamicRealm.dynamic.find('i-dont-exist', 'i-dont-exist'),
            throws<RealmException>("Object type i-dont-exist not configured in the current Realm's schema"));
      });
    });

    group('RealmObject.dynamic.get when isDynamic=$isDynamic', () {
      test('gets all property types', () {
        final config = Configuration([AllTypes.schema]);
        final staticRealm = getRealm(config);

        staticRealm.write(() {
          staticRealm.add(_getPopulatedAllTypes());
          staticRealm.add(_getEmptyAllTypes());
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);
        final objects = dynamicRealm.dynamic.all(AllTypes.schema.name);

        final obj1 = objects.singleWhere((o) => o.dynamic.get<String>('stringProp') == 'abc');
        final obj2 = objects.singleWhere((o) => o.dynamic.get<String>('stringProp') == '');

        _validateDynamic(obj1, _getPopulatedAllTypes());
        _validateDynamic(obj2, _getEmptyAllTypes());
      });

      test('gets normal links', () {
        final config = Configuration([LinksClass.schema]);
        final staticRealm = getRealm(config);

        final uuid1 = Uuid.v4();
        final uuid2 = Uuid.v4();

        staticRealm.write(() {
          final obj1 = staticRealm.add(LinksClass(uuid1));
          staticRealm.add(LinksClass(uuid2, link: obj1));
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj1 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid1)!;
        final obj2 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid2)!;

        expect(obj1.dynamic.getNullable<RealmObject>('link'), isNull);
        expect(obj1.dynamic.getNullable('link'), isNull);

        expect(obj2.dynamic.getNullable<RealmObject>('link'), obj1);
        expect(obj2.dynamic.getNullable('link'), obj1);
        expect(obj2.dynamic.getNullable<RealmObject>('link')?.dynamic.get<Uuid>('id'), uuid1);
      });

      test('fails with non-existent property', () {
        final config = Configuration([AllTypes.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getEmptyAllTypes());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllTypes.schema.name).single;
        expect(() => obj.dynamic.get('i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllTypes'"));
        expect(() => obj.dynamic.getNullable('i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllTypes'"));
      });

      test('fails with wrong type', () {
        final config = Configuration([AllTypes.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getEmptyAllTypes());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllTypes.schema.name).single;

        expect(
            () => obj.dynamic.get<int>('stringProp'),
            throws<RealmException>(
                "Property 'stringProp' on class 'AllTypes' is not the correct type. Expected 'RealmPropertyType.int', got 'RealmPropertyType.string'."));

        expect(
            () => obj.dynamic.getNullable<int>('nullableStringProp'),
            throws<RealmException>(
                "Property 'nullableStringProp' on class 'AllTypes' is not the correct type. Expected 'RealmPropertyType.int', got 'RealmPropertyType.string'."));

        expect(() => obj.dynamic.get<int>('nullableIntProp'),
            throws<RealmException>("Property 'nullableIntProp' on class 'AllTypes' is nullable but the wrong method was used to access it."));

        expect(() => obj.dynamic.getNullable<int>('intProp'),
            throws<RealmException>("Property 'intProp' on class 'AllTypes' is required but the wrong method was used to access it."));
      });

      test('fails on collection properties', () {
        final config = Configuration([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(AllCollections());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;
        expect(
            () => obj.dynamic.get<String>('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));

        expect(
            () => obj.dynamic.get('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));

        expect(
            () => obj.dynamic.getNullable<String>('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));

        expect(
            () => obj.dynamic.getNullable('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));
      });
    });

    group('RealmObject.dynamic.getList', () {
      test('gets all list types', () {
        final config = Configuration([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getPopulatedAllCollections());
          staticRealm.add(AllCollections());
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);
        final objects = dynamicRealm.dynamic.all(AllCollections.schema.name);
        final obj1 = objects.singleWhere((element) => element.dynamic.getList('strings').isNotEmpty);
        final obj2 = objects.singleWhere((element) => element.dynamic.getList('strings').isEmpty);

        _validateDynamicLists(obj1, _getPopulatedAllCollections());
        _validateDynamicLists(obj2, AllCollections());
      });

      test('gets collections of objects', () {
        final config = Configuration([LinksClass.schema]);
        final staticRealm = getRealm(config);

        final uuid1 = Uuid.v4();
        final uuid2 = Uuid.v4();

        staticRealm.write(() {
          final obj1 = staticRealm.add(LinksClass(uuid1));
          staticRealm.add(LinksClass(uuid2, list: [obj1, obj1]));
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj1 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid1)!;
        final obj2 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid2)!;

        expect(obj1.dynamic.getList<RealmObject>('list'), isEmpty);
        expect(obj1.dynamic.getList('list'), isEmpty);

        expect(obj2.dynamic.getList<RealmObject>('list'), [obj1, obj1]);
        expect(obj2.dynamic.getList('list'), [obj1, obj1]);
        expect(obj2.dynamic.getList<RealmObject>('list')[0].dynamic.get<Uuid>('id'), uuid1);
      });

      test('fails with non-existent property', () {
        final config = Configuration([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(AllCollections());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;
        expect(() => obj.dynamic.getList('i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllCollections'"));
      });

      test('fails with wrong type', () {
        final config = Configuration([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(AllCollections());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;

        expect(
            () => obj.dynamic.getList<int>('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is not the correct type. Expected 'RealmPropertyType.int', got 'RealmPropertyType.string'"));
      });

      test('fails on non-collection properties', () {
        final config = Configuration([AllTypes.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getEmptyAllTypes());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllTypes.schema.name).single;
        expect(
            () => obj.dynamic.getList('intProp'),
            throws<RealmException>(
                "Property 'intProp' on class 'AllTypes' is 'RealmCollectionType.none' but the method used to access it expected 'RealmCollectionType.list'."));
      });
    });
  }

  test('RealmObject.dynamic.get when static can get all property types', () {
    final config = Configuration([AllTypes.schema]);
    final staticRealm = getRealm(config);

    final objectId = ObjectId();
    final uuid = Uuid.v4();
    final date = DateTime.now();

    staticRealm.write(() {
      staticRealm.add(_getPopulatedAllTypes());
      staticRealm.add(_getEmptyAllTypes());
    });

    for (var obj in staticRealm.all<AllTypes>()) {
      _validateDynamic(obj, obj);
    }
  });

  test('RealmObject.dynamic.getList when static can get all list types', () {
    final config = Configuration([AllCollections.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(_getPopulatedAllCollections());

      realm.add(AllCollections());
    });

    for (final obj in realm.all<AllCollections>()) {
      _validateDynamicLists(obj, obj);
    }
  });
}
