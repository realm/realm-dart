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
library;

import 'dart:convert';

import 'package:ejson/ejson.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';
import 'package:test/test.dart';

import 'person.dart';

void _testCase<T>(T value, EJsonValue expected) {
  test('encode from $value of type $T', () {
    expect(toEJson(value), expected);
  });

  test('encode fluent from $value of type $T', () {
    expect(value.toEJson(), expected);
  });

  test('decode to $value of type $T', () {
    expect(fromEJson<T>(expected), value);
  });

  test('roundtrip $value of type $T', () {
    expect(fromEJson<T>(toEJson(value)), value);
  });

  test('reverse roundtrip $value of type $T', () {
    expect(toEJson(fromEJson<T>(expected)), expected);
  });

  test('roundtrip $value of type $T as String', () {
    expect(
      fromEJson<T>(
        jsonDecode(jsonEncode(toEJson(value))), // roundtrip as String
      ),
      value,
    );
  });

  test('decode to dynamic', () {
    // no <T> here, so dynamic
    expect(() => fromEJson(expected), returnsNormally);
  });

  if (value is! Defined) {
    test('roundtrip $value of type $T as dynamic', () {
      // no <T> here, so dynamic
      expect(fromEJson(toEJson(value)), value);
    });

    test('reverse roundtrip $value of type $T as dynamic', () {
      // no <T> here, so dynamic
      expect(toEJson(fromEJson(expected)), expected);
    });
  }
}

class Dummy {}

void _invalidTestCase<T>([EJsonValue ejson = const {}]) {
  test('decode $T from invalid ejson: $ejson', () {
    expect(() => fromEJson<T>(ejson), throwsA(isA<InvalidEJson>().having((e) => e.toString(), 'toString', 'Invalid EJson for $T: $ejson')));
  });
}

