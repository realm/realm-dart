// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:test/test.dart' hide test, throws;
import 'package:realm_dart/realm.dart';
import 'test.dart';
import 'package:realm_dart/src/results.dart';
import 'package:realm_dart/src/realm_object.dart';
import 'package:realm_dart/src/list.dart';

part 'migration_test.realm.dart';

@RealmModel()
@MapTo("Person")
class _PersonIntName {
  late int name;
}

@RealmModel()
@MapTo('Student')
class _StudentV1 {
  // See test.dart/_Student for how v2 looks like.
  // In v1, the name is a PK, in v2, name is optional and the PK
  // is an int number.

  @PrimaryKey()
  late String name;
  late int? yearOfBirth;
}

@RealmModel()
@MapTo('MyObject')
class _MyObjectWithTypo {
  late String nmae;

  late int vlaue;
}

@RealmModel()
@MapTo('MyObject')
class _MyObjectWithoutTypo {
  late String name;

  late int value;
}

@RealmModel()
@MapTo('MyObject')
class _MyObjectWithoutValue {
  late String name;
}

void main() {
  setupTests();

  test('Configuration.migrationCallback executed when schema version changes', () {
    final config1 = Configuration.local([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration.local([PersonIntName.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });

  test('Configuration.migrationCallback executed when schema changes', () {
    final config1 = Configuration.local([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration.local([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });

  test('Configuration.migrationCallback not invoked when schemaVersion is the same', () {
    final config1 = Configuration.local([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    // Keep schema version the same
    final config2 = Configuration.local([Person.schema], schemaVersion: 1, migrationCallback: (migration, oldVersion) {
      invoked = true;
    });

    expect(
        () => getRealm(config2),
        throwsA(isA<MigrationRequiredException>()
            .having((e) => e.message, 'message', contains('Migration is required due to the following errors'))
            .having((e) => e.helpLink, 'helpLink', isNotNull)));
    expect(invoked, false);
  });

  test('Migration can change primary key type', () {
    final v1Config = Configuration.local([PersonIntName.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);

    for (var i = 0; i < 10; i++) {
      v1Realm.write(() {
        v1Realm.add(PersonIntName(i));
      });
    }

    v1Realm.close();

    final v2Config = Configuration.local([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      final oldPeople = migration.oldRealm.all('Person');
      final newPeople = migration.newRealm.all<Person>();

      for (var i = 0; i < oldPeople.length; i++) {
        final oldPerson = oldPeople[i];
        final newPerson = newPeople[i];

        newPerson.name = oldPerson.dynamic.get<int>('name').toString();
      }
    });

    final v2Realm = getRealm(v2Config);
    final peopleNames = v2Realm.all<Person>().map((e) => e.name);
    final expectedNames = [for (var i = 0; i < 10; i += 1) i.toString()];

    expect(peopleNames, expectedNames);
  });

  test('Migration can change primary key to another property', () {
    final v1Config = Configuration.local([StudentV1.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.write(() {
      v1Realm.add(StudentV1('Peter'));
      v1Realm.add(StudentV1('Alice'));
      v1Realm.add(StudentV1('John'));
    });

    v1Realm.close();

    final v2Config = Configuration.local([Student.schema, School.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      // We want to assign numbers in ascending order
      final oldStudents = migration.oldRealm.all('Student').query('TRUEPREDICATE SORT(name ASC)');
      final newStudents = migration.newRealm.all<Student>().query('TRUEPREDICATE sort(name ASC)');

      for (var i = 0; i < oldStudents.length; i++) {
        final oldStudent = oldStudents[i];
        final newStudent = newStudents[i];

        newStudent.number = i;
      }
    });

    final v2Realm = getRealm(v2Config);
    final students = v2Realm.all<Student>().query('TRUEPREDICATE sort(number ASC)');

    expect(students[0].name, 'Alice');
    expect(students[0].number, 0);

    expect(students[1].name, 'John');
    expect(students[1].number, 1);

    expect(students[2].name, 'Peter');
    expect(students[2].number, 2);
  });

  test('Migration can find old object in new realm', () {
    final v1Config = Configuration.local([StudentV1.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);

    for (var i = 0; i < 10; i++) {
      v1Realm.write(() {
        v1Realm.add(StudentV1(i.toString(), yearOfBirth: 2000 + i));
      });
    }

    v1Realm.close();

    final v2Config = Configuration.local([Student.schema, School.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      final oldStudents = migration.oldRealm.all('Student');

      var number = 0;
      for (final student in oldStudents) {
        final newStudent = migration.findInNewRealm<Student>(student);
        expect(newStudent, isNotNull);
        expect(newStudent!.name, student.dynamic.get<String>('name'));
        expect(newStudent.yearOfBirth, student.dynamic.get<int?>('yearOfBirth'));

        newStudent.number = number++;
      }
    });

    final v2Realm = getRealm(v2Config);
    final studentNumbers = v2Realm.all<Student>().map((e) => e.number);
    final expectedNumbers = [for (var i = 0; i < 10; i += 1) i];

    expect(studentNumbers, expectedNumbers);
  });

  test('Migration can rename property', () {
    final v1Config = Configuration.local([MyObjectWithTypo.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);

    v1Realm.write(() {
      v1Realm.add(MyObjectWithTypo('Peter', 123));
      v1Realm.add(MyObjectWithTypo('George', 456));
    });

    v1Realm.close();

    final v2Config = Configuration.local([MyObjectWithoutTypo.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      migration.renameProperty('MyObject', 'nmae', 'name');
    });

    final v2Realm = getRealm(v2Config);

    // We renamed 'nmae' to 'name', but don't rename 'vlaue' to 'value' so we expect
    // the names to have been preserved, but the values - not.
    final names = v2Realm.all<MyObjectWithoutTypo>().map((e) => e.name);
    final values = v2Realm.all<MyObjectWithoutTypo>().map((e) => e.value);

    expect(names, ['Peter', 'George']);
    expect(values, [0, 0]);
  });

  test('Migration renameProperty with invalid argumetns', () {
    final v1Config = Configuration.local([MyObjectWithTypo.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.close();

    final renameToNonExistentConfig = Configuration.local([MyObjectWithoutTypo.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      migration.renameProperty('MyObject', 'nmae', 'non-existent');
    });

    expect(() => getRealm(renameToNonExistentConfig), throws<RealmException>("Renamed property 'MyObject.non-existent' does not exist"));

    final renameFromNonExistentConfig = Configuration.local([MyObjectWithoutTypo.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      migration.renameProperty('MyObject', 'non-existent', 'name');
    });

    expect(
        () => getRealm(renameFromNonExistentConfig), throws<UserCallbackException>("Cannot rename property 'MyObject.non-existent' because it does not exist"));

    final renameNonExistentClassClass = Configuration.local([MyObjectWithoutTypo.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      migration.renameProperty('non-existent', 'foo', 'bar');
    });

    expect(() => getRealm(renameNonExistentClassClass),
        throws<UserCallbackException>("Cannot rename properties for type 'non-existent' because it does not exist"));
  });

  test('Migration error in callback gets propagated correctly', () {
    final v1Config = Configuration.local([Person.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.close();

    final userError = Exception('this is a user error');

    final v2Config = Configuration.local([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      throw userError;
    });

    expect(() => getRealm(v2Config), throwsA(isA<UserCallbackException>().having((error) => error.userException, 'userException', userError)));
  });

  test('Migration when type is not removed table remains', () {
    final v1Config = Configuration.local([Person.schema, Dog.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.write(() {
      v1Realm.add(Dog('Fido'));
      v1Realm.add(Person('Peter'));
    });

    v1Realm.close();

    final v2Config = Configuration.local([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      // We remove the Dog type from the list of types, but don't explicitly delete the table.
      // Core will not remove it automatically, so it will still be there, even if it's invisible
      // when opening the Realm with a specific schema.
      expect(migration.oldRealm.schema.length, 2);
      expect(migration.newRealm.schema.length, 1);
    });

    final v2Realm = getRealm(v2Config);
    expect(v2Realm.schema.length, 1);
    v2Realm.close();

    // We reopen the Realm as dynamic - the schema will be read from disk and the Dog type should still be there.
    final dynamicConfig = Configuration.local([], schemaVersion: 2);
    final dynamicRealm = getRealm(dynamicConfig);

    expect(dynamicRealm.schema.length, 2);

    final dogs = dynamicRealm.dynamic.all('Dog');
    expect(dogs.length, 1);
    expect(dogs[0].dynamic.get<String>('name'), 'Fido');
  });

  test('Migration when type is removed table is removed as well', () {
    final v1Config = Configuration.local([Person.schema, Dog.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.write(() {
      v1Realm.add(Dog('Fido'));
      v1Realm.add(Person('Peter'));
    });

    v1Realm.close();

    // Verify that just removing a type does not actually delete it.
    final v2Config = Configuration.local([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(migration.oldRealm.schema.length, 2);
      expect(migration.newRealm.schema.length, 1);
    });

    final v2Realm = getRealm(v2Config);
    expect(v2Realm.schema.length, 1);
    v2Realm.close();

    // We reopen the Realm as dynamic - the schema will be read from disk and the Dog type should be there because we didn't remove it
    final v2DynamicConfig = Configuration.local([], schemaVersion: 2);
    final v2DynamicRealm = getRealm(v2DynamicConfig);

    expect(v2DynamicRealm.schema.length, 2);
    expect(v2DynamicRealm.schema.any((element) => element.name == 'Dog'), true);
    expect(v2DynamicRealm.dynamic.all('Dog').single.dynamic.get('name'), 'Fido');

    v2DynamicRealm.close();

    // Verify that calling deleteType deletes the table and its data

    final v3Config = Configuration.local([Person.schema], schemaVersion: 3, migrationCallback: ((migration, oldSchemaVersion) {
      expect(migration.oldRealm.schema.length, 2);
      expect(migration.newRealm.schema.length, 1);

      expect(migration.deleteType('Dog'), true);
      expect(migration.deleteType('i-dont-exist'), false);
    }));

    final v3Realm = getRealm(v3Config);
    expect(v3Realm.schema.length, 1);
    v3Realm.close();

    // We reopen the Realm as dynamic - the schema will be read from disk and the Dog type should be there because we didn't remove it
    final v3DynamicConfig = Configuration.local([], schemaVersion: 2);
    final v3DynamicRealm = getRealm(v3DynamicConfig);

    expect(v3DynamicRealm.schema.length, 1);
    expect(v3DynamicRealm.schema.any((element) => element.name == 'Dog'), false);
    expect(() => v3DynamicRealm.dynamic.all('Dog'), throws<RealmError>("Object type Dog not configured in the current Realm's schema"));
  });

  test('Migration when property is removed, column gets removed as well', () {
    final v1Config = Configuration.local([MyObjectWithoutTypo.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.write(() {
      v1Realm.add(MyObjectWithoutTypo('name', 123));
    });

    v1Realm.close();

    final v2Config = Configuration.local([MyObjectWithoutValue.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(migration.oldRealm.schema.single.length, 2);
      expect(migration.newRealm.schema.single.length, 1);
    });

    final v2Realm = getRealm(v2Config);
    expect(v2Realm.schema.single.length, 1);
    expect(v2Realm.all<MyObjectWithoutValue>().single.name, 'name');
    v2Realm.close();

    // We reopen the Realm as dynamic - the schema will be read from disk and the Dog type should be gone because we explicitly removed it
    final dynamicConfig = Configuration.local([], schemaVersion: 2);
    final dynamicRealm = getRealm(dynamicConfig);

    expect(dynamicRealm.schema.single.length, 1);
    expect(dynamicRealm.dynamic.all('MyObject').single.dynamic.get<String>('name'), 'name');
  });

  test("Migration doesn't hold on to handles", () {
    final v1Config = Configuration.local([Person.schema, Team.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);

    v1Realm.write(() {
      v1Realm.add(Team('Lakers', players: [Person('Kobe')]));
    });

    v1Realm.close();

    late RealmObject oldTeam;
    late Team newTeam;

    late RealmResults<RealmObject> oldTeams;
    late RealmResults<Team> newTeams;

    late RealmList<RealmObject> oldPlayers;
    late RealmList<Person> newPlayers;

    final v2Config = Configuration.local([Person.schema, Team.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      oldTeams = migration.oldRealm.all('Team');
      newTeams = migration.newRealm.all();

      oldTeam = oldTeams.single;
      newTeam = newTeams.single;

      oldPlayers = oldTeam.dynamic.getList('players');
      newPlayers = newTeam.players;
    });

    final v2Realm = getRealm(v2Config);

    expect(() => oldTeam.handle.released, throws<RealmClosedError>());
    expect(() => newTeam.handle.released, throws<RealmClosedError>());

    expect(() => oldTeams.handle.released, throws<RealmClosedError>());
    expect(() => newTeams.handle.released, throws<RealmClosedError>());

    expect(() => oldPlayers.handle.released, throws<RealmClosedError>());
    expect(() => newPlayers.handle.released, throws<RealmClosedError>());
  });

  test('LocalConfiguration.shouldDeleteIfMigrationNeeded deletes Realm', () {
    final config = Configuration.local([PersonIntName.schema]);
    final realm = getRealm(config);
    realm.write(() {
      realm.add(PersonIntName(1));
    });
    realm.close();

    final config2 = Configuration.local([Person.schema], shouldDeleteIfMigrationNeeded: true);
    final realm2 = getRealm(config2);

    expect(realm2.all<Person>().length, 0);

    realm2.write(() {
      realm2.add(Person('1'));
    });
  });

  test("LocalConfiguration.shouldDeleteIfMigrationNeeded doesn't delete if no migration is needed", () {
    final config = Configuration.local([Person.schema]);
    final realm = getRealm(config);
    realm.write(() {
      realm.add(Person("abc"));
    });
    realm.close();

    final config2 = Configuration.local([Person.schema], shouldDeleteIfMigrationNeeded: true);
    final realm2 = getRealm(config2);

    expect(realm2.all<Person>().length, 1);
    expect(realm2.all<Person>()[0].name, 'abc');
  });

  test("LocalConfiguration.shouldDeleteIfMigrationNeeded deletes file on schema version bump", () {
    final config = Configuration.local([Person.schema], schemaVersion: 1);
    final realm = getRealm(config);
    realm.write(() {
      realm.add(Person("abc"));
    });
    realm.close();

    final config2 = Configuration.local([Person.schema], schemaVersion: 2, shouldDeleteIfMigrationNeeded: true);
    final realm2 = getRealm(config2);

    expect(realm2.all<Person>().length, 0);
  });
}
