// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';

import 'test.dart';


part 'realm_map_test.realm.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late String make;
  late String? color;
}

@RealmModel(ObjectType.embeddedObject)
class _EmbeddedValue {
  late int intValue;
}

@RealmModel()
class _TestRealmMaps {
  @PrimaryKey()
  late int key;

  late Map<String, bool> boolMap;
  late Map<String, int> intMap;
  late Map<String, String> stringMap;
  late Map<String, double> doubleMap;
  late Map<String, DateTime> dateTimeMap;
  late Map<String, ObjectId> objectIdMap;
  late Map<String, Uuid> uuidMap;
  late Map<String, Uint8List> binaryMap;
  late Map<String, Decimal128> decimalMap;

  late Map<String, bool?> nullableBoolMap;
  late Map<String, int?> nullableIntMap;
  late Map<String, String?> nullableStringMap;
  late Map<String, double?> nullableDoubleMap;
  late Map<String, DateTime?> nullableDateTimeMap;
  late Map<String, ObjectId?> nullableObjectIdMap;
  late Map<String, Uuid?> nullableUuidMap;
  late Map<String, Uint8List?> nullableBinaryMap;
  late Map<String, Decimal128?> nullableDecimalMap;

  late Map<String, _Car?> objectsMap;
  late Map<String, _EmbeddedValue?> embeddedMap;

  late Map<String, RealmValue> mixedMap;
}

class TestCaseData<T> {
  final T Function(T) _cloneFunc;
  final bool Function(T?, T?) _equalityFunc;

  final T _sampleValue;

  final List<(String key, T value)> _initialValues;

  List<(String key, T value)> get initialValues => _initialValues.map((kvp) => (kvp.$1, _cloneFunc(kvp.$2))).toList();

  T get sampleValue => _cloneFunc(_sampleValue);

  TestCaseData(this._sampleValue, {bool Function(T?, T?)? equalityFunc, List<(String key, T value)> initialValues = const [], T Function(T)? cloneFunc})
      : _equalityFunc = equalityFunc ?? ((a, b) => a == b),
        _cloneFunc = cloneFunc ?? ((v) => v),
        _initialValues = initialValues;

  void seed(Map<String, T> target, {Iterable<(String key, T value)>? values}) {
    _writeIfNecessary(target, () {
      target.clear();
      for (var (key, value) in values ?? initialValues) {
        target[key] = value;
      }
    });
  }

  void assertEquivalent(Map<String, T> target) {
    final reference = _getReferenceMap();
    _isEquivalent(target, reference);
  }

  void assertContainsKey(Map<String, T> target) {
    for (final (key, _) in initialValues) {
      expect(target.containsKey(key), true, reason: 'expected to find $key');
    }

    expect(target.containsKey(Uuid.v4().toString()), false);
  }

  void assertKeys(Map<String, T> target) {
    expect(target.keys, unorderedEquals(initialValues.map((e) => e.$1)));
  }

  void assertValues(Map<String, T> target) {
    expect(target.values.length, initialValues.length);
    final actualValues = target.values;
    for (final (_, value) in initialValues) {
      expect(actualValues.where((element) => _equalityFunc(element, value)).length, greaterThanOrEqualTo(1)); // values may be duplicates
    }

    // Test in the other direction in case we have duplicates
    for (final value in actualValues) {
      expect(initialValues.where((element) => _equalityFunc(element.$2, value)).length, greaterThanOrEqualTo(1)); // values may be duplicates
    }
  }

  void assertEntries(Map<String, T> target) {
    final reference = _getReferenceMap();
    for (final kvp in target.entries) {
      expect(reference.containsKey(kvp.key), true);
      expect(_equalityFunc(reference[kvp.key], target[kvp.key]), true);

      reference.remove(kvp.key);
    }

    expect(reference, isEmpty);
  }

  void assertAccessor(Map<String, T> target) {
    for (final (key, value) in initialValues) {
      expect(_equalityFunc(target[key], value), true);
    }

    expect(target[Uuid.v4().toString()], null);
  }

  void assertSet(Map<String, T> target) {
    var expectedLength = target.length;

    if (target.isNotEmpty) {
      final key = target.keys.first;
      _writeIfNecessary(target, () {
        target[key] = sampleValue;
      });

      expect(target.containsKey(key), true);
      expect(_equalityFunc(target[key], sampleValue), true);
      expect(target.length, expectedLength);
    }

    final newKey = Uuid.v4().toString();
    _writeIfNecessary(target, () {
      target[newKey] = sampleValue;
    });

    expectedLength++;

    expect(target.containsKey(newKey), true);
    expect(_equalityFunc(target[newKey], sampleValue), true);
    expect(target.length, expectedLength);
  }

