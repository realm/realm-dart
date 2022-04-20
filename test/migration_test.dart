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
import 'test.dart' hide Person;

import 'test.dart' as models show Person;

part 'migration_test.g.dart';

@RealmModel()
@MapTo("Person")
class _PersonIntName {
  late int name;
}

Future<void> main([List<String>? args]) async {
  print("Current PID $pid");

  await setupTests(args);

  test('Configuration.migrationCallback executed when schema version changes', () {
    final config1 = Configuration([Person.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration([Person.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });

  test('Configuration.migrationCallback executed when schema changes', () {
    final config1 = Configuration([Person.schema], schemaVersion: 1);
    getRealm(config1).close();

    var invoked = false;
    final config2 = Configuration([models.Person.schema], schemaVersion: 2, migrationCallback: (migration, oldVersion) {
      invoked = true;
      expect(oldVersion, 1);
    });

    getRealm(config2);
    expect(invoked, true);
  });
}
