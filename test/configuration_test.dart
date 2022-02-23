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
    Configuration config = Configuration([Car.schema]);
    expect(config.path, endsWith('.realm'));

    const path = "my/path/default.realm";
    config.path = path;
    expect(config.path, equals(path));
  });

  test('Configuration get/set schema version', () {
    Configuration config = Configuration([Car.schema]);
    expect(config.schemaVersion, equals(0));

    config.schemaVersion = 3;
    expect(config.schemaVersion, equals(3));
  });

  test('Configuration readOnly - opening non existing realm throws', () {
    Configuration config = Configuration([Car.schema], readOnly: true);
    expect(() => Realm(config), throws<RealmException>("at path '${config.path}' does not exist"));
  });

  test('Configuration readOnly - open existing realm with read-only config', () {
    Configuration config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.close();

    // Open an existing realm as readonly.
    config = Configuration([Car.schema], readOnly: true);
    realm = Realm(config);
    realm.close();
  });

  test('Configuration readOnly - reading is possible', () {
    Configuration config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.write(() => realm.add(Car("Mustang")));
    realm.close();

    config.isReadOnly = true;
    realm = Realm(config);
    var cars = realm.all<Car>();
    realm.close();
  });

  test('Configuration readOnly - writing on read-only Realms throws', () {
    Configuration config = Configuration([Car.schema]);
    var realm = Realm(config);
    realm.close();

    config = Configuration([Car.schema], readOnly: true);
    realm = Realm(config);
    expect(() => realm.write(() {}), throws<RealmException>("Can't perform transactions on read-only Realms."));
    realm.close();
  });
}
