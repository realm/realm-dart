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

import 'dart:typed_data';

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
  // TODO: @Indexed() - depends on https://github.com/realm/realm-core/issues/7246
  late RealmValue oneAny;
  late List<RealmValue> manyAny;
  late Map<String, RealmValue> dictOfAny;
  late Set<RealmValue> setOfAny;
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
      Decimal128.fromDouble(128.128),
      Uint8List.fromList([1, 2, 0])
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

        // Uint8List can not be in the switch
        if (something.oneAny.type == Uint8List(0).runtimeType) {
          expect(value, isA<Uint8List>());
          return;
        }

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
          case Decimal128:
            expect(value, isA<Decimal128>());
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
        } else if (value is Decimal128) {
          expect(type, Decimal128);
        } else if (value is Uint8List) {
          expect(type, Uint8List(0).runtimeType);
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
      Decimal128.fromInt(128),
    ];

    test('Roundtrip', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      final something = realm.write(() => realm.add(AnythingGoes(manyAny: values.map(RealmValue.from))));
      expect(something.manyAny.map((e) => e.value), values);
      expect(something.manyAny, values.map(RealmValue.from));
    });
  });

  test('Query with list of realm values in arguments', () {
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
      Decimal128.fromInt(128),
    ];
    final config = Configuration.local([AnythingGoes.schema, Stuff.schema]);
    final realm = getRealm(config);
    final realmValues = values.map(RealmValue.from);
    realm.write(() => realm.add(AnythingGoes(manyAny: realmValues, oneAny: realmValues.last)));

    var results = realm.query<AnythingGoes>("manyAny IN \$0", [values]);
    expect(results.first.manyAny, realmValues);

    results = realm.query<AnythingGoes>("oneAny IN \$0", [values]);
    expect(results.first.oneAny, realmValues.last);
  });

  group('Collections in RealmValue', () {
    test('Set<RealmValue> throws', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      final list = RealmValue.list([RealmValue.from(5)]);
      final map = RealmValue.map({'a': RealmValue.from('abc')});

      final obj = AnythingGoes();
      expect(() => obj.setOfAny.add(list), throws<RealmStateError>());
      expect(() => obj.setOfAny.add(map), throws<RealmStateError>());

      realm.write(() => realm.add(obj));

      realm.write(() {
        expect(() => obj.setOfAny.add(list), throws<RealmStateError>());
        expect(() => obj.setOfAny.add(map), throws<RealmStateError>());
      });
    });

    test('List get and set', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      final list = RealmValue.list([RealmValue.from(5)]);

      final obj = AnythingGoes(oneAny: list);
      expect(obj.oneAny.value, isA<List<RealmValue>>());
      expect(obj.oneAny.asList().length, 1);
      expect(obj.oneAny.asList().single.value, 5);

      realm.write(() {
        realm.add(obj);
      });

      final foundObj = realm.all<AnythingGoes>().single;
      expect(foundObj.oneAny.value, isA<List<RealmValue>>());
      final foundList = foundObj.oneAny.asList();
      expect(foundList.length, 1);
      expect(foundList[0].value, 5);

      realm.write(() {
        foundList.add(RealmValue.from('abc'));
      });

      expect(obj.oneAny.asList()[1].value, 'abc');
    });

    test('Map get and set', () {
      final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
      final realm = getRealm(config);
      final map = RealmValue.from({'foo': 5});

      final obj = AnythingGoes(oneAny: map);
      expect(obj.oneAny.value, isA<Map<String, RealmValue>>());
      expect(obj.oneAny.asMap().length, 1);
      expect(obj.oneAny.asMap()['foo']!.value, 5);

      realm.write(() {
        realm.add(obj);
      });

      final foundObj = realm.all<AnythingGoes>().single;
      expect(foundObj.oneAny.value, isA<Map<String, RealmValue>>());
      final foundMap = foundObj.oneAny.asMap();
      expect(foundMap.length, 1);
      expect(foundMap['foo']!.value, 5);

      realm.write(() {
        foundMap['bar'] = RealmValue.from('abc');
      });

      expect(obj.oneAny.asMap()['bar']!.value, 'abc');
    });

    for (var isManaged in [true, false]) {
      final managedString = isManaged ? 'managed' : 'unmanaged';
      RealmValue _persistAndFind(RealmValue rv, Realm realm) {
        if (isManaged) {
          realm.write(() {
            realm.add(AnythingGoes(oneAny: rv));
          });

          return realm.all<AnythingGoes>().first.oneAny;
        }

        return rv;
      }

      test('List when $managedString works with all types', () {
        final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
        final realm = getRealm(config);
        final originalList = [
          null,
          1,
          true,
          'string',
          DateTime(1999, 3, 4, 5, 30, 23).toUtc(),
          2.3,
          Decimal128.parse('1.23456789'),
          ObjectId.fromHexString('5f63e882536de46d71877979'),
          Uuid.fromString('3809d6d9-7618-4b3d-8044-2aa35fd02f31'),
          Uint8List.fromList([1, 2, 0]),
          Stuff(i: 123),
          [5, 'abc'],
          {'int': -10, 'string': 'abc'}
        ];
        final foundValue = _persistAndFind(RealmValue.from(originalList), realm);
        expect(foundValue.value, isA<List<RealmValue>>());

        final foundList = foundValue.asList();
        expect(foundList.length, originalList.length);

        // Last 3 elements are objects/collections, so they are treated specially
        final primitiveCount = originalList.length - 3;
        for (var i = 0; i < primitiveCount; i++) {
          expect(foundList[i].value, originalList[i]);
        }

        final storedObj = foundList[primitiveCount];
        expect(storedObj.value, isA<Stuff>());
        expect(storedObj.as<Stuff>().isManaged, isManaged);
        expect(storedObj.as<Stuff>().i, 123);

        final storedList = foundList[primitiveCount + 1];
        expect(storedList.value, isA<List<RealmValue>>());
        expect(storedList.asList().length, 2);
        expect(storedList.asList()[0].value, 5);
        expect(storedList.asList()[1].value, 'abc');

        final storedDict = foundList[primitiveCount + 2];
        expect(storedDict.value, isA<Map<String, RealmValue>>());
        expect(storedDict.asMap().length, 2);
        expect(storedDict.asMap()['int']!.value, -10);
        expect(storedDict.asMap()['string']!.value, 'abc');
        expect(storedDict.asMap()['non-existent'], null);
      });

      test('Map when $managedString works with all types', () {
        final config = Configuration.local([AnythingGoes.schema, Stuff.schema, TuckedIn.schema]);
        final realm = getRealm(config);
        final originalMap = {
          'primitive_null': null,
          'primitive_int': 1,
          'primitive_bool': true,
          'primitive_string': 'string',
          'primitive_date': DateTime(1999, 3, 4, 5, 30, 23).toUtc(),
          'primitive_double': 2.3,
          'primitive_decimal': Decimal128.parse('1.23456789'),
          'primitive_objectId': ObjectId.fromHexString('5f63e882536de46d71877979'),
          'primitive_uuid': Uuid.fromString('3809d6d9-7618-4b3d-8044-2aa35fd02f31'),
          'primitive_binary': Uint8List.fromList([1, 2, 0]),
          'object': Stuff(i: 123),
          'list': [5, 'abc'],
          'map': {'int': -10, 'string': 'abc'}
        };
        final foundValue = _persistAndFind(RealmValue.from(originalMap), realm);
        expect(foundValue.value, isA<Map<String, RealmValue>>());

        final foundMap = foundValue.asMap();
        expect(foundMap.length, foundMap.length);

        for (var key in originalMap.keys.where((k) => k.startsWith('primitive_'))) {
          expect(foundMap[key]!.value, originalMap[key]);
        }

        final storedObj = foundMap['object']!;
        expect(storedObj.value, isA<Stuff>());
        expect(storedObj.as<Stuff>().isManaged, isManaged);
        expect(storedObj.as<Stuff>().i, 123);

        final storedList = foundMap['list']!;
        expect(storedList.value, isA<List<RealmValue>>());
        expect(storedList.asList().length, 2);
        expect(storedList.asList()[0].value, 5);
        expect(storedList.asList()[1].value, 'abc');

        final storedDict = foundMap['map']!;
        expect(storedDict.value, isA<Map<String, RealmValue>>());
        expect(storedDict.asMap().length, 2);
        expect(storedDict.asMap()['int']!.value, -10);
        expect(storedDict.asMap()['string']!.value, 'abc');
        expect(storedDict.asMap()['non-existent'], null);
      });
    }
  });
}
