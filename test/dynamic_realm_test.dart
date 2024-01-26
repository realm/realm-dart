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

// ignore_for_file: avoid_relative_lib_imports

import 'package:collection/collection.dart';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';

import 'test.dart';

part 'dynamic_realm_test.g.dart';

@RealmModel()
@MapTo('Task')
class _Taskv2 {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String description;
}

void main() {
  setupTests();

  void assertSchemaMatches(SchemaObject actual, SchemaObject expected) {
    expect(actual.name, expected.name);
    expect(actual.baseType, expected.baseType);
    expect(actual.length, expected.length);

    for (final prop in actual) {
      final expectedProp = expected.singleWhereOrNull((e) => e.name == prop.name || e.mapTo == prop.name);
      expect(expectedProp, isNotNull,
          reason: "Expected to find '${prop.name}' in schema '${actual.name}', but couldn't. Properties in schema: ${expected.map((e) => e.name).join(', ')}");
      expect(prop.collectionType, expectedProp!.collectionType);
      expect(prop.linkTarget, expectedProp.linkTarget);
      expect(prop.optional, expectedProp.optional);
      expect(prop.primaryKey, expectedProp.primaryKey);
      expect(prop.propertyType, expectedProp.propertyType);
    }
  }

  void assertSchemaExists(Realm realm, SchemaObject expected) {
    final foundSchema = realm.schema.singleWhere((e) => e.name == expected.name);
    assertSchemaMatches(foundSchema, expected);
  }

  test('schema is read from disk', () {
    final config = Configuration.local([
      Car.schema,
      Dog.schema,
      Person.schema,
      AllTypes.schema,
      LinksClass.schema,
      ObjectWithEmbedded.schema,
      AllTypesEmbedded.schema,
      RecursiveEmbedded1.schema,
      RecursiveEmbedded2.schema,
      RecursiveEmbedded3.schema
    ]);

    final staticRealm = getRealm(config);

    staticRealm.write(() {
      staticRealm.add(ObjectWithEmbedded('abc', recursiveObject: RecursiveEmbedded1('embedded')));
    });

    staticRealm.close();

    final dynamicConfig = Configuration.local([]);
    final realm = getRealm(dynamicConfig);

    expect(realm.schema.length, 10);

    assertSchemaExists(realm, Car.schema);
    assertSchemaExists(realm, Dog.schema);
    assertSchemaExists(realm, Person.schema);
    assertSchemaExists(realm, AllTypes.schema);
    assertSchemaExists(realm, LinksClass.schema);
    assertSchemaExists(realm, ObjectWithEmbedded.schema);
    assertSchemaExists(realm, AllTypesEmbedded.schema);
    assertSchemaExists(realm, RecursiveEmbedded1.schema);
    assertSchemaExists(realm, RecursiveEmbedded2.schema);
    assertSchemaExists(realm, RecursiveEmbedded3.schema);

    final obj = realm.dynamic.all(ObjectWithEmbedded.schema.name).single;
    assertSchemaMatches(obj.objectSchema, ObjectWithEmbedded.schema);

    final embedded = obj.dynamic.get<EmbeddedObject?>('recursiveObject')!;
    assertSchemaMatches(embedded.objectSchema, RecursiveEmbedded1.schema);
  });

  test('dynamic is always the same', () {
    final config = Configuration.local([Car.schema]);
    final realm = getRealm(config);

    final dynamic1 = realm.dynamic;
    final dynamic2 = realm.dynamic;

    expect(dynamic1, same(dynamic2));
  });

  final date = DateTime.now().toUtc();
  final objectId = ObjectId();
  final uuid = Uuid.v4();

  AllTypes _getPopulatedAllTypes() => AllTypes('abc', true, date, -123.456, objectId, uuid, -987, Decimal128.fromDouble(42),
      nullableStringProp: 'def',
      nullableBoolProp: true,
      nullableDateProp: date,
      nullableDoubleProp: -123.456,
      nullableObjectIdProp: objectId,
      nullableUuidProp: uuid,
      nullableIntProp: 123,
      nullableDecimalProp: Decimal128.fromDouble(4242));

  AllTypes _getEmptyAllTypes() => AllTypes('', false, DateTime(0).toUtc(), 0, objectId, uuid, 0, Decimal128.zero);

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
    expect(actual.dynamic.get<String?>('nullableStringProp'), expected.nullableStringProp);
    expect(actual.dynamic.get('nullableStringProp'), expected.nullableStringProp);

    expect(actual.dynamic.get<bool>('boolProp'), expected.boolProp);
    expect(actual.dynamic.get('boolProp'), expected.boolProp);
    expect(actual.dynamic.get<bool?>('nullableBoolProp'), expected.nullableBoolProp);
    expect(actual.dynamic.get('nullableBoolProp'), expected.nullableBoolProp);

    expect(actual.dynamic.get<DateTime>('dateProp'), expected.dateProp);
    expect(actual.dynamic.get('dateProp'), expected.dateProp);
    expect(actual.dynamic.get<DateTime?>('nullableDateProp'), expected.nullableDateProp);
    expect(actual.dynamic.get('nullableDateProp'), expected.nullableDateProp);

    expect(actual.dynamic.get<double>('doubleProp'), expected.doubleProp);
    expect(actual.dynamic.get('doubleProp'), expected.doubleProp);
    expect(actual.dynamic.get<double?>('nullableDoubleProp'), expected.nullableDoubleProp);
    expect(actual.dynamic.get('nullableDoubleProp'), expected.nullableDoubleProp);

    expect(actual.dynamic.get<ObjectId>('objectIdProp'), expected.objectIdProp);
    expect(actual.dynamic.get('objectIdProp'), expected.objectIdProp);
    expect(actual.dynamic.get<ObjectId?>('nullableObjectIdProp'), expected.nullableObjectIdProp);
    expect(actual.dynamic.get('nullableObjectIdProp'), expected.nullableObjectIdProp);

    expect(actual.dynamic.get<Uuid>('uuidProp'), expected.uuidProp);
    expect(actual.dynamic.get('uuidProp'), expected.uuidProp);
    expect(actual.dynamic.get<Uuid?>('nullableUuidProp'), expected.nullableUuidProp);
    expect(actual.dynamic.get('nullableUuidProp'), expected.nullableUuidProp);

    expect(actual.dynamic.get<int>('intProp'), expected.intProp);
    expect(actual.dynamic.get('intProp'), expected.intProp);
    expect(actual.dynamic.get<int?>('nullableIntProp'), expected.nullableIntProp);
    expect(actual.dynamic.get('nullableIntProp'), expected.nullableIntProp);

    expect(actual.dynamic.get<Decimal128>('decimalProp'), expected.decimalProp);
    expect(actual.dynamic.get('decimalProp'), expected.decimalProp);
    expect(actual.dynamic.get<Decimal128?>('nullableDecimalProp'), expected.nullableDecimalProp);
    expect(actual.dynamic.get('nullableDecimalProp'), expected.nullableDecimalProp);

    dynamic actualDynamic = actual;
    expect(actualDynamic.stringProp, expected.stringProp);
    expect(actualDynamic.nullableStringProp, expected.nullableStringProp);
    expect(actualDynamic.boolProp, expected.boolProp);
    expect(actualDynamic.nullableBoolProp, expected.nullableBoolProp);
    expect(actualDynamic.dateProp, expected.dateProp);
    expect(actualDynamic.nullableDateProp, expected.nullableDateProp);
    expect(actualDynamic.doubleProp, expected.doubleProp);
    expect(actualDynamic.nullableDoubleProp, expected.nullableDoubleProp);
    expect(actualDynamic.objectIdProp, expected.objectIdProp);
    expect(actualDynamic.nullableObjectIdProp, expected.nullableObjectIdProp);
    expect(actualDynamic.uuidProp, expected.uuidProp);
    expect(actualDynamic.nullableUuidProp, expected.nullableUuidProp);
    expect(actualDynamic.intProp, expected.intProp);
    expect(actualDynamic.nullableIntProp, expected.nullableIntProp);
    expect(actualDynamic.decimalProp, expected.decimalProp);
    expect(actualDynamic.nullableDecimalProp, expected.nullableDecimalProp);
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

    expect(actual.dynamic.getList<Decimal128>('decimals'), expected.decimals);
    expect(actual.dynamic.getList('decimals'), expected.decimals);

    dynamic actualDynamic = actual;
    expect(actualDynamic.strings, expected.strings);
    expect(actualDynamic.bools, expected.bools);
    expect(actualDynamic.dates, expected.dates);
    expect(actualDynamic.doubles, expected.doubles);
    expect(actualDynamic.objectIds, expected.objectIds);
    expect(actualDynamic.uuids, expected.uuids);
    expect(actualDynamic.ints, expected.ints);
    expect(actualDynamic.decimals, expected.decimals);
  }

  for (var isDynamic in [true, false]) {
    Realm _getDynamicRealm(Realm original) {
      if (isDynamic) {
        original.close();
        return getRealm(Configuration.local([]));
      }

      return original;
    }

    group('Realm.dynamic when isDynamic=$isDynamic', () {
      test('all returns empty collection', () {
        final config = Configuration.local([Car.schema]);
        final staticRealm = getRealm(config);

        final realm = _getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars.length, 0);
      });

      test('all returns non-empty collection', () {
        final config = Configuration.local([Car.schema]);
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
        final config = Configuration.local([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = _getDynamicRealm(staticRealm);

        expect(() => dynamicRealm.dynamic.all('i-dont-exist'), throws<RealmError>("Object type i-dont-exist not configured in the current Realm's schema"));
      });

      test('all can follow links', () {
        final config = Configuration.local([LinksClass.schema]);
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

        expect(obj1.dynamic.get<RealmObject?>('link'), obj2);
        expect(obj2.dynamic.get<RealmObject?>('link'), obj3);

        final list = obj1.dynamic.getList<RealmObject>('list');

        expect(list[0], obj1);
        expect(list[1], obj2);
        expect(list[2], obj3);
      });

      test('all can be filtered', () {
        final config = Configuration.local([Car.schema]);
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
        final config = Configuration.local([Car.schema]);
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
        final config = Configuration.local([Car.schema]);
        final staticRealm = getRealm(config);

        final dynamicRealm = _getDynamicRealm(staticRealm);

        expect(() => dynamicRealm.dynamic.find('i-dont-exist', 'i-dont-exist'),
            throws<RealmError>("Object type i-dont-exist not configured in the current Realm's schema"));
      });

      test('all returns objects with schema', () {
        final config = Configuration.local([Car.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(Car('Honda'));
          staticRealm.add(Car('Toyota'));
        });

        final realm = _getDynamicRealm(staticRealm);
        final allCars = realm.dynamic.all(Car.schema.name);
        expect(allCars, hasLength(2));

        for (final car in allCars) {
          assertSchemaMatches(car.objectSchema, Car.schema);
        }
      });
    });

    group('RealmObject.dynamic.get when isDynamic=$isDynamic', () {
      test('gets all property types', () {
        final config = Configuration.local([AllTypes.schema]);
        final staticRealm = getRealm(config);

        final nonEmpty = _getPopulatedAllTypes();
        final empty = _getEmptyAllTypes();

        staticRealm.write(() {
          staticRealm.add(_getPopulatedAllTypes());
          staticRealm.add(_getEmptyAllTypes());
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);
        final objects = dynamicRealm.dynamic.all(AllTypes.schema.name);

        final obj1 = objects.singleWhere((o) => o.dynamic.get<String>('stringProp') == nonEmpty.stringProp);
        final obj2 = objects.singleWhere((o) => o.dynamic.get<String>('stringProp') == empty.stringProp);

        _validateDynamic(obj1, _getPopulatedAllTypes());
        _validateDynamic(obj2, _getEmptyAllTypes());
      });

      test('gets normal links', () {
        final config = Configuration.local([LinksClass.schema]);
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

        expect(obj1.dynamic.get<RealmObject?>('link'), isNull);
        expect(obj1.dynamic.get('link'), isNull);

        expect(obj2.dynamic.get<RealmObject?>('link'), obj1);
        expect(obj2.dynamic.get('link'), obj1);
        expect(obj2.dynamic.get<RealmObject?>('link')?.dynamic.get<Uuid>('id'), uuid1);

        assertSchemaMatches(obj2.dynamic.get<RealmObject?>('link')!.objectSchema, LinksClass.schema);

        dynamic dynamicObj1 = obj1;
        dynamic dynamicObj2 = obj2;

        expect(dynamicObj1.link, isNull);

        expect(dynamicObj2.link, obj1);
        expect(dynamicObj2.link.id, uuid1);
        assertSchemaMatches(dynamicObj2.link.objectSchema, LinksClass.schema);
      });

      test('fails with non-existent property', () {
        final config = Configuration.local([AllTypes.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getEmptyAllTypes());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllTypes.schema.name).single;
        dynamic dynamicObj = obj;
        expect(() => obj.dynamic.get('i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllTypes'"));
        expect(() => dynamicObj.idontexist, throws<RealmException>("Property idontexist does not exist on class AllTypes"));
      });

      test('fails with wrong type', () {
        final config = Configuration.local([AllTypes.schema]);
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
            () => obj.dynamic.get<int?>('nullableStringProp'),
            throws<RealmException>(
                "Property 'nullableStringProp' on class 'AllTypes' is not the correct type. Expected 'RealmPropertyType.int', got 'RealmPropertyType.string'."));

        expect(() => obj.dynamic.get<int>('nullableIntProp'),
            throws<RealmException>("Property 'nullableIntProp' on class 'AllTypes' is nullable but the generic argument passed to get<T> is int."));

        expect(() => obj.dynamic.get<int?>('intProp'),
            throws<RealmException>("Property 'intProp' on class 'AllTypes' is required but the generic argument passed to get<T> is int?."));
      });

      test('fails on collection properties', () {
        final config = Configuration.local([AllCollections.schema]);
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
            () => obj.dynamic.get<String?>('strings'),
            throws<RealmException>(
                "Property 'strings' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));
      });
    });

    group('RealmObject.dynamic.getList', () {
      test('gets all list types', () {
        final config = Configuration.local([AllCollections.schema]);
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
        final config = Configuration.local([LinksClass.schema]);
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

        dynamic dynamicObj1 = obj1;
        dynamic dynamicObj2 = obj2;

        expect(dynamicObj1.list, isEmpty);

        expect(dynamicObj2.list, [obj1, obj1]);
        expect(dynamicObj2.list[0].id, uuid1);
      });

      test('fails with non-existent property', () {
        final config = Configuration.local([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(AllCollections());
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;
        expect(() => obj.dynamic.getList('i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllCollections'"));
      });

      test('fails with wrong type', () {
        final config = Configuration.local([AllCollections.schema]);
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
        final config = Configuration.local([AllTypes.schema]);
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
    final config = Configuration.local([AllTypes.schema]);
    final staticRealm = getRealm(config);

    staticRealm.write(() {
      staticRealm.add(_getPopulatedAllTypes());
      staticRealm.add(_getEmptyAllTypes());
    });

    for (var obj in staticRealm.all<AllTypes>()) {
      _validateDynamic(obj, obj);
    }
  });

  test('RealmObject.dynamic.getList when static can get all list types', () {
    final config = Configuration.local([AllCollections.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(_getPopulatedAllCollections());

      realm.add(AllCollections());
    });

    for (final obj in realm.all<AllCollections>()) {
      _validateDynamicLists(obj, obj);
    }
  });

  test('RealmObject.dynamic.get when static can get links', () {
    final config = Configuration.local([LinksClass.schema]);
    final realm = getRealm(config);

    final uuid1 = Uuid.v4();
    final uuid2 = Uuid.v4();

    realm.write(() {
      final obj1 = realm.add(LinksClass(uuid1));
      realm.add(LinksClass(uuid2, link: obj1));
    });

    final obj1 = realm.find<LinksClass>(uuid1)!;
    final obj2 = realm.find<LinksClass>(uuid2)!;

    expect(obj1.dynamic.get<RealmObject?>('link'), isNull);
    expect(obj1.dynamic.get('link'), isNull);

    expect(obj2.dynamic.get<RealmObject?>('link'), obj1);
    expect(obj2.dynamic.get('link'), obj1);
    expect(obj2.dynamic.get<RealmObject?>('link')?.dynamic.get<Uuid>('id'), uuid1);

    dynamic dynamicObj1 = obj1;
    dynamic dynamicObj2 = obj2;

    expect(dynamicObj1.link, isNull);

    expect(dynamicObj2.link, obj1);
    expect(dynamicObj2.link.id, uuid1);
  });

  test('RealmObject.dynamic.getList when static can get links', () {
    final config = Configuration.local([LinksClass.schema]);
    final realm = getRealm(config);

    final uuid1 = Uuid.v4();
    final uuid2 = Uuid.v4();

    realm.write(() {
      final obj1 = realm.add(LinksClass(uuid1));
      realm.add(LinksClass(uuid2, list: [obj1, obj1]));
    });

    final obj1 = realm.find<LinksClass>(uuid1)!;
    final obj2 = realm.find<LinksClass>(uuid2)!;

    expect(obj1.dynamic.getList<RealmObject>('list'), isEmpty);
    expect(obj1.dynamic.getList('list'), isEmpty);

    expect(obj2.dynamic.getList<RealmObject>('list'), [obj1, obj1]);
    expect(obj2.dynamic.getList('list'), [obj1, obj1]);
    expect(obj2.dynamic.getList<RealmObject>('list')[0].dynamic.get<Uuid>('id'), uuid1);

    dynamic dynamicObj1 = obj1;
    dynamic dynamicObj2 = obj2;

    expect(dynamicObj1.list, isEmpty);

    expect(dynamicObj2.list, [obj1, obj1]);
    expect(dynamicObj2.list[0].id, uuid1);
  });

  test('Realm.schema is updated with a new class', () {
    final v1Config = Configuration.local([
      Car.schema,
    ]);

    final v1Realm = getRealm(v1Config);
    v1Realm.close();

    final dynamicRealm = getRealm(Configuration.local([]));

    expect(dynamicRealm.schema, hasLength(1));
    assertSchemaExists(dynamicRealm, Car.schema);

    final v2Config = Configuration.local([Car.schema, Person.schema]);
    final v2Realm = getRealm(v2Config);

    v2Realm.write(() {
      v2Realm.add(Person('Peter'));
    });

    expect(v2Realm.schema, hasLength(2));
    assertSchemaExists(v2Realm, Car.schema);
    assertSchemaExists(v2Realm, Person.schema);

    dynamicRealm.refresh();
    expect(dynamicRealm.schema, hasLength(2));
    assertSchemaExists(dynamicRealm, Car.schema);
    assertSchemaExists(dynamicRealm, Person.schema);

    final dynamicPeople = dynamicRealm.dynamic.all(Person.schema.name);
    expect(dynamicPeople, hasLength(1));
    expect(dynamicPeople.single.dynamic.get<String>('name'), 'Peter');

    assertSchemaMatches(dynamicPeople.single.objectSchema, Person.schema);
  });

  baasTest('Realm.schema is updated with a new property', (config) async {
    // This test validates that adding a property in the schema will update the Realm.schema collection
    // It goes through sync, because that's the only way to add a property without triggering a migration.
    // It is necessary to immediately stop the sync sessions to make sure those changes don't make it to the
    // server, otherwise the schema for all tests will be adjusted, which may pollute the test run.

    final app = App(config);
    final user = await getIntegrationUser(app);

    final v1Config = Configuration.flexibleSync(user, [
      Task.schema,
    ]);

    final v1Realm = getRealm(v1Config);
    v1Realm.syncSession.pause();

    final v2Config = Configuration.flexibleSync(user, [Taskv2.schema]);
    final v2Realm = getRealm(v2Config);
    v2Realm.syncSession.pause();

    v2Realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(v2Realm.all<Taskv2>());
    });

    final taskId = ObjectId();
    v2Realm.write(() {
      v2Realm.add(Taskv2(taskId, 'lorem ipsum'));
    });

    expect(v2Realm.schema, hasLength(1));
    assertSchemaExists(v2Realm, Taskv2.schema);

    v1Realm.refresh();
    expect(v1Realm.schema, hasLength(1));
    assertSchemaExists(v1Realm, Taskv2.schema);

    final tasks = v1Realm.all<Task>();
    expect(tasks, hasLength(1));
    expect(tasks.single.id, taskId);
    expect(tasks.single.dynamic.get<String>('description'), 'lorem ipsum');

    assertSchemaMatches(tasks.single.objectSchema, Taskv2.schema);
  });
}
