// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:typed_data';

import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';

import 'test.dart';

part 'realm_value_test.realm.dart';

@RealmModel(ObjectType.embeddedObject)
class _TuckedIn {
  int x = 42;
}

void main() {
  setupTests();

  Realm getMixedRealm() {
    final config = Configuration.local([ObjectWithRealmValue.schema, ObjectWithInt.schema, TuckedIn.schema]);
    return getRealm(config);
  }

  Future<Realm> logInAndGetSyncedRealm(AppConfiguration appConfig, ObjectId differentiator) async {
    final realm = await getIntegrationRealm(appConfig: appConfig, differentiator: differentiator);
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<ObjectWithRealmValue>(r'differentiator = $0', [differentiator]));
      mutableSubscriptions.add(realm.query<ObjectWithInt>(r'differentiator = $0', [differentiator]));
    });
    await realm.subscriptions.waitForSynchronization();

    return realm;
  }

  Future<(Realm, Realm)> logInAndGetSyncedRealms(AppConfiguration appConfig, ObjectId differentiator) async {
    final realm1 = await logInAndGetSyncedRealm(appConfig, differentiator);
    final realm2 = await logInAndGetSyncedRealm(appConfig, differentiator);
    expect(realm1.all<ObjectWithRealmValue>().isEmpty, true);
    expect(realm2.all<ObjectWithRealmValue>().isEmpty, true);

    return (realm1, realm2);
  }

  Future<void> waitForSynchronization({required Realm uploadRealm, required Realm downloadRealm}) async {
    await uploadRealm.syncSession.waitForUpload();
    await downloadRealm.syncSession.waitForDownload();
  }

  group('RealmValue', () {
    final primitiveValues = [
      null,
      true,
      'text',
      42,
      3.14,
      DateTime.utc(2024, 5, 3, 23, 11, 54),
      ObjectId.fromHexString('64c13ab08edf48a008793cac'),
      Uuid.fromString('7a459a5e-5eb6-45f6-9b72-8f794e324105'),
      Decimal128.fromDouble(128.128),
      Uint8List.fromList([1, 2, 0])
    ];

    for (final x in primitiveValues) {
      test('Roundtrip ${x.runtimeType} $x', () {
        final realm = getMixedRealm();
        final something = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(x))));
        expect(something.oneAny.value.runtimeType, x.runtimeType);
        expect(something.oneAny.value, x);
        expect(something.oneAny, RealmValue.from(x));
      });

      baasTest('Roundtrip ${x.runtimeType} $x', (appConfig) async {
        final differentiator = ObjectId();
        final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

        // Add object in first realm.
        final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, oneAny: RealmValue.from(x));
        realm1.write(() => realm1.add(object));

        await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

        // Check object values in second realm.
        final syncedObject = realm2.all<ObjectWithRealmValue>().single;
        expect(syncedObject.id, object.id);
        expect(syncedObject.oneAny.value.runtimeType, x.runtimeType);
        expect(syncedObject.oneAny.value, x);
        expect(syncedObject.oneAny, RealmValue.from(x));
      });

      final queryArg = RealmValue.from(x);
      test('Query @type == ${queryArg.type} $x', () {
        final realm = getMixedRealm();
        realm.write(() {
          // Add all values, we're going to query for just one of them.
          for (final v in primitiveValues) {
            realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(v)));
          }
          realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(ObjectWithInt(ObjectId()))));
        });

        final matches = realm.query<ObjectWithRealmValue>(r'oneAny.@type == $0', [queryArg.type]);
        expect(matches.length, 1);
        expect(matches.single.oneAny.value, x);
        expect(matches.single.oneAny.type, queryArg.type);
        expect(matches.single.oneAny, queryArg);
      });
    }

    test('Roundtrip object', () {
      final stuff = ObjectWithInt(ObjectId(), i: 123);
      final realm = getMixedRealm();
      final something = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(stuff))));
      expect(something.oneAny.value.runtimeType, ObjectWithInt);
      expect(something.oneAny.as<ObjectWithInt>().i, 123);
    });

    baasTest('Roundtrip object', (appConfig) async {
      final differentiator = ObjectId();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final child = ObjectWithInt(ObjectId(), differentiator: differentiator, i: 123);
      final parent = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, oneAny: RealmValue.from(child));
      realm1.write(() => realm1.add(parent));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Check object values in second realm.
      expect(realm2.all<ObjectWithInt>().single.i, 123);
      final syncedParent = realm2.all<ObjectWithRealmValue>().single;
      expect(syncedParent.id, parent.id);

      expect(syncedParent.oneAny.value.runtimeType, ObjectWithInt);
      final syncedChild = syncedParent.oneAny.as<ObjectWithInt>();
      expect(syncedChild.i, 123);

      // Update child object in second realm.
      const newValue = 456;
      realm2.write(() => syncedChild.i = newValue);

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

      // Check updated object in first realm.
      expect(parent.oneAny.as<ObjectWithInt>().i, newValue);
    });

    test('Query @type == object', () {
      final realm = getMixedRealm();
      realm.write(() {
        for (final v in primitiveValues) {
          realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(v)));
        }

        realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(ObjectWithInt(ObjectId(), i: 123))));
      });

      final matches = realm.query<ObjectWithRealmValue>(r'oneAny.@type == $0', [RealmValueType.object]);
      expect(matches.length, 1);
      expect(matches.single.oneAny.as<ObjectWithInt>().i, 123);
      expect(matches.single.oneAny.type, RealmValueType.object);
    });

    test('Illegal value', () {
      final realm = getMixedRealm();
      expect(() => realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(realm)))), throwsArgumentError);
    });

    test('Embedded object not allowed in RealmValue', () {
      final realm = getMixedRealm();
      expect(() => realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(TuckedIn())))), throwsArgumentError);
    });

    for (final x in primitiveValues) {
      test('Switch $x', () {
        final something = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(x));
        final value = something.oneAny.value;

        switch (something.oneAny.type) {
          case RealmValueType.nullValue:
            expect(value, isA<void>());
            break;
          case RealmValueType.boolean:
            expect(value, isA<bool>());
            break;
          case RealmValueType.string:
            expect(value, isA<String>());
            break;
          case RealmValueType.int:
            expect(value, isA<int>());
            break;
          case RealmValueType.double:
            expect(value, isA<double>());
            break;
          case RealmValueType.object:
            expect(value is ObjectWithRealmValue || value is ObjectWithInt, true);
            break;
          case RealmValueType.dateTime:
            expect(value, isA<DateTime>());
            break;
          case RealmValueType.objectId:
            expect(value, isA<ObjectId>());
            break;
          case RealmValueType.uuid:
            expect(value, isA<Uuid>());
            break;
          case RealmValueType.decimal:
            expect(value, isA<Decimal128>());
            break;
          case RealmValueType.binary:
            expect(value, isA<Uint8List>());
            break;
          case RealmValueType.list:
          case RealmValueType.map:
            fail('List and map should not be tested here.');
        }
      });
    }

    for (final x in primitiveValues) {
      test('If-is $x', () {
        final something = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(x));
        final value = something.oneAny.value;
        final type = something.oneAny.type;
        if (value == null) {
          expect(type, RealmValueType.nullValue);
        } else if (value is int) {
          expect(type, RealmValueType.int);
        } else if (value is String) {
          expect(type, RealmValueType.string);
        } else if (value is bool) {
          expect(type, RealmValueType.boolean);
        } else if (value is double) {
          expect(type, RealmValueType.double);
        } else if (value is DateTime) {
          expect(type, RealmValueType.dateTime);
        } else if (value is Uuid) {
          expect(type, RealmValueType.uuid);
        } else if (value is ObjectId) {
          expect(type, RealmValueType.objectId);
        } else if (value is Decimal128) {
          expect(type, RealmValueType.decimal);
        } else if (value is Uint8List) {
          expect(type, RealmValueType.binary);
        } else if (value is ObjectWithRealmValue) {
          expect(type, RealmValueType.object);
        } else if (value is ObjectWithInt) {
          expect(type, RealmValueType.object);
        } else {
          fail('$value not handled correctly in if-is');
        }
      });
    }

    test('Unknown schema for RealmValue.value after bad migration', () {
      {
        final config = Configuration.local([ObjectWithRealmValue.schema, ObjectWithInt.schema], schemaVersion: 0);
        Realm.deleteRealm(config.path);
        final realm = Realm(config);

        final object = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.realmObject(ObjectWithInt(ObjectId())));
        final something = realm.write(() => realm.add(object));
        expect(something.oneAny, isA<RealmValue>());
        expect(something.oneAny.value, isA<ObjectWithInt>());
        expect(something.oneAny.as<ObjectWithInt>().i, 42);

        realm.close();
      }

      // From here on Stuff is unknown
      final config = Configuration.local(
        [ObjectWithRealmValue.schema],
        schemaVersion: 1,
        migrationCallback: (migration, oldSchemaVersion) {
          // forget to handle RealmValue pointing to Stuff
        },
      );
      final realm = getRealm(config);

      final something = realm.all<ObjectWithRealmValue>()[0];
      // something.oneAny points to a Stuff, but that is not known, so returns null.
      // A better option would be to return a DynamicRealmObject, but c-api does
      // not currently allow this.
      expect(something.oneAny, const RealmValue.nullValue()); // at least we don't crash :-)
    });
  });

  group('List<RealmValue>', () {
    final differentiator = ObjectId();
    List<Object?> getValues() {
      final now = DateTime.now().toUtc();
      return [
        null,
        true,
        'text',
        42,
        3.14,
        ObjectWithRealmValue(ObjectId(), differentiator: differentiator),
        ObjectWithInt(ObjectId(), differentiator: differentiator),
        now,
        ObjectId.fromTimestamp(now),
        Uuid.v4(),
        Decimal128.fromInt(128),
      ];
    }

    test('Roundtrip', () {
      final values = getValues();
      final realm = getMixedRealm();
      final something = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), manyAny: values.map(RealmValue.from))));
      expect(something.manyAny.map((e) => e.value), values);
      expect(something.manyAny, values.map(RealmValue.from));
    });

    baasTest('Roundtrip', (appConfig) async {
      final values = getValues();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, manyAny: values.map(RealmValue.from));
      realm1.write(() => realm1.add(object));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Check object values in second realm.
      expect(realm2.all<ObjectWithInt>().single.i, 42);
      expect(realm2.all<ObjectWithRealmValue>().length, 2);
      final syncedObject = realm2.query<ObjectWithRealmValue>(r'_id == $0', [object.id]).single;
      expect(syncedObject.manyAny.length, values.length);
      expect(syncedObject.manyAny[0].value, values[0]);

      // Add new item in second realm.
      const newValue = 'new value';
      realm2.write(() => syncedObject.manyAny.add(RealmValue.from(newValue)));

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

      // Check new item in first realm.
      expect(object.manyAny.length, values.length + 1);
      expect(object.manyAny.last.value, newValue);
    });

    test('Query with list of realm values in arguments', () {
      final values = getValues();
      final realm = getMixedRealm();
      final realmValues = values.map(RealmValue.from);
      realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), manyAny: realmValues, oneAny: realmValues.last)));

      var results = realm.query<ObjectWithRealmValue>("manyAny IN \$0", [values]);
      expect(results.first.manyAny, realmValues);

      results = realm.query<ObjectWithRealmValue>("oneAny IN \$0", [values]);
      expect(results.first.oneAny, realmValues.last);
    });
  });

  group('Set<RealmValue>', () {
    final numericValues = [RealmValue.int(0), RealmValue.double(0.0), RealmValue.bool(false), RealmValue.decimal128(Decimal128.zero), RealmValue.nullValue()];

    test('With numeric values', () {
      final realm = getMixedRealm();
      final obj = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId()))..setOfAny.addAll(numericValues));

      expect(obj.setOfAny, unorderedMatches([RealmValue.int(0), RealmValue.bool(false), RealmValue.nullValue()]));
    });

    baasTest('With numeric values', (appConfig) async {
      final differentiator = ObjectId();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator);
      realm1.write(() => realm1.add(object)..setOfAny.addAll(numericValues));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Check object values in second realm.
      final syncedObject = realm2.all<ObjectWithRealmValue>().single;
      expect(syncedObject.id, object.id);
      expect(syncedObject.setOfAny, unorderedMatches([RealmValue.int(0), RealmValue.bool(false), RealmValue.nullValue()]));
    });

    test('Removes duplicates', () {
      final realm = getMixedRealm();
      final values = [
        RealmValue.int(1),
        RealmValue.nullValue(),
        RealmValue.double(2.0),
        RealmValue.string('abc'),
        RealmValue.nullValue(),
        RealmValue.string('abc')
      ];
      final obj = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId()))..setOfAny.addAll(values));

      expect(obj.setOfAny, unorderedMatches([RealmValue.int(1), RealmValue.double(2.0), RealmValue.nullValue(), RealmValue.string('abc')]));
    });
  });

  group('Collections in RealmValue', () {
    void expectMatches(RealmValue actual, Object? expected) {
      switch (actual.collectionType) {
        case RealmCollectionType.list:
          expect(expected, isList);
          final actualList = actual.asList();
          final expectedList = expected as List;
          expect(actualList, hasLength(expectedList.length));
          for (var i = 0; i < expectedList.length; i++) {
            expectMatches(actualList[i], expectedList[i]);
          }
          break;
        case RealmCollectionType.map:
          expect(expected, isMap);
          final actualMap = actual.asMap();
          final expectedMap = expected as Map<String, dynamic>;
          expect(actualMap, hasLength(expectedMap.length));
          for (String key in expectedMap.keys) {
            expect(actualMap.containsKey(key), true, reason: "Didn't find $key in the actual map");
            expectMatches(actualMap[key]!, expectedMap[key]);
          }
          break;
        default:
          expect(actual, RealmValue.from(expected));
          break;
      }
    }

    test('Set<RealmValue> throws', () {
      final realm = getMixedRealm();
      final list = RealmValue.list([RealmValue.from(5)]);
      final map = RealmValue.map({'a': RealmValue.from('abc')});

      final obj = ObjectWithRealmValue(ObjectId());
      expect(() => obj.setOfAny.add(list), throws<RealmStateError>());
      expect(() => obj.setOfAny.add(map), throws<RealmStateError>());

      realm.write(() => realm.add(obj));

      realm.write(() {
        expect(() => obj.setOfAny.add(list), throws<RealmStateError>());
        expect(() => obj.setOfAny.add(map), throws<RealmStateError>());
      });
    });

    test('List get and set', () {
      final realm = getMixedRealm();
      final list = RealmValue.from([5]);

      final obj = ObjectWithRealmValue(ObjectId(),
        oneAny: list,
        manyAny: [list],
        dictOfAny: {'value': list});

      expect(obj.oneAny.value, isA<List<RealmValue>>());
      expect(obj.oneAny.asList().length, 1);
      expect(obj.oneAny.asList().single.value, 5);

      expect(obj.manyAny[0].value, isA<List<RealmValue>>());
      expect(obj.manyAny[0].asList().length, 1);
      expect(obj.manyAny[0].asList().single.value, 5);

      expect(obj.dictOfAny['value']!.value, isA<List<RealmValue>>());
      expect(obj.dictOfAny['value']!.asList().length, 1);
      expect(obj.dictOfAny['value']!.asList().single.value, 5);

      realm.write(() {
        realm.add(obj);
      });

      final foundObj = realm.all<ObjectWithRealmValue>().single;
      expect(foundObj.oneAny.value, isA<List<RealmValue>>());
      expect(foundObj.oneAny.asList().length, 1);
      expect(foundObj.oneAny.asList()[0].value, 5);

      expect(foundObj.manyAny[0].value, isA<List<RealmValue>>());
      expect(foundObj.manyAny[0].asList().length, 1);
      expect(foundObj.manyAny[0].asList()[0].value, 5);

      expect(foundObj.dictOfAny['value']!.value, isA<List<RealmValue>>());
      expect(foundObj.dictOfAny['value']!.asList().length, 1);
      expect(foundObj.dictOfAny['value']!.asList()[0].value, 5);

      realm.write(() {
        foundObj.oneAny.asList().add(RealmValue.from('abc'));
        foundObj.manyAny[0].asList().add(RealmValue.from('abc'));
        foundObj.dictOfAny['value']!.asList().add(RealmValue.from('abc'));
      });

      expect(obj.oneAny.asList()[1].value, 'abc');
      expect(obj.manyAny[0].asList()[1].value, 'abc');
      expect(obj.dictOfAny['value']!.asList()[1].value, 'abc');
    });

    baasTest('List get and set', (appConfig) async {
      final differentiator = ObjectId();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final list = RealmValue.from([5]);
      final object = ObjectWithRealmValue(ObjectId(),
        differentiator: differentiator,
        oneAny: list,
        manyAny: [list],
        dictOfAny: {'value': list});
      realm1.write(() => realm1.add(object));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Check object values in second realm.
      final syncedObject = realm2.all<ObjectWithRealmValue>().single;
      expect(syncedObject.id, object.id);
      expect(syncedObject.oneAny.value, isA<List<RealmValue>>());
      expect(syncedObject.oneAny.asList().length, 1);
      expect(syncedObject.oneAny.asList().single.value, 5);

      expect(syncedObject.manyAny[0].value, isA<List<RealmValue>>());
      expect(syncedObject.manyAny[0].asList().length, 1);
      expect(syncedObject.manyAny[0].asList().single.value, 5);

      expect(syncedObject.dictOfAny['value']!.value, isA<List<RealmValue>>());
      expect(syncedObject.dictOfAny['value']!.asList().length, 1);
      expect(syncedObject.dictOfAny['value']!.asList().single.value, 5);

      // Add new items in second realm.
      realm2.write(() {
        syncedObject.oneAny.asList().add(RealmValue.from('abc'));
        syncedObject.manyAny[0].asList().add(RealmValue.from('abc'));
        syncedObject.dictOfAny['value']!.asList().add(RealmValue.from('abc'));
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

      // Check new items in first realm.
      expect(object.oneAny.asList()[1].value, 'abc');
      expect(object.manyAny[0].asList()[1].value, 'abc');
      expect(object.dictOfAny['value']!.asList()[1].value, 'abc');
    });

    test('Map get and set', () {
      final realm = getMixedRealm();
      final map = RealmValue.from({'foo': 5});

      final obj = ObjectWithRealmValue(ObjectId(), oneAny: map, manyAny: [map], dictOfAny: {'value': map});
      expect(obj.oneAny.value, isA<Map<String, RealmValue>>());
      expect(obj.oneAny.asMap().length, 1);
      expect(obj.oneAny.asMap()['foo']!.value, 5);

      expect(obj.manyAny[0].value, isA<Map<String, RealmValue>>());
      expect(obj.manyAny[0].asMap().length, 1);
      expect(obj.manyAny[0].asMap()['foo']!.value, 5);

      expect(obj.dictOfAny['value']!.value, isA<Map<String, RealmValue>>());
      expect(obj.dictOfAny['value']!.asMap().length, 1);
      expect(obj.dictOfAny['value']!.asMap()['foo']!.value, 5);

      realm.write(() {
        realm.add(obj);
      });

      final foundObj = realm.all<ObjectWithRealmValue>().single;
      expect(foundObj.oneAny.value, isA<Map<String, RealmValue>>());
      expect(foundObj.oneAny.asMap().length, 1);
      expect(foundObj.oneAny.asMap()['foo']!.value, 5);

      expect(foundObj.manyAny[0].value, isA<Map<String, RealmValue>>());
      expect(foundObj.manyAny[0].asMap().length, 1);
      expect(foundObj.manyAny[0].asMap()['foo']!.value, 5);

      expect(foundObj.dictOfAny['value']!.value, isA<Map<String, RealmValue>>());
      expect(foundObj.dictOfAny['value']!.asMap().length, 1);
      expect(foundObj.dictOfAny['value']!.asMap()['foo']!.value, 5);

      realm.write(() {
        foundObj.oneAny.asMap()['bar'] = RealmValue.from('abc');
        foundObj.manyAny[0].asMap()['bar'] = RealmValue.from('abc');
        foundObj.dictOfAny['value']!.asMap()['bar'] = RealmValue.from('abc');
      });

      expect(obj.oneAny.asMap()['bar']!.value, 'abc');
      expect(obj.manyAny[0].asMap()['bar']!.value, 'abc');
      expect(obj.dictOfAny['value']!.asMap()['bar']!.value, 'abc');
    });

    baasTest('Map get and set', (appConfig) async {
      final differentiator = ObjectId();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final map = RealmValue.from({'foo': 5});
      final object = ObjectWithRealmValue(ObjectId(),
        differentiator: differentiator,
        oneAny: map,
        manyAny: [map],
        dictOfAny: {'value': map});
      realm1.write(() => realm1.add(object));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Check object values in second realm.
      final syncedObject = realm2.all<ObjectWithRealmValue>().single;
      expect(syncedObject.id, object.id);
      expect(object.oneAny.value, isA<Map<String, RealmValue>>());
      expect(object.oneAny.asMap().length, 1);
      expect(object.oneAny.asMap()['foo']!.value, 5);

      expect(object.manyAny[0].value, isA<Map<String, RealmValue>>());
      expect(object.manyAny[0].asMap().length, 1);
      expect(object.manyAny[0].asMap()['foo']!.value, 5);

      expect(object.dictOfAny['value']!.value, isA<Map<String, RealmValue>>());
      expect(object.dictOfAny['value']!.asMap().length, 1);
      expect(object.dictOfAny['value']!.asMap()['foo']!.value, 5);

      // Add new items in second realm.
      realm2.write(() {
        syncedObject.oneAny.asMap()['bar'] = RealmValue.from('abc');
        syncedObject.manyAny[0].asMap()['bar'] = RealmValue.from('abc');
        syncedObject.dictOfAny['value']!.asMap()['bar'] = RealmValue.from('abc');
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

      // Check new items in first realm.
      expect(object.oneAny.asMap()['bar']!.value, 'abc');
      expect(object.manyAny[0].asMap()['bar']!.value, 'abc');
      expect(object.dictOfAny['value']!.asMap()['bar']!.value, 'abc');
    });

    for (var isManaged in [true, false]) {
      final managedString = isManaged ? 'managed' : 'unmanaged';
      RealmValue persistIfNecessary(RealmValue rv, Realm realm) {
        if (isManaged) {
          realm.write(() {
            realm.add(ObjectWithRealmValue(ObjectId(), oneAny: rv));
          });

          return realm.all<ObjectWithRealmValue>().first.oneAny;
        }

        return rv;
      }

      void writeIfNecessary(Realm realm, void Function() func) {
        if (isManaged) {
          realm.write(() => func());
        } else {
          func();
        }
      }

      List<Object?> getListAllTypes({ObjectId? differentiator}) {
        return [
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
          ObjectWithInt(ObjectId(), differentiator: differentiator, i: 123),
          [5, 'abc'],
          {'int': -10, 'string': 'abc'}
        ];
      }

      test('List when $managedString works with all types', () {
        final realm = getMixedRealm();
        final originalList = getListAllTypes();
        final foundValue = persistIfNecessary(RealmValue.from(originalList), realm);
        expect(foundValue.value, isA<List<RealmValue>>());
        expect(foundValue.type, RealmValueType.list);

        final foundList = foundValue.asList();
        expect(foundList.length, originalList.length);

        // Last 3 elements are objects/collections, so they are treated specially
        final primitiveCount = originalList.length - 3;
        for (var i = 0; i < primitiveCount; i++) {
          expect(foundList[i].value, originalList[i]);
        }

        final storedObj = foundList[primitiveCount];
        expect(storedObj.value, isA<ObjectWithInt>());
        expect(storedObj.as<ObjectWithInt>().isManaged, isManaged);
        expect(storedObj.as<ObjectWithInt>().i, 123);

        final storedList = foundList[primitiveCount + 1];
        expectMatches(storedList, [5, 'abc']);

        final storedDict = foundList[primitiveCount + 2];
        expectMatches(storedDict, {'int': -10, 'string': 'abc'});
        expect(storedDict.asMap()['non-existent'], null);
      });

      // This test only needs to run once, but it's placed
      // here to be collocated with the above test.
      if (isManaged) {
        baasTest('List works with all types', (appConfig) async {
          final differentiator = ObjectId();
          final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

          // Add object in first realm.
          final originalList = getListAllTypes(differentiator: differentiator);
          final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, oneAny: RealmValue.from(originalList));
          realm1.write(() => realm1.add(object));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check object values in second realm.
          final syncedObject = realm2.all<ObjectWithRealmValue>().single;
          expect(syncedObject.id, object.id);

          final foundValue = syncedObject.oneAny;
          expect(foundValue.value, isA<List<RealmValue>>());
          expect(foundValue.type, RealmValueType.list);

          final foundList = foundValue.asList();
          expect(foundList.length, originalList.length);

          // Last 3 elements are objects/collections, so they are treated specially.
          final primitiveCount = originalList.length - 3;
          for (var i = 0; i < primitiveCount; i++) {
            expect(foundList[i].value, originalList[i]);
          }

          final storedObjIndex = primitiveCount;
          final storedObj = foundList[storedObjIndex];
          expect(storedObj.value, isA<ObjectWithInt>());
          expect(storedObj.as<ObjectWithInt>().isManaged, true);
          expect(storedObj.as<ObjectWithInt>().i, 123);

          final storedListIndex = primitiveCount + 1;
          final storedList = foundList[storedListIndex];
          expectMatches(storedList, [5, 'abc']);

          final storedDictIndex = primitiveCount + 2;
          final storedDict = foundList[storedDictIndex];
          expectMatches(storedDict, {'int': -10, 'string': 'abc'});
          expect(storedDict.asMap()['non-existent'], null);

          // Update and add items in second realm.
          realm2.write(() {
            storedObj.as<ObjectWithInt>().i = 456;
            storedList.asList()[0] = RealmValue.from('updated');
            storedList.asList().add(RealmValue.from('new-value'));
            storedDict.asMap()['string'] = RealmValue.from('updated');
            storedDict.asMap()['new-value'] = RealmValue.from('new-value');
          });

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check updated items in first realm.
          final list = object.oneAny.asList();
          expect(list[storedObjIndex].as<ObjectWithInt>().i, 456);
          expectMatches(list[storedListIndex], ['updated', 'abc', 'new-value']);
          expectMatches(list[storedDictIndex], {'int': -10, 'string': 'updated', 'new-value': 'new-value'});
        });
      }

      test('List when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from([true, 5.3]));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        expect(obj.oneAny.type, RealmValueType.list);
        expectMatches(obj.oneAny, [true, 5.3]);

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from(['foo']));
        expectMatches(obj.oneAny, ['foo']);

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from(999));
        expectMatches(obj.oneAny, 999);

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from({'int': -100}));
        expectMatches(obj.oneAny, {'int': -100});
      });

      if (isManaged) {
        baasTest('List can be reassigned', (appConfig) async {
          final differentiator = ObjectId();
          final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

          // Add object in first realm.
          final object = ObjectWithRealmValue(ObjectId(),
            differentiator: differentiator,
            oneAny: RealmValue.from([true, 5.3]));
          realm1.write(() => realm1.add(object));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check object values in second realm.
          final syncedObject = realm2.all<ObjectWithRealmValue>().single;
          expect(syncedObject.oneAny.type, RealmValueType.list);
          expectMatches(syncedObject.oneAny, [true, 5.3]);

          // Reassign value in second realm.
          realm2.write(() => syncedObject.oneAny = RealmValue.from(['foo']));

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check and reassign new value in first realm.
          expectMatches(object.oneAny, ['foo']);
          realm1.write(() => object.oneAny = RealmValue.from(999));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check and reassign new value in second realm.
          expectMatches(syncedObject.oneAny, 999);
          realm2.write(() => syncedObject.oneAny = RealmValue.from({'int': -100}));

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check new value in first realm.
          expectMatches(syncedObject.oneAny, {'int': -100});
        });
      }

      Map<String, Object?> getDictAllTypes({ObjectId? differentiator}) {
        return {
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
          'object': ObjectWithInt(ObjectId(), differentiator: differentiator, i: 123),
          'list': [5, 'abc'],
          'map': {'int': -10, 'string': 'abc'}
        };
      }

      test('Map when $managedString works with all types', () {
        final realm = getMixedRealm();
        final originalMap = getDictAllTypes();
        final foundValue = persistIfNecessary(RealmValue.from(originalMap), realm);
        expect(foundValue.value, isA<Map<String, RealmValue>>());
        expect(foundValue.type, RealmValueType.map);

        final foundMap = foundValue.asMap();
        expect(foundMap.length, foundMap.length);

        final primitiveKeys = originalMap.keys.where((k) => k.startsWith('primitive_'));
        for (var key in primitiveKeys) {
          expect(foundMap[key]!.value, originalMap[key]);
        }

        final storedObj = foundMap['object']!;
        expect(storedObj.value, isA<ObjectWithInt>());
        expect(storedObj.as<ObjectWithInt>().isManaged, isManaged);
        expect(storedObj.as<ObjectWithInt>().i, 123);

        final storedList = foundMap['list']!;
        expectMatches(storedList, [5, 'abc']);

        final storedDict = foundMap['map']!;
        expectMatches(storedDict, {'int': -10, 'string': 'abc'});
      });

      // This test only needs to run once, but it's placed
      // here to be collocated with the above test.
      if (isManaged) {
        baasTest('Map works with all types', (appConfig) async {
          final differentiator = ObjectId();
          final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

          // Add object in first realm.
          final originalMap = getDictAllTypes(differentiator: differentiator);
          final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, oneAny: RealmValue.from(originalMap));
          realm1.write(() => realm1.add(object));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check object values in second realm.
          final syncedObject = realm2.all<ObjectWithRealmValue>().single;
          expect(syncedObject.id, object.id);

          final foundValue = syncedObject.oneAny;
          expect(foundValue.value, isA<Map<String, RealmValue>>());
          expect(foundValue.type, RealmValueType.map);

          final foundMap = foundValue.asMap();
          expect(foundMap.length, foundMap.length);

          final primitiveKeys = originalMap.keys.where((k) => k.startsWith('primitive_'));
          for (var key in primitiveKeys) {
            expect(foundMap[key]!.value, originalMap[key]);
          }

          final storedObj = foundMap['object']!;
          expect(storedObj.value, isA<ObjectWithInt>());
          expect(storedObj.as<ObjectWithInt>().isManaged, isManaged);
          expect(storedObj.as<ObjectWithInt>().i, 123);

          final storedList = foundMap['list']!;
          expectMatches(storedList, [5, 'abc']);

          final storedDict = foundMap['map']!;
          expectMatches(storedDict, {'int': -10, 'string': 'abc'});

          // Update and add items in second realm.
          realm2.write(() {
            storedObj.as<ObjectWithInt>().i = 456;
            storedList.asList()[0] = RealmValue.from('updated');
            storedList.asList().add(RealmValue.from('new-value'));
            storedDict.asMap()['string'] = RealmValue.from('updated');
            storedDict.asMap()['new-value'] = RealmValue.from('new-value');
          });

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check updated items in first realm.
          final map = object.oneAny.asMap();
          expect(map['object']?.as<ObjectWithInt>().i, 456);
          expectMatches(map['list']!, ['updated', 'abc', 'new-value']);
          expectMatches(map['map']!, {'int': -10, 'string': 'updated', 'new-value': 'new-value'});
        });
      }

      test('Map when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from({'bool': true, 'double': 5.3}));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        expect(obj.oneAny.type, RealmValueType.map);
        expectMatches(obj.oneAny, {'bool': true, 'double': 5.3});

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from({'foo': 'bar'}));
        expectMatches(obj.oneAny, {'foo': 'bar'});

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from(999));
        expectMatches(obj.oneAny, 999);

        writeIfNecessary(realm, () => obj.oneAny = RealmValue.from([1.23456789]));
        expectMatches(obj.oneAny, [1.23456789]);
      });

      if (isManaged) {
        baasTest('Map can be reassigned', (appConfig) async {
          final differentiator = ObjectId();
          final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

          // Add object in first realm.
          final object = ObjectWithRealmValue(ObjectId(),
            differentiator: differentiator,
            oneAny: RealmValue.from({'bool': true, 'double': 5.3}));
          realm1.write(() => realm1.add(object));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check object values in second realm.
          final syncedObject = realm2.all<ObjectWithRealmValue>().single;
          expect(syncedObject.oneAny.type, RealmValueType.map);
          expectMatches(syncedObject.oneAny, {'bool': true, 'double': 5.3});

          // Reassign value in second realm.
          realm2.write(() => syncedObject.oneAny = RealmValue.from({'newKey': 'new value'}));

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check and reassign new value in first realm.
          expectMatches(object.oneAny, {'newKey': 'new value'});
          realm1.write(() => object.oneAny = RealmValue.from(999));

          await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

          // Check and reassign new value in second realm.
          expectMatches(syncedObject.oneAny, 999);
          realm2.write(() => syncedObject.oneAny = RealmValue.from([1.23456789]));

          await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

          // Check new value in first realm.
          expectMatches(object.oneAny, [1.23456789]);
        });
      }

      test('Map inside list when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from([
          true,
          {'foo': 'bar'},
          5.3
        ]));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final list = obj.oneAny.asList();

        expect(list[1].type, RealmValueType.map);

        writeIfNecessary(realm, () => list[1] = RealmValue.from({'new': 5}));
        expectMatches(obj.oneAny, [
          true,
          {'new': 5},
          5.3
        ]);

        writeIfNecessary(realm, () {
          list.add(list[1]);
        });

        expectMatches(obj.oneAny, [
          true,
          {'new': 5},
          5.3,
          {'new': 5}
        ]);
      });

      // TODO: Self-assignment - this doesn't work due to https://github.com/realm/realm-core/issues/7422
      test('Map inside list when $managedString can self-assign', () {
        final realm = getMixedRealm();
        final originalList = [true, {'foo': 'bar'}, 5.3];
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalList));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final list = obj.oneAny.asList();

        expect(list[1].type, RealmValueType.map);

        writeIfNecessary(realm, () {
          list[1] = list[1];
        });
        expectMatches(obj.oneAny, originalList);
      }, skip: true);

      test('Map inside map when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from({
          'a': 5,
          'b': {'foo': 'bar'}
        }));

        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final map = obj.oneAny.asMap();

        expect(map['b']!.type, RealmValueType.map);

        writeIfNecessary(realm, () => map['b'] = RealmValue.from({'new': 5}));
        expectMatches(obj.oneAny, {
          'a': 5,
          'b': {'new': 5}
        });

        writeIfNecessary(realm, () {
          map['c'] = map['b']!;
        });

        expectMatches(obj.oneAny, {
          'a': 5,
          'b': {'new': 5},
          'c': {'new': 5},
        });
      });

      // TODO: Self-assignment - this doesn't work due to https://github.com/realm/realm-core/issues/7422
      test('Map inside map when $managedString can self-assign', () {
        final realm = getMixedRealm();
        final originalMap = {
          'a': 5,
          'b': {'foo': 'bar'}
        };
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalMap));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final map = obj.oneAny.asMap();

        expect(map['b']!.type, RealmValueType.map);

        writeIfNecessary(realm, () {
          map['b'] = map['b']!;
        });
        expectMatches(obj.oneAny, originalMap);
      }, skip: true);

      test('List inside list when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from([
          true,
          ['foo'],
          5.3
        ]));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final list = obj.oneAny.asList();

        expect(list[1].type, RealmValueType.list);

        writeIfNecessary(realm, () => list[1] = RealmValue.from([5, true]));
        expectMatches(obj.oneAny, [
          true,
          [5, true],
          5.3
        ]);

        writeIfNecessary(realm, () {
          list.add(list[1]);
        });

        expectMatches(obj.oneAny, [
          true,
          [5, true],
          5.3,
          [5, true]
        ]);
      });

      // TODO: Self-assignment - this doesn't work due to https://github.com/realm/realm-core/issues/7422
      test('List inside list when $managedString can self-assign', () {
        final realm = getMixedRealm();
        final originalList = [true, ['foo'], 5.3];
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalList));
        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final list = obj.oneAny.asList();

        expect(list[1].type, RealmValueType.list);

        writeIfNecessary(realm, () {
          list[1] = list[1];
        });
        expectMatches(obj.oneAny, originalList);
      }, skip: true);

      test('List inside map when $managedString can be reassigned', () {
        final realm = getMixedRealm();
        final obj = ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from({
          'a': 5,
          'b': ['foo']
        }));

        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final map = obj.oneAny.asMap();

        expect(map['b']!.type, RealmValueType.list);

        writeIfNecessary(realm, () => map['b'] = RealmValue.from([999, true]));
        expectMatches(obj.oneAny, {
          'a': 5,
          'b': [999, true]
        });

        writeIfNecessary(realm, () {
          map['c'] = map['b']!;
        });

        expectMatches(obj.oneAny, {
          'a': 5,
          'b': [999, true],
          'c': [999, true]
        });
      });

      // TODO: Self-assignment - this doesn't work due to https://github.com/realm/realm-core/issues/7422
      test('List inside map when $managedString can self-assign', () {
        final realm = getMixedRealm();
        final originalMap = {
          'a': 5,
          'b': ['foo']
        };
        final obj = ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalMap));

        if (isManaged) {
          realm.write(() => realm.add(obj));
        }

        final map = obj.oneAny.asMap();

        expect(map['b']!.type, RealmValueType.list);

        writeIfNecessary(realm, () {
          map['b'] = map['b']!;
        });
        expectMatches(obj.oneAny, originalMap);
      }, skip: true);

      group('Complex structs', () {
        final originalList = [
          {'0_bool': true, '0_double': 5.3},
          {
            '1_int': 5,
            '1_map': {
              '2_decimal': Decimal128.fromDouble(0.1),
              '2_list': [
                'bla bla',
                {
                  '3_dict': {'4_string': 'abc'}
                }
              ]
            }
          }
        ];

        test('RealmValue when $managedString can store complex struct', () {
          final realm = getMixedRealm();
          final rv = persistIfNecessary(RealmValue.from(originalList), realm);

          expectMatches(rv, originalList);

          writeIfNecessary(realm, () {
            rv.asList().removeAt(0);
          });

          expectMatches(rv, [
            {
              '1_int': 5,
              '1_map': {
                '2_decimal': Decimal128.fromDouble(0.1),
                '2_list': [
                  'bla bla',
                  {
                    '3_dict': {'4_string': 'abc'}
                  }
                ]
              }
            }
          ]);

          writeIfNecessary(realm, () {
            rv.asList()[0].asMap()['1_double'] = RealmValue.double(5.5);
            rv.asList()[0].asMap().remove('1_map');
            rv.asList().add(RealmValue.bool(true));
          });

          expectMatches(rv, [
            {'1_int': 5, '1_double': 5.5},
            true
          ]);
        });

        if (isManaged) {
          baasTest('RealmValue can store complex struct', (appConfig) async {
            final differentiator = ObjectId();
            final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

            // Add object in first realm.
            final object = ObjectWithRealmValue(ObjectId(),
              differentiator: differentiator,
              oneAny: RealmValue.from(originalList));
            realm1.write(() => realm1.add(object));

            await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

            // Check object values in second realm.
            final syncedObject = realm2.all<ObjectWithRealmValue>().single;
            expectMatches(syncedObject.oneAny, originalList);

            // Remove list item in second realm.
            realm2.write(() => syncedObject.oneAny.asList().removeAt(0));

            await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);

            // Check list in first realm.
            expectMatches(object.oneAny, [
              {
                '1_int': 5,
                '1_map': {
                  '2_decimal': Decimal128.fromDouble(0.1),
                  '2_list': [
                    'bla bla',
                    {
                      '3_dict': {'4_string': 'abc'}
                    }
                  ]
                }
              }
            ]);

            // Make updates in first realm.
            realm1.write(() {
              final list = object.oneAny.asList();
              list[0].asMap()['1_double'] = RealmValue.double(5.5);
              // TODO: This removal will cause termination:
              //       libc++abi: terminating due to uncaught exception of type realm::StaleAccessor: This collection is no more
              list[0].asMap().remove('1_map');
              list.add(RealmValue.bool(true));
            });

            await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

            // Check updated list in second realm.
            expectMatches(syncedObject.oneAny, [
              {'1_int': 5, '1_double': 5.5},
              true
            ]);
          }, skip: true);
        }
      });
    }

    test('List inside RealmValue equality', () {
      final realm = getMixedRealm();
      final originalList = [1];
      final managedValue = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalList))).oneAny;
      });

      final unmanagedValue = RealmValue.from(originalList);

      expect(managedValue.type, RealmValueType.list);
      expect(unmanagedValue.type, RealmValueType.list);

      expect(managedValue.asList().isManaged, true);
      expect(unmanagedValue.asList().isManaged, false);

      expect(managedValue == unmanagedValue, false);
      expect(unmanagedValue == managedValue, false);
      expect(managedValue == managedValue, false);
      expect(unmanagedValue == unmanagedValue, false);

      // ignore: unrelated_type_equality_checks
      expect(managedValue == originalList, false);

      // ignore: unrelated_type_equality_checks
      expect(unmanagedValue == originalList, false);
    });

    test('List<RealmValue>.indexOf for list', () {
      final realm = getMixedRealm();
      final originalList = [1];
      final managedList = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), manyAny: [RealmValue.from(originalList)])).manyAny;
      });

      final unmanagedList = [RealmValue.from(originalList)];

      expect(managedList.isManaged, true);

      expect(managedList.indexOf(RealmValue.from(originalList)), -1);
      expect(managedList.indexOf(managedList.first), -1);
      expect(managedList.contains(RealmValue.from(originalList)), false);
      expect(managedList.contains(managedList.first), false);

      expect(managedList.asResults().indexOf(RealmValue.from(originalList)), -1);
      expect(managedList.asResults().indexOf(managedList.first), -1);
      expect(managedList.asResults().contains(RealmValue.from(originalList)), false);
      expect(managedList.asResults().contains(managedList.first), false);

      expect(unmanagedList.indexOf(RealmValue.from(originalList)), -1);
      expect(unmanagedList.indexOf(unmanagedList.first), -1);
      expect(unmanagedList.contains(RealmValue.from(originalList)), false);
      expect(unmanagedList.contains(unmanagedList.first), false);
    });

    test('List<RealmValue>.indexOf for map', () {
      final realm = getMixedRealm();
      final originalMap = {'foo': 1};
      final managedList = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), manyAny: [RealmValue.from(originalMap)])).manyAny;
      });

      final unmanagedList = [RealmValue.from(originalMap)];

      expect(managedList.isManaged, true);

      expect(managedList.indexOf(RealmValue.from(originalMap)), -1);
      expect(managedList.indexOf(managedList.first), -1);
      expect(managedList.contains(RealmValue.from(originalMap)), false);
      expect(managedList.contains(managedList.first), false);

      expect(managedList.asResults().indexOf(RealmValue.from(originalMap)), -1);
      expect(managedList.asResults().indexOf(managedList.first), -1);
      expect(managedList.asResults().contains(RealmValue.from(originalMap)), false);
      expect(managedList.asResults().contains(managedList.first), false);

      expect(unmanagedList.indexOf(RealmValue.from(originalMap)), -1);
      expect(unmanagedList.indexOf(unmanagedList.first), -1);
      expect(unmanagedList.contains(RealmValue.from(originalMap)), false);
      expect(unmanagedList.contains(unmanagedList.first), false);
    });

    test('Map inside RealmValue equality', () {
      final realm = getMixedRealm();
      final originalMap = {'foo': 'bar'};
      final managedValue = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), oneAny: RealmValue.from(originalMap))).oneAny;
      });

      final unmanagedValue = RealmValue.from(originalMap);

      expect(managedValue.type, RealmValueType.map);
      expect(unmanagedValue.type, RealmValueType.map);

      expect(managedValue.asMap().isManaged, true);
      expect(unmanagedValue.asMap().isManaged, false);

      expect(managedValue == unmanagedValue, false);
      expect(unmanagedValue == managedValue, false);
      expect(managedValue == managedValue, false);
      expect(unmanagedValue == unmanagedValue, false);

      // ignore: unrelated_type_equality_checks
      expect(managedValue == originalMap, false);

      // ignore: unrelated_type_equality_checks
      expect(unmanagedValue == originalMap, false);
    });

    test('Map<String, RealmValue>.contains for list', () {
      final realm = getMixedRealm();
      final originalList = [1];
      final managedMap = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), dictOfAny: {'foo': RealmValue.from(originalList)})).dictOfAny;
      });

      final unmanagedMap = {'foo': RealmValue.from(originalList)};

      expect(managedMap.isManaged, true);

      expect(managedMap.containsValue(RealmValue.from(originalList)), false);
      expect(managedMap.containsValue(managedMap.values.first), false);

      expect(managedMap.values.contains(RealmValue.from(originalList)), false);
      expect(managedMap.values.contains(managedMap.values.first), false);

      expect(unmanagedMap.containsValue(RealmValue.from(originalList)), false);
      expect(unmanagedMap.containsValue(unmanagedMap.values.first), false);

      expect(unmanagedMap.values.contains(RealmValue.from(originalList)), false);
      expect(unmanagedMap.values.contains(managedMap.values.first), false);
    });

    test('Map<String, RealmValue>.contains for map', () {
      final realm = getMixedRealm();
      final originalMap = {'bar': 1};
      final managedMap = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), dictOfAny: {'foo': RealmValue.from(originalMap)})).dictOfAny;
      });

      final unmanagedMap = {'foo': RealmValue.from(originalMap)};

      expect(managedMap.isManaged, true);

      expect(managedMap.containsValue(RealmValue.from(originalMap)), false);
      expect(managedMap.containsValue(managedMap.values.first), false);

      expect(managedMap.values.contains(RealmValue.from(originalMap)), false);
      expect(managedMap.values.contains(managedMap.values.first), false);

      expect(unmanagedMap.containsValue(RealmValue.from(originalMap)), false);
      expect(unmanagedMap.containsValue(unmanagedMap.values.first), false);

      expect(unmanagedMap.values.contains(RealmValue.from(originalMap)), false);
      expect(unmanagedMap.values.contains(managedMap.values.first), false);
    });

    test('Map<RealmValue>.indexOf for map', () {
      final realm = getMixedRealm();
      final originalMap = {'foo': 1};
      final managedList = realm.write(() {
        return realm.add(ObjectWithRealmValue(ObjectId(), manyAny: [RealmValue.from(originalMap)])).manyAny;
      });

      final unmanagedList = [RealmValue.from(originalMap)];

      expect(managedList.isManaged, true);

      expect(managedList.indexOf(RealmValue.from(originalMap)), -1);
      expect(managedList.indexOf(managedList.first), -1);
      expect(managedList.contains(RealmValue.from(originalMap)), false);
      expect(managedList.contains(managedList.first), false);

      expect(managedList.asResults().indexOf(RealmValue.from(originalMap)), -1);
      expect(managedList.asResults().indexOf(managedList.first), -1);
      expect(managedList.asResults().contains(RealmValue.from(originalMap)), false);
      expect(managedList.asResults().contains(managedList.first), false);

      expect(unmanagedList.indexOf(RealmValue.from(originalMap)), -1);
      expect(unmanagedList.indexOf(unmanagedList.first), -1);
      expect(unmanagedList.contains(RealmValue.from(originalMap)), false);
      expect(unmanagedList.contains(unmanagedList.first), false);
    });

    test('List in RealmValue when unmanaged is equal to original list', () {
      final list = [RealmValue.bool(true), RealmValue.string('abc')];
      final rv = RealmValue.list(list);
      expect(rv.asList() == list, true);
    });

    test('List in RealmValue when managed is different instance', () {
      final list = [RealmValue.bool(true), RealmValue.string('abc')];
      final rv = RealmValue.list(list);
      final realm = getMixedRealm();
      final obj = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: rv)));
      expect(identical(obj.oneAny.asList(), list), false);
    });

    test('Map in RealmValue when unmanaged is equal to original map', () {
      final map = {'bool': RealmValue.bool(true), 'str': RealmValue.string('abc')};
      final rv = RealmValue.map(map);
      expect(rv.asMap() == map, true);
    });

    test('Map in RealmValue when managed is different instance', () {
      final map = {'bool': RealmValue.bool(true), 'str': RealmValue.string('abc')};
      final rv = RealmValue.map(map);
      final realm = getMixedRealm();
      final obj = realm.write(() => realm.add(ObjectWithRealmValue(ObjectId(), oneAny: rv)));
      expect(identical(obj.oneAny.asMap(), map), false);
    });

    test('Notifications', () async {
      final realm = getMixedRealm();
      final obj = ObjectWithRealmValue(ObjectId(),
          oneAny: RealmValue.from([
        5,
        {
          'string': 'bar',
          'list': [10]
        }
      ]));

      realm.write(() {
        realm.add(obj);
      });

      // Add listeners.
      final List<RealmObjectChanges<ObjectWithRealmValue>> parentChanges = [];
      final subscription = obj.changes.listen((event) {
        parentChanges.add(event);
      });

      final List<RealmListChanges<RealmValue>> listChanges = [];
      final listSubscription = obj.oneAny.asList().changes.listen((event) {
        listChanges.add(event);
      });

      final List<RealmMapChanges<RealmValue>> mapChanges = [];
      final mapSubscription = obj.oneAny.asList()[1].asMap().changes.listen((event) {
        mapChanges.add(event);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      parentChanges.clear();
      listChanges.clear();
      mapChanges.clear();

      // Add item to list.
      realm.write(() {
        obj.oneAny.asList().add(RealmValue.bool(true));
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired.
      expect(parentChanges, hasLength(1));
      expect(parentChanges[0].properties, ['oneAny']);

      expect(listChanges, hasLength(1));
      expect(listChanges[0].inserted, [2]);
      expect(listChanges[0].deleted, isEmpty);
      expect(listChanges[0].modified, isEmpty);
      expect(listChanges[0].isCleared, false);
      expect(listChanges[0].isCollectionDeleted, false);

      expect(mapChanges, hasLength(0));

      // Update and add entry in nested dictionary.
      realm.write(() {
        obj.oneAny.asList()[1].asMap()['list'] = RealmValue.from([10]);
        obj.oneAny.asList()[1].asMap()['new-value'] = RealmValue.from({'foo': 'bar'});
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired.
      expect(parentChanges, hasLength(2));
      expect(parentChanges[1].properties, ['oneAny']);

      expect(listChanges, hasLength(2));
      expect(listChanges[1].inserted, isEmpty);
      expect(listChanges[1].deleted, isEmpty);
      expect(listChanges[1].modified, [1]);
      expect(listChanges[1].isCleared, false);
      expect(listChanges[1].isCollectionDeleted, false);

      expect(mapChanges, hasLength(1));
      expect(mapChanges[0].modified, ['list']);
      expect(mapChanges[0].inserted, ['new-value']);
      expect(mapChanges[0].deleted, isEmpty);
      expect(mapChanges[0].isCleared, false);
      expect(mapChanges[0].isCollectionDeleted, false);

      // Remove entry in nested dictionary.
      realm.write(() {
        obj.oneAny.asList()[1].asMap().remove('string');
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired.
      expect(parentChanges, hasLength(3));
      expect(parentChanges[2].properties, ['oneAny']);

      expect(listChanges, hasLength(3));
      expect(listChanges[2].inserted, isEmpty);
      expect(listChanges[2].deleted, isEmpty);
      expect(listChanges[2].modified, [1]);
      expect(listChanges[2].isCleared, false);
      expect(listChanges[2].isCollectionDeleted, false);

      expect(mapChanges, hasLength(2));
      expect(mapChanges[1].modified, isEmpty);
      expect(mapChanges[1].inserted, isEmpty);
      expect(mapChanges[1].deleted, ['string']);
      expect(mapChanges[1].isCleared, false);
      expect(mapChanges[1].isCollectionDeleted, false);
      expect(mapChanges[1].isCollectionDeleted, false);

      // Remove dictionary from list.
      realm.write(() {
        obj.oneAny.asList().removeAt(1);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired.
      expect(parentChanges, hasLength(4));
      expect(parentChanges[3].properties, ['oneAny']);

      expect(listChanges, hasLength(4));
      expect(listChanges[3].inserted, isEmpty);
      expect(listChanges[3].deleted, [1]);
      expect(listChanges[3].modified, isEmpty);
      expect(listChanges[3].isCleared, false);
      expect(listChanges[3].isCollectionDeleted, false);

      expect(mapChanges, hasLength(3));
      expect(mapChanges[2].isCollectionDeleted, true);

      // Cancel subscriptions.
      subscription.cancel();
      listSubscription.cancel();
      mapSubscription.cancel();

      // Overwrite list with primitive.
      realm.write(() {
        obj.oneAny = RealmValue.bool(false);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      // Subscriptions have been canceled - shouldn't get more notifications
      expect(parentChanges, hasLength(4));
      expect(listChanges, hasLength(4));
      expect(mapChanges, hasLength(3));
    });

    baasTest('Notifications', (appConfig) async {
      final differentiator = ObjectId();
      final (realm1, realm2) = await logInAndGetSyncedRealms(appConfig, differentiator);

      // Add object in first realm.
      final list = [
        5,
        {
          'string': 'bar',
          'list': [10]
        }
      ];
      final object = ObjectWithRealmValue(ObjectId(), differentiator: differentiator, oneAny: RealmValue.from(list));
      realm1.write(() => realm1.add(object));

      await waitForSynchronization(uploadRealm: realm1, downloadRealm: realm2);

      // Add listeners in first realm.
      final List<RealmObjectChanges<ObjectWithRealmValue>> parentChanges = [];
      final subscription = object.changes.listen((event) {
        parentChanges.add(event);
      });

      final List<RealmListChanges<RealmValue>> listChanges = [];
      final listSubscription = object.oneAny.asList().changes.listen((event) {
        listChanges.add(event);
      });

      final List<RealmMapChanges<RealmValue>> mapChanges = [];
      final mapSubscription = object.oneAny.asList()[1].asMap().changes.listen((event) {
        mapChanges.add(event);
      });

      await Future<void>.delayed(Duration(milliseconds: 20));

      parentChanges.clear();
      listChanges.clear();
      mapChanges.clear();

      // Get object in second realm.
      final syncedObject = realm2.query<ObjectWithRealmValue>(r'_id == $0', [object.id]).single;

      // Add item to list in second realm.
      realm2.write(() {
        syncedObject.oneAny.asList().add(RealmValue.bool(true));
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);
      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired in first realm.
      expect(parentChanges, hasLength(1));
      expect(parentChanges[0].properties, ['oneAny']);

      expect(listChanges, hasLength(1));
      expect(listChanges[0].inserted, [2]);
      expect(listChanges[0].deleted, isEmpty);
      expect(listChanges[0].modified, isEmpty);
      expect(listChanges[0].isCleared, false);
      expect(listChanges[0].isCollectionDeleted, false);

      expect(mapChanges, hasLength(0));

      // Update and add entry in nested dictionary in second realm.
      realm2.write(() {
        syncedObject.oneAny.asList()[1].asMap()['list'] = RealmValue.from([10]);
        syncedObject.oneAny.asList()[1].asMap()['new-value'] = RealmValue.from({'foo': 'bar'});
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);
      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired in first realm.
      expect(parentChanges, hasLength(2));
      expect(parentChanges[1].properties, ['oneAny']);

      expect(listChanges, hasLength(2));
      expect(listChanges[1].inserted, isEmpty);
      expect(listChanges[1].deleted, isEmpty);
      expect(listChanges[1].modified, [1]);
      expect(listChanges[1].isCleared, false);
      expect(listChanges[1].isCollectionDeleted, false);

      expect(mapChanges, hasLength(1));
      expect(mapChanges[0].modified, ['list']);
      expect(mapChanges[0].inserted, ['new-value']);
      expect(mapChanges[0].deleted, isEmpty);
      expect(mapChanges[0].isCleared, false);
      expect(mapChanges[0].isCollectionDeleted, false);

      // Remove entry in nested dictionary in second realm.
      realm2.write(() {
        syncedObject.oneAny.asList()[1].asMap().remove('string');
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);
      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired in first realm.
      expect(parentChanges, hasLength(3));
      expect(parentChanges[2].properties, ['oneAny']);

      expect(listChanges, hasLength(3));
      expect(listChanges[2].inserted, isEmpty);
      expect(listChanges[2].deleted, isEmpty);
      expect(listChanges[2].modified, [1]);
      expect(listChanges[2].isCleared, false);
      expect(listChanges[2].isCollectionDeleted, false);

      expect(mapChanges, hasLength(2));
      expect(mapChanges[1].modified, isEmpty);
      expect(mapChanges[1].inserted, isEmpty);
      expect(mapChanges[1].deleted, ['string']);
      expect(mapChanges[1].isCleared, false);
      expect(mapChanges[1].isCollectionDeleted, false);
      expect(mapChanges[1].isCollectionDeleted, false);

      // Remove dictionary from list in second realm.
      realm2.write(() {
        syncedObject.oneAny.asList().removeAt(1);
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);
      await Future<void>.delayed(Duration(milliseconds: 20));

      // Expect listeners to be fired in first realm.
      expect(parentChanges, hasLength(4));
      expect(parentChanges[3].properties, ['oneAny']);

      expect(listChanges, hasLength(4));
      expect(listChanges[3].inserted, isEmpty);
      expect(listChanges[3].deleted, [1]);
      expect(listChanges[3].modified, isEmpty);
      expect(listChanges[3].isCleared, false);
      expect(listChanges[3].isCollectionDeleted, false);

      expect(mapChanges, hasLength(3));
      expect(mapChanges[2].isCollectionDeleted, true);

      // Cancel subscriptions.
      subscription.cancel();
      listSubscription.cancel();
      mapSubscription.cancel();

      // Overwrite list with primitive in second realm.
      realm2.write(() {
        syncedObject.oneAny = RealmValue.bool(false);
      });

      await waitForSynchronization(uploadRealm: realm2, downloadRealm: realm1);
      await Future<void>.delayed(Duration(milliseconds: 20));

      // Subscriptions have been canceled - shouldn't get more notifications.
      expect(parentChanges, hasLength(4));
      expect(listChanges, hasLength(4));
      expect(mapChanges, hasLength(3));
    });

    test('Queries', () {
      final realm = getMixedRealm();

      late ObjectWithRealmValue first;
      late ObjectWithRealmValue second;
      late ObjectWithRealmValue third;

      realm.write(() {
        first = realm.add(ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from([
          1,
          'a',
          {'foo': 'bar'}
        ])));

        second = realm.add(ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from([
          2,
          {'foo': 'baz'}
        ])));

        third = realm.add(ObjectWithRealmValue(ObjectId(),
            oneAny: RealmValue.from([
          3,
          'c',
          {
            'foo': {'child': 5},
            'bar': 10
          },
          3.4
        ])));
      });

      final listElementQuery = realm.query<ObjectWithRealmValue>('oneAny[0] < 3');
      expect(listElementQuery, unorderedMatches([first, second]));

      final listLengthQuery = realm.query<ObjectWithRealmValue>('oneAny.@size > 3');
      expect(listLengthQuery, unorderedMatches([third]));

      final listStarQuery = realm.query<ObjectWithRealmValue>('oneAny[*] == 3.4');
      expect(listStarQuery, unorderedMatches([third]));

      final typeQuery = realm.query<ObjectWithRealmValue>("oneAny[2].@type == 'dictionary'");
      expect(typeQuery, unorderedMatches([first, third]));

      final dictionaryInListQuery = realm.query<ObjectWithRealmValue>("oneAny[*].foo BEGINSWITH 'ba'");
      expect(dictionaryInListQuery, unorderedMatches([first, second]));

      final dictionaryKeysQuery = realm.query<ObjectWithRealmValue>("oneAny[*].foo.@keys == 'child'");
      expect(dictionaryKeysQuery, unorderedMatches([third]));

      final noMatchesQuery = realm.query<ObjectWithRealmValue>("oneAny[*].bar == 9");
      expect(noMatchesQuery, isEmpty);
    });
  });

  group('RealmValue.fromJson', () {
    test('Throws with invalid json', () {
      final json = '{ "This is": invalid }';

      expect(() => RealmValue.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('Constructs objects', () {
      final json = '{ "1.1": { "2.1": "foo", "2.2": 5 }, "1.2": [ 1, 2, true ], "1.3": null }';

      final result = RealmValue.fromJson(json);
      expect(result.type, RealmValueType.map);

      final o1 = result.asMap()['1.1'];
      expect(o1, isNotNull);
      expect(o1!.type, RealmValueType.map);
      expect(o1.asMap()['2.1']!.value, 'foo');
      expect(o1.asMap()['2.2']!.value, 5);

      final o2 = result.asMap()['1.2'];
      expect(o2, isNotNull);
      expect(o2!.type, RealmValueType.list);
      expect(o2.asList()[0].value, 1);
      expect(o2.asList()[1].value, 2);
      expect(o2.asList()[2].value, true);

      final o3 = result.asMap()['1.3'];
      expect(o3, isNotNull);
      expect(o3!.type, RealmValueType.nullValue);
      expect(o3.value, null);
    });

    test('Constructs arrays', () {
      final json = '[ "foo", true, { "foo": "bar" }, [ 1, 2.2, 3 ]]';

      final result = RealmValue.fromJson(json);
      expect(result.type, RealmValueType.list);
      expect(result.asList(), hasLength(4));
      expect(result.asList()[0].value, "foo");
      expect(result.asList()[1].value, true);

      final map = result.asList()[2];
      expect(map.type, RealmValueType.map);
      expect(map.asMap()['foo']!.value, 'bar');

      final list = result.asList()[3];
      expect(list.type, RealmValueType.list);
      expect(list.asList(), hasLength(3));
      expect(list.asList()[0].value, 1);
      expect(list.asList()[0].type, RealmValueType.int);
      expect(list.asList()[1].value, 2.2);
      expect(list.asList()[1].type, RealmValueType.double);
      expect(list.asList()[2].value, 3);
      expect(list.asList()[2].type, RealmValueType.int);
    });

    test('Constructs string', () {
      final json = '"foo"';
      final result = RealmValue.fromJson(json);

      expect(result.type, RealmValueType.string);
      expect(result.value, 'foo');
    });

    test('Constructs integers', () {
      final json = '-123';
      final result = RealmValue.fromJson(json);

      expect(result.type, RealmValueType.int);
      expect(result.value, -123);
    });

    test('Constructs doubles', () {
      final json = '-123.456';
      final result = RealmValue.fromJson(json);

      expect(result.type, RealmValueType.double);
      expect(result.value, -123.456);
    });

    test('Constructs bools', () {
      final json = 'true';
      final result = RealmValue.fromJson(json);

      expect(result.type, RealmValueType.boolean);
      expect(result.value, true);
    });

    test('Constructs nulls', () {
      final json = 'null';
      final result = RealmValue.fromJson(json);

      expect(result.type, RealmValueType.nullValue);
      expect(result.value, isNull);
    });
  });
}