  void assertRemove(Map<String, T> target) {
    seed(target);

    var expectedLength = target.length;

    if (target.isNotEmpty) {
      final kvp = target.entries.last;
      final removedValue = _writeIfNecessary(target, () => target.remove(kvp.key));
      expectedLength--;

      expect(removedValue, kvp.value);
      expect(target.containsKey(kvp.key), false);
      expect(target.length, expectedLength);
    }

    final newKey = Uuid.v4().toString();
    final removedValue = _writeIfNecessary(target, () => target.remove(newKey));

    expect(removedValue, null);
    expect(target.containsKey(newKey), false);
    expect(target.length, expectedLength);
  }

  (String key, T value) _getDifferentValue(Map<String, T> collection, T valueToCompare) {
    for (final kvp in collection.entries) {
      if (!_areValuesEqual(kvp.value, valueToCompare)) {
        return (kvp.key, kvp.value);
      }
    }

    throw StateError('Could not find a different value');
  }

  void _isEquivalent(Map<String, T> actual, Map<String, T> expected) {
    expect(actual, hasLength(expected.length));
    for (final kvp in expected.entries) {
      final actualEntry = actual.entries.firstWhereOrNull((element) => element.key == kvp.key);
      expect(actualEntry, isNotNull, reason: 'expect actual to contain ${kvp.key}');
      final actualValue = actual[kvp.key];
      expect(_equalityFunc(actualValue, kvp.value), true, reason: 'expected $actualValue == ${kvp.value}');
    }
  }

  bool _areValuesEqual(T first, T second) {
    if (first == second) {
      return true;
    }

    if (first is Uint8List && second is Uint8List) {
      return IterableEquality().equals(first, second);
    }

    return false;
  }

  U _writeIfNecessary<U>(Map<String, T> collection, U Function() writeAction) {
    Transaction? transaction;
    try {
      if (collection is RealmMap<T> && collection.isManaged) {
        transaction = collection.realm.beginWrite();
      }

      final result = writeAction();

      transaction?.commit();

      return result;
    } catch (e) {
      transaction?.rollback();
      rethrow;
    }
  }

  Map<String, T> _getReferenceMap() => {for (var v in initialValues) v.$1: v.$2};

  @override
  String toString() {
    return _initialValues.map((kvp) => '${kvp.$1}-${kvp.$2}').join(', ');
  }
}

List<TestCaseData<bool>> boolTestValues() => [
      TestCaseData(true),
      TestCaseData(true, initialValues: [('a', true)]),
      TestCaseData(false, initialValues: [('b', false)]),
      TestCaseData(true, initialValues: [('a', false), ('b', true)]),
      TestCaseData(false, initialValues: [('a', true), ('b', false), ('c', true)]),
    ];

List<TestCaseData<bool?>> nullableBoolTestValues() => [
      TestCaseData(true),
      TestCaseData(true, initialValues: [('a', true)]),
      TestCaseData(true, initialValues: [('b', false)]),
      TestCaseData(false, initialValues: [('c', null)]),
      TestCaseData(true, initialValues: [('a', false), ('b', true)]),
      TestCaseData(null, initialValues: [('a', true), ('b', false), ('c', null)]),
    ];

List<TestCaseData<int>> intTestCases() => [
      TestCaseData(123456789),
      TestCaseData(123456789, initialValues: [('123', 123)]),
      TestCaseData(123456789, initialValues: [('123', -123)]),
      TestCaseData(123456789, initialValues: [('a', 1), ('b', 1), ('c', 1)]),
      TestCaseData(123456789, initialValues: [('a', 1), ('b', 2), ('c', 3)]),
      TestCaseData(123456789, initialValues: [('a', -0x8000000000000000), ('z', 0x7FFFFFFFFFFFFFFF)]),
      TestCaseData(123456789, initialValues: [('a', -0x8000000000000000), ('zero', 0), ('one', 1), ('z', 0x7FFFFFFFFFFFFFFF)]),
    ];

List<TestCaseData<int?>> nullableIntTestCases() => [
      TestCaseData(1234),
      TestCaseData(null, initialValues: [('123', 123)]),
      TestCaseData(1234, initialValues: [('123', -123)]),
      TestCaseData(1234, initialValues: [('null', null)]),
      TestCaseData(1234, initialValues: [('null1', null), ('null2', null), ('null3', null)]),
      TestCaseData(null, initialValues: [('a', 1), ('b', null), ('c', 3)]),
      TestCaseData(1234, initialValues: [('a', -0x8000000000000000), ('m', null), ('z', 0x7FFFFFFFFFFFFFFF)]),
      TestCaseData(1234, initialValues: [('a', -0x8000000000000000), ('zero', 0), ('null', null), ('one', 1), ('z', 0x7FFFFFFFFFFFFFFF)]),
    ];

