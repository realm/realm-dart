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

// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';

part 'migration_test.g.dart';

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

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Configuration.migrationCallback executed when schema version changes', () {
    final config1 = Configuration([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration([PersonIntName.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });

  test('Configuration.migrationCallback executed when schema changes', () {
    final config1 = Configuration([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });

  test('Configuration.migrationCallback not invoked when schemaVersion is the same', () {
    final config1 = Configuration([PersonIntName.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    // Keep schema version the same
    final config2 = Configuration([Person.schema], schemaVersion: 1, migrationCallback: (migration, oldVersion) {
      invoked = true;
    });

    expect(() => getRealm(config2), throws<RealmException>('Migration is required due to the following errors'));
    expect(invoked, false);
  });

  test('Migration can read old data', () {
    final v1Config = Configuration([PersonIntName.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);

    for (var i = 0; i < 10; i++) {
      v1Realm.write(() {
        v1Realm.add(PersonIntName(i));
      });
    }

    v1Realm.close();

    final v2Config = Configuration([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      final oldPeople = migration.oldRealm.dynamic.all('Person');
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

  test('Migration can change primary keys', () {
    final v1Config = Configuration([StudentV1.schema], schemaVersion: 1);
    final v1Realm = getRealm(v1Config);
    v1Realm.write(() {
      v1Realm.add(StudentV1('Peter'));
      v1Realm.add(StudentV1('Alice'));
      v1Realm.add(StudentV1('John'));
    });

    v1Realm.close();

    final v2Config = Configuration([Student.schema, School.schema], schemaVersion: 2, migrationCallback: (migration, oldSchemaVersion) {
      expect(oldSchemaVersion, 1);

      // We want to assign numbers in ascending order
      final oldStudents = migration.oldRealm.dynamic.all('Student').query('TRUEPREDICATE SORT(name ASC)');
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
  }, skip: 'This crashes because the results are not closed at the end of the migration callback: https://github.com/realm/realm-dart/issues/527');
}
