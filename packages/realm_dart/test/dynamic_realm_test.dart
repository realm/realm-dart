// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: avoid_relative_lib_imports

import 'package:collection/collection.dart';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';

import 'test.dart';

part 'dynamic_realm_test.realm.dart';

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

  AllTypes _getPopulatedAllTypes() => AllTypes('abc', true, date, -123.456, objectId, uuid, -987, Decimal128.fromDouble(42), Uint8List.fromList([1, 2, 3]),
      nullableStringProp: 'def',
      nullableBoolProp: true,
      nullableDateProp: date,
      nullableDoubleProp: -123.456,
      nullableObjectIdProp: objectId,
      nullableUuidProp: uuid,
      nullableIntProp: 123,
      nullableDecimalProp: Decimal128.fromDouble(4242));

  AllTypes _getEmptyAllTypes() => AllTypes('', false, DateTime(0).toUtc(), 0, objectId, uuid, 0, Decimal128.zero, Uint8List(16));

  AllCollections _getPopulatedAllCollections() => AllCollections(
        stringList: ['abc', 'def'],
        boolList: [true, false],
        dateList: [date, DateTime(0).toUtc()],
        doubleList: [-123.456, 555.666],
        objectIdList: [objectId, objectId],
        uuidList: [uuid, uuid],
        intList: [-987, 123],
        nullableStringList: ['abc', null],
        nullableBoolList: [true, null],
        nullableDateList: [date, null],
        nullableDoubleList: [555.666, null],
        nullableObjectIdList: [objectId, null],
        nullableUuidList: [uuid, null],
        nullableIntList: [123, null],
        stringSet: {'abc', 'def'},
        boolSet: {true, false},
        dateSet: {date, DateTime(0).toUtc()},
        doubleSet: {-123.456, 555.666},
        objectIdSet: {objectId, objectId},
        uuidSet: {uuid, uuid},
        intSet: {-987, 123},
        nullableStringSet: {'abc', null},
        nullableBoolSet: {true, null},
        nullableDateSet: {date, null},
        nullableDoubleSet: {555.666, null},
        nullableObjectIdSet: {objectId, null},
        nullableUuidSet: {uuid, null},
        nullableIntSet: {123, null},
        stringMap: {'a': 'abc', 'b': 'def'},
        boolMap: {'a': true, 'b': false},
        dateMap: {'a': date, 'b': DateTime(0).toUtc()},
        doubleMap: {'a': -123.456, 'b': 555.666},
        objectIdMap: {'a': objectId, 'b': objectId},
        uuidMap: {'a': uuid, 'b': uuid},
        intMap: {'a': -987, 'b': 123},
        nullableStringMap: {'a': 'abc', 'b': null},
        nullableBoolMap: {'a': true, 'b': null},
        nullableDateMap: {'a': date, 'b': null},
        nullableDoubleMap: {'a': 555.666, 'b': null},
        nullableObjectIdMap: {'a': objectId, 'b': null},
        nullableUuidMap: {'a': uuid, 'b': null},
        nullableIntMap: {'a': 123, 'b': null},
      );

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

  void _validateDynamicCollections(RealmObject actual, AllCollections expected) {
    dynamic actualDynamic = actual;

    // Lists
    expect(actual.dynamic.getList<String>('stringList'), expected.stringList);
    expect(actual.dynamic.getList('stringList'), expected.stringList);

    expect(actual.dynamic.getList<bool>('boolList'), expected.boolList);
    expect(actual.dynamic.getList('boolList'), expected.boolList);

    expect(actual.dynamic.getList<DateTime>('dateList'), expected.dateList);
    expect(actual.dynamic.getList('dateList'), expected.dateList);

    expect(actual.dynamic.getList<double>('doubleList'), expected.doubleList);
    expect(actual.dynamic.getList('doubleList'), expected.doubleList);

    expect(actual.dynamic.getList<ObjectId>('objectIdList'), expected.objectIdList);
    expect(actual.dynamic.getList('objectIdList'), expected.objectIdList);

    expect(actual.dynamic.getList<Uuid>('uuidList'), expected.uuidList);
    expect(actual.dynamic.getList('uuidList'), expected.uuidList);

    expect(actual.dynamic.getList<int>('intList'), expected.intList);
    expect(actual.dynamic.getList('intList'), expected.intList);

    expect(actual.dynamic.getList<Decimal128>('decimalList'), expected.decimalList);
    expect(actual.dynamic.getList('decimalList'), expected.decimalList);

    expect(actualDynamic.stringList, expected.stringList);
    expect(actualDynamic.boolList, expected.boolList);
    expect(actualDynamic.dateList, expected.dateList);
    expect(actualDynamic.doubleList, expected.doubleList);
    expect(actualDynamic.objectIdList, expected.objectIdList);
    expect(actualDynamic.uuidList, expected.uuidList);
    expect(actualDynamic.intList, expected.intList);
    expect(actualDynamic.decimalList, expected.decimalList);

    // Nullable lists
    expect(actual.dynamic.getList<String?>('nullableStringList'), expected.nullableStringList);
    expect(actual.dynamic.getList('nullableStringList'), expected.nullableStringList);

    expect(actual.dynamic.getList<bool?>('nullableBoolList'), expected.nullableBoolList);
    expect(actual.dynamic.getList('nullableBoolList'), expected.nullableBoolList);

    expect(actual.dynamic.getList<DateTime?>('nullableDateList'), expected.nullableDateList);
    expect(actual.dynamic.getList('nullableDateList'), expected.nullableDateList);

    expect(actual.dynamic.getList<double?>('nullableDoubleList'), expected.nullableDoubleList);
    expect(actual.dynamic.getList('nullableDoubleList'), expected.nullableDoubleList);

    expect(actual.dynamic.getList<ObjectId?>('nullableObjectIdList'), expected.nullableObjectIdList);
    expect(actual.dynamic.getList('nullableObjectIdList'), expected.nullableObjectIdList);

    expect(actual.dynamic.getList<Uuid?>('nullableUuidList'), expected.nullableUuidList);
    expect(actual.dynamic.getList('nullableUuidList'), expected.nullableUuidList);

    expect(actual.dynamic.getList<int?>('nullableIntList'), expected.nullableIntList);
    expect(actual.dynamic.getList('nullableIntList'), expected.nullableIntList);

    expect(actual.dynamic.getList<Decimal128?>('nullableDecimalList'), expected.nullableDecimalList);
    expect(actual.dynamic.getList('nullableDecimalList'), expected.nullableDecimalList);

    expect(actualDynamic.nullableStringList, expected.nullableStringList);
    expect(actualDynamic.nullableBoolList, expected.nullableBoolList);
    expect(actualDynamic.nullableDateList, expected.nullableDateList);
    expect(actualDynamic.nullableDoubleList, expected.nullableDoubleList);
    expect(actualDynamic.nullableObjectIdList, expected.nullableObjectIdList);
    expect(actualDynamic.nullableUuidList, expected.nullableUuidList);
    expect(actualDynamic.nullableIntList, expected.nullableIntList);
    expect(actualDynamic.nullableDecimalList, expected.nullableDecimalList);

    // Sets
    expect(actual.dynamic.getSet<String>('stringSet'), expected.stringSet);
    expect(actual.dynamic.getSet('stringSet'), expected.stringSet);

    expect(actual.dynamic.getSet<bool>('boolSet'), expected.boolSet);
    expect(actual.dynamic.getSet('boolSet'), expected.boolSet);

    expect(actual.dynamic.getSet<DateTime>('dateSet'), expected.dateSet);
    expect(actual.dynamic.getSet('dateSet'), expected.dateSet);

    expect(actual.dynamic.getSet<double>('doubleSet'), expected.doubleSet);
    expect(actual.dynamic.getSet('doubleSet'), expected.doubleSet);

    expect(actual.dynamic.getSet<ObjectId>('objectIdSet'), expected.objectIdSet);
    expect(actual.dynamic.getSet('objectIdSet'), expected.objectIdSet);

    expect(actual.dynamic.getSet<Uuid>('uuidSet'), expected.uuidSet);
    expect(actual.dynamic.getSet('uuidSet'), expected.uuidSet);

    expect(actual.dynamic.getSet<int>('intSet'), expected.intSet);
    expect(actual.dynamic.getSet('intSet'), expected.intSet);

    expect(actual.dynamic.getSet<Decimal128>('decimalSet'), expected.decimalSet);
    expect(actual.dynamic.getSet('decimalSet'), expected.decimalSet);

    expect(actualDynamic.stringSet, expected.stringSet);
    expect(actualDynamic.boolSet, expected.boolSet);
    expect(actualDynamic.dateSet, expected.dateSet);
    expect(actualDynamic.doubleSet, expected.doubleSet);
    expect(actualDynamic.objectIdSet, expected.objectIdSet);
    expect(actualDynamic.uuidSet, expected.uuidSet);
    expect(actualDynamic.intSet, expected.intSet);
    expect(actualDynamic.decimalSet, expected.decimalSet);

    // Nullable sets
    expect(actual.dynamic.getSet<String?>('nullableStringSet'), expected.nullableStringSet);
    expect(actual.dynamic.getSet('nullableStringSet'), expected.nullableStringSet);

    expect(actual.dynamic.getSet<bool?>('nullableBoolSet'), expected.nullableBoolSet);
    expect(actual.dynamic.getSet('nullableBoolSet'), expected.nullableBoolSet);

    expect(actual.dynamic.getSet<DateTime?>('nullableDateSet'), expected.nullableDateSet);
    expect(actual.dynamic.getSet('nullableDateSet'), expected.nullableDateSet);

    expect(actual.dynamic.getSet<double?>('nullableDoubleSet'), expected.nullableDoubleSet);
    expect(actual.dynamic.getSet('nullableDoubleSet'), expected.nullableDoubleSet);

    expect(actual.dynamic.getSet<ObjectId?>('nullableObjectIdSet'), expected.nullableObjectIdSet);
    expect(actual.dynamic.getSet('nullableObjectIdSet'), expected.nullableObjectIdSet);

    expect(actual.dynamic.getSet<Uuid?>('nullableUuidSet'), expected.nullableUuidSet);
    expect(actual.dynamic.getSet('nullableUuidSet'), expected.nullableUuidSet);

    expect(actual.dynamic.getSet<int?>('nullableIntSet'), expected.nullableIntSet);
    expect(actual.dynamic.getSet('nullableIntSet'), expected.nullableIntSet);

    expect(actual.dynamic.getSet<Decimal128?>('nullableDecimalSet'), expected.nullableDecimalSet);
    expect(actual.dynamic.getSet('nullableDecimalSet'), expected.nullableDecimalSet);

    expect(actualDynamic.nullableStringSet, expected.nullableStringSet);
    expect(actualDynamic.nullableBoolSet, expected.nullableBoolSet);
    expect(actualDynamic.nullableDateSet, expected.nullableDateSet);
    expect(actualDynamic.nullableDoubleSet, expected.nullableDoubleSet);
    expect(actualDynamic.nullableObjectIdSet, expected.nullableObjectIdSet);
    expect(actualDynamic.nullableUuidSet, expected.nullableUuidSet);
    expect(actualDynamic.nullableIntSet, expected.nullableIntSet);
    expect(actualDynamic.nullableDecimalSet, expected.nullableDecimalSet);

    // Maps
    expect(actual.dynamic.getMap<String>('stringMap'), expected.stringMap);
    expect(actual.dynamic.getMap('stringMap'), expected.stringMap);

    expect(actual.dynamic.getMap<bool>('boolMap'), expected.boolMap);
    expect(actual.dynamic.getMap('boolMap'), expected.boolMap);

    expect(actual.dynamic.getMap<DateTime>('dateMap'), expected.dateMap);
    expect(actual.dynamic.getMap('dateMap'), expected.dateMap);

    expect(actual.dynamic.getMap<double>('doubleMap'), expected.doubleMap);
    expect(actual.dynamic.getMap('doubleMap'), expected.doubleMap);

    expect(actual.dynamic.getMap<ObjectId>('objectIdMap'), expected.objectIdMap);
    expect(actual.dynamic.getMap('objectIdMap'), expected.objectIdMap);

    expect(actual.dynamic.getMap<Uuid>('uuidMap'), expected.uuidMap);
    expect(actual.dynamic.getMap('uuidMap'), expected.uuidMap);

    expect(actual.dynamic.getMap<int>('intMap'), expected.intMap);
    expect(actual.dynamic.getMap('intMap'), expected.intMap);

    expect(actual.dynamic.getMap<Decimal128>('decimalMap'), expected.decimalMap);
    expect(actual.dynamic.getMap('decimalMap'), expected.decimalMap);

    expect(actualDynamic.stringMap, expected.stringMap);
    expect(actualDynamic.boolMap, expected.boolMap);
    expect(actualDynamic.dateMap, expected.dateMap);
    expect(actualDynamic.doubleMap, expected.doubleMap);
    expect(actualDynamic.objectIdMap, expected.objectIdMap);
    expect(actualDynamic.uuidMap, expected.uuidMap);
    expect(actualDynamic.intMap, expected.intMap);
    expect(actualDynamic.decimalMap, expected.decimalMap);

    // Nullable Maps
    expect(actual.dynamic.getMap<String?>('nullableStringMap'), expected.nullableStringMap);
    expect(actual.dynamic.getMap('nullableStringMap'), expected.nullableStringMap);

    expect(actual.dynamic.getMap<bool?>('nullableBoolMap'), expected.nullableBoolMap);
    expect(actual.dynamic.getMap('nullableBoolMap'), expected.nullableBoolMap);

    expect(actual.dynamic.getMap<DateTime?>('nullableDateMap'), expected.nullableDateMap);
    expect(actual.dynamic.getMap('nullableDateMap'), expected.nullableDateMap);

    expect(actual.dynamic.getMap<double?>('nullableDoubleMap'), expected.nullableDoubleMap);
    expect(actual.dynamic.getMap('nullableDoubleMap'), expected.nullableDoubleMap);

    expect(actual.dynamic.getMap<ObjectId?>('nullableObjectIdMap'), expected.nullableObjectIdMap);
    expect(actual.dynamic.getMap('nullableObjectIdMap'), expected.nullableObjectIdMap);

    expect(actual.dynamic.getMap<Uuid?>('nullableUuidMap'), expected.nullableUuidMap);
    expect(actual.dynamic.getMap('nullableUuidMap'), expected.nullableUuidMap);

    expect(actual.dynamic.getMap<int?>('nullableIntMap'), expected.nullableIntMap);
    expect(actual.dynamic.getMap('nullableIntMap'), expected.nullableIntMap);

    expect(actual.dynamic.getMap<Decimal128?>('nullableDecimalMap'), expected.nullableDecimalMap);
    expect(actual.dynamic.getMap('nullableDecimalMap'), expected.nullableDecimalMap);

    expect(actualDynamic.nullableStringMap, expected.nullableStringMap);
    expect(actualDynamic.nullableBoolMap, expected.nullableBoolMap);
    expect(actualDynamic.nullableDateMap, expected.nullableDateMap);
    expect(actualDynamic.nullableDoubleMap, expected.nullableDoubleMap);
    expect(actualDynamic.nullableObjectIdMap, expected.nullableObjectIdMap);
    expect(actualDynamic.nullableUuidMap, expected.nullableUuidMap);
    expect(actualDynamic.nullableIntMap, expected.nullableIntMap);
    expect(actualDynamic.nullableDecimalMap, expected.nullableDecimalMap);
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

        assertSchemaMatches(dynamicObj2.link.objectSchema as SchemaObject, LinksClass.schema);
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
            () => obj.dynamic.get<String>('stringList'),
            throws<RealmException>(
                "Property 'stringList' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));

        expect(
            () => obj.dynamic.get('stringList'),
            throws<RealmException>(
                "Property 'stringList' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));

        expect(
            () => obj.dynamic.get<String?>('stringList'),
            throws<RealmException>(
                "Property 'stringList' on class 'AllCollections' is 'RealmCollectionType.list' but the method used to access it expected 'RealmCollectionType.none'."));
      });
    });

    group('RealmObject.dynamic.getCollection when isDynamic=$isDynamic', () {
      test('gets collection of primitive types', () {
        final config = Configuration.local([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getPopulatedAllCollections());
          staticRealm.add(AllCollections());
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);
        final objects = dynamicRealm.dynamic.all(AllCollections.schema.name);
        final obj1 = objects.singleWhere((element) => element.dynamic.getList('stringList').isNotEmpty);
        final obj2 = objects.singleWhere((element) => element.dynamic.getList('stringList').isEmpty);

        _validateDynamicCollections(obj1, _getPopulatedAllCollections());
        _validateDynamicCollections(obj2, AllCollections());
      });

      test('gets collection of objects', () {
        final config = Configuration.local([LinksClass.schema]);
        final staticRealm = getRealm(config);

        final uuid1 = Uuid.v4();
        final uuid2 = Uuid.v4();

        staticRealm.write(() {
          final obj1 = staticRealm.add(LinksClass(uuid1));
          staticRealm.add(LinksClass(uuid2, list: [obj1, obj1], linksSet: {obj1}, map: {'a': obj1, 'b': obj1}));
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);

        final obj1 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid1)!;
        final obj2 = dynamicRealm.dynamic.find(LinksClass.schema.name, uuid2)!;

        expect(obj1.dynamic.getList<RealmObject>('list'), isEmpty);
        expect(obj1.dynamic.getList('list'), isEmpty);
        expect(obj1.dynamic.getSet<RealmObject>('linksSet'), isEmpty);
        expect(obj1.dynamic.getSet('linksSet'), isEmpty);
        expect(obj1.dynamic.getMap<RealmObject?>('map'), isEmpty);
        expect(obj1.dynamic.getMap('map'), isEmpty);

        expect(obj2.dynamic.getList<RealmObject>('list'), [obj1, obj1]);
        expect(obj2.dynamic.getList('list'), [obj1, obj1]);
        expect(obj2.dynamic.getList<RealmObject>('list')[0].dynamic.get<Uuid>('id'), uuid1);

        expect(obj2.dynamic.getSet<RealmObject>('linksSet'), [obj1]);
        expect(obj2.dynamic.getSet('linksSet'), [obj1]);
        expect(obj2.dynamic.getSet<RealmObject>('linksSet').first.dynamic.get<Uuid>('id'), uuid1);

        expect(obj2.dynamic.getMap<RealmObject?>('map'), {'a': obj1, 'b': obj1});
        expect(obj2.dynamic.getMap('map'), {'a': obj1, 'b': obj1});
        expect(obj2.dynamic.getMap<RealmObject?>('map')['a']!.dynamic.get<Uuid>('id'), uuid1);
        expect(obj2.dynamic.getMap<RealmObject?>('map')['non-existent'], null);

        dynamic dynamicObj1 = obj1;
        dynamic dynamicObj2 = obj2;

        expect(dynamicObj1.list, isEmpty);
        expect(dynamicObj1.linksSet, isEmpty);
        expect(dynamicObj1.map, isEmpty);

        expect(dynamicObj2.list, [obj1, obj1]);
        expect(dynamicObj2.list[0].id, uuid1);
        expect(dynamicObj2.linksSet, [obj1]);
        expect(dynamicObj2.linksSet.first.id, uuid1);
        expect(dynamicObj2.map, {'a': obj1, 'b': obj1});
        expect(dynamicObj2.map['a']!.id, uuid1);
        expect(dynamicObj2.map['non-existent'], null);
      });

      for (final collectionType in [RealmCollectionType.list, RealmCollectionType.set, RealmCollectionType.map]) {
        dynamic getter<T>(RealmObjectBase object, String property) {
          return switch (collectionType) {
            RealmCollectionType.list => object.dynamic.getList<T>(property),
            RealmCollectionType.set => object.dynamic.getSet<T>(property),
            RealmCollectionType.map => object.dynamic.getMap<T>(property),
            _ => throw RealmError('Unexpected collectionType: $collectionType'),
          };
        }

        final propertySuffix = switch (collectionType) {
          RealmCollectionType.list => 'List',
          RealmCollectionType.set => 'Set',
          RealmCollectionType.map => 'Map',
          _ => throw RealmError('Unexpected collectionType: $collectionType'),
        };

        test('get$propertySuffix fails with non-existent property', () {
          final config = Configuration.local([AllCollections.schema]);
          final staticRealm = getRealm(config);
          staticRealm.write(() {
            staticRealm.add(AllCollections());
          });
          final dynamicRealm = _getDynamicRealm(staticRealm);

          final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;
          expect(() => getter(obj, 'i-dont-exist'), throws<RealmException>("Property 'i-dont-exist' does not exist on class 'AllCollections'"));
        });

        test('get$propertySuffix fails with wrong type', () {
          final config = Configuration.local([AllCollections.schema]);
          final staticRealm = getRealm(config);
          staticRealm.write(() {
            staticRealm.add(AllCollections());
          });
          final dynamicRealm = _getDynamicRealm(staticRealm);

          final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;

          expect(
              () => getter<int>(obj, 'string$propertySuffix'),
              throws<RealmException>(
                  "Property 'string$propertySuffix' on class 'AllCollections' is not the correct type. Expected 'RealmPropertyType.int', got 'RealmPropertyType.string'"));
        });

        test('get$propertySuffix fails on non-collection properties', () {
          final config = Configuration.local([AllTypes.schema]);
          final staticRealm = getRealm(config);
          staticRealm.write(() {
            staticRealm.add(_getEmptyAllTypes());
          });
          final dynamicRealm = _getDynamicRealm(staticRealm);

          final obj = dynamicRealm.dynamic.all(AllTypes.schema.name).single;
          expect(
              () => getter(obj, 'intProp'),
              throws<RealmException>(
                  "Property 'intProp' on class 'AllTypes' is 'RealmCollectionType.none' but the method used to access it expected '$collectionType'."));
        });
      }
    });

    group('.changes when isDynamic=$isDynamic', () {
      test('Returns stream for objects', () async {
        final config = Configuration.local(
            [ObjectWithEmbedded.schema, AllTypesEmbedded.schema, RecursiveEmbedded1.schema, RecursiveEmbedded2.schema, RecursiveEmbedded3.schema]);

        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(ObjectWithEmbedded('abc', recursiveObject: RecursiveEmbedded1('child 1')));
        });
        final dynamicRealm = _getDynamicRealm(staticRealm);

        final toplevelChanges = <RealmObjectChanges<RealmObject>>[];
        final embeddedChanges = <RealmObjectChanges<EmbeddedObject>>[];
        final topLevel = dynamicRealm.dynamic.all(ObjectWithEmbedded.schema.name).single;
        final embedded = topLevel.dynamic.get<EmbeddedObject?>('recursiveObject')!;

        final topLevelSubscription = topLevel.changes.listen((event) {
          toplevelChanges.add(event);
        });

        final embeddedSubscription = embedded.changes.listen((event) {
          embeddedChanges.add(event);
        });

        final newUuid = Uuid.v4();
        dynamicRealm.write(() {
          topLevel.dynamic.set('differentiator', newUuid);
          embedded.dynamic.set('value', 'updated child 1');
        });

        await Future<void>.delayed(Duration(milliseconds: 20));

        expect(topLevel.dynamic.get<Uuid?>('differentiator'), newUuid);
        expect(embedded.dynamic.get<String>('value'), 'updated child 1');

        expect(toplevelChanges, hasLength(2));
        expect(toplevelChanges[0].properties, isEmpty); // First notification is delivered with empty properties
        expect(toplevelChanges[1].object, topLevel);
        expect(toplevelChanges[1].properties, hasLength(1));
        expect(toplevelChanges[1].properties[0], 'differentiator');

        expect(embeddedChanges, hasLength(2));
        expect(embeddedChanges[0].properties, isEmpty); // First notification is delivered with empty properties
        expect(embeddedChanges[1].object, embedded);
        expect(embeddedChanges[1].properties, hasLength(1));
        expect(embeddedChanges[1].properties[0], 'value');

        topLevelSubscription.cancel();
        embeddedSubscription.cancel();
      });

      test('Returns stream for collection of primitives', () async {
        final config = Configuration.local([AllCollections.schema]);
        final staticRealm = getRealm(config);
        staticRealm.write(() {
          staticRealm.add(_getPopulatedAllCollections());
        });

        final dynamicRealm = _getDynamicRealm(staticRealm);
        final obj = dynamicRealm.dynamic.all(AllCollections.schema.name).single;

        final listChanges = <RealmListChanges<String>>[];
        final setChanges = <RealmSetChanges<double>>[];
        final mapChanges = <RealmMapChanges<Uuid?>>[];

        final list = obj.dynamic.getList<String>('stringList');
        final listSub = list.changes.listen((event) {
          listChanges.add(event);
        });

        final set = obj.dynamic.getSet<double>('doubleSet');
        final setSub = set.changes.listen((event) {
          setChanges.add(event);
        });

        final map = obj.dynamic.getMap<Uuid?>('nullableUuidMap');
        final mapSub = map.changes.listen((event) {
          mapChanges.add(event);
        });

        dynamicRealm.write(() {
          list[0] = 'new string';
          set.clear();
          map['new map value'] = null;
        });

        await Future<void>.delayed(Duration(milliseconds: 20));

        expect(listChanges, hasLength(2));
        expect(listChanges[1].inserted, isEmpty);
        expect(listChanges[1].deleted, isEmpty);
        expect(listChanges[1].modified, [0]);

        expect(setChanges, hasLength(2));
        expect(setChanges[1].deleted, [0, 1]);
        expect(setChanges[1].inserted, isEmpty);
        expect(setChanges[1].modified, isEmpty);

        expect(mapChanges, hasLength(2));
        expect(mapChanges[1].inserted, ['new map value']);
        expect(mapChanges[1].deleted, isEmpty);
        expect(mapChanges[1].modified, isEmpty);

        listSub.cancel();
        setSub.cancel();
        mapSub.cancel();
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
      _validateDynamicCollections(obj, obj);
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
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  void updateLocalSchema(String realmPath, List<SchemaObject> newSchema) {
    final config = Configuration.local(newSchema, path: realmPath);

    final realm = getRealm(config);
    realm.close();
  }

  void assertSchemaChangeNotification(
      RealmSchemaChanges event, List<SchemaObject> expectedCurrent, List<SchemaObject> expectedNew, List<Object> validationErrors) {
    try {
      expect(event.currentSchema, hasLength(expectedCurrent.length));
      expect(event.newSchema, hasLength(expectedNew.length));
      expect(event.currentSchema.map((e) => e.name), unorderedMatches(expectedCurrent.map((e) => e.name)));
      expect(event.newSchema.map((e) => e.name), unorderedMatches(expectedNew.map((e) => e.name)));
    } catch (e) {
      validationErrors.add(e);
    }
  }

  test('Realm.schemaChanges is raised when the schema changes', () async {
    final dynamicConfig = Configuration.local([]);
    updateLocalSchema(dynamicConfig.path, [Car.schema]);

    final dynamicRealm = getRealm(dynamicConfig);

    final validationErrors = <Object>[];
    var invocations = 0;

    // final sub = dynamicRealm.schemaChanges.listen((event) {
    //   invocations++;
    //   assertSchemaChangeNotification(event, [Car.schema], [Car.schema, Person.schema], validationErrors);
    // });

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema]);

    // dynamicRealm.refresh();
    // expect(dynamicRealm.schema, hasLength(2));
    // expect(invocations, 1);
    // expect(validationErrors, isEmpty);

    // await sub.cancel();
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  test('Realm.schemaChanges can be paused and resumed', () async {
    final dynamicConfig = Configuration.local([]);
    updateLocalSchema(dynamicConfig.path, [Car.schema]);
    final dynamicRealm = getRealm(dynamicConfig);

    var invocations = 0;
    final validationErrors = <Object>[];
    // final sub = dynamicRealm.schemaChanges.listen((event) {
    //   invocations++;

    //   if (invocations == 2) {
    //     assertSchemaChangeNotification(event, [Car.schema, Person.schema, Dog.schema], [Car.schema, Person.schema, Dog.schema, Team.schema], validationErrors);
    //   }
    // });

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema]);
    // dynamicRealm.refresh();

    // expect(invocations, 1);

    // sub.pause();

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema, Dog.schema]);

    // // We paused the subscription, should not get a notification for this update
    // dynamicRealm.refresh();
    // expect(invocations, 1);

    // sub.resume();

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema, Dog.schema, Team.schema]);

    // // We resumed the subscription, should get a notification for the latest update only
    // dynamicRealm.refresh();
    // expect(invocations, 2);
    // expect(validationErrors, isEmpty);

    // await sub.cancel();

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema, Dog.schema, Team.schema, RemappedClass.schema]);

    // // We canceled the subscription, should not get a notification
    // dynamicRealm.refresh();
    // expect(invocations, 2);
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  test("Realm.schemaChanges multiple subscribers", () async {
    final dynamicConfig = Configuration.local([]);
    updateLocalSchema(dynamicConfig.path, [Car.schema]);

    final dynamicRealm = getRealm(dynamicConfig);

    final validationErrors = <Object>[];

    var sub1Invocations = 0;
    // final sub1 = dynamicRealm.schemaChanges.listen((event) {
    //   sub1Invocations++;
    //   assertSchemaChangeNotification(event, [Car.schema], [Car.schema, Person.schema], validationErrors);
    // });

    // var sub2Invocations = 0;
    // final sub2 = dynamicRealm.schemaChanges.listen((event) {
    //   sub2Invocations++;
    // });

    // updateLocalSchema(dynamicConfig.path, [Car.schema, Person.schema]);
    // dynamicRealm.refresh();

    // expect(sub1Invocations, 1);
    // expect(sub2Invocations, 1);

    // assertSchemaExists(dynamicRealm, Person.schema);

    // expect(validationErrors, isEmpty);

    // await sub1.cancel();
    // await sub2.cancel();
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  Realm openPausedSyncRealm(User user, List<SchemaObject> schemas) {
    // Some tests validate that adding a property in the schema will update the Realm.schema collection
    // It goes through sync, because that's the only way to add a property without triggering a migration.
    // It is necessary to immediately stop the sync sessions to make sure those changes don't make it to the
    // server, otherwise the schema for all tests will be adjusted, which may pollute the test run.

    final config = Configuration.flexibleSync(user, schemas);

    final realm = getRealm(config);
    realm.syncSession.pause();

    realm.subscriptions.update((mutableSubscriptions) {
      for (final schema in schemas) {
        mutableSubscriptions.add(realm.dynamic.all(schema.name));
      }
    });

    return realm;
  }

  baasTest('Realm.schema is updated with a new property', (config) async {
    final user = await getIntegrationUser(appConfig: config);

    final v1Realm = openPausedSyncRealm(user, [Task.schema]);
    v1Realm.syncSession.pause();

    final v2Realm = openPausedSyncRealm(user, [Taskv2.schema]);

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
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  baasTest('RealmObject.schema is updated with a new property', (config) async {
    final user = await getIntegrationUser(appConfig: config);

    final v1Realm = openPausedSyncRealm(user, [Task.schema]);
    final task = v1Realm.write(() => v1Realm.add(Task(ObjectId())));
    assertSchemaMatches(task.objectSchema, Task.schema);

    final v2Realm = openPausedSyncRealm(user, [Taskv2.schema]);

    expect(v2Realm.schema, hasLength(1));
    assertSchemaExists(v2Realm, Taskv2.schema);

    v2Realm.write(() {
      final v2Task = v2Realm.find<Taskv2>(task.id)!;
      v2Task.description = 'lorem ipsum';
    });

    v1Realm.refresh();
    expect(v1Realm.schema, hasLength(1));
    assertSchemaExists(v1Realm, Taskv2.schema);

    assertSchemaMatches(task.objectSchema, Taskv2.schema);
    expect(task.dynamic.get<String>('description'), 'lorem ipsum');
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');

  baasTest('UnmanagedObject.schema is updated with a new property', (config) async {
    final user = await getIntegrationUser(appConfig: config);

    final v1Realm = openPausedSyncRealm(user, [Task.schema]);

    // Update the schema
    openPausedSyncRealm(user, [Taskv2.schema]);

    final task = Task(ObjectId());
    expect(() => task.dynamic.get<String>('description'),
        throwsA(isA<RealmError>().having((p0) => p0.message, 'message', "Property 'description' does not exist on object of type 'Task'")));
    assertSchemaMatches(task.objectSchema, Task.schema);

    v1Realm.write(() {
      v1Realm.add(task);
    });

    assertSchemaMatches(task.objectSchema, Taskv2.schema);

    // Schema was updated so description shouldn't throw now
    expect(task.dynamic.get<String>('description'), '');
  }, skip: 'Requires https://github.com/realm/realm-core/issues/7426');
}
