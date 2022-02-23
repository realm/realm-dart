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

import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  setupTests(args);

  test('Lists add object with a list property', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    expect(teams.length, 1);
    expect(teams[0].name, "Ferrari");
    expect(teams[0].players, isNotNull);
    expect(teams[0].players.length, 0);
    realm.close();
  });

  test('Lists get set', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('Lists get invalid index throws exception', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => players[-1], throws<RealmException>("Index out of range"));
    expect(() => players[800], throws<RealmException>());
    realm.close();
  });

  test('Lists set invalid index throws', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final team = Team("Ferrari");
    realm.write(() => realm.add(team));

    final teams = realm.all<Team>();
    final players = teams[0].players;

    expect(() => realm.write(() => players[-1] = Person('')), throws<RealmException>("Index out of range"));
    expect(() => realm.write(() => players[800] = Person('')), throws<RealmException>());
    realm.close();
  });

  test('List clear items from list', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('List clear - same list related to two objects', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('List clear - same item added to two lists', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    realm.close();
  });

  test('List clear in closed realm - expected exception', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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

    realm = Realm(config);

    //Teams must be reloaded since realm was reopened
    teams = realm.all<Team>();

    //Ensure that the team is still related to the player
    expect(teams.length, 1);
    expect(teams[0].players.length, 1);
    realm.close();
  });

  test('Read list property of a deleted object', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var teams = realm.all<Team>();
    realm.write(() => realm.delete(team));
    expect(() => team.players, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));
    realm.close();
  });

  test('Delete a list of objects through a deleted parent', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne");
    realm.write(() => realm.add(team));
    var players = team.players;
    realm.write(() => realm.delete(team));
    expect(() => realm.write(() => realm.deleteMany(players)), throws<RealmException>("Access to invalidated Collection object"));
    realm.close();
  });

  test('Get length of list property on a deleted object', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    var team = Team("TeamOne")..players.add(Person("Nikos"));
    realm.write(() {
      realm.add(team);
      realm.delete(team);
    });
    expect(() => team.players.length, throws<RealmException>("Accessing object of type Team which has been invalidated or deleted"));

    realm.close();
  });

  test('List isValid', () {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

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
    final players = teams[0].players as RealmList<Person>;
    expect(players.isValid, true);
    realm.close();
    expect(players.isValid, false);
  });

  test('List notifications', () async {
    var config = Configuration([Team.schema, Person.schema]);
    var realm = Realm(config);

    final team = Team('t1', players: [Person("p1")]);
    realm.write(() => realm.add(team));

    var firstCall = true;
    final subscription = (team.players as RealmList<Person>).changes.listen((changes) {
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
    realm.close();
  });

  test('List query', () {
    final config = Configuration([Team.schema, Person.schema]);
    final realm = Realm(config);

    final person = Person('John');
    final team = Team('team1', players: [
      Person('Pavel'),
      person,
      Person('Alex'),
    ]);

    realm.write(() => realm.add(team));

    // TODO: Get rid of cast, once type signature of team.players is a RealmList<Person>
    // as opposed to the List<Person> we have today.
    final result = (team.players as RealmList<Person>).query(r'name BEGINSWITH $0', ['J']);

    expect(result, [person]);

    realm.close();
  });
}