List<TestCaseData<String>> stringTestValues() => [
      TestCaseData(''),
      TestCaseData('', initialValues: [('123', 'abc')]),
      TestCaseData('', initialValues: [('a', 'AbCdEfG'), ('b', 'HiJklMn'), ('c', 'OpQrStU')]),
      TestCaseData('', initialValues: [('a', 'vwxyz'), ('b', ''), ('c', ' ')]),
      TestCaseData('', initialValues: [('a', ''), ('z', 'aa bb cc dd ee ff gg hh ii jj kk ll mm nn oo pp qq rr ss tt uu vv ww xx yy zz')]),
      TestCaseData('', initialValues: [('a', ''), ('z', 'lorem ipsum'), ('zero', '-1234567890'), ('one', 'lololo')]),
    ];

List<TestCaseData<String?>> nullableStringTestValues() => [
      TestCaseData(null),
      TestCaseData(null, initialValues: [('123', 'abc')]),
      TestCaseData('', initialValues: [('null', null)]),
      TestCaseData('', initialValues: [('null1', null), ('null2', null)]),
      TestCaseData('', initialValues: [('a', 'AbCdEfG'), ('b', null), ('c', 'OpQrStU')]),
      TestCaseData(null, initialValues: [('a', 'vwxyz'), ('b', null), ('c', ''), ('d', ' ')]),
      TestCaseData('', initialValues: [('a', ''), ('m', null), ('z', 'aa bb cc dd ee ff gg hh ii jj kk ll mm nn oo pp qq rr ss tt uu vv ww xx yy zz')]),
      TestCaseData('', initialValues: [('a', ''), ('zero', 'lorem ipsum'), ('null', null), ('one', '-1234567890'), ('z', 'lololo')]),
    ];

List<TestCaseData<double>> doubleTestValues() => [
      TestCaseData(789.123),
      TestCaseData(789.123, initialValues: [('123', 123.123)]),
      TestCaseData(789.123, initialValues: [('123', -123.456)]),
      TestCaseData(789.123, initialValues: [('a', 1.1), ('b', 1.1), ('c', 1.1)]),
      TestCaseData(789.123, initialValues: [('a', 1), ('b', 2.2), ('c', 3.3)]),
      TestCaseData(789.123,
          initialValues: [('a', 1), ('b', 2.2), ('c', 3.3), ('d', 4385948963486946854968945789458794538793438693486934869.238593285932859238952398)]),
      TestCaseData(789.123, initialValues: [('a', -double.maxFinite), ('z', double.maxFinite)]),
      TestCaseData(789.123, initialValues: [('a', -double.maxFinite), ('zero', 0.0), ('one', 1.1), ('z', double.maxFinite)]),
    ];

List<TestCaseData<double?>> nullableDoubleTestValues() => [
      TestCaseData(-123.789),
      TestCaseData(-123.789, initialValues: [('123', 123.123)]),
      TestCaseData(null, initialValues: [('123', -123.456)]),
      TestCaseData(-123.789, initialValues: [('null', null)]),
      TestCaseData(-123.789, initialValues: [('null1', null), ('null2', null)]),
      TestCaseData(-123.789, initialValues: [('a', 1), ('b', null), ('c', 3.3)]),
      TestCaseData(null,
          initialValues: [('a', 1), ('b', null), ('c', 3.3), ('d', 4385948963486946854968945789458794538793438693486934869.238593285932859238952398)]),
      TestCaseData(-123.789, initialValues: [('a', -double.maxFinite), ('m', null), ('z', double.maxFinite)]),
      TestCaseData(-123.789, initialValues: [('a', -double.maxFinite), ('zero', 0), ('null', null), ('one', 1.1), ('z', double.maxFinite)]),
    ];

List<TestCaseData<Decimal128>> decimal128TestValues() => [
      TestCaseData(Decimal128.parse('1.5')),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [('123', Decimal128.parse('123.123'))]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [('123', Decimal128.parse('-123.456'))]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [('a', Decimal128.parse('1.1')), ('b', Decimal128.parse('1.1')), ('c', Decimal128.parse('1.1'))]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [('a', Decimal128.parse('1')), ('b', Decimal128.parse('2.2')), ('c', Decimal128.parse('3.3'))]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [
        ('a', Decimal128.parse('1')),
        ('b', Decimal128.parse('2.2')),
        ('c', Decimal128.parse('3.3')),
        ('d', Decimal128.parse('43859489538793438693486934869.238436346943634634634634634634634634634593285932859238952398'))
      ]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [
        ('a', Decimal128.parse('-79228162514264337593543950335')),
        ('a1', Decimal128.parse('-79228162514264337593543950335')),
        ('z', Decimal128.parse('79228162514264337593543950335')),
        ('z1', Decimal128.parse('79228162514264337593543950335'))
      ]),
      TestCaseData(Decimal128.parse('1.5'), initialValues: [
        ('a', Decimal128.parse('-79228162514264337593543950335')),
        ('zero', Decimal128.parse('0')),
        ('one', Decimal128.parse('1.1')),
        ('z', Decimal128.parse('79228162514264337593543950335'))
      ]),
    ];

