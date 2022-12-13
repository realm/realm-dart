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

import 'dart:math';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_value_test.g.dart';

@RealmModel()
class _AnythingGoes {
  @Indexed()
  late RealmValue oneAny;
  late List<RealmValue> manyAny;
}

void main() {
  group('RealmValue', () {
    final now = DateTime.now().toUtc();
    final values = <Object?>[
      null,
      true,
      'text',
      42,
      3.14,
      AnythingGoes(),
      now,
      ObjectId.fromTimestamp(now),
      Uuid.v4(),
    ];

    final config = Configuration.inMemory([AnythingGoes.schema]);
    final realm = getRealm(config);

    for (final x in values) {
      test('Roundtrip ${x.runtimeType} $x', () {
        final something = realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.from(x))));
        expect(something.oneAny.value, x);
        expect(something.oneAny, RealmValue.from(x));
      });
    }

    test('Illegal value', () {
      expect(() => realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.from(<int>[1, 2])))), throwsArgumentError);
    });

    for (final x in values) {
      test('Switch $x', () {
        final something = AnythingGoes(oneAny: RealmValue.from(x));
        final value = something.oneAny.value;
        switch (something.oneAny.type) {
          case Null:
            expect(value, isA<void>());
            break;
          case bool:
            expect(value, isA<bool>());
            break;
          case String:
            expect(value, isA<String>());
            break;
          case int:
            expect(value, isA<int>());
            break;
          case double:
            expect(value, isA<double>());
            break;
          case AnythingGoes: // RealmObject won't work with switch
            expect(value, isA<AnythingGoes>());
            expect(value, isA<RealmObject>());
            break;
          case DateTime:
            expect(value, isA<DateTime>());
            break;
          case ObjectId:
            expect(value, isA<ObjectId>());
            break;
          case Uuid:
            expect(value, isA<Uuid>());
            break;
          default:
            fail('${something.oneAny} not handled correctly in switch');
        }
      });
    }

    for (final x in values) {
      test('If-is $x', () {
        final something = AnythingGoes(oneAny: RealmValue.from(x));
        final value = something.oneAny.value;
        final type = something.oneAny.type;
        if (value == null) {
          expect(type, Null);
        } else if (value is int) {
          expect(type, int);
        } else if (value is String) {
          expect(type, String);
        } else if (value is bool) {
          expect(type, bool);
        } else if (value is double) {
          expect(type, double);
        } else if (value is DateTime) {
          expect(type, DateTime);
        } else if (value is Uuid) {
          expect(type, Uuid);
        } else if (value is ObjectId) {
          expect(type, ObjectId);
        } else if (value is AnythingGoes) {
          expect(type, AnythingGoes);
        } else {
          fail('$value not handled correctly in if-is');
        }
      });
    }
  });

  group('List<RealmValue>', () {
    final now = DateTime.now().toUtc();
    final values = <Object?>[
      null,
      true,
      'text',
      42,
      3.14,
      AnythingGoes(),
      now,
      ObjectId.fromTimestamp(now),
      Uuid.v4(),
    ];

    final config = Configuration.inMemory([AnythingGoes.schema]);
    final realm = getRealm(config);

    test('Roundtrip', () {
      final something = realm.write(() => realm.add(AnythingGoes(manyAny: values.map(RealmValue.from))));
      expect(something.manyAny.map((e) => e.value), values);
      expect(something.manyAny, values.map(RealmValue.from));
//      expect(something.manyAny.cast<Object>(), [true, 42]);
    });
  });
}
