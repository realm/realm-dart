////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

// ignore_for_file: unused_local_variable

import 'dart:math';

import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  await setupTests(args);

  test('Lists add object with a list property', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    expect(teams.length, 1);
    expect(teams[0].name, "Ferrari");
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 0);
  });

  test('Lists get set', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    expect(teams.length, 1);
    final players = teams[0].players;
    expect(players, isNotNull);
    expect(players.length, 0);

    realm.write(() => players.add(Person("Michael")));
    expect(players.length, 1);

    realm.write(() => players.addAll([
          Person("Sebastian"),
          Person("Kimi"),
        ]));

    expect(players.length, 3);

    expect(players[0].name, "Michael");
    expect(players[1].name, "Sebastian");
    expect(players[2].name, "Kimi");
  });

  test('Lists get invalid index throws exception', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => players[-1], throws<RealmException>("Index out of range"));
    expect(() => players[800], throws<RealmException>());
  });

  test('Lists set invalid index throws', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => realm.write(() => players[-1] = Person('')), throws<RealmException>("Index out of range"));
    expect(() => realm.write(() => players[800] = Person('')), throws<RealmException>());
  });

  test('List clear items from list', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create a team
    final team = Team("Team");
    realm.write(() => realm.add(team));

    //Add players to the team
    final newPlayers = [
      Person("Michael Schumacher"),
      Person("Sebastian Vettel"),
      Person("Kimi Räikkönen"),
    ];

    realm.write(() {
      team.players.addAll(newPlayers);
    });

    //Ensure teams and players are in realm
    var teams = realm.all<Team>();
    expect(teams.length, 1);

    var players = teams[0].players;
    expect(players, isNotNull);
    expect(players.length, 3);

    //Clear list of team players
    realm.write(() => teams[0].players.clear());

    expect(teams[0].players.length, 0);

    //Ensure that players objects still exist in realm detached from the team
    final allPlayers = realm.all<Person>();
    expect(allPlayers.length, 3);
  });

  test('List clear - same list related to two objects', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create two teams
    final teamOne = Team("TeamOne");
    final teamTwo = Team("TeamTwo");
    realm.write(() {
      realm.add(teamOne);
      realm.add(teamTwo);
    });

    //Create common players list for both teams
    final newPlayers = [
      Person("Michael Schumacher"),
      Person("Sebastian Vettel"),
      Person("Kimi Räikkönen"),
    ];
    realm.write(() {
      teamOne.players.addAll(newPlayers);
      teamTwo.players.addAll(newPlayers);
    });

    //Ensure that teams and players exist in realm
    var teams = realm.all<Team>();
    expect(teams.length, 2);
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 3);
    expect(teams[1].players, isNotNull);
    expect(teams[1].players.length, 3);

    //Clear first team's players only
    realm.write(() => teams[0].players.clear());

    //Ensure that second team is still related to players
    expect(teams[0].players.length, 0);
    expect(teams[1].players.length, 3);

    //Ensure players still exist in realm
    final players = realm.all<Person>();
    expect(players.length, 3);
  });

  test('List clear - same item added to two lists', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create two Teams
    final teamOne = Team("TeamOne");
    final teamTwo = Team("TeamTwo");
    realm.write(() {
      realm.add(teamOne);
      realm.add(teamTwo);
    });

    //Add the same player to both teams
    Person player = Person("Michael Schumacher");
    realm.write(() {
      teamOne.players.add(player);
      teamTwo.players.add(player);
    });

    //Ensure teams and player are in realm
    var teams = realm.all<Team>();
    expect(teams.length, 2);
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 1);
    expect(teams[1].players, isNotNull);
    expect(teams[1].players.length, 1);

    //Clear player from the first team
    realm.write(() => teams[0].players.clear());

    //Ensure that the second team has no more players
    // but the first team is still related to the player
    expect(teams[0].players.length, 0);
    expect(teams[1].players.length, 1);

    //Ensure the player still exists in realm
    final allPlayers = realm.all<Person>();
    expect(allPlayers.length, 1);
  });

  test('List clear in closed realm - expected exception', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    //Create a team
    var team = Team("TeamOne");
    realm.write(() => realm.add(team));

    //Add the player to the team
    realm.write(() => team.players.add(Person("Michael Schumacher")));

    //Ensure teams and player are in realm
    var teams = realm.all<Team>();
    expect(teams.length, 1);
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 1);

    var players = teams[0].players;

    realm.close();
    expect(
        () => realm.write(() {
              players.clear();
            }),
        throws<RealmException>());

    config = Configuration.local([Team.schema, Person.schema]);
    realm = getRealm(config);

    //Teams must be reloaded since realm was reopened
    teams = realm.all<Team>();

    //Ensure that the team is still related to the player
    expect(teams.length, 1);
    expect(teams[0].players.length, 1);
  });

  test('Read list property of a deleted object', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.write(() => realm.delete(team));
    expect(() => team.players, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('Delete a list of objects through a deleted parent', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var players = team.players;
    realm.write(() => realm.delete(team));
    expect(() => realm.write(() => realm.deleteMany(players)), throws<RealmException>("Access to invalidated Collection object"));
  });

  test('Get length of list property on a deleted object', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    var team = Team("TeamOne")..players.add(Person("Nikos"));
    realm.write(() {
      realm.add(team);
      realm.delete(team);
    });
    expect(() => team.players.length, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
  });

  test('List isValid', () {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    realm.write(() {
      realm.add(Team("Speed Team", players: [
        Person("Michael Schumacher"),
        Person("Sebastian Vettel"),
        Person("Kimi Räikkönen"),
      ]));
    });

    var teams = realm.all<Team>();

    expect(teams, isNotNull);
    expect(teams.length, 1);
    final players = teams[0].players;
    expect(players.isValid, true);
    realm.close();
    expect(players.isValid, false);
  });

  test('List notifications', () async {
    var config = Configuration.local([Team.schema, Person.schema]);
    var realm = getRealm(config);

    final team = Team('t1', players: [Person("p1")]);
    realm.write(() => realm.add(team));

    var firstCall = true;
    final subscription = team.players.changes.listen((changes) {
      if (firstCall) {
        firstCall = false;
        expect(changes.inserted.isEmpty, true);
        expect(changes.modified.isEmpty, true);
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified.isEmpty, true);
        expect(changes.moved.isEmpty, true);
      } else {
        expect(changes.inserted, [1]); //new object at index 1
        expect(changes.modified, [0]); //object at index 0 changed
        expect(changes.deleted.isEmpty, true);
        expect(changes.newModified, [0]);
        expect(changes.moved.isEmpty, true);
      }
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    realm.write(() {
      team.players.add(Person("p2"));
      team.players.first.name = "p3";
    });

    await Future<void>.delayed(Duration(milliseconds: 20));
    subscription.cancel();

    await Future<void>.delayed(Duration(milliseconds: 20));
  });

  test('List query', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final person = Person('John');
    final team = Team('team1', players: [
      Person('Pavel'),
      person,
      Person('Alex'),
    ]);

    realm.write(() => realm.add(team));

    final result = team.players.query(r'name BEGINSWITH $0', ['J']);
    expect(result, [person]);
  });

  test('List.freeze freezes the list', () {
    final config = Configuration.local([Person.schema, Team.schema]);
    final realm = getRealm(config);

    final livePlayers = realm.write(() {
      return realm.add(Team('team', players: [Person('Peter')], scores: [123]));
    }).players;

    final frozenPlayers = freezeList(livePlayers);

    expect(frozenPlayers.length, 1);
    expect(frozenPlayers.isFrozen, true);
    expect(frozenPlayers.realm.isFrozen, true);
    expect(frozenPlayers.single.isFrozen, true);

    realm.write(() {
      livePlayers.single.name = 'Peter II';
      livePlayers.add(Person('George'));
    });

    expect(livePlayers.length, 2);
    expect(livePlayers.first.name, 'Peter II');
    expect(frozenPlayers.length, 1);
    expect(frozenPlayers.single.name, 'Peter');
  });

  test("FrozenList.changes throws", () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    realm.write(() {
      realm.add(Team('team'));
    });

    final frozenPlayers = freezeList(realm.all<Team>().single.players);

    expect(() => frozenPlayers.changes, throws<RealmStateError>('List is frozen and cannot emit changes'));
  });

  test('UnmanagedList.freeze throws', () {
    final team = Team('team');

    expect(() => freezeList(team.players), throws<RealmStateError>("Unmanaged lists can't be frozen"));
  });

  test('List.freeze when frozen returns same object', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = realm.write(() => realm.add(Team('Barcelona', players: [Person('Peter')])));

    final frozenPlayers = freezeList(team.players);
    final deepFrozenPlayers = freezeList(frozenPlayers);

    expect(identical(frozenPlayers, deepFrozenPlayers), true);

    final frozenPlayersAgain = freezeList(team.players);
    expect(identical(frozenPlayers, frozenPlayersAgain), false);
  });

  test('ManagedRealmList.removeAt', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    expect(realm.write(() => team.players.removeAt(2)), carol);
    expect(team.players.length, 3);
    expect(team.players, [alice, bob, dan]);

    expect(realm.write(() => team.players.removeAt(0)), alice);
    expect(team.players.length, 2);
    expect(team.players, [bob, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.length set', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.length = 2);
    expect(team.players.length, 2);
    expect(team.players, [alice, bob]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.contains', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));

    for (var p in players) {
      expect(team.players.contains(p), isTrue);
    }

    realm.write(() => team.players.clear());

    for (var p in players) {
      expect(team.players.contains(p), isFalse);
    }
  });

  test('ManagedRealmList.removeRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeRange(1, 3)); // removes [1; 3)
    expect(team.players.length, 2);
    expect(team.players, [alice, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.removeWhere', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeWhere((p) => p.name.contains('a')));
    expect(team.players.length, 2);
    expect(team.players, [alice, bob]); // Alice is capital 'a'

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.retainWhere', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.retainWhere((p) => p.name.contains('a')));
    expect(team.players.length, 2);
    expect(team.players, [carol, dan]); // Alice is capital 'a', so not included

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.removeLast', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.removeLast());
    expect(team.players.length, 3);
    expect(team.players, [alice, bob, carol]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.replaceRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.replaceRange(1, 3, [dan, alice]));
    expect(team.players, [alice, dan, alice, dan]);

    realm.write(() => team.players.replaceRange(0, 3, [bob, carol]));
    expect(team.players, [bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.setAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.setAll(1, [dan, alice]));
    expect(team.players, [alice, dan, alice, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.fillRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.fillRange(1, 3, dan));
    expect(team.players, [alice, dan, dan, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.insert', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.insert(1, dan));
    expect(team.players, [alice, dan, bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.insertAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.insertAll(1, [dan, bob]));
    expect(team.players, [alice, dan, bob, bob, carol, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.remove', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, dan, bob, carol, dan]; // extra dan after alice!
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 5);
    expect(team.players, players);

    expect(realm.write(() => team.players.remove(dan)), isTrue); // only removes first instance
    expect(team.players, [alice, bob, carol, dan]);

    expect(realm.write(() => team.players.remove(dan)), isTrue);
    expect(team.players, [alice, bob, carol]);

    expect(realm.write(() => team.players.remove(dan)), isFalse);

    expect(team.players.every((p) => p.isValid && p.isManaged), isTrue);

    expect(
      () => (team.players as List<Object>).indexOf("wrong type"), // ignore: unnecessary_cast
      throwsA(isA<TypeError>()),
    );

    expect(
      () => team.players.remove(Person('alice')),
      throws<RealmStateError>('Cannot call remove on a managed list with an element that is an unmanaged object'),
    );
  });

  test('ManagedRealmList.setRange', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    realm.write(() => team.players.setRange(1, 3, [dan, dan, dan, bob, carol], 2));
    expect(team.players, [alice, dan, bob, dan]);

    expect(realm.all<Person>(), players); // nothing disappeared from realm
  });

  test('ManagedRealmList.insertAll', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];
    final team = Team('Class of 92', players: players);

    realm.write(() => realm.add(team));
    expect(team.players.length, 4);
    expect(team.players, [alice, bob, carol, dan]);

    final r = Random(42);
    realm.write(() => team.players.shuffle(r));
    expect(team.players, isNot(players));
    expect(team.players, unorderedMatches(players));
  });

  test('ManagedRealmList.length= throws on increase', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team');

    realm.write(() => realm.add(team));

    expect(() => realm.write(() => team.players.length = 100), throws<RealmException>('You cannot increase length on a realm list without adding elements'));
  });

  test('ManagedRealmList.length= truncates on decrease', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team', players: [for (int i = 0; i < 100; ++i) Person('$i')]);
    realm.write(() => realm.add(team));
    expect(team.players.length, 100);
    expect(realm.all<Person>().length, 100);

    expect(realm.write(() => team.players.length = 10), 10);
    expect(team.players.length, 10);
    expect(realm.all<Person>().length, 100);
  });

  test('List.query when other objects exists', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final alice = Person('Alice');
    final bob = Person('Bob');
    final carol = Person('Carol');
    final dan = Person('Dan');
    final players = [alice, bob, carol, dan];

    final team = Team('Class of 92', players: [alice, bob]);

    realm.write(() {
      realm.addAll(players);
      return realm.add(team);
    });

    expect(realm.all<Person>(), [alice, bob, carol, dan]);
    expect(team.players.query('TRUEPREDICATE'), isNot(realm.all<Person>()));
    expect(team.players.query('TRUEPREDICATE'), [alice, bob]);
  });

  test('ManagedRealmList.indexOf', () {
    final config = Configuration.local([Team.schema, Person.schema]);
    final realm = getRealm(config);

    final team = Team('sad team', players: [for (int i = 0; i < 100; ++i) Person('$i')]);
    realm.write(() => realm.add(team));
    final players = team.players;

    expect(players, isA<RealmList<Person>>());
    expect(players.isManaged, isTrue);
    expect(players.indexOf(players.first, -1), 0); // okay to start from negative index
    expect(players.indexOf(players.first, 1), -1); // start respected
    expect(players.indexOf(players.first, 101), -1); // okay to start from non-existent index

    var index = 0;
    final r = Random(42); // deterministic
    for (final p in players) {
      expect(players.indexOf(p, r.nextInt(index + 1) - 1), index++);
    }

    // List.indexOf with wrong type of element, just returns -1.
    // Proof:
    final dartList = <int>[1, 2, 3];
    expect((dartList as List<Object>).indexOf("abc"), -1); // ignore: unnecessary_cast

    // .. but realm list behaves differently in this regard.
    expect(() => (players as List<Object>).indexOf(1), throwsA(isA<TypeError>())); // ignore: unnecessary_cast

    // .. Also it is a state error to lookup an unmanaged object in a managed list,
    // even if the static type is right.
    expect(
      () => players.indexOf(Person('10')),
      throwsA(isA<RealmStateError>().having(
        (e) => e.message,
        'message',
        'Cannot call indexOf on a managed list with an element that is an unmanaged object',
      )),
    );
  });

  test('List of nullables', () {
    final config = Configuration.local([Player.schema, Game.schema]);
    final realm = getRealm(config);

    final game = Game();
    final alice = Player('alice', game: game);
    final bob = Player('bob', game: game);
    final carol = Player('carol', game: game);
    final players = [alice, bob, carol];

    realm.write(() => realm.addAll(players));

    void checkResult(List<Player> winnerByRound, Map<Player, List<int?>> scoresByPlayer) {
      expect(game.winnerByRound, winnerByRound);
      for (final p in players) {
        expect(p.scoresByRound, scoresByPlayer[p] ?? []);
      }
    }

    checkResult([], {});

    int currentRound = 0;
    void playRound(Map<Player, int> scores) {
      realm.write(() {
        for (final p in players) {
          p.scoresByRound.add(scores[p]);
        }
        final bestResult =
            scores.entries.fold<MapEntry<Player, int>?>(null, (bestResult, result) => result.value > (bestResult?.value ?? 0) ? result : bestResult);
        game.winnerByRound[currentRound++] = bestResult!.key;
      });
    }

    playRound({alice: 1, bob: 2});

    checkResult([
      bob
    ], {
      alice: [1],
      bob: [2],
      carol: [null]
    });

    playRound({alice: 3, carol: 1});

    checkResult([
      bob,
      alice
    ], {
      alice: [1, 3],
      bob: [2, null],
      carol: [null, 1]
    });

    playRound({alice: 2, bob: 3, carol: 1});

    checkResult([
      bob,
      alice,
      bob
    ], {
      alice: [1, 3, 2],
      bob: [2, null, 3],
      carol: [null, 1, 1]
    });
  });
}