List<TestCaseData<Decimal128?>> nullableDecimal128TestValues() => [
      TestCaseData(null),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [('123', Decimal128.parse('123.123'))]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [('123', Decimal128.parse('-123.456'))]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [('null', null)]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [('null1', null), ('null2', null)]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [('a', Decimal128.parse('1')), ('b', null), ('c', Decimal128.parse('3.3'))]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [
        ('a', Decimal128.parse('1')),
        ('b', null),
        ('c', Decimal128.parse('3.3')),
        ('d', Decimal128.parse('43859489538793438693486934869.238436346943634634634634634634634634634593285932859238952398'))
      ]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [
        ('a', Decimal128.parse('-79228162514264337593543950335')),
        ('a1', Decimal128.parse('-79228162514264337593543950335')),
        ('m', null),
        ('z', Decimal128.parse('79228162514264337593543950335'))
      ]),
      TestCaseData(Decimal128.parse('-9.7'), initialValues: [
        ('a', Decimal128.parse('-79228162514264337593543950335')),
        ('zero', Decimal128.parse('0')),
        ('null', null),
        ('one', Decimal128.parse('1.1')),
        ('z', Decimal128.parse('79228162514264337593543950335'))
      ]),
    ];

DateTime date0 = DateTime(0).toUtc();
DateTime date1 = DateTime(1999, 3, 4, 5, 30, 23).toUtc();
DateTime date2 = DateTime(2030, 1, 3, 9, 25, 34).toUtc();

List<TestCaseData<DateTime>> dateTimeTestValues() => [
      TestCaseData(DateTime.now().toUtc()),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('123', date1)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('123', date2)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', date1), ('b', date1), ('c', date1)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', date0), ('b', date1), ('c', date2)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', DateTime.fromMillisecondsSinceEpoch(0).toUtc()), ('z', date2)]),
      TestCaseData(DateTime.now().toUtc(),
          initialValues: [('a', DateTime.fromMillisecondsSinceEpoch(0).toUtc()), ('zero', date1), ('one', date2), ('z', date2)]),
    ];

List<TestCaseData<DateTime?>> nullableDateTimeTestValues() => [
      TestCaseData(null),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('123', date1)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('123', date2)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('null', null)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('null1', null), ('null2', null)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', date0), ('b', null), ('c', date2)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', date2), ('b', null), ('c', date1), ('d', date0)]),
      TestCaseData(DateTime.now().toUtc(), initialValues: [('a', DateTime.fromMillisecondsSinceEpoch(0).toUtc()), ('m', null), ('z', date2)]),
      TestCaseData(DateTime.now().toUtc(),
          initialValues: [('a', DateTime.fromMillisecondsSinceEpoch(0).toUtc()), ('zero', date1), ('null', null), ('one', date2), ('z', date2)]),
    ];

ObjectId objectId0 = ObjectId.fromValues(987654321, 5, 1);
ObjectId objectId1 = ObjectId.fromValues(0, 0, 0);
ObjectId objectId2 = ObjectId.fromValues(987654321, 5, 2);
ObjectId objectId3 = ObjectId.fromValues(55555, 123, 1);

List<TestCaseData<ObjectId>> objectIdTestValues() => [
      TestCaseData(ObjectId()),
      TestCaseData(ObjectId(), initialValues: [('123', objectId1)]),
      TestCaseData(ObjectId(), initialValues: [('123', objectId2)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId1), ('b', objectId1), ('c', objectId1)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId0), ('b', objectId1), ('c', objectId2)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId0), ('z', objectId3)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId0), ('zero', objectId1), ('one', objectId2), ('z', objectId3)]),
    ];

List<TestCaseData<ObjectId?>> nullableObjectIdTestValues() => [
      TestCaseData(ObjectId()),
      TestCaseData(ObjectId(), initialValues: [('123', objectId1)]),
      TestCaseData(ObjectId(), initialValues: [('123', objectId2)]),
      TestCaseData(ObjectId(), initialValues: [('null', null)]),
      TestCaseData(ObjectId(), initialValues: [('null1', null), ('null2', null)]),
      TestCaseData(null, initialValues: [('a', objectId0), ('b', null), ('c', objectId2)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId2), ('b', null), ('c', objectId1), ('d', objectId0)]),
      TestCaseData(ObjectId(), initialValues: [('a', objectId0), ('m', null), ('z', objectId3)]),
      TestCaseData(null, initialValues: [('a', objectId0), ('zero', objectId1), ('null', null), ('one', objectId2), ('z', objectId3)]),
    ];

Uuid uuid0 = Uuid.fromString('48f11f3a-7609-471f-b7ab-81c20c723ed9');
Uuid uuid1 = Uuid.fromString('957ba4de-3966-46f6-b19f-242996608a8b');
Uuid uuid2 = Uuid.fromString('081924e2-8e62-4af1-bc9c-e1a7fc365d84');
Uuid uuid3 = Uuid.fromString('0bef5993-7480-4862-abdc-160bb364d1f3');

