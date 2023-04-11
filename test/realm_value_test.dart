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

import 'dart:io';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'realm_value_test.g.dart';

@RealmModel(ObjectType.embeddedObject)
class _TuckedIn {
  int x = 42;
}

@RealmModel()
class _AnythingGoes {
  @Indexed()
  late RealmValue oneAny;
  late List<RealmValue> manyAny;
}

@RealmModel()
class _Stuff {
  int i = 42;
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  group('RealmValue', () {
    final now = DateTime.now().toUtc();
    final values = <Object?>[
      null,
      true,
      'text',
      42,
      3.14,
      AnythingGoes(),
      Stuff(),
      now,
      ObjectId.fromTimestamp(now),
      Uuid.v4(),
    ];

    for (final x in values) {
      test('Roundtrip ${x.runtimeType} $x', () {
        final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
        final realm = getRealm(config);
        final something = realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.from(x))));
        expect(something.oneAny.type, x.runtimeType);
        expect(something.oneAny.value, x);
        expect(something.oneAny, RealmValue.from(x));
      });
    }

    test('Illegal value', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      expect(() => realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.from(<int>[1, 2])))), throwsArgumentError);
    });

    test('Embedded object not allowed in RealmValue', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      expect(() => realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.from(TuckedIn())))), throwsArgumentError);
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
            break;
          case Stuff: // RealmObject won't work with switch
            expect(value, isA<Stuff>());
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
        } else if (value is Stuff) {
          expect(type, Stuff);
        } else {
          fail('$value not handled correctly in if-is');
        }
      });
    }

    test('Unknown schema for RealmValue.value after bad migration', () {
      {
        final config = Configuration.local([AnythingGoes.schema, Stuff.schema], schemaVersion: 0);
        Realm.deleteRealm(config.path);
        final realm = Realm(config);

        final something = realm.write(() => realm.add(AnythingGoes(oneAny: RealmValue.realmObject(Stuff()))));
        expect(something.oneAny, isA<RealmValue>());
        expect(something.oneAny.value, isA<Stuff>());
        expect(something.oneAny.as<Stuff>().i, 42);

        realm.close();
      }

      // From here on Stuff is unknown
      final config = Configuration.local(
        [AnythingGoes.schema],
        schemaVersion: 1,
        migrationCallback: (migration, oldSchemaVersion) {
          // forget to handle RealmValue pointing to Stuff
        },
      );
      final realm = getRealm(config);

      final something = realm.all<AnythingGoes>()[0];
      // something.oneAny points to a Stuff, but that is not known, so returns null.
      // A better option would be to return a DynamicRealmObject, but c-api does
      // not currently allow this.
      expect(something.oneAny, const RealmValue.nullValue()); // at least we don't crash :-)
    });
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
      Stuff(),
      now,
      ObjectId.fromTimestamp(now),
      Uuid.v4(),
    ];

    final config = Configuration.local([AnythingGoes.schema, Stuff.schema]);
    final realm = getRealm(config);

    test('Roundtrip', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      final something = realm.write(() => realm.add(AnythingGoes(manyAny: values.map(RealmValue.from))));
      expect(something.manyAny.map((e) => e.value), values);
      expect(something.manyAny, values.map(RealmValue.from));
    });
  });
}
