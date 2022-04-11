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

  await setupTests(args);

  test('Configuration can be created', () {
    Configuration([Car.schema]);
  });

  test('Configuration exception if no schema', () {
    expect(() => Configuration([]), throws<RealmException>());
  });

  test('Configuration default path', () {
    if (Platform.isAndroid || Platform.isIOS) {
      expect(Configuration.defaultPath, endsWith(".realm"));
      expect(Configuration.defaultPath, startsWith("/"), reason: "on Android and iOS the default path should contain the path to the user data directory");
    } else {
      expect(Configuration.defaultPath, endsWith(".realm"));
    }
  });

  test('Configuration files path', () {
    if (Platform.isAndroid || Platform.isIOS) {
      expect(Configuration.filesPath, isNot(endsWith(".realm")), reason: "on Android and iOS the files path should be a directory");
      expect(Configuration.filesPath, startsWith("/"), reason: "on Android and iOS the files path should be a directory");
    } else {
      expect(Configuration.filesPath, equals(""), reason: "on Dart standalone the files path should be an empty string");
    }
  });

  test('Configuration get/set path', () {
    final config = Configuration([Car.schema]);
    expect(config.path, endsWith('.realm'));

    const path = "my/path/default.realm";
    final explicitPathConfig = Configuration([Car.schema], path: path);
    expect(explicitPathConfig.path, equals(path));
  });

  test('Configuration get/set schema version', () {
    final config = Configuration([Car.schema]);
    expect(config.schemaVersion, equals(0));

    final explicitSchemaConfig = Configuration([Car.schema], schemaVersion: 3);
    expect(explicitSchemaConfig.schemaVersion, equals(3));
  });

  test('Configuration readOnly - opening non existing realm throws', () {
    Configuration config = Configuration([Car.schema], isReadOnly: true);
    expect(() => getRealm(config), throws<RealmException>("at path '${config.path}' does not exist"));
  });

  test('Configuration readOnly - open existing realm with read-only config', () {
    Configuration config = Configuration([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    // Open an existing realm as readonly.
    config = Configuration([Car.schema], isReadOnly: true);
    realm = getRealm(config);
  });

  test('Configuration readOnly - reading is possible', () {
    Configuration config = Configuration([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Mustang")));
    realm.close();

    config = Configuration([Car.schema], isReadOnly: true);
    realm = getRealm(config);
    var cars = realm.all<Car>();
    expect(cars.length, 1);
  });

  test('Configuration readOnly - writing on read-only Realms throws', () {
    Configuration config = Configuration([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    config = Configuration([Car.schema], isReadOnly: true);
    realm = getRealm(config);
    expect(() => realm.write(() {}), throws<RealmException>("Can't perform transactions on read-only Realms."));
  });

  test('Configuration inMemory - no files after closing realm', () {
    Configuration config = Configuration([Car.schema], isInMemory: true);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car('Tesla')));
    realm.close();
    expect(Realm.existsSync(config.path), false);
  });

  test('Configuration inMemory can not be readOnly', () {
    Configuration config = Configuration([Car.schema], isInMemory: true);
    final realm = getRealm(config);

    expect(() {
      config = Configuration([Car.schema], isReadOnly: true);
      getRealm(config);
    }, throws<RealmException>("Realm at path '${config.path}' already opened with different read permissions"));
  });

  test('Configuration - FIFO files fallback path', () {
    Configuration config = Configuration([Car.schema], fifoFilesFallbackPath: "./fifo_folder");
    final realm = getRealm(config);
  });

  test('Configuration.operator== equal configs', () {
    final config = Configuration([Dog.schema, Person.schema]);
    final realm = getRealm(config);
    expect(config, realm.config);
  });

  test('Configuration.operator== different configs', () {
    var config = Configuration([Dog.schema, Person.schema]);
    final realm1 = getRealm(config);
    config = Configuration([Dog.schema, Person.schema]);
    final realm2 = getRealm(config);
    expect(realm1.config, isNot(realm2.config));
  });
}
