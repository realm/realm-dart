x.x.x Release notes (yyyy-MM-dd)
==============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Breaking Changes
* Made all `Configuration` fields final so they can only be initialized in the constructor. This better conveys the immutability of the configuration class. ([#455](https://github.com/realm/realm-dart/pull/455))

### Enhancements
* Support result value from write transaction callbacks ([#294](https://github.com/realm/realm-dart/pull/294/))
* Added a property `Realm.isInTransaction` that indicates whether the Realm instance has an open write transaction associated with it.
* Support anonymous application credentials ([#443](https://github.com/realm/realm-dart/pull/443/))

### Fixed
* Fixed an issue that would result in the wrong transaction being rolled back if you start a write transaction inside a write transaction. ([#442](https://github.com/realm/realm-dart/issues/442))

### Internal
* Added a command to deploy a MongoDB Realm app to `realm_dart`. Usage: `dart run realm_dart deploy-apps`. By default it will deploy apps to `http://localhost:9090` which is the endpoint of the local docker image. If `--atlas-cluster` is provided, it will authenticate, create an application and link the provided cluster to it. (PR [#309](https://github.com/realm/realm-dart/pull/309))
* Unit tests will now attempt to lookup and create if necessary MongoDB applications (similarly to the above mentioned command). See `test.dart/setupBaas()` for the environment variables that control the Url and Atlas Cluster that will be used. If the `BAAS_URL` environment variable is not set, no apps will be imported and sync tests will not run. (PR [#309](https://github.com/realm/realm-dart/pull/309))

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.1+alpha Release notes (2022-03-20)
==============================================================

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

0.2.0+alpha Release notes (2022-01-31)
==============================================================

**This project is in the Alpha stage. All API's might change without warning and no guarantees are given about stability. Do not use it in production.**

### Enhancements
* Completely rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha.2 Release notes (2022-01-29)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Fix running package commands.

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha.1 Release notes (2022-01-29)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Realm close stops internal scheduler.

### Internal
* Fix linter issues

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

0.2.0-alpha Release notes (2022-01-27)
==============================================================

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completеly rewritten from the ground up with sound null safety and using Dart FFI

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

### Internal
* Uses Realm Core v11.9.0

0.1.1+preview Release notes (2021-04-01)
=============================================================
### Fixed
* `realm_dart install` command is correctly installing the realm native binary

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/

0.1.0+preview Release notes (2021-04-01)
=============================================================
### Enhancements
* The initial preview version of the Realm SDK for Dart.

### Compatibility
* Windows and Mac
* Dart SDK 2.12 stable from https://dart.dev/