// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import 'test.dart';

void main() {
  setupTests();

  test('optional absent', () {
    // load codecs
    Realm(Configuration.inMemory([Player.schema, Game.schema]));
    expect(() => fromEJson<Player>({}), throwsA(isA<InvalidEJson>()));
    final p = fromEJson<Player>({'name': 'Christian Eriksen'});
    expect(p.toEJson(), {'name': 'Christian Eriksen', 'game': null, 'scoresByRound': <int?>[]});
  });

  group('RealmValue', () {
    // load custom codecs for Player and Game. This is done to test that it
    // doesn't interfere with the RealmValue codecs.
    Realm(Configuration.inMemory([Player.schema, Game.schema]));
    for (final entry in {
      42: {'\$numberInt': '42'},
      42.0: {'\$numberInt': '42'},
      '42': '42',
      true: true,
      null: null,
      [1, 2, 3]: [
        {'\$numberInt': '1'},
        {'\$numberInt': '2'},
        {'\$numberInt': '3'},
      ],
      {'a': 1, 'b': 2}: {
        // Even though Game could be deserialized from this (everything in Game
        // is optional, hence {} and by extension any map can deserialize to Game),
        // we always decode a map as a map inside a RealmValue.
        'a': {'\$numberInt': '1'},
        'b': {'\$numberInt': '2'},
      },
    }.entries) {
      final value = entry.key;
      final encoded = entry.value;
      test(value.runtimeType.toString(), () {
        final r = RealmValue.from(value);
        expect(r.toEJson(), encoded);
        expect(fromEJson<RealmValue>(encoded).value, r.value);
        if (r.value is! List && r.value is! Map) {
          expect(fromEJson<RealmValue>(r.toEJson()), r);
        }
      });
    }

    test('RealmObject', () {
      // load custom codecs for Player and Game. This is done to test that it
      // doesn't interfere with the RealmValue codecs.
      Realm(Configuration.inMemory([Player.schema, Game.schema]));

      final p = Player('Christian Eriksen');
      final rv = RealmValue.from(p);
      expect(rv.toEJson(), {'\$id': 'Christian Eriksen', '\$ref': 'Player'});
      expect(fromEJson<DBRef<String>>(rv.toEJson()), isA<DBRef<String>>().having((r) => r.id, '\$id', 'Christian Eriksen'));
      expect((fromEJson<RealmValue>(rv.toEJson()).value as Player).name, p.name);
    });
  });

  test('Decimal128', () {
    final d = Decimal128.fromInt(42);
    expect(toEJson(d), {'\$numberDecimal': '+42E+0'});
    expect(fromEJson<Decimal128>({'\$numberDecimal': '42'}), d);
  });

  test('Set<RealmValue> on RealmObject', () {
    final oid = ObjectId();
    final realm = Realm(Configuration.inMemory([ObjectWithRealmValue.schema]));
    final o = realm.write(() => realm.add(ObjectWithRealmValue(oid, setOfAny: {RealmValue.from(42), RealmValue.from('42')})));
    expect(o.setOfAny, {RealmValue.from(42), RealmValue.from('42')});
    final serialized = toEJsonString(o);
    expect(serialized, '{"_id":{"\$oid":"$oid"},"differentiator":null,"oneAny":null,"manyAny":[],"dictOfAny":{},"setOfAny":[{"\$numberInt":"42"},"42"]}');
    final deserialized = fromEJsonString<ObjectWithRealmValue>(serialized);
    // deserialized is unmanaged, so will never compare equal, but we can test properties
    expect(deserialized.id, o.id);
    expect(deserialized.setOfAny, o.setOfAny);
  });

  test('Set on RealmObject', () {
    final realm = Realm(Configuration.inMemory([AllCollections.schema]));
    final o = realm.write(() => realm.add(AllCollections(intSet: {1, 2, 3})));
    expect(o.intSet, {1, 2, 3});
    final deserialized = fromEJsonString<AllCollections>(toEJsonString(o));
    // deserialized is unmanaged, so will never compare equal, but we can test properties
    expect(deserialized.intSet, o.intSet);
  });

  test('Set in RealmValue', () {
    final rv = RealmValue.from({1, 2, 3}); // constructed from a list of ints
    expect(rv.value, [RealmValue.from(1), RealmValue.from(2), RealmValue.from(3)]); // but becomes a list RealmValues
    expect(rv.toEJson(), [
      // and serializes as a list of EJson
      {'\$numberInt': '1'},
      {'\$numberInt': '2'},
      {'\$numberInt': '3'},
    ]);
    // expect(rv.as<Set<int>>(), {1, 2, 3}); // doesn't work because the set is a list of RealmValues. Should we support this?
  });
}