List<TestCaseData<Uuid>> uuidTestValues() => [
      TestCaseData(Uuid.v4()),
      TestCaseData(Uuid.v4(), initialValues: [('123', uuid1)]),
      TestCaseData(Uuid.v4(), initialValues: [('123', uuid2)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid1), ('b', uuid1), ('c', uuid1)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid0), ('b', uuid1), ('c', uuid2)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid0), ('z', uuid3)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid0), ('zero', uuid1), ('one', uuid2), ('z', uuid3)]),
    ];

List<TestCaseData<Uuid?>> nullableUuidTestValues() => [
      TestCaseData(Uuid.v4()),
      TestCaseData(Uuid.v4(), initialValues: [('123', uuid1)]),
      TestCaseData(Uuid.v4(), initialValues: [('123', uuid2)]),
      TestCaseData(Uuid.v4(), initialValues: [('null', null)]),
      TestCaseData(Uuid.v4(), initialValues: [('null1', null), ('null2', null)]),
      TestCaseData(null, initialValues: [('a', uuid0), ('b', null), ('c', uuid2)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid2), ('b', null), ('c', uuid1), ('d', uuid0)]),
      TestCaseData(Uuid.v4(), initialValues: [('a', uuid0), ('m', null), ('z', uuid3)]),
      TestCaseData(null, initialValues: [('a', uuid0), ('zero', uuid1), ('null', null), ('one', uuid2), ('z', uuid3)]),
    ];

Uint8List byteArray0 = Uint8List.fromList([1, 2, 3]);
Uint8List byteArray1 = Uint8List.fromList([4, 5, 6]);
Uint8List byteArray2 = Uint8List.fromList([7, 8, 9]);

List<TestCaseData<Uint8List>> byteArrayTestValues() => [
      TestCaseData(Uint8List.fromList([1, 2, 3]), equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('123', byteArray1)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('123', byteArray2)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [('a', byteArray1), ('b', byteArray1), ('c', byteArray1)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [('a', byteArray0), ('b', byteArray1), ('c', byteArray2)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [
            ('a', Uint8List.fromList([0])),
            ('z', Uint8List.fromList([255]))
          ],
          equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [
            ('a', byteArray0),
            ('zero', byteArray1),
            ('one', byteArray2),
            ('z', Uint8List.fromList([255]))
          ],
          equalityFunc: IterableEquality().equals),
    ];

List<TestCaseData<Uint8List?>> nullableByteArrayTestValues() => [
      TestCaseData(null),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('123', byteArray1)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('123', byteArray2)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('null', null)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]), initialValues: [('null1', null), ('null2', null)], equalityFunc: IterableEquality().equals),
      TestCaseData(null, initialValues: [('a', byteArray0), ('b', null), ('c', byteArray2)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [('a', byteArray2), ('b', null), ('c', byteArray1), ('d', byteArray0)], equalityFunc: IterableEquality().equals),
      TestCaseData(Uint8List.fromList([1, 2, 3]),
          initialValues: [
            ('a', byteArray0),
            ('m', null),
            ('z', Uint8List.fromList([255]))
          ],
          equalityFunc: IterableEquality().equals),
      TestCaseData(null,
          initialValues: [
            ('a', byteArray0),
            ('zero', byteArray1),
            ('null', null),
            ('one', byteArray2),
            ('z', Uint8List.fromList([255]))
          ],
          equalityFunc: IterableEquality().equals),
    ];

List<TestCaseData<RealmValue>> realmValueTestValues() => [
      TestCaseData(RealmValue.string('sampleValue'), initialValues: [
        ('nullKey', RealmValue.nullValue()),
        ('intKey', RealmValue.int(10)),
        ('boolKey', RealmValue.bool(true)),
        ('stringKey', RealmValue.string('abc')),
        ('dataKey', RealmValue.binary(Uint8List.fromList([0, 1, 2]))),
        ('dateKey', RealmValue.dateTime(DateTime.fromMillisecondsSinceEpoch(1616137641000).toUtc())),
        ('doubleKey', RealmValue.double(2.5)),
        ('decimalKey', RealmValue.decimal128(Decimal128.fromDouble(5.0))),
        ('objectIdKey', RealmValue.objectId(ObjectId.fromHexString('5f63e882536de46d71877979'))),
        ('guidKey', RealmValue.from(Uuid.fromString('F2952191-A847-41C3-8362-497F92CB7D24'))),
        ('objectKey', RealmValue.from(Car('Honda')))
      ])
    ];

