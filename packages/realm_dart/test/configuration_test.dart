// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:math';
import 'package:test/test.dart' hide test, throws;
import 'package:path/path.dart' as path;
import 'package:realm_dart/realm.dart';
import 'test.dart';

void main() {
  setupTests();

  test('Configuration can be created', () {
    Configuration.local([Car.schema]);
  });

  test('Configuration default path', () {
    final config = Configuration.local([Car.schema]);
    if (Platform.isAndroid || Platform.isIOS) {
      expect(config.path, endsWith(".realm"));
      expect(config.path, startsWith("/"), reason: "on Android and iOS the default path should contain the path to the user data directory");
    } else {
      expect(config.path, endsWith(".realm"));
    }
  });

  test('Configuration defaultRealmName can be set for LocalConfiguration', () {
    var customDefaultRealmName = "myRealmName.realm";
    Configuration.defaultRealmName = customDefaultRealmName;
    final config = Configuration.local([Car.schema]);
    expect(path.basename(config.path), path.basename(customDefaultRealmName));

    final realm = getRealm(config);
    expect(path.basename(realm.config.path), customDefaultRealmName);

    //set a new defaultRealmName
    customDefaultRealmName = "anotherRealmName.realm";
    Configuration.defaultRealmName = customDefaultRealmName;
    final config1 = Configuration.local([Car.schema]);
    final realm1 = getRealm(config1);
    expect(path.basename(realm1.config.path), customDefaultRealmName);
  });

  test('Configuration defaultRealmPath can be set for LocalConfiguration', () async {
    final customDefaultRealmPath = path.join((await Directory.systemTemp.createTemp()).path, Configuration.defaultRealmName);
    Configuration.defaultRealmPath = customDefaultRealmPath;
    final config = Configuration.local([Car.schema]);
    expect(path.dirname(config.path), path.dirname(customDefaultRealmPath));

    final realm = getRealm(config);
    expect(path.dirname(realm.config.path), path.dirname(customDefaultRealmPath));

    //set a new defaultRealmPath
    final customDefaultRealmPath1 = path.join((await Directory.systemTemp.createTemp()).path, Configuration.defaultRealmName);
    Configuration.defaultRealmPath = customDefaultRealmPath1;
    final config1 = Configuration.local([Car.schema]);
    final realm1 = getRealm(config1);
    expect(path.dirname(realm1.config.path), path.dirname(customDefaultRealmPath1));
  });

  baasTest('Configuration defaultRealmName can be set for FlexibleSyncConfiguration', (configuration) async {
    final app = App(configuration);
    final user = await app.logIn(Credentials.anonymous());

    var customDefaultRealmName = "myRealmName.realm";
    Configuration.defaultRealmName = customDefaultRealmName;
    var config = Configuration.flexibleSync(user, getSyncSchema());
    expect(path.basename(config.path), path.basename(customDefaultRealmName));

    var realm = getRealm(config);
    expect(path.basename(realm.config.path), customDefaultRealmName);

    //set a new defaultRealmName
    customDefaultRealmName = "anotherRealmName.realm";
    Configuration.defaultRealmName = customDefaultRealmName;
    config = Configuration.flexibleSync(user, getSyncSchema());
    realm = getRealm(config);
    expect(path.basename(realm.config.path), customDefaultRealmName);
  });

  baasTest('Configuration defaultRealmPath can be set for FlexibleSyncConfiguration', (_) async {
    var customDefaultRealmPath = path.join((await Directory.systemTemp.createTemp()).path, Configuration.defaultRealmName);
    Configuration.defaultRealmPath = customDefaultRealmPath;

    final appClientId = baasHelper!.getClientAppId(appName: AppName.flexible);
    final baasUrl = baasHelper!.baseUrl;
    var appConfig = AppConfiguration(appClientId, baseUrl: Uri.parse(baasUrl));
    expect(appConfig.baseFilePath.path, path.dirname(customDefaultRealmPath));

    var app = App(appConfig);
    var user = await app.logIn(Credentials.anonymous());

    var config = Configuration.flexibleSync(user, getSyncSchema());
    expect(path.dirname(config.path), startsWith(path.dirname(customDefaultRealmPath)));

    var realm = getRealm(config);
    expect(path.dirname(realm.config.path), startsWith(path.dirname(customDefaultRealmPath)));

    //set a new defaultRealmPath
    customDefaultRealmPath = path.join((await Directory.systemTemp.createTemp()).path, Configuration.defaultRealmName);
    Configuration.defaultRealmPath = customDefaultRealmPath;

    appConfig = AppConfiguration(appClientId, baseUrl: Uri.parse(baasUrl));
    expect(appConfig.baseFilePath.path, path.dirname(customDefaultRealmPath));

    clearCachedApps();

    app = App(appConfig);
    user = await app.logIn(Credentials.anonymous());
    config = Configuration.flexibleSync(user, getSyncSchema());
    realm = getRealm(config);
    expect(path.dirname(realm.config.path), startsWith(path.dirname(customDefaultRealmPath)));
  });

  test('Configuration get/set path', () {
    final config = Configuration.local([Car.schema]);
    expect(config.path, endsWith('.realm'));

    const path = "my/path/default.realm";
    final explicitPathConfig = Configuration.local([Car.schema], path: path);
    expect(explicitPathConfig.path, equals(path));
  });

  test('Configuration get/set schema version', () {
    final config = Configuration.local([Car.schema]);
    expect(config.schemaVersion, equals(0));

    final explicitSchemaConfig = Configuration.local([Car.schema], schemaVersion: 3);
    expect(explicitSchemaConfig.schemaVersion, equals(3));
  });

  test('Configuration readOnly - opening non existing realm throws', () {
    Configuration config = Configuration.local([Car.schema], isReadOnly: true);
    expect(() => getRealm(config), throws<RealmException>("Failed to open Realm file at path '${config.path}': No such file or directory"));
  });

  test('Configuration readOnly - open existing realm with read-only config', () {
    Configuration config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.close();

    // Open an existing realm as readonly.
    config = Configuration.local([Car.schema], isReadOnly: true);
    realm = getRealm(config);
  });

  test('Configuration readOnly - reading is possible', () {
    Configuration config = Configuration.local([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car("Mustang")));
    realm.close();

    config = Configuration.local([Car.schema], isReadOnly: true);
    realm = getRealm(config);
    var cars = realm.all<Car>();
    expect(cars.length, 1);
  });

  test('Configuration inMemory - no files after closing realm', () {
    Configuration config = Configuration.inMemory([Car.schema]);
    var realm = getRealm(config);
    realm.write(() => realm.add(Car('Tesla')));
    realm.close();
    expect(Realm.existsSync(config.path), false);
  });

  test('Configuration inMemory can not be readOnly', () {
    Configuration config = Configuration.inMemory([Car.schema]);
    final realm = getRealm(config);

    expect(() {
      config = Configuration.local([Car.schema], isReadOnly: true);
      getRealm(config);
    }, throws<RealmException>("Realm at path '${config.path}' already opened with different read permissions"));
  });

  test('Configuration - FIFO files fallback path', () {
    Configuration config = Configuration.local([Car.schema], fifoFilesFallbackPath: "./fifo_folder");
    final realm = getRealm(config);
  });

  test('Configuration.operator== equal configs', () {
    final config = Configuration.local([Dog.schema, Person.schema]);
    final realm = getRealm(config);
    expect(config, realm.config);
  });

  test('Configuration.operator== different configs', () {
    var config = Configuration.local([Dog.schema, Person.schema]);
    final realm1 = getRealm(config);
    config = Configuration.local([Dog.schema, Person.schema]);
    final realm2 = getRealm(config);
    expect(realm1.config, isNot(realm2.config));
  });

  test('Configuration - disableFormatUpgrade=true throws error', () async {
    var config = Configuration.local([Car.schema], disableFormatUpgrade: true);
    await copyFile('test/data/realm_files/old-format.realm', config.path);
    expect(() => getRealm(config), throws<RealmException>("Database upgrade required but prohibited."));
  });

  test('Configuration - disableFormatUpgrade=false', () async {
    var config = Configuration.local([Car.schema], disableFormatUpgrade: false);
    await copyFile('test/data/realm_files/old-format.realm', config.path);
    expect(() => getRealm(config), isNot(throwsException));
  });

  test('Configuration.initialDataCallback invoked', () {
    var invoked = false;
    var config = Configuration.local([Dog.schema, Person.schema], initialDataCallback: (realm) {
      invoked = true;
      realm.add(Dog('fido', owner: Person('john')));
    });

    final realm = getRealm(config);
    expect(invoked, true);

    final people = realm.all<Person>();
    expect(people.length, 1);
    expect(people[0].name, 'john');

    final dogs = realm.all<Dog>();
    expect(dogs.length, 1);
    expect(dogs[0].name, 'fido');
  });

  test('Configuration.initialDataCallback not invoked for existing realm', () {
    var invoked = false;
    final config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      invoked = true;
      realm.add(Person('peter'));
    });

    final realm = getRealm(config);
    expect(invoked, true);
    expect(realm.all<Person>().length, 1);
    realm.close();

    var invokedAgain = false;
    final configAgain = Configuration.local([Person.schema], initialDataCallback: (realm) {
      invokedAgain = true;
      realm.add(Person('p1'));
      realm.add(Person('p2'));
    });

    final realmAgain = getRealm(configAgain);
    expect(invokedAgain, false);
    expect(realmAgain.all<Person>().length, 1);
  });

  test('Configuration.initialDataCallback with error', () {
    var invoked = false;
    var config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      invoked = true;
      realm.add(Person('p1'));
      throw Exception('very careless developer');
    });

    expect(
        () => getRealm(config),
        throwsA(isA<UserCallbackException>()
            .having((e) => e.message, 'message', contains('An exception occurred while executing a user-provided callback.'))
            .having((e) => e.userException.toString(), 'userException', contains('very careless developer'))));
    expect(invoked, true);

    // No data should have been written to the Realm
    config = Configuration.local([Person.schema]);
    final realm = getRealm(config);

    expect(realm.all<Person>().length, 0);
  });

  test('Configuration.initialDataCallback with error, invoked on second attempt', () {
    var invoked = false;
    var config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      invoked = true;
      realm.add(Person('p1'));
      throw Exception('very careless developer');
    });

    expect(() => getRealm(config), throws<UserCallbackException>('An exception occurred while executing a user-provided callback'));
    expect(invoked, true);

    var secondInvoked = false;
    config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      secondInvoked = true;
      realm.add(Person('p1'));
    });

    final realm = getRealm(config);
    expect(secondInvoked, true);
    expect(realm.all<Person>().length, 1);
  });

  test('Configuration.initialDataCallback is a no-op when opening an empty existing Realm', () {
    var config = Configuration.local([Person.schema]);

    // Create the Realm and close it
    getRealm(config).close();

    var invoked = false;
    config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      invoked = true;
      realm.add(Person("john"));
    });

    // Even though the Realm was empty, since we're not creating it,
    // we expect initialDataCallback not to be invoked.
    final realm = getRealm(config);

    expect(invoked, false);
    expect(realm.all<Person>().length, 0);
  });

  test('Configuration.initialDataCallback can use non-add API in callback', () {
    Exception? callbackEx;
    final config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      try {
        final george = realm.add(Person("George"));

        // We try to make sure some basic Realm API are available in the callback
        expect(realm.all<Person>().length, 1);
        realm.delete(george);
      } on Exception catch (ex) {
        callbackEx = ex;
      }
    });

    final realm = getRealm(config);

    expect(callbackEx, null);
    expect(realm.all<Person>().length, 0);
  });

  test('Configuration.initialDataCallback realm.write fails', () {
    Exception? callbackEx;
    final config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      try {
        realm.write(() => null);
      } on RealmException catch (ex) {
        callbackEx = ex;
      }
    });

    final realm = getRealm(config);

    expect(callbackEx, isNotNull);
    expect(callbackEx.toString(), contains('The Realm is already in a write transaction'));
  });

  test("Configuration.initialDataCallback destroys objects after callback", () {
    Exception? callbackEx;
    late RealmResults<Person> people;
    late Person george;
    final config = Configuration.local([Person.schema], initialDataCallback: (realm) {
      george = realm.add(Person('George'));
      people = realm.all<Person>();
      expect(people.length, 1);
    });

    final realm = getRealm(config);

    expect(() => people.length, throws<RealmClosedError>());
    expect(() => george.name, throws<RealmClosedError>());
    expect(people.realm.isClosed, true);

    final peopleAgain = realm.all<Person>();
    expect(peopleAgain.length, 1);
  });

  test('Configuration.shouldCompact can return false', () {
    var invoked = false;
    var config = Configuration.local([Dog.schema, Person.schema], shouldCompactCallback: (totalSize, usedSize) {
      invoked = true;
      return false;
    });

    final realm = getRealm(config);
    expect(invoked, true);
  });

  test('Configuration.shouldCompact invoked on every open', () {
    var invoked = 0;
    var config = Configuration.local([Dog.schema, Person.schema], shouldCompactCallback: (totalSize, usedSize) {
      invoked++;
      return false;
    });

    final realm = getRealm(config);
    expect(invoked, 1);
    realm.close();

    // Try to open the realm again - we should see the callback get invoked.
    getRealm(config);
    expect(invoked, 2);
  });

  test('Configuration.shouldCompact not invoked if a Realm is still open', () {
    var invoked = 0;
    var config = Configuration.local([Dog.schema, Person.schema], shouldCompactCallback: (totalSize, usedSize) {
      invoked++;
      return false;
    });

    final realm = getRealm(config);
    expect(invoked, 1);

    // Try to open the Realm again - callback should not be invoked because the first Realm
    // is still open
    getRealm(config);
    expect(invoked, 1);
  });

  test('Configuration.shouldCompact can return true', () {
    var invoked = false;
    var config = Configuration.local([Dog.schema, Person.schema], shouldCompactCallback: (totalSize, usedSize) {
      invoked = true;
      return totalSize > 0;
    });

    final realm = getRealm(config);
    expect(invoked, true);
  });

  const dummyDataSize = 100;
  addDummyData(Realm realm) {
    for (var i = 0; i < dummyDataSize; i++) {
      realm.write(() {
        realm.add(Person(generateRandomString(1000)));
      });
    }

    var rand = Random();
    var people = realm.all<Person>();
    for (var i = 0; i < dummyDataSize / 2; i++) {
      realm.write(() {
        final toDelete = people[rand.nextInt(people.length)];
        realm.delete(toDelete);
      });
    }
  }

  for (var shouldCompact in [true, false]) {
    test('Configuration.shouldCompact when return $shouldCompact triggers compaction', () {
      var config = Configuration.local([Person.schema]);

      final populateRealm = Realm(config);
      addDummyData(populateRealm);
      populateRealm.close();

      final oldSize = File(config.path).lengthSync();
      var projectedNewSize = 0;

      config = Configuration.local([Person.schema], shouldCompactCallback: (totalSize, usedSize) {
        projectedNewSize = usedSize;
        return shouldCompact;
      });

      final compactedRealm = getRealm(config);
      final newSize = File(config.path).lengthSync();

      if (shouldCompact) {
        expect(newSize, lessThan(oldSize));

        // Space occupied should be less than twice the data size
        expect(newSize, lessThan(2 * projectedNewSize));
      } else {
        expect(newSize, oldSize);
      }

      expect(compactedRealm.all<Person>().length, dummyDataSize / 2);
    });
  }

  baasTest('Configuration.flexibleSync shouldCompactCallback is invoked', (appConfig) async {
    final app = App(appConfig);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    var invoked = false;
    var config = Configuration.flexibleSync(user, getSyncSchema(), shouldCompactCallback: (totalSize, usedSize) {
      invoked = true;
      return false;
    });

    final realm = getRealm(config);
    expect(invoked, isTrue);
  });

  baasTest('Configuration.flexibleSync suggests correct path', (appConfig) async {
    final app = App(appConfig);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    final config = Configuration.flexibleSync(user, getSyncSchema());

    expect(config.path, contains(user.id));
    expect(config.path, contains(appConfig.appId));
  });

  baasTest('Configuration.flexibleSync when path is supplied, uses that', (appConfig) async {
    final app = App(appConfig);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    final config = Configuration.flexibleSync(user, getSyncSchema(), path: 'my-custom-path.realm');

    expect(config.path, 'my-custom-path.realm');
  });

  baasTest('Configuration.flexibleSync when path is supplied, open realm', (appConfig) async {
    final app = App(appConfig);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));
    var customPath = path.join(
      path.dirname(Configuration.defaultStoragePath),
      path.basename('my-custom-realm-name.realm'),
    );
    final config = Configuration.flexibleSync(user, getSyncSchema(), path: customPath);
    var realm = getRealm(config);
  });

  baasTest('Configuration.disconnectedSync', (appConfig) async {
    final app = App(appConfig);
    final user = await app.logIn(Credentials.emailPassword(testUsername, testPassword));

    final dir = await Directory.systemTemp.createTemp();
    final realmPath = path.join(dir.path, 'test.realm');

    final flexibleSyncConfig = Configuration.flexibleSync(user, getSyncSchema(), path: realmPath);
    final realm = getRealm(flexibleSyncConfig);
    final oid = ObjectId();
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.query<Task>(r'_id == $0', [oid]));
    });
    realm.write(() => realm.add(Task(oid)));
    realm.close();

    final disconnectedSyncConfig = Configuration.disconnectedSync([Task.schema], path: realmPath);
    final disconnectedRealm = getRealm(disconnectedSyncConfig);
    expect(disconnectedRealm.find<Task>(oid), isNotNull);
  });

  test('Configuration.local set too short encryption key size', () {
    List<int> key = [1, 2, 3];
    expect(
      () => Configuration.local([Car.schema], encryptionKey: key),
      throws<RealmException>("Wrong encryption key size"),
    );
  });

  test('Configuration set encryption key not a list of bytes', () {
    List<int> byteExceedingKey = List<int>.generate(encryptionKeySize, (i) => random.nextInt(4294967296));
    expect(
      () => Configuration.local([Car.schema], encryptionKey: byteExceedingKey),
      throws<RealmException>("Encryption key must be a list of bytes with allowed values form 0 to 255"),
    );
  });

  test('Configuration set a valid encryption key', () {
    List<int> key = List<int>.generate(encryptionKeySize, (i) => random.nextInt(256));
    final config = Configuration.local([Car.schema], encryptionKey: key);
    expect(config.encryptionKey, key);
  });

  baasTest('FlexibleSyncConfiguration set too long encryption key size', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);

    List<int> key = List<int>.generate(encryptionKeySize + 10, (i) => random.nextInt(256));
    expect(
      () => Configuration.flexibleSync(user, getSyncSchema(), encryptionKey: key),
      throws<RealmException>("Wrong encryption key size"),
    );
  });

  test('LocalConfiguration.maxNumberOfActiveVersions - throw when exceeded', () {
    var config = Configuration.local([Dog.schema, Person.schema], maxNumberOfActiveVersions: 1);

    final realm = getRealm(config); // First writing to the Realm when opening
    expect(() => realm.write(() {}), throws<RealmException>("Number of active versions (2) in the Realm exceeded the limit of 1"));
  });

  test('InMemoryConfiguration.maxNumberOfActiveVersions - throw when exceeded', () {
    var config = Configuration.inMemory([Dog.schema, Person.schema], maxNumberOfActiveVersions: 1);

    final realm = getRealm(config); // First writing to the Realm when opening
    expect(() => realm.write(() {}), throws<RealmException>("Number of active versions (2) in the Realm exceeded the limit of 1"));
  });

  baasTest('FlexibleSyncConfiguration.maxNumberOfActiveVersions - throw when exceeded', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);

    final config = Configuration.flexibleSync(user, getSyncSchema(), maxNumberOfActiveVersions: 1);
    final realm = await getRealmAsync(config); // First writing to the Realm when opening
    realm.subscriptions.update((mutableSubscriptions) => mutableSubscriptions.add(realm.all<Task>()));
    expect(() => realm.write(() {}), throws<RealmException>("in the Realm exceeded the limit of 1"));
  });

  baasTest('DisconnectedSyncConfiguration.maxNumberOfActiveVersions - throw when exceeded', (appConfiguration) async {
    final app = App(appConfiguration);
    final credentials = Credentials.anonymous();
    final user = await app.logIn(credentials);
    final config = Configuration.flexibleSync(user, getSyncSchema());

    final disconnectedConfig = Configuration.disconnectedSync([Task.schema], path: config.path, maxNumberOfActiveVersions: 1);
    final realm = getRealm(disconnectedConfig); // First writing to the Realm when opening
    expect(() => realm.write(() {}), throws<RealmException>("in the Realm exceeded the limit of 1"));
  });

  test('LocalConfiguration.maxNumberOfActiveVersions - freeze to exceed the version and then throw', () {
    var config = Configuration.local([Dog.schema, Person.schema], maxNumberOfActiveVersions: 2);

    final realm = getRealm(config);
    final frozen1 = realm.freeze();
    realm.write(() => realm.add(Dog("Foxi1")));
    final frozen2 = realm.freeze();
    realm.write(() => realm.add(Dog("Foxi2")));
    expect(() => realm.write(() {}), throws<RealmException>("Number of active versions (3) in the Realm exceeded the limit of 2"));
  });
}