void main() {
  test('fluent encoding', () {
    // NOTE: These cannot be handled generically, as we want to hit the correct
    // extension method, ie. not the fallback on Object?.
    expect(null.toEJson(), toEJson(null));
    expect(1.toEJson(), toEJson(1));
    expect(1.0.toEJson(), toEJson(1.0));
    expect('a'.toEJson(), toEJson('a'));
    expect(true.toEJson(), toEJson(true));
    expect(false.toEJson(), toEJson(false));
    expect([1, 2, 3].toEJson(), toEJson([1, 2, 3]));
    expect({'a': 1, 'b': 2}.toEJson(), toEJson({'a': 1, 'b': 2}));
    expect(DateTime(1974, 4, 10, 2, 42, 12, 202).toEJson(), toEJson(DateTime(1974, 4, 10, 2, 42, 12, 202)));
    expect((#sym).toEJson(), toEJson(#sym));
    expect(Key.max.toEJson(), toEJson(Key.max));
    expect(Key.min.toEJson(), toEJson(Key.min));
    expect(undefined.toEJson(), toEJson(undefined));
    expect(const Undefined<int?>().toEJson(), toEJson(const Undefined<int?>()));
    expect(Undefined<int?>().toEJson(), toEJson(Undefined<int?>()));
    expect(const Defined<int?>(42).toEJson(), toEJson(const Defined<int?>(42)));
    expect(const Defined<int?>(null).toEJson(), toEJson(const Defined<int?>(null)));
    expect(ObjectId.fromValues(1, 2, 3).toEJson(), toEJson(ObjectId.fromValues(1, 2, 3)));
    final uuid = Uuid.v4();
    expect(uuid.toEJson(), toEJson(uuid));
    final bytes = uuid.bytes.asUint8List();
    expect(bytes.toEJson(), toEJson(bytes));
  });

  test('missing encoder', () {
    expect(
        () => toEJson(Dummy()), throwsA(isA<MissingEncoder>().having((e) => e.toString(), 'toString', "Missing encoder for type Dummy (Instance of 'Dummy')")));
  });

  group('invalid', () {
    _invalidTestCase<bool>();
    _invalidTestCase<DateTime>();
    _invalidTestCase<double>({'\$numberDouble': 'foobar'});
    _invalidTestCase<double>();
    _invalidTestCase<int>();
    _invalidTestCase<Key>();
    _invalidTestCase<List<int>>();
    _invalidTestCase<Map<int, int>>([]);
    _invalidTestCase<Null>();
    _invalidTestCase<num>();
    _invalidTestCase<ObjectId>();
    _invalidTestCase<Person>();
    _invalidTestCase<String>();
    _invalidTestCase<Symbol>();
    _invalidTestCase<Undefined<int>>();
    _invalidTestCase<Uuid>();

    test('missing decoder', () {
      expect(() => fromEJson<Dummy>({}), throwsA(isA<MissingDecoder>().having((e) => e.toString(), 'toString', 'Missing decoder for Dummy')));
    });
  });

  for (final canonical in [true, false]) {
    group(canonical ? 'canonical' : 'relaxed', () {
      setUp(() => relaxed = !canonical);

      group('common types', () {
        final time = DateTime(1974, 4, 10, 2, 42, 12, 202); // no microseconds!

        _testCase(null, null);
        _testCase(1, canonical ? {'\$numberLong': '1'} : 1);
        _testCase(1.0, canonical ? {'\$numberDouble': '1.0'} : 1.0);
        _testCase(double.infinity, {'\$numberDouble': 'Infinity'});
        _testCase(double.negativeInfinity, {'\$numberDouble': '-Infinity'});
        _testCase('a', 'a');
        _testCase(true, true);
        _testCase(false, false);
        _testCase(
          [1, 2, 3],
          canonical
              ? [
                  {'\$numberLong': '1'},
                  {'\$numberLong': '2'},
                  {'\$numberLong': '3'},
                ]
              : [1, 2, 3],
        );
        _testCase(
          [1, 1.1],
          canonical
              ? [
                  {'\$numberLong': '1'},
                  {'\$numberDouble': '1.1'},
                ]
              : [1, 1.1],
        );
        _testCase(
          [1, null, 3],
          canonical
              ? [
                  {'\$numberLong': '1'},
                  null,
                  {'\$numberLong': '3'},
                ]
              : [1, null, 3],
        );
        _testCase(
          {'a': 'abe', 'b': 1},
          canonical
              ? {
                  'a': 'abe',
                  'b': {'\$numberLong': '1'},
                }
              : {'a': 'abe', 'b': 1},
        );
        _testCase(
          time,
          canonical
              ? {
                  '\$date': {'\$numberLong': time.millisecondsSinceEpoch.toString()}
                }
              : {'\$date': time.toIso8601String()},
        );
        _testCase(#sym, {'\$symbol': 'sym'});
        _testCase(Key.max, {'\$maxKey': 1});
        _testCase(Key.min, {'\$minKey': 1});
        _testCase(undefined, {'\$undefined': 1});
        _testCase(const Undefined<int?>(), {'\$undefined': 1});
        _testCase(Undefined<int?>(), {'\$undefined': 1});
        _testCase(const Defined<int?>(42), canonical ? {'\$numberLong': '42'} : 42);
        _testCase(const Defined<int?>(null), null);
        _testCase(Defined<int?>(42), canonical ? {'\$numberLong': '42'} : 42);
        _testCase(Defined<int?>(null), null);
        _testCase(ObjectId.fromValues(1, 2, 3), {'\$oid': '000000000000000002000003'});
        final uuid = Uuid.v4();
        _testCase(uuid, {
          '\$binary': {'base64': base64.encode(uuid.bytes.asUint8List()), 'subType': '04'}
        });
        // a complex nested generic type
        _testCase<Map<String, Map<String, List<num?>?>>>(
          {
            'a': {
              'b': null,
              'c': [1, 1.1, null]
            }
          },
          canonical
              ? {
                  'a': {
                    'b': null,
                    'c': [
                      {'\$numberLong': '1'},
                      {'\$numberDouble': '1.1'},
                      null
                    ]
                  }
                }
              : {
                  'a': {
                    'b': null,
                    'c': [1, 1.1, null]
                  }
                },
        );

        test('UndefinedOr', () {
          UndefinedOr<int?> x = Undefined();
          expect(x.toEJson(), {'\$undefined': 1});

          x = Defined(42);
          expect(x.toEJson(), relaxed ? 42 : {'\$numberLong': '42'});

          x = Defined(null);
          expect(x.toEJson(), isNull);

          expect(
            fromEJson<UndefinedOr<int?>>({'\$undefined': 1}),
            const Undefined<int?>(),
          );

          expect(
            fromEJson<UndefinedOr<int?>>({'\$numberLong': '42'}),
            Defined<int?>(42),
          );

          expect(fromEJson<UndefinedOr<int?>>(null), Defined<int?>(null));
        });

        test('NaN', () {
          expect(toEJson(double.nan), {'\$numberDouble': 'NaN'});
          expect(fromEJson<double>({'\$numberDouble': 'NaN'}), isNaN);
        });
      });

      group('custom types', () {
        register(encodePerson, decodePerson);

        final person = Person(
          'John',
          DateTime(1974),
          80000,
          spouse: Person('Jane', DateTime(1973), 90000),
        );

        _testCase(
          person,
          canonical
              ? {
                  'name': 'John',
                  'birthDate': {
                    '\$date': {'\$numberLong': '126226800000'}
                  },
                  'income': {'\$numberDouble': '80000.0'},
                  'spouse': {
                    'name': 'Jane',
                    'birthDate': {
                      '\$date': {'\$numberLong': '94690800000'}
                    },
                    'income': {'\$numberDouble': '90000.0'},
                    'spouse': null
                  }
                }
              : {
                  'name': 'John',
                  'birthDate': {'\$date': '1974-01-01T00:00:00.000'},
                  'income': 80000.0,
                  'spouse': {
                    'name': 'Jane',
                    'birthDate': {'\$date': '1973-01-01T00:00:00.000'},
                    'income': 90000.0,
                    'spouse': null
                  }
                },
        );
        _testCase<Map<String, Person>>(
          {'a': person},
          canonical
              ? {
                  'a': {
                    'name': 'John',
                    'birthDate': {
                      '\$date': {'\$numberLong': '126226800000'}
                    },
                    'income': {'\$numberDouble': '80000.0'},
                    'spouse': {
                      'name': 'Jane',
                      'birthDate': {
                        '\$date': {'\$numberLong': '94690800000'}
                      },
                      'income': {'\$numberDouble': '90000.0'},
                      'spouse': null
                    }
                  }
                }
              : {
                  'a': {
                    'name': 'John',
                    'birthDate': {'\$date': '1974-01-01T00:00:00.000'},
                    'income': 80000.0,
                    'spouse': {
                      'name': 'Jane',
                      'birthDate': {'\$date': '1973-01-01T00:00:00.000'},
                      'income': 90000.0,
                      'spouse': null
                    }
                  }
                },
        );
      });
    });
  }
}
