// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:ejson/ejson.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

part 'ctor_test.g.dart';

class Empty {
  @ejson
  const Empty();
}

class Simple {
  final int i;
  @ejson
  const Simple(this.i);
}

class Named {
  String namedCtor;
  @ejson
  Named.nameIt(this.namedCtor);
}

class RequiredNamedParameters {
  final String requiredNamed;
  @ejson
  const RequiredNamedParameters({required this.requiredNamed});
}

class OptionalNamedParameters {
  String optionalNamed;
  @ejson
  OptionalNamedParameters({this.optionalNamed = 'rabbit'});
}

class OptionalParameters {
  String optional;
  @ejson
  OptionalParameters([this.optional = 'racoon']);
}

class PrivateMembers {
  final int _id;

  int get id => _id; // must match constructor parameter name

  @ejson
  const PrivateMembers(int id) : _id = id; // instead of @MapTo
}

class Person {
  final String name;
  final DateTime birthDate;
  Duration get age => DateTime.now().difference(birthDate);

  final int? cprNumber;
  final double income;
  final Person? spouse;

  final children = <Person>[];

  @ejson // annotate constructor to generate decoder and encoder
  Person(this.name, this.birthDate, this.income, {this.spouse, this.cprNumber});
}

@isTest
void _testCase<T>(T value, EJsonValue expected) {
  test('encode $T to $expected', () {
    expect(toEJson(value), expected);
  });

  test('decode $expected to $T', () {
    expect(() => fromEJson<T>(expected), returnsNormally);
  });

  EJsonValue badInput = {'bad': 'input'};
  badInput = value is Map ? [badInput] : badInput; // wrap in list for maps
  test('decode $badInput to $T fails', () {
    expect(() => fromEJson<T>(badInput), throwsA(isA<InvalidEJson>()));
  });

  test('roundtrip $expected as $T', () {
    expect(toEJson(fromEJson<T>(expected)), expected);
  });

  test('roundtrip $expected of type $T as dynamic', () {
    // no <T> here, so dynamic
    final decoded = fromEJson<dynamic>(expected);
    expect(decoded, isA<T>());
    expect(toEJson(decoded), expected);
  });
}

void main() {
  group('ctors', () {
    registerEmpty();
    registerSimple();
    registerNamed();
    registerRequiredNamedParameters();
    registerOptionalNamedParameters();
    registerOptionalParameters();
    registerPrivateMembers();
    registerPerson();

    _testCase(const Empty(), {});
    _testCase(const Simple(42), {
      'i': {'\$numberInt': '42'}
    });
    _testCase(Named.nameIt('foobar'), {'namedCtor': 'foobar'});
    _testCase(const RequiredNamedParameters(requiredNamed: 'foobar'), {'requiredNamed': 'foobar'});
    _testCase(OptionalNamedParameters(), {'optionalNamed': 'rabbit'});
    _testCase(OptionalParameters(), {'optional': 'racoon'});
    _testCase(const PrivateMembers(42), {
      'id': {'\$numberInt': '42'}
    });

    final birthDate = DateTime.utc(1973);
    _testCase(Person('Eva', DateTime.utc(1973), 90000.0), {
      'name': 'Eva',
      'birthDate': {
        '\$date': {'\$numberLong': birthDate.millisecondsSinceEpoch.toString()}
      },
      'income': {'\$numberDouble': '90000.0'},
      'spouse': null,
      'cprNumber': null,
    });
  });
}