List<TestCaseData<EmbeddedValue?>> _embeddedObjectTestValues() => [
      TestCaseData(null),
      TestCaseData(null,
          initialValues: [('123', EmbeddedValue(1))],
          equalityFunc: (a, b) => a?.intValue == b?.intValue,
          cloneFunc: (a) => a == null ? null : EmbeddedValue(a.intValue)),
      TestCaseData(EmbeddedValue(999),
          initialValues: [('123', EmbeddedValue(1))],
          equalityFunc: (a, b) => a?.intValue == b?.intValue,
          cloneFunc: (a) => a == null ? null : EmbeddedValue(a.intValue)),
      TestCaseData(EmbeddedValue(999),
          initialValues: [('null', null)], equalityFunc: (a, b) => a?.intValue == b?.intValue, cloneFunc: (a) => a == null ? null : EmbeddedValue(a.intValue)),
      TestCaseData(EmbeddedValue(999),
          initialValues: [('null1', null), ('null2', null)],
          equalityFunc: (a, b) => a?.intValue == b?.intValue,
          cloneFunc: (a) => a == null ? null : EmbeddedValue(a.intValue)),
      TestCaseData(EmbeddedValue(999),
          initialValues: [('a', EmbeddedValue(1)), ('null', null), ('z', EmbeddedValue(2))],
          equalityFunc: (a, b) => a?.intValue == b?.intValue,
          cloneFunc: (a) => a == null ? null : EmbeddedValue(a.intValue)),
    ];

@isTest
void testUnmanaged<T>(RealmMap<T> Function(TestRealmMaps) accessor, TestCaseData<T> testData) {
  test('$T unmanaged: $testData', () async {
    final testObject = TestRealmMaps(0);
    final map = accessor(testObject);

    testData.seed(map);

    await runTestsCore(testData, map, expectManaged: false);

    expect(() => map.freeze(), throwsA(isA<RealmStateError>()));
  });
}

@isTest
void testManaged<T>(RealmMap<T> Function(TestRealmMaps) accessor, TestCaseData<T> testData) {
  test('$T managed: $testData', () async {
    final testObject = TestRealmMaps(0);
    final map = accessor(testObject);

    testData.seed(map);

    final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(testObject);
    });

    final managedMap = accessor(testObject);
    expect(identical(map, managedMap), false);

    await runTestsCore(testData, managedMap, expectManaged: true);

    final frozen = managedMap.freeze();
    expect(frozen.isFrozen, true);

    final newKey = Uuid.v4().toString();
    realm.write(() {
      managedMap[newKey] = testData.sampleValue;
    });

    expect(frozen.length, managedMap.length - 1);
    expect(frozen[newKey], null);
    expect(frozen.containsKey(newKey), false);
    expect(() => frozen.changes, throwsA(isA<RealmStateError>()));
  });
}

@isTest
void testNotifications<T>(RealmMap<T> Function(TestRealmMaps) accessor, TestCaseData<T> testData) {
  test('$T notifications', () async {
    final testObject = TestRealmMaps(0);
    final map = accessor(testObject);

    testData.seed(map);

    final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(testObject);
    });

    final managedMap = accessor(testObject);
    await runManagedNotificationTests(testData, managedMap, testObject);
  });

  test('$T key notifications', () async {
    // TODO: for some reason, we don't appear to be getting key notifications: https://github.com/realm/realm-core/issues/7219
    final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
    final realm = getRealm(config);

    final map = realm.write(() {
      final testObject = realm.add(TestRealmMaps(0));
      return accessor(testObject);
    });

    final keysResults = map.keys as RealmResults<String>;
    expectLater(
        keysResults.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges<String>>().having((ch) => ch.inserted, 'inserted', <int>[]), // always an empty event on subscription
          isA<RealmResultsChanges<String>>().having((ch) => ch.inserted, 'inserted', [0]),
          isA<RealmResultsChanges<String>>().having((ch) => ch.inserted, 'inserted', [1]),
          isA<RealmResultsChanges<String>>().having((ch) => ch.deleted, 'deleted', [0]),
        ]));

    realm.write(() {
      map['a'] = testData.sampleValue;
    });
    realm.refresh();

    realm.write(() {
      map['b'] = testData.sampleValue;
    });
    realm.refresh();

    realm.write(() {
      map.remove('a');
    });
  }, skip: 'Key notifications are not working: https://github.com/realm/realm-core/issues/7219');

  test('$T value notifications', () async {
    final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
    final realm = getRealm(config);

    final map = realm.write(() {
      final testObject = realm.add(TestRealmMaps(0));
      return accessor(testObject);
    });

    final valueResults = map.values as RealmResults<T>;
    expectLater(
        valueResults.changes,
        emitsInOrder(<Matcher>[
          isA<RealmResultsChanges<T>>().having((ch) => ch.inserted, 'inserted', <int>[]), // always an empty event on subscription
          isA<RealmResultsChanges<T>>().having((ch) => ch.inserted, 'inserted', [0]),
          isA<RealmResultsChanges<T>>().having((ch) => ch.inserted, 'inserted', [1]),
          isA<RealmResultsChanges<T>>().having((ch) => ch.deleted, 'deleted', [0]),
        ]));

    realm.write(() {
      map['a'] = testData.sampleValue;
    });
    realm.refresh();

    realm.write(() {
      map['b'] = testData.sampleValue;
    });
    realm.refresh();

    realm.write(() {
      map.remove('a');
    });
  });
}

