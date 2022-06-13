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

// ignore_for_file: avoid_relative_lib_imports

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';

import 'test.dart';

part 'add_or_update_test.g.dart';

@RealmModel()
class _Friend {
  @PrimaryKey()
  late int id;
  _Friend? friend;
}

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Transitive adds', () {
    final r = getRealm(Configuration.local([Friend.schema]));

    var alice = Friend(1);
    var bob = Friend(2, friend: alice);

    r.write(() => r.add(bob));
    expect(bob.isManaged, true);
    expect(alice.isManaged, true);
    expect(r.find<Friend>(bob.id), bob);
    expect(r.find<Friend>(alice.id), alice);
  });

  test('Transitive updates', () {
    final r = getRealm(Configuration.local([Friend.schema]));

    var alice = Friend(1);
    var bob = Friend(2, friend: alice);

    r.write(() => r.add(bob));

    final aliceAgain = Friend(1);
    final bobAgain = Friend(2, friend: aliceAgain);

    r.write(() => r.add(bobAgain, update: true));

    expect(bob.isManaged, true);
    expect(alice.isManaged, true);
    expect(bobAgain.isManaged, true);
    expect(aliceAgain.isManaged, true);

    // Re-fetch from realm
    alice = r.find(alice.id)!;
    bob = r.find(bob.id)!;    

    expect(bob, bobAgain);
    expect(alice, aliceAgain);
    expect(bob.friend, alice);
  });

  test('Cycles added correctly', () {
    final r = getRealm(Configuration.local([Friend.schema]));

    var alice = Friend(1);
    var bob = Friend(2, friend: alice);
    alice.friend = bob; // form cycle

    r.write(() => r.add(alice));

    // Re-fetch from realm
    alice = r.find(alice.id)!;
    bob = r.find(bob.id)!;

    expect(alice.friend, bob);
    expect(alice.friend!.friend, alice);
    expect(alice.friend!.friend!.friend, bob);
  });

  test('Cycles updated correctly', () {
    final r = getRealm(Configuration.local([Friend.schema]));

    var alice = Friend(1);
    var bob = Friend(2, friend: alice);
    alice.friend = bob; // form cycle

    r.write(() => r.add(alice));

    final aliceAgain = Friend(1);
    final bobAgain = Friend(2, friend: aliceAgain);
    aliceAgain.friend = bobAgain;

    alice = r.write(() => r.add(aliceAgain, update: true));

    // Re-fetch from realm
    alice = r.find(alice.id)!;
    bob = r.find(bob.id)!;

    expect(alice.friend, bobAgain);
    expect(alice.friend!.friend, aliceAgain);
    expect(alice.friend!.friend!.friend, bobAgain);
  });

  test('Cycles updated correctly 2', () {
    final r = getRealm(Configuration.local([Friend.schema]));

    var alice = Friend(1);
    var bob = Friend(2, friend: alice);
    alice.friend = bob; // form cycle

    r.write(() => r.add(alice));

    var carol = Friend(3, friend: alice);
    final aliceAgain = Friend(1, friend: carol); // form new cycle

    alice = r.write(() => r.add(aliceAgain, update: true));

    // Re-fetch from realm
    alice = r.find(alice.id)!;
    bob = r.find(bob.id)!;
    carol = r.find(carol.id)!;

    expect(bob.friend, alice);
    expect(alice.friend, carol);
    expect(alice.friend!.friend, alice);
    expect(alice.friend!.friend!.friend, carol);
  });
}
