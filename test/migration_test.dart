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

import 'dart:async';
import 'dart:io';
import 'package:test/test.dart' hide test, throws;
import '../lib/realm.dart';
import 'test.dart';
import '../lib/src/results.dart';

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

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

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

    expect(() => getRealm(config2), throws<RealmException>('Migration is required due to the following errors'));
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
      final oldStudents = migration.oldRealm.dynamic.all('Student').query('TRUEPREDICATE SORT(name ASC)');
      final newStudents = migration.newRealm.all<Student>().query('TRUEPREDICATE sort(name ASC)');

      for (var i = 0; i < oldStudents.length; i++) {
        final oldStudent = oldStudents[i];
        final newStudent = newStudents[i];

        newStudent.number = i;
      }

      // TODO: this is a hack to get the test working until https://github.com/realm/realm-dart/issues/527 is
      // implemented. The issue is that the results are not released at the end of the migration, which will
      // trigger the notification mechanics when the write transaction is committed. This will cause the queries
      // to be reevaluated, which is no longer possible since the tables have changed and the columns don't match.
      oldStudents.handle.release();
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

      final oldStudents = migration.oldRealm.dynamic.all('Student');

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

    // Verify that calling removeType removes the table

    final v3Config = Configuration.local([Person.schema], schemaVersion: 3, migrationCallback: ((migration, oldSchemaVersion) {
      expect(migration.oldRealm.schema.length, 2);
      expect(migration.newRealm.schema.length, 1);

      expect(migration.removeType('Dog'), true);
      expect(migration.removeType('i-dont-exist'), false);
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
      expect(migration.oldRealm.schema.single.properties.length, 2);
      expect(migration.newRealm.schema.single.properties.length, 1);
    });

    final v2Realm = getRealm(v2Config);
    expect(v2Realm.schema.single.properties.length, 1);
    expect(v2Realm.all<MyObjectWithoutValue>().single.name, 'name');
    v2Realm.close();

    // We reopen the Realm as dynamic - the schema will be read from disk and the Dog type should be gone because we explicitly removed it
    final dynamicConfig = Configuration.local([], schemaVersion: 2);
    final dynamicRealm = getRealm(dynamicConfig);

    expect(dynamicRealm.schema.single.properties.length, 1);
    expect(dynamicRealm.dynamic.all('MyObject').single.dynamic.get<String>('name'), 'name');
  });
}