Future<void> runTestsCore<T>(TestCaseData<T> testData, RealmMap<T> map, {required bool expectManaged}) async {
  expect(map.isManaged, expectManaged);
  expect(map.isValid, true);

  testData.assertEquivalent(map);
  testData.assertContainsKey(map);
  testData.assertKeys(map);
  testData.assertValues(map);
  testData.assertEntries(map);
  testData.assertAccessor(map);
  testData.assertSet(map);
  testData.assertRemove(map);
}

Future<void> runManagedNotificationTests<T>(TestCaseData<T> testData, RealmMap<T> map, TestRealmMaps parent) async {
  final insertedKey = Uuid.v4().toString();
  final (keyToUpdate, _) = testData._getDifferentValue(map, testData.sampleValue);

  final changes = <RealmMapChanges<T>>[];
  final subscription = map.changes.listen((change) {
    changes.add(change);
  });

  var expectedCallbacks = 0;

  Future<RealmMapChanges<T>> waitForChanges(({List<String> inserted, List<String> modified, List<String> deleted})? expected) async {
    expectedCallbacks++;

    map.realm.refresh();

    await waitForCondition(() => changes.length == expectedCallbacks);
    final result = changes[expectedCallbacks - 1];
    if (expected != null) {
      expect(result.inserted, expected.inserted);
      expect(result.modified, expected.modified);
      expect(result.deleted, expected.deleted);
      expect(result.isCleared, false);
      expect(result.isCollectionDeleted, false);
    }

    return result;
  }

  // Initial callback
  await waitForChanges((inserted: [], modified: [], deleted: []));

  // Insert
  map.realm.write(() {
    map[insertedKey] = testData.sampleValue;
  });

  await waitForChanges((inserted: [insertedKey], modified: [], deleted: []));

  // Modify
  map.realm.write(() {
    map[keyToUpdate] = testData.sampleValue;
  });

  await waitForChanges((inserted: [], modified: [keyToUpdate], deleted: []));

  // Delete
  map.realm.write(() {
    map.remove(keyToUpdate);
  });

  await waitForChanges((inserted: [], modified: [], deleted: [keyToUpdate]));

  // Stop listening
  subscription.cancel();

  expect(changes.length, expectedCallbacks);

  map.realm.write(() {
    map[Uuid.v4().toString()] = testData.sampleValue;
  });

  map.realm.refresh();

  // We shouldn't have received a notification
  expect(changes.length, expectedCallbacks);

  final subscription2 = map.changes.listen((change) {
    changes.add(change);
  });

  // Initial callback
  await waitForChanges((inserted: [], modified: [], deleted: []));

  final preClearMapSize = map.length;
  map.realm.write(() {
    map.clear();
  });

  // Cleared callback
  final clearedChange = await waitForChanges(null);
  expect(clearedChange.isCleared, true);
  expect(clearedChange.isCollectionDeleted, false);
  expect(clearedChange.deleted.length, preClearMapSize);

  parent.realm.write(() {
    parent.realm.delete(parent);
  });

  // Deleted callback
  final deletedChange = await waitForChanges(null);
  expect(deletedChange.isCleared, false);
  expect(deletedChange.isCollectionDeleted, true);

  subscription2.cancel();
}

@isTest
void runTests<T>(List<TestCaseData<T>> Function() testGetter, RealmMap<T> Function(TestRealmMaps) accessor) {
  group('$T test cases', () {
    for (var test in testGetter()) {
      testUnmanaged(accessor, test);
      testManaged(accessor, test);
    }
  });

  group('notifications', () {
    testNotifications(accessor, testGetter().last);

    test('key notifications', () {});
  });
}

final List<({String key, String errorFragment})> invalidKeys = [
  (key: '.', errorFragment: "must not contain '.'"),
  (key: '\$', errorFragment: "must not start with '\$'"),
  (key: '\$foo', errorFragment: "must not start with '\$'"),
  (key: 'foo.bar', errorFragment: "must not contain '.'"),
  (key: 'foo.', errorFragment: "must not contain '.'")
];

