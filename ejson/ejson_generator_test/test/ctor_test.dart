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

import 'package:ejson/ejson.dart';
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
  String s;
  @ejson
  Named.nameIt(this.s);
}

class RequiredNamedParameters {
  final String s;
  @ejson
  const RequiredNamedParameters({required this.s});
}

class OptionalNamedParameters {
  String s;
  @ejson
  OptionalNamedParameters({this.s = 'rabbit'});
}

class OptionalParameters {
  String s;
  @ejson
  OptionalParameters([this.s = 'racoon']);
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

void _testCase<T>(T value, EJsonValue expected) {
  test('encode $T to $expected', () {
    expect(toEJson(value), expected);
  });

  test('decode $expected to $T', () {
    expect(() => fromEJson<T>(expected), returnsNormally);
  });

  test('roundtrip $expected as $T', () {
    expect(toEJson(fromEJson<T>(expected)), expected);
  });

  test('roundtrip $expected of type $T as dynamic', () {
    // no <T> here, so dynamic
    expect(toEJson(fromEJson(expected)), expected);
  });
}

void main() {
  group('ctors', () {
    register(encodeEmpty, decodeEmpty);
    register(encodeSimple, decodeSimple);
    register(encodeNamed, decodeNamed);
    register(encodeRequiredNamedParameters, decodeRequiredNamedParameters);
    register(encodeOptionalNamedParameters, decodeOptionalNamedParameters);
    register(encodeOptionalParameters, decodeOptionalParameters);
    register(encodePrivateMembers, decodePrivateMembers);
    register(encodePerson, decodePerson);

    _testCase(const Empty(), {});
    _testCase(const Simple(42), {
      'i': {'\$numberLong': 42}
    });
    _testCase(Named.nameIt('foobar'), {'s': 'foobar'});
    _testCase(const RequiredNamedParameters(s: 'foobar'), {'s': 'foobar'});
    _testCase(OptionalNamedParameters(), {'s': 'rabbit'});
    _testCase(OptionalParameters(), {'s': 'racoon'});
    _testCase(const PrivateMembers(42), {
      'id': {'\$numberLong': 42}
    });
    _testCase(Person('Eva', DateTime(1973), 90000.0), {
      'name': 'Eva',
      'birthDate': {
        '\$date': {'\$numberLong': 94690800000}
      },
      'income': {'\$numberDouble': 90000.0},
      'spouse': null,
      'cprNumber': null,
    });
  });
}
