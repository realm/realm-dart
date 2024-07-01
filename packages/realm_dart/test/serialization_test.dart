// Copyright 2022 MongoDB, Inc.
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
      Player('Christian Eriksen'): {
        // Player is a RealmObject, so it is encoded as a reference inside a RealmValue.
        '@ref': 'Player',
        '@id': 'Christian Eriksen'
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
  });

  test('Decimal128', () {
    final d = Decimal128.fromInt(42);
    expect(toEJson(d), {'\$numberDecimal': '+42E+0'});
    expect(fromEJson<Decimal128>({'\$numberDecimal': '42'}), d);
  });
}