void main() {
  setupTests();

  group('key validation', () {
    for (final testData in invalidKeys) {
      test('Invalid key: ${testData.key}', () {
        final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
        final realm = getRealm(config);

        realm.write(() {
          final testObject = realm.add(TestRealmMaps(0));
          expect(() => testObject.stringMap[testData.key] = 'value',
              throwsA(isA<RealmException>().having((e) => e.message, 'message', contains(testData.errorFragment))));

          final unmanaged = TestRealmMaps(1);
          unmanaged.stringMap[testData.key] = 'value';

          expect(() => realm.add(unmanaged), throwsA(isA<RealmException>().having((e) => e.message, 'message', contains(testData.errorFragment))));
        });
      });
    }

    for (final key in [r'a$', r'a$$$$$$$$$', r'_$_$_']) {
      test('key may contain \$: $key', () {
        final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
        final realm = getRealm(config);

        realm.write(() {
          final testObject = realm.add(TestRealmMaps(0));
          testObject.stringMap[key] = 'value';
        });
      });
    }
  });

  group('queries', () {
    test('invalid predicate', () {
      final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
      final realm = getRealm(config);
      final map = realm.write(() => realm.add(TestRealmMaps(0))).objectsMap;

      expect(() => map.query('invalid predicate'), throwsA(isA<RealmException>().having((e) => e.message, 'message', contains('Invalid predicate'))));
    });

    test('invalid number of arguments', () {
      final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
      final realm = getRealm(config);
      final map = realm.write(() => realm.add(TestRealmMaps(0))).objectsMap;

      expect(() => map.query(r'make = $0'),
          throwsA(isA<RealmException>().having((e) => e.message, 'message', contains('Request for argument at index 0 but no arguments are provided'))));
    });

    test('unmanaged dictionary throws', () {
      final map = TestRealmMaps(0).objectsMap;
      expect(() => map.query('query'), throwsA(isA<RealmStateError>()));
    });

    test('can be filtered', () {
      final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
      final realm = getRealm(config);
      final map = realm.write(() => realm.add(TestRealmMaps(0))).objectsMap;

      final filtered = map.query(r'make BEGINSWITH $0', ['A']);
      realm.write(() {
        map['a'] = Car('Acura');
        map['b'] = Car('BMW');
        map['c'] = Car('Astra');
      });

      expect(filtered.length, 2);
      expect(filtered.firstWhereOrNull((element) => element.make == 'BMW'), isNull);
    });

    test('can be sorted', () {
      final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
      final realm = getRealm(config);
      final map = realm.write(() => realm.add(TestRealmMaps(0))).objectsMap;

      final filtered = map.query(r'make BEGINSWITH[c] $0 SORT(make desc)', ['A']);
      realm.write(() {
        map['a'] = Car('aaaa');
        map['b'] = Car('azzz');
        map['c'] = Car('abbb');
      });

      expect(filtered.length, 3);
      expect(filtered.map((e) => e.make), ['azzz', 'abbb', 'aaaa']);
    });

    test('raises notifications', () {
      final config = Configuration.local([TestRealmMaps.schema, Car.schema, EmbeddedValue.schema]);
      final realm = getRealm(config);
      final map = realm.write(() => realm.add(TestRealmMaps(0))).objectsMap;

      expectLater(
          map.query('TRUEPREDICATE SORT(make asc)').changes,
          emitsInOrder(<Matcher>[
            isA<RealmResultsChanges<Car>>().having((ch) => ch.inserted, 'inserted', <int>[]), // always an empty event on subscription
            isA<RealmResultsChanges<Car>>().having((ch) => ch.inserted, 'inserted', [0]),
            isA<RealmResultsChanges<Car>>().having((ch) => ch.modified, 'modified', [0]),
            isA<RealmResultsChanges<Car>>().having((ch) => ch.inserted, 'inserted', [1]),
            isA<RealmResultsChanges<Car>>().having((ch) => ch.deleted, 'deleted', [0]),
          ]));

      realm.write(() {
        map['a'] = Car('aaaa');
      });
      realm.refresh();

      realm.write(() {
        map['a']!.color = 'some color';
      });
      realm.refresh();

      realm.write(() {
        map['b'] = Car('bbbb');
      });
      realm.refresh();

      realm.write(() {
        map.remove('a');
      });
      realm.refresh();
    });
  });

  runTests(boolTestValues, (e) => e.boolMap);
  runTests(nullableBoolTestValues, (e) => e.nullableBoolMap);

  runTests(intTestCases, (e) => e.intMap);
  runTests(nullableIntTestCases, (e) => e.nullableIntMap);

  runTests(stringTestValues, (e) => e.stringMap);
  runTests(nullableStringTestValues, (e) => e.nullableStringMap);

  runTests(doubleTestValues, (e) => e.doubleMap);
  runTests(nullableDoubleTestValues, (e) => e.nullableDoubleMap);

  // Something sinister is going on when setting up these tests on Android,
  if (!Platform.isAndroid) {
    runTests(decimal128TestValues, (e) => e.decimalMap);
    runTests(nullableDecimal128TestValues, (e) => e.nullableDecimalMap);
  }

  runTests(dateTimeTestValues, (e) => e.dateTimeMap);
  runTests(nullableDateTimeTestValues, (e) => e.nullableDateTimeMap);

  runTests(objectIdTestValues, (e) => e.objectIdMap);
  runTests(nullableObjectIdTestValues, (e) => e.nullableObjectIdMap);

  runTests(uuidTestValues, (e) => e.uuidMap);
  runTests(nullableUuidTestValues, (e) => e.nullableUuidMap);

  runTests(byteArrayTestValues, (e) => e.binaryMap);
  runTests(nullableByteArrayTestValues, (e) => e.nullableBinaryMap);

  runTests(realmValueTestValues, (e) => e.mixedMap);

  runTests(_embeddedObjectTestValues, (e) => e.embeddedMap);
}
