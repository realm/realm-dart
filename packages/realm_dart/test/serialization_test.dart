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
    final p = fromEJson<Player>({'name': 'Ericsen'});
    expect(p.toEJson(), {'name': 'Ericsen', 'game': null, 'scoresByRound': <int?>[]});
  });

  test('RealmValue', () {
    final r = RealmValue.int(42);
    expect(r.toEJson(), {'\$numberInt': '42'});
    expect(fromEJson<RealmValue>({'\$numberInt': '42'}), r);
  });

  test('Decimal128', () {
    final d = Decimal128.fromInt(42);
    expect(toEJson(d), {'\$numberDecimal': '+42E+0'});
    expect(fromEJson<Decimal128>({'\$numberDecimal': '42'}), d);
  });
}
