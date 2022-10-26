## vNext (TBD)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Breaking Changes
* SyncClientResetErrorHandler is renamed to ClientResetHandler. SyncClientResetError is renamed to ClientResetError. ManualSyncClientResetHandler is renamed to ManualRecoveryHandler.
* Default resync mode for `FlexibleSyncConfiguration` is changed from `manual` to `recoverOrDiscard`. In this mode Realm attempts to recover unsynced local changes and if that fails, then the changes are discarded.(PR [#925](https://github.com/realm/realm-dart/pull/925))

### Enhancements
* Added `MutableSubscriptionSet.removeByType` for removing subscriptions by their realm object type. (Issue [#317](https://github.com/realm/realm-dart/issues/317))
* Support results of primitives, ie. `RealmResult<int>`. (Issue [#162](https://github.com/realm/realm-dart/issues/162))
* Support notifications on all managed realm lists, including list of primitives, ie. `RealmList<int>.changes` is supported. ([#893](https://github.com/realm/realm-dart/pull/893))

### Fixed
* Fixed a wrong mapping for `AuthProviderType` returned by `User.provider` for google, facebook and apple credentials.
* Opening an unencrypted file with an encryption key would sometimes report a misleading error message that indicated that the problem was something other than a decryption failure (Core upgrade)
* Fix a rare deadlock which could occur when closing a synchronized Realm immediately after committing a write transaction when the sync worker thread has also just finished processing a changeset from the server. (Core upgrade)

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Uses Realm Core 12.11.0. ([#988](https://github.com/realm/realm-dart/pull/988))

## 0.6.0+beta (2022-10-21)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Enhancements
* Added support for asynchronous transactions. (Issue [#802](https://github.com/realm/realm-dart/issues/802))
  * Added `Transaction` which is a class that exposes an API for committing and rolling back an active transaction.
  * Added `realm.beginWriteAsync` which returns a `Future<Transaction>` that resolves when the write lock has been obtained.
  * Added `realm.writeAsync` which opens an asynchronous transaction, invokes the provided callback, then commits the transaction asynchronously.
* Support `Realm.open` API to asynchronously open a local or synced Realm. When opening a synchronized Realm it will download all the content available at the time the operation began and then return a usable Realm. ([#731](https://github.com/realm/realm-dart/pull/731))
* Add support for embedded objects. Embedded objects are objects which are owned by a single parent object, and are deleted when that parent object is deleted or their parent no longer references them. Embedded objects are declared by passing `ObjectType.embedded` to the `@RealmModel` annotation. Reassigning an embedded object is not allowed and neither is linking to it from multiple parents. Querying for embedded objects directly is also disallowed as they should be viewed as complex structures belonging to their parents as opposed to standalone objects. (Issue [#662](https://github.com/realm/realm-dart/issues/662))

```dart
@RealmModel()
class _Person {
  late String name;

  _Address? address;
}

// The generated `Address` class will be an embedded object.
@RealmModel(ObjectType.embedded)
class _Address {
  late String street;
  late String city;
}
```
* Added `User.functions`. This is the entry point for calling Atlas App functions. Functions allow you to define and execute server-side logic for your application. Atlas App functions are created on the server, written in modern JavaScript (ES6+) and executed in a serverless manner. When you call a function, you can dynamically access components of the current application as well as information about the request to execute the function and the logged in user that sent the request. ([#973](https://github.com/realm/realm-dart/pull/973))

### Fixed
* Added more validations when using `User.apiKeys` to return more meaningful errors when the user cannot perform API key actions - e.g. when the user has been logged in with API key credentials or when the user has been logged out. (Issue [#950](https://github.com/realm/realm-dart/issues/950))
* Fixed `dart run realm_dart generate` and `flutter pub run realm generate` commands to exit with the correct error code on failure.
* Added more descriptive error messages when passing objects managed by another Realm as arguments to `Realm.add/delete/deleteMany`. (PR [#942](https://github.com/realm/realm-dart/pull/942))
* Fixed a bug where `list.remove` would not correctly remove the value if the value is the first element in the list. (PR [#975](https://github.com/realm/realm-dart/pull/975))

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Uses Realm Core v12.9.0

## 0.5.0+beta (2022-10-10)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Breaking Changes
* Fixed an issue that would cause passwords sent to the server (e.g. `Credentials.EmailPassword` or `EmailPasswordAuthProvider.registerUser`) to contain an extra empty byte at the end. (PR [#918](https://github.com/realm/realm-dart/pull/918)).
  Notice: Any existing email users might need to be recreated because of this breaking change.

### Enhancements
* Added support for "frozen objects" - these are objects, queries, lists, or Realms that have been "frozen" at a specific version. All frozen objects can be accessed and queried as normal, but attempting to mutate them or add change listeners will throw an exception. `Realm`, `RealmObject`, `RealmList`, and `RealmResults` now have a method `freeze()` which returns an immutable version of the object, as well as an `isFrozen` property which can be used to check whether an object is frozen. ([#56](https://github.com/realm/realm-dart/issues/56))
* You can now set a realm property of type `T` to any object `o` where `o is T`. Previously it was required that `o.runtimeType == T`. ([#904](https://github.com/realm/realm-dart/issues/904))
* Performance of indexOf on realm lists has been improved. It now uses realm-core instead of the generic version from ListMixin. ([#911](https://github.com/realm/realm-dart/pull/911))
* Performance of remove on realm list has been improved. It now uses indexOf and removeAt. ([#915](https://github.com/realm/realm-dart/pull/915))
* Added support for migrations for local Realms. You can now construct a configuration with a migration callback that will be invoked if the schema version of the file on disk is lower than the schema version supplied by the callback. ([#70](https://github.com/realm/realm-dart/issues/70))
  Example:
  ```dart
  final config = Configuration.local([Person.schema], schemaVersion: 4, migrationCallback: (migration, oldSchemaVersion) {
    if (oldSchemaVersion == 1) {
      // Between v1 and v2 we removed the Bar type
      migration.deleteType('Bar');
    }

    if (oldSchemaVersion == 2) {
      // Between v2 and v3 we fixed a typo in the 'Person.name' property.
      migration.renameProperty('Person', 'nmae', 'name');
    }

    if (oldSchemaVersion == 3) {
      final oldPeople = migration.oldRealm.all('Person');
      for (final oldPerson in oldPeople) {
        final newPerson = migration.findInNewRealm<Person>(oldPerson);
        if (newPerson == null) {
          // That person must have been deleted, so nothing to do.
          continue;
        }

        // Between v3 and v4 we're obfuscating the users' exact age by storing age group instead.
        newPerson.ageGroup = calculateAgeGroup(oldPerson.dynamic.get<int>('age'));
      }
    }
  });
  ```
* Added support for realm list of nullable primitive types, ie. `RealmList<int?>`. ([#163](https://github.com/realm/realm-dart/issues/163))
* Allow null arguments on query. ([#871](https://github.com/realm/realm-dart/issues/871))
* Added support for API key authentication. (Issue [#432](https://github.com/realm/realm-dart/issues/432))
  * Expose `User.apiKeys` client - this client can be used to create, fetch, and delete API keys.
  * Expose `Credentials.apiKey` that enable authentication with API keys.
* Exposed `User.accessToken` and `User.refreshToken` - these tokens can be used to authenticate against the server when calling HTTP API outside of the Dart/Flutter SDK. For example, if you want to use the GraphQL. (PR [#919](https://github.com/realm/realm-dart/pull/919))
* Added support for `encryptionKey` to `Configuration.local`, `Configuration.flexibleSync` and `Configuration.disconnectedSync` so realm files can be encrypted and existing encrypted files from other Realm sources opened (assuming you have the key)([#920](https://github.com/realm/realm-dart/pull/920))

### Fixed
* Previously removeAt did not truncate length. ([#883](https://github.com/realm/realm-dart/issues/883))
* List.length= now throws, if you try to increase length. This previously succeeded silently. ([#894](https://github.com/realm/realm-dart/pull/894)).
* Queries on lists were broken. ([#909](https://github.com/realm/realm-dart/issues/909))
  Example:
  ```dart
  expect(realm.all<Person>(), [alice, bob, carol, dan]); // assume this pass, then ...
  expect(team.players.query('TRUEPREDICATE'), [alice, bob]); // <-- ... this fails and return the same as realm.all<Person>()
  ```
* Queries on results didn't filter the existing results. ([#908](https://github.com/realm/realm-dart/issues/908)).
  Example
  ```dart
  expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty); //<-- Fails if a Persion object exists
  ```
* Fixed copying of native structs for session errors and http requests. ([#924](https://github.com/realm/realm-dart/pull/924))
* Fixed a crash when closing the SyncSession on App instance teardown. ([#5752](https://github.com/realm/realm-core/issues/5752))
* Fixed sporadic generator failure. ([#879](https://github.com/realm/realm-dart/issues/879))
* Exceptions thrown by user code inside the `Configuration.initialDataCallback` are now properly surfaced back to the `Realm()` constructor. ([#698](https://github.com/realm/realm-dart/issues/698))

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Uses Realm Core v12.9.0
* Added tracking of child handles for objects/results/lists obtained from an unowned Realm. This ensures that all children are invalidated as soon as the parent Realm gets released at the end of the callback. (Issue [#527](https://github.com/realm/realm-dart/issues/527))
* Added an action to enforce that the changelog is updated before a PR is merged (Issue [#939](https://github.com/realm/realm-dart/issues/939))

## 0.4.0+beta (2022-08-19)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Breaking Changes
* Changed the name of `Configuration.schema` to `Configuration.schemaObjects` and changed its type to `Iterable<SchemaObject>`. You can now access the Realm's schema via the new `Realm.schema` property. [#495](https://github.com/realm/realm-dart/pull/495))

### Enhancements
* Expose an API for string-based access to the objects in the `Realm`. Those are primarily intended to be used during migrations, but are available at all times for advanced use cases. [#495](https://github.com/realm/realm-dart/pull/495))
* Added `Realm.schema` property exposing the Realm's schema as passed through the Configuration or read from disk. [#495](https://github.com/realm/realm-dart/pull/495))

### Fixed
* Lifted a limitation that only allowed non-nullable primary keys. ([#458](https://github.com/realm/realm-dart/issues/458))
* Fix boolean values get/set after ffigen update. ([#854](https://github.com/realm/realm-dart/pull/854))

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Uses Realm Core v12.5.1

## 0.3.2+beta (2022-08-16)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Enhancements
* Added `DisconnectedSyncConfiguration` for opening a synchronized realm in a disconnected state. This configuration allows a synchronized realm to be opened by a secondary process, while a primary process handles synchronization. ([#621](https://github.com/realm/realm-dart/pull/621))
* Support better default paths on Flutter. ([#665](https://github.com/realm/realm-dart/pull/665))
* Support `Configuration.defaultRealmName` for setting the default realm name. ([#665](https://github.com/realm/realm-dart/pull/665))
* Support `Configuration.defaultRealmPath` for setting a custom default path for realms. ([#665](https://github.com/realm/realm-dart/pull/665))
* Support `Configuration.defaultStoragePath ` for getting the platform specific storage paths. ([#665](https://github.com/realm/realm-dart/pull/665))
* Support `App.deleteUser ` for deleting user accounts. ([#679](https://github.com/realm/realm-dart/pull/679))
* Support Apple, Facebook and Google authentication. ([#740](https://github.com/realm/realm-dart/pull/740))
* Allow multiple anonymous sessions. When using anonymous authentication you can now easily log in with a different anonymous user than last time. ([#750](https://github.com/realm/realm-dart/pull/750)).
* Support `Credentials.jwt` for login user with JWT issued by custom provider . ([#715](https://github.com/realm/realm-dart/pull/715))
* Support `Credentials.function` for login user with Custom Function Authentication Provider. ([#742](https://github.com/realm/realm-dart/pull/742))
* Added `update` flag on `Realm.add` and `Realm.addAll` to support upserts. ([#668](https://github.com/realm/realm-dart/pull/668))
* Allow multiple anonymous sessions. ([PR #5693](https://github.com/realm/realm-core/pull/5693)).
* Introducing query parser support for constant list expressions such as `fruit IN {'apple', 'orange'}`. This also includes general query support for list vs list matching such as `NONE fruits IN {'apple', 'orange'}`. ([Issue #4266](https://github.com/realm/realm-core/issues/4266))
* SubscriptionSet::refresh() does less work if no commits have been made since the last call to refresh(). ([PR #5695](https://github.com/realm/realm-core/pull/5695))
* Reduce use of memory mappings and virtual address space ([PR #5645](https://github.com/realm/realm-core/pull/5645)). Also fixes some errors (see below)

### Fixed
* Use Dart 2.17 `Finalizable` to ensure lexically scoped lifetime of finalizable resources (Realm, App, etc.). ([#754](https://github.com/realm/realm-dart/pull/754))
* Fix crash after hot-restart. ([#711](https://github.com/realm/realm-dart/pull/711) and [PR #5570](https://github.com/realm/realm-core/issues/5570))
* Processing a pending bootstrap before the sync client connects will properly surface errors to the user's error handler ([#5707](https://github.com/realm/realm-core/issues/5707), since Realm Core v12.0.0)
* Using the Query Parser, it was not allowed to query on a property named `desc`. ([#5723](https://github.com/realm/realm-core/issues/5723))
* Improved performance of sync clients during integration of changesets with many small strings (totalling > 1024 bytes per changeset) on iOS 14, and devices which have restrictive or fragmented memory. ([#5614](https://github.com/realm/realm-core/issues/5614))
* Fixed a segfault in sync compiled by MSVC 2022. ([#5557](https://github.com/realm/realm-core/pull/5557), since Realm Core 12.1.0)
* Fix a data race when opening a flexible sync Realm (since Realm Core v12.1.0).
* Fixed an issue on Windows that would cause high CPU usage by the sync client when there are no active sync sessions. (Issue [#5591](https://github.com/realm/realm-core/issues/5591), since the introduction of Sync support for Windows)
* Fix a data race when committing a transaction while multiple threads are waiting for the write lock on platforms using emulated interprocess condition variables (most platforms other than non-Android Linux).
* Fix some cases of running out of virtual address space (seen/reported as mmap failures) ([PR #5645](https://github.com/realm/realm-core/pull/5645))

### Internal
* Added a command to `realm_dart` for deleting Atlas App Services applications. Usage: `dart run realm_dart delete-apps`. By default it will delete apps from `http://localhost:9090` which is the endpoint of the local docker image. If `--atlas-cluster` is provided, it will authenticate, delete the application from the provided cluster. (PR [#663](https://github.com/realm/realm-dart/pull/663))
* Uses Realm Core v12.5.1

## 0.3.1+beta (2022-06-07)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Fixed
* Fixed the Url command to correctly encode the SDK version. ([#650](https://github.com/realm/realm-dart/issues/650))

## 0.3.0+beta (2022-06-02)

**This project is in the Beta stage. The API should be quite stable, but occasional breaking changes may be made.**

### Breaking Changes
* Made all `Configuration` fields final so they can only be initialized in the constructor. This better conveys the immutability of the configuration class. ([#455](https://github.com/realm/realm-dart/pull/455))
* Removed `inMemory` field from `Configuration`. Use `Configuration.inMemory` factory instead.
* Due to the introduction of different types of configurations the `Configuration` constructor has been removed. Use the `Configuration.local` factory instead. ([#496](https://github.com/realm/realm-dart/pull/496))

### Enhancements
* Added a property `Configuration.disableFormatUpgrade`. When set to `true`, opening a Realm with an older file format will throw an exception to avoid automatically upgrading it. ([#310](https://github.com/realm/realm-dart/pull/310))
* Support result value from write transaction callbacks. ([#294](https://github.com/realm/realm-dart/pull/294))
* Added a property `Realm.isInTransaction` that indicates whether the Realm instance has an open write transaction associated with it.
* Support anonymous application credentials. ([#443](https://github.com/realm/realm-dart/pull/443))
* Added a property `Configuration.initialDataCallback`. This is a callback executed when a Realm file is first created and allows you to populate some initial data necessary for your application. ([#298](https://github.com/realm/realm-dart/issues/298))
* Support app configuration. ([#306](https://github.com/realm/realm-dart/pull/306))
* Support app class. ([#446](https://github.com/realm/realm-dart/pull/446))
* Support should realm compact on open callback `Configuration.shouldCompactCallback` as option when configuring a Realm to determine if it should be compacted before being returned.  ([#466](https://github.com/realm/realm-dart/pull/466/))
* Support ObjectId type. ([#468](https://github.com/realm/realm-dart/pull/468))
* Support Uuid type. ([#470](https://github.com/realm/realm-dart/pull/470))
* Support application login. ([#469](https://github.com/realm/realm-dart/pull/469))
* Support app configuration log level and request timeout.([#566](https://github.com/realm/realm-dart/pull/566))
* Support EmailPassword register user. ([#452](https://github.com/realm/realm-dart/pull/452))
* Support EmailPassword confirm user. ([#478](https://github.com/realm/realm-dart/pull/478))
* Support EmailPassword resend user confirmation email. ([#479](https://github.com/realm/realm-dart/pull/479))
* Support EmailPassword complete reset password. ([#480](https://github.com/realm/realm-dart/pull/480))
* Support EmailPassword reset password. ([#481](https://github.com/realm/realm-dart/pull/481))
* Support EmailPassword calling custom reset password functions. ([#482](https://github.com/realm/realm-dart/pull/482))
* Support EmailPassword retry custom user confirmation functions. ([#484](https://github.com/realm/realm-dart/pull/484))
* Expose currentUser property on App. ([473](https://github.com/realm/realm-dart/pull/473))
* Support remove user. ([#492](https://github.com/realm/realm-dart/pull/492))
* Support switch current user. ([#493](https://github.com/realm/realm-dart/pull/493))
* Support user custom data and refresh. ([#525](https://github.com/realm/realm-dart/pull/525))
* Support linking user credentials. ([#525](https://github.com/realm/realm-dart/pull/525))
* Support user state. ([#525](https://github.com/realm/realm-dart/pull/525))
* Support getting user id and identities. ([#525](https://github.com/realm/realm-dart/pull/525))
* Support user logout. ([#525](https://github.com/realm/realm-dart/pull/525))
* Support user deviceId. ([#570](https://github.com/realm/realm-dart/pull/570))
* Support user authentication provider type. ([#570](https://github.com/realm/realm-dart/pull/570))
* Support user profile data. ([#570](https://github.com/realm/realm-dart/pull/570))
* Support flexible synchronization. ([#496](https://github.com/realm/realm-dart/pull/496))
* Added support for DateTime properties. ([#569](https://github.com/realm/realm-dart/pull/569))
* Support setting logger on AppConfiguration. ([#583](https://github.com/realm/realm-dart/pull/583))
* Support setting logger on Realm class. Default is to print info message or worse to the console. ([#583](https://github.com/realm/realm-dart/pull/583))
* Support getting the `SyncSession` for a synchronized Realm via the `realm.syncSession` property.
* Support the following `SyncSession` API:
  * `realmPath` returning the path of the Realm for the session.
  * `state` returning the current state of the session.
  * `connectionState` returning the current state of the connection.
  * `connectionStateChanges` returns a Stream that emits connection state updates.
  * `user` returning the user that owns the session.
  * `pause()` pauses synchronization.
  * `resume()` resumes synchronization.
  * `waitForUpload/waitForDownload` returns a Future that completes when the session uploaded/downloaded all changes.
  * `getProgressStream` returns a Stream that emits progress updates.
* Support SyncErrorHandler in FlexibleSyncConfiguration. ([#577](https://github.com/realm/realm-dart/pull/577))
* Support SyncClientResetHandler in FlexibleSyncConfiguration. ([#608](https://github.com/realm/realm-dart/pull/608))
* [Dart] Added `Realm.Shutdown` method to allow normal process exit in Dart applications. ([#617](https://github.com/realm/realm-dart/pull/617))

### Fixed
* Fixed an issue that would result in the wrong transaction being rolled back if you start a write transaction inside a write transaction. ([#442](https://github.com/realm/realm-dart/issues/442))
* Fixed boolean value persistence ([#474](https://github.com/realm/realm-dart/issues/474))

### Internal
* Added a command to deploy an Atlas App Services application to `realm_dart`. Usage: `dart run realm_dart deploy-apps`. By default it will deploy apps to `http://localhost:9090` which is the endpoint of the local docker image. If `--atlas-cluster` is provided, it will authenticate, create an application and link the provided cluster to it. (PR [#309](https://github.com/realm/realm-dart/pull/309))
* Unit tests will now attempt to lookup and create if necessary Atlas App Services applications (similarly to the above mentioned command). See `test.dart/setupBaas()` for the environment variables that control the Url and Atlas Cluster that will be used. If the `BAAS_URL` environment variable is not set, no apps will be imported and sync tests will not run. (PR [#309](https://github.com/realm/realm-dart/pull/309))
* Uses Realm Core v12.1.0

### Compatibility
* Dart ^2.17 on Windows, MacOS and Linux
* Flutter ^3.0 on Android, iOS, Linux, MacOS and Windows

## 0.2.1+alpha Release notes (2022-03-20)

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements
* Support change notifications on query results. ([#208](https://github.com/realm/realm-dart/pull/208))

    Every `RealmResults<T>` object now has a `changes` method returning a `Stream<RealmResultsChanges<T>>` which can be listened to.

    ```dart
    final subscription = realm.all<Dog>().changes.listen((changes) {
    changes.inserted // indexes of inserted ojbects
    changes.modified // indexes of modified objects
    changes.deleted  // indexes of deleted objects
    changes.newModified // indexes of modified objects after deletions and insertions are accounted for.
    changes.moved // indexes of moved objects
    }});
    subscription.cancel(); // cancel the subscription
    ```

* Support change notifications on list collections. ([#261](https://github.com/realm/realm-dart/pull/261))

    Every `RealmList<T extends RealmObject>` object now has a `changes` method returning a `Stream<RealmListChanges<T>>` which can be listened to.

    ```dart
    final team = Team('team', players: [Person("player")]);
    realm.write(() => realm.add(team));

    var firstCall = true;
    final subscription = team.players.changes.listen((changes) {
    changes.inserted // indexes of inserted ojbects
    changes.modified // indexes of modified objects
    changes.deleted  // indexes of deleted objects
    changes.newModified // indexes of modified objects after deletions and insertions are accounted for.
    changes.moved // indexes of moved objects
    });

    subscription.cancel(); // cancel the subscription
    ```

* Support change notifications on realm objects. ([#262](https://github.com/realm/realm-dart/pull/262))

    Every managed `RealmObject` now has a changes method which allows to listen for object property changes.

    ```dart
    var dog = realm.all<Dog>().first;

    final subscription = dog.changes.listen((changes) {
    changes.isDeleted // if the object has been deleted
    changes.object // the RealmObject being listened to.
    changes.properties // the changed properties
    });

    subscription.cancel(); // cancel the subscription
    ```

* Added support for checking if realm lists and realm objects are valid. ([#183](https://github.com/realm/realm-dart/pull/183))
* Support query on lists of realm objects. ([#239](https://github.com/realm/realm-dart/pull/239))

    Every RealmList<T extends RealmObject> now has a query method.

    ```dart
    final team = Team('Dream Team', players: [Person("Michael Jordan")]);
    realm.write(() => realm.add(team)); // Object needs to be managed.
    final result = team.players.query(r'name BEGINSWITH $0', ['M']);
    ```

* Added support for opening realm in read-only mode. ([#260](https://github.com/realm/realm-dart/pull/260))
* Added support for opening in-memory realms. ([#280](https://github.com/realm/realm-dart/pull/280))
* Primary key fields no longer required to be `final` in data model classes ([#240](https://github.com/realm/realm-dart/pull/240))

    Previously primary key fields needed to be `final`.

    ```dart
    @RealmModel()
    class _Car {
    @PrimaryKey()
    late final String make; // previously
    }

    ```

    Now primary key fields no longer need to be `final`

    ```dart
    @RealmModel()
    class _Car {
    @PrimaryKey()
    late String make; // now
    }
    ```

* List fields no longer required to be `final` in data model classes. ([#253](https://github.com/realm/realm-dart/pull/253))

    Previously list fields needed to be `final`.

    ```dart
    @RealmModel()
    class _Car {
    late final List<Person> owner; // previously
    }

    ```

    Now list fields no longer need to be `final`

    ```dart
    @RealmModel()
    class _Car {
    late List<Person> owner; // now
    }
    ```

* Support custom FIFO special files. ([#284](https://github.com/realm/realm-dart/pull/284))
* Support flutter for Linux desktop. ([#279](https://github.com/realm/realm-dart/pull/279/))

### Fixed
* Snapshot the results collection when iterating collections of realm objects. ([#258](https://github.com/realm/realm-dart/pull/258))

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux
* Flutter ^2.10 on Android, iOS, Linux, MacOS and Windows

## 0.2.0+alpha Release notes (2022-01-31)

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements
* Completely rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

## 0.2.0-alpha.2 Release notes (2022-01-29)

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Fix running package commands.

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

## 0.2.0-alpha.1 Release notes (2022-01-29)

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Realm close stops internal scheduler.

### Internal
* Fix linter issues

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

## 0.2.0-alpha Release notes (2022-01-27)

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

### Internal
* Uses Realm Core v11.9.0

## 0.1.1+preview Release notes (2021-04-01)

### Fixed
* `realm_dart install` command is correctly installing the realm native binary

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/

## 0.1.0+preview Release notes (2021-04-01)

### Enhancements
* The initial preview version of the Realm SDK for Dart.

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/
