## 20.1.1 (2025-05-12)

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core x.y.z.

## 20.1.0 (2025-05-09)

### Enhancements
* Ignore coverage in generated files. (Issue [#1826](https://github.com/realm/realm-dart/issues/1826))
* Upgrade min Dart SDK to 3.6.0, update all dependencies to latest stable version, and tighten lower bounds. (Issue [#1825](https://github.com/realm/realm-dart/issues/1825))

### Fixed
* Update source_gen to latest stable version (^2.0.0). (Issue [#1825](https://github.com/realm/realm-dart/issues/1825))

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core x.y.z.

## 20.0.1 (2025-01-02)

### Fixed
* For the Android platform, changed compileSdkVersion into 31 from 28 to fix the fatal `android:attr/lStar not found` error when using Flutter 3.24.
* Fix breakage of `PseudoType` after Flutter 3.27.1. (Issue [#1813](https://github.com/realm/realm-dart/issues/1813))

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 20.0.1.

## 20.0.0 (2024-09-09)

### Breaking Changes
* Removed all functionality related to App Services/Atlas Device Sync.

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 20.0.1.

## 3.4.2 (2025-01-02)

### Fixed
* For the Android platform, changed compileSdkVersion into 31 from 28 to fix the fatal `android:attr/lStar not found` error when using Flutter 3.24.
* Fix breakage of `PseudoType` after Flutter 3.27.1. (Issue [#1813](https://github.com/realm/realm-dart/issues/1813))

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.11.0.

## 3.4.1 (2024-08-14)

### Fixed
* Fixed ejson dependency to 0.4.0.

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.11.0.

## 3.4.0 (2024-08-13)

### Enhancements
* Added a new parameter of type `SyncTimeoutOptions` to `AppConfiguration`. It allows users to control sync timings, such as ping/pong intervals as well various connection timeouts. (Issue [#1763](https://github.com/realm/realm-dart/issues/1763))
* Added a new parameter `cancelAsyncOperationsOnNonFatalErrors` on `Configuration.flexibleSync` that allows users to control whether non-fatal errors such as connection timeouts should be surfaced in the form of errors or if sync should try and reconnect in the background. (PR [#1764](https://github.com/realm/realm-dart/pull/1764))
* Allow nullable and other optional fields to be absent in EJson, when deserializing realm objects. (Issue [#1735](https://github.com/realm/realm-dart/issues/1735))

### Fixed
* Fixed an issue where creating a flexible sync configuration with an embedded object not referenced by any top-level object would throw a "No such table" exception with no meaningful information about the issue. Now a `RealmException` will be thrown that includes the offending object name, as well as more precise text for what the root cause of the error is. (PR [#1748](https://github.com/realm/realm-dart/pull/1748))
* `AppConfiguration.maxConnectionTimeout` never had any effect and has been deprecated in favor of `SyncTimeoutOptions.connectTimeout`. (PR [#1764](https://github.com/realm/realm-dart/pull/1764))
* Pure dart apps, when compiled to an exe and run from outside the project directory would fail to load the native shared library. (Issue [#1765](https://github.com/realm/realm-dart/issues/1765))

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.11.0.

## 3.3.0 (2024-07-20)

### Enhancements
* On Windows devices Device Sync will additionally look up SSL certificates in the Windows Trusted Root Certification Authorities certificate store when establishing a connection. (Core 14.11.0)
* Role and permissions changes no longer require a client reset to update the local realm. (Core 14.11.0)

### Fixed
* When a public name is defined on a property (using `@MapTo`), calling `query("... SORT/DISTINCT(mapped-to-name)")` with the internal name could throw an error like `Cannot sort on key path 'NAME': property 'PersonObject.NAME' does not exist`. (Core 14.10.4)

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.11.0.

## 3.2.0 (2024-07-10)

### Enhancements
* "Next launch" metadata file actions are now performed in a multi-process safe manner. (Core 14.10.3)
* Performance has been improved for range queries on integers and timestamps. Requires that you use the "BETWEEN" in the `realm.query<T>()` method when you build the query. (Core 14.10.1)
* Include the originating client reset error in AutoClientResetFailure errors. (Core 14.10.0)
* Reduce the size of the local transaction log produced by creating objects, improving the performance of insertion-heavy transactions. (Core 14.10.0)
* Make `SubscriptionSet` an abstract interface class, to allow mocking. (Issue [#1744](https://github.com/realm/realm-dart/issues/1744))

### Fixed
* Fixed an issue that affects sync apps that use embedded objects which have a `List<RealmValue>` that contains a link to another top level object which has been deleted by another sync client (creating a tombstone locally). In this particular case, the switch would cause any remaining link removals to recursively delete the destination object if there were no other links to it. (Core v14.10.3)
* Fixed removing backlinks from the wrong objects if the link came from a nested list, nested dictionary, top-level map, or `List<RealmValue>`, and the source table had more than 256 objects. This could manifest as `array_backlink.cpp:112: Assertion failed: int64_t(value >> 1) == key.value` when removing an object. (Core 14.10.3)
* Fixed the collapse/rejoin of clusters which contained nested collections with links. This could manifest as `array.cpp:319: Array::move() Assertion failed: begin <= end [2, 1]` when removing an object. (Core 14.10.3)
* `waitForUpload()` was inconsistent in how it handled commits which did not produce any changesets to upload. Previously it would sometimes complete immediately if all commits waiting to be uploaded were empty, and at other times it would wait for a server roundtrip. It will now always complete immediately. (Core v14.10.3).
* Opening an FLX realm asynchronously may not wait to download all data (Core 14.10.1).
* Clearing a List of Mixed in an upgraded file would lead to an assertion failing (Core 14.10.1)
* Fix some client resets (such as migrating to flexible sync) potentially failing with AutoClientResetFailed if a new client reset condition (such as rolling back a flexible sync migration) occurred before the first one completed. (Core 14.10.0)
* Encrypted files on Windows had a maximum size of 2GB even on x64 due to internal usage of `off_t`, which is a 32-bit type on 64-bit Windows. (Core 14.10.0)
* The encryption code no longer behaves differently depending on the system page size, which should entirely eliminate a recurring source of bugs related to copying encrypted Realm files between platforms with different page sizes. (Core 14.10.0)
* There were several complicated scenarios which could result in stale reads from encrypted files in multiprocess scenarios. These were very difficult to hit and would typically lead to a crash, either due to an assertion failure or DecryptionFailure being thrown. (Core 14.10.0)
* Tokenizing strings for full-text search could fail. (Core 14.10.0)


### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.10.3

## 3.1.0 (2024-06-25)

### Enhancements
* The download progress estimate reported by `Session.getProgressStream` will now return meaningful estimated values, while previously it always returned 1. (Issue [#1564](https://github.com/realm/realm-dart/issues/1564))

### Fixed
* [sane_uuid](https://pub.dev/packages/sane_uuid) 1.0.0 was released, which has a few minor breaking change as compared to to 1.0.0-rc.5 that impact realm:
  - The `Uuid.fromBytes` factory now accepts a `Uint8List` instead of a `ByteBuffer`
  - The type of `Uuid.bytes` has changed to `Uint8List`.

  Issue [#1729](https://github.com/realm/realm-dart/issues/1729)

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.9.0

## 3.0.0 (2024-06-07)

### Breaking Changes
* To avoid dependency on `dart:io`
  - `AppConfiguration.httpClient` is now of type [`Client`](https://pub.dev/documentation/http/latest/http/Client-class.html) and
  - `AppConfiguration.baseFilePath` is now of type `String`.

  Assuming you are configuring these today, migration is easy:
  ```dart
  import 'dart:io';
  import 'package:realm_dart/realm.dart';

  final client = HttpClient();
  final dir = Directory.current;
  final config = AppConfiguration(
    'your-app-id',
    httpClient: client,
    baseFilePath: dir,
  );
  ```
  becomes:
  ```dart
  import 'dart:io';
  import 'package:realm_dart/realm.dart';
  import 'package:http/io_client.dart';

  final client = HttpClient();
  final dir = Directory.current;
  final config = AppConfiguration(
    'your-app-id',
    httpClient: IOClient(client),
    baseFilePath: dir.path,
  );
  ```
  (Issue [#1374](https://github.com/realm/realm-dart/issues/1374))

### Enhancements
* Report the originating error that caused a client reset to occur. (Core 14.9.0)
* Allow the realm package, and code generated by realm_generator to be included when building
  for web without breaking compilation. (Issue [#1374](https://github.com/realm/realm-dart/issues/1374),
  PR [#1713](https://github.com/realm/realm-dart/pull/1713)). This does **not** imply that realm works on web!
* Added support for specifying key paths when listening to notifications on a collection with the `changesFor([List<String>? keyPaths])` method. Available on `RealmResults`, `RealmList`, `RealmSet`, and `RealmMap`. The key paths indicates what properties should raise a notification, if changed either directly or transitively.
  ```dart
  @RealmModel()
  class _Person {
    late String name;
    late int age;
    late List<_Person> friends;
  }

  // ....

  // Only changes to "age" or "friends" of any of the elements of the collection, together with changes to the collection itself, will raise a notification
  realm.all<Person>().changesFor(["age", "friends"]).listen( .... )
  ```

### Fixed
* `Realm.writeAsync` did not handle async callbacks (`Future<T> Function()`) correctly. (Issue [#1667](https://github.com/realm/realm-dart/issues/1667))
* Fixed an issue that would cause macOS apps to be rejected with `Invalid Code Signing Entitlements` error. (Issue [#1679](https://github.com/realm/realm-dart/issues/1679))
* Fixed a regression that makes it inconvenient to run unit tests using realm. (Issue [#1619](https://github.com/realm/realm-dart/issues/1619))
* After compacting, a file upgrade would be triggered. This could cause loss of data if schema mode is SoftResetFile (Core 14.9.0)
* A non-streaming progress notifier would not immediately call its callback after registration. Instead you would have to wait for a download message to be received to get your first update - if you were already caught up when you registered the notifier you could end up waiting a long time for the server to deliver a download that would call/expire your notifier (Core 14.8.0).
* Comparing a numeric property with an argument list containing a string would throw. (Core 14.8.0)

### Compatibility
* Realm Studio: 15.0.0 or later.
* Fileformat: Generates files with format v24. Reads and automatically upgrade from fileformat v10.

### Internal
* Using Core 14.9.0.
* Disabled codesigning of Apple binaries. (Issue [#1679](https://github.com/realm/realm-dart/issues/1679))
* Drop building xcframework for catalyst. (Issue [#1695](https://github.com/realm/realm-dart/issues/1695))
* Using xcode 15.4 for native build. (Issue [#1547](https://github.com/realm/realm-dart/issues/1547))
* Using puro on CI. ([#1710](https://github.com/realm/realm-dart/pull/1710))

## 2.3.0 (2024-05-23)

### Enhancements
* Added support for creating and storing a RealmObject using the `Realm.dynamic` API: `realm.dynamic.create("Person", primaryKey: 123)`. (PR [#1669](https://github.com/realm/realm-dart/pull/1669))
* Added support for setting properties on a RealmObject using the dynamic API: `obj.dynamic.set("name", "Peter")`. (PR [#1669](https://github.com/realm/realm-dart/pull/1669))
* Listening for `.changes` on a dynamic object (obtained via the `realm.dynamic` API) no longer throws. (Issue [#1668](https://github.com/realm/realm-dart/issues/1668))
* Nested collections have full support for automatic client reset. (Core 14.7.0)

### Fixed
* Private fields did not work with default values. (Issue [#1663](https://github.com/realm/realm-dart/issues/1663))
* Invoke scheduler callback on Zone.current. (Issue [#1676](https://github.com/realm/realm-dart/issues/1676))

* Having links in a nested collections would leave the file inconsistent if the top object is removed. (Core 14.7.0)

* Accessing App.currentUser from within a notification produced by App.switchUser() (which includes notifications for a newly logged in user) would deadlock. (Core 14.7.0)

* Inserting the same typed link to the same key in a dictionary more than once would incorrectly create multiple backlinks to the object. This did not appear to cause any crashes later, but would have affecting explicit backlink count queries (eg: `...@links.@count`) and possibly notifications. (Core 14.7.0)


### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.7.0.

## 2.2.1 (2024-05-02)

### Fixed
* `realm_privacy` bundle mistakenly included an exe-file preventing app store submissions. (Issue [#1656](https://github.com/realm/realm-dart/issues/1656))

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.6.2.
* Drop build of `x86` android slice. (Issue [#1670](https://github.com/realm/realm-dart/issues/1670))

## 2.2.0 (2024-05-01)

### Enhancements
* Allow configuration of generator per model class. Currently support specifying the constructor style to use.
  ```dart
  const config = GeneratorConfig(ctorStyle: CtorStyle.allNamed);
  const realmModel = RealmModel.using(baseType: ObjectType.realmObject, generatorConfig: config);

  @realmModel
  class _Person {
    late String name;
    int age = 42;
  }
  ```
  will generate a constructor like:
  ```dart
  Person({
    required String name,
    int age = 42,
  }) { ... }
  ```
  (Issue [#292](https://github.com/realm/realm-dart/issues/292))
* Add privacy manifest to apple binaries. (Issue [#1551](https://github.com/realm/realm-dart/issues/1551))

### Fixed
* Avoid: Attempt to execute code removed by Dart AOT compiler (TFA). (Issue [#1647](https://github.com/realm/realm-dart/issues/1647))
* Fixed nullability annotations for the experimental API `App.baseUrl` and `App.updateBaseUrl`. The former is guaranteed not to be `null`, while the latter will now accept a `null` argument, in which case the base url will be restored to its default value. (Issue [#1523](https://github.com/realm/realm-dart/issues/1523))
* `App.users` included logged out users only if they were logged out while the App instance existed. It now always includes all logged out users. (Core 14.6.0)
* Fixed several issues around encrypted file portability (copying a "bundled" encrypted Realm from one device to another): (Core 14.6.0)
  * Fixed `Assertion failed: new_size % (1ULL << m_page_shift) == 0` when opening an encrypted Realm less than 64Mb that was generated on a platform with a different page size than the current platform.
  * Fixed a `DecryptionFailed` exception thrown when opening a small (<4k of data) Realm generated on a device with a page size of 4k if it was bundled and opened on a device with a larger page size.
  * Fixed an issue during a subsequent open of an encrypted Realm for some rare allocation patterns when the top ref was within ~50 bytes of the end of a page. This could manifest as a DecryptionFailed exception or as an assertion: `encrypted_file_mapping.hpp:183: Assertion failed: local_ndx < m_page_state.size()`.
* Schema initialization could hit an assertion failure if the sync client applied a downloaded changeset while the Realm file was in the process of being opened. (Core 14.6.0)
* Improve performance of "chained OR equality" queries for UUID/ObjectId types and RQL parsed "IN" queries on string/int/uuid/objectid types. (Core 14.6.0)
* Fixed a bug when running a IN query (or a query of the pattern `x == 1 OR x == 2 OR x == 3`) when evaluating on a string property with an empty string in the search condition. Matches with an empty string would have been evaluated as if searching for a null string instead. (Core 14.6.2)

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.6.2.
* Flutter: ^3.19.0
* Dart: ^3.3.0


## 2.1.0 (2024-04-17)

### Enhancements
* Improve file compaction performance on platforms with page sizes greater than 4k (for example arm64 Apple platforms) for files less than 256 pages in size (Core 14.4.0).
* Added support for specifying key paths when listening to notifications on an object with the `RealmObject.changesFor([List<String>? keyPaths])` method. The key paths indicates which changes in properties should raise a notification.
  ```dart
  @RealmModel()
  class _Person {
    late String name;
    late int age;
    late List<_Person> friends;
  }

  // ....

  // Only changes to person.age and person.friends will raise a notification
  person.changesFor(["age", "friends"]).listen( .... )
  ```
* Add better hint to error message, if opening native library fails. (Issue [#1595](https://github.com/realm/realm-dart/issues/1595))
* Added support for specifying schema version on `Configuration.flexibleSync`. This allows you to take advantage of an upcoming server-side feature that will allow schema migrations for synchronized Realms. (Issue [#1599](https://github.com/realm/realm-dart/issues/1599))
* The default base url in `AppConfiguration` has been updated to point to `services.cloud.mongodb.com`. See https://www.mongodb.com/docs/atlas/app-services/domain-migration/ for more information. (Issue [#1549](https://github.com/realm/realm-dart/issues/1549))
* Don't ignore private fields on realm models. (Issue [#1367](https://github.com/realm/realm-dart/issues/1367))
* Improve performance of `RealmValue.operator==` when containing binary data. (PR [#1628](https://github.com/realm/realm-dart/pull/1628))

### Fixed
* Using valid const, but non-literal expressions, such as negation of numbers, as an initializer would fail. (Issue [#1606](https://github.com/realm/realm-dart/issues/1606))
* Backlinks mistakenly included in EJson serialization. (Issue [#1616](https://github.com/realm/realm-dart/issues/1616))
* Fix an assertion failure "m_lock_info && m_lock_info->m_file.get_path() == m_filename" that appears to be related to opening a Realm while the file is in the process of being closed on another thread. (Core 14.5.0)
* Fixed diverging history due to a bug in the replication code when setting default null values (embedded objects included). (Core 14.5.0)
* Null pointer exception may be triggered when logging out and async commits callbacks not executed. (Core 14.5.0)
* Comparing RealmValue containing a collection to itself would return false. Semantics changed to ensure reference equality always imply equality. (Issue [[#1632](https://github.com/realm/realm-dart/issues/1632)])
* Clearing a nested collection could end with a crash. (Core 14.5.1)
* Removing nested collections in RealmValue for synced realms throws. (Core 14.5.1)
* Fixed crash when integrating removal of already removed dictionary key. (Core 14.5.2)

### Compatibility
* Realm Studio: 15.0.0 or later.

### Internal
* Using Core 14.5.2.

## 2.0.0 (2024-03-20)

**Note**: Using the newly added support for collections in `RealmValue` with Atlas Device Sync is currently in private preview. Reach out to the support team if you need it enabled for your app. Rolling it out across all apps is expected to happen in late April 2024.

### Breaking Changes
* `RealmValue.type` is now an enum of type `RealmValueType` rather than `Type`. If you need the runtime type of the value wrapped in `RealmValue`, use `RealmValue.value.runtimeType`. (Issue [#1505](https://github.com/realm/realm-dart/issues/1505))
* Renamed `RealmValue.uint8List` constructor to `RealmValue.binary`. (PR [#1469](https://github.com/realm/realm-dart/pull/1469))
* Removed the following deprecated classes and members:
  * `AppConfiguration.localAppName` - was unused and had no effect
  * `AppConfiguration.localAppVersion` - was unused and had no effect
  * `ClientResetError.isFatal` - it was always `true`
  * `ClientResetError.sessionErrorCode`
  * `SyncError.codeValue` - can be accessed through `SyncError.code.code`
  * `SyncError.category` - categories were deprecated in `1.6.0`
  * `SyncError.detailedMessage` - was always empty
  * `SyncError` constructor and `SyncError.create` factory - sync errors are created internally by the SDK and are not supposed to be constructed by users
  * `SyncClientError`, `SyncConnectionError`, `SyncSessionError`, `SyncResolveError`, `SyncWebSocketError`, `GeneralSyncError` - consolidated into `SyncError` as part of the error simplification in `1.6.0`
  * `RealmProperty.indexed` - replaced by `RealmProperty.indexType`
  * `SyncErrorCategory`, `SyncClientErrorCode`, `SyncConnectionErrorCode`, `SyncSessionErrorCode`, `SyncResolveErrorCode`, `SyncWebsocketErrorCode`, `GeneralSyncErrorCode` - consolidated into `SyncErrorCode` as part of the error simplification in `1.6.0`
  * `User.provider` - the provider is associated with each identity, so the value was incorrect for users who had more than one identity
* The generated parts are now named `.realm.dart` instead of `.g.dart`. This is because the builder is now a `PartBuilder`, instead of a `SharedPartBuilder`. To migrate to this version you need to update all the part declarations to match, ie. `part 'x.g.dart` becomes `part x.realm.dart` and rerun the generator.

  This makes it easier to combine builders. Here is an example of combining with `dart_mappable`:
  ```dart
  import 'package:dart_mappable/dart_mappable.dart';
  import 'package:realm_dart/realm.dart';

  part 'part_builder.realm.dart';
  part 'part_builder.mapper.dart';

  @MappableClass()
  @RealmModel()
  class $Stuff with $StuffMappable {
    @MappableField()
    late int id;

    @override
    String toString() => 'Stuff{id: $id}';
  }

  final realm = Realm(Configuration.local([Stuff.schema]));
  void main(List<String> arguments) {
    final s = realm.write(() => realm.add(Stuff(1), update: true));
    print(s.toJson()); // <-- realm object as json
    Realm.shutdown();
  }
  ```
* Removed `SchemaObject.properties` - instead, `SchemaObject` is now an iterable collection of `Property`. (Issue [#1449](https://github.com/realm/realm-dart/issues/1449))
* `SyncProgress.transferredBytes` and `SyncProgress.transferableBytes` have been consolidated into `SyncProgress.progressEstimate`. The values reported previously were incorrect and did not accurately represent bytes either. The new field better conveys the uncertainty around the progress being reported. With this release, we're reporting accurate estimates for upload progress, but estimating downloads is still unreliable. A future server and SDK release will add better estimations for download progress. (Issue [#1562](https://github.com/realm/realm-dart/issues/1562))
* `Realm.logger` is no longer settable, and no longer implements `Logger` from package `logging`. In particular you can no longer call `Realm.logger.level =`. Instead you should call `Realm.logger.setLogLevel(RealmLogLevel level, {RealmLogCategory? category})` that takes an optional category. If no category is explicitly given, then `RealmLogCategory.realm` is assumed.

  Also, note that setting a level is no longer local to the current isolate, but shared across all isolates. At the core level there is just one process wide logger.

  Categories form a hierarchy and setting the log level of a parent category will override the level of its children. The hierarchy is exposed in a type safe manner with:
  ```dart
  sealed class RealmLogCategory {
    /// All possible log categories.
    static final values = [
    realm,
    realm.app,
    realm.sdk,
    realm.storage,
    realm.storage.notification,
    realm.storage.object,
    realm.storage.query,
    realm.storage.transaction,
    realm.sync,
    realm.sync.client,
    realm.sync.client.changeset,
    realm.sync.client.network,
    realm.sync.client.reset,
    realm.sync.client.session,
    realm.sync.server,
    ...
  ```
  The `onRecord` stream now pumps `RealmLogRecord`s that include the category the message was logged to.

  If you want to hook up realm logging with conventional dart logging you can do:
  ```dart
  Realm.logger.onRecord.forEach((r) => Logger(r.category.toString()).log(r.level.level, r.message));
  ```
  If no isolate subscribes to `Realm.logger.onRecord` then the logs will by default be sent to stdout. (Issue [#1578](https://github.com/realm/realm-dart/issues/1578))


### Enhancements
* Realm objects can now be serialized as [EJSON](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/). (Issue [#1254](https://github.com/realm/realm-dart/issues/1254))
  ```dart
  import 'package:ejson/ejson.dart';
  // ...
  class _Event {
    late DateTime timestamp;
    late String message;
  }
  // ...
  final ejson = toEJson(aRealmObject);
  final anUnmanagedRealmObject = fromEJson<Event>(ejson);
  ```
* Added `isCollectionDeleted` to `RealmListChanges`, `RealmSetChanges`, and `RealmMapChanges` which will be `true` if the parent object, containing the collection has been deleted. (Core 14.0.0)
* Added `isCleared` to `RealmMapChanges` which will be `true` if the map has been cleared. (Core 14.0.0)
* Querying a specific entry in a collection (in particular 'first and 'last') is supported. (Core 14.0.0)
  ```dart
  class _Owner {
    late List<_Dog> dogs;
  }

  realm.query<Owner>('dogs[1].age = 5'); // Query all owners whose second dog element is 5 years old
  realm.query<Owner>('dogs[FIRST].age = 5'); // Query all owners whose first dog is 5 years old
  realm.query<Owner>('dogs[LAST].age = 5'); // Query all owners whose last dog is 5 years old
  realm.query<Owner>('dogs[SIZE] = 10'); // Query all owners who have 10 dogs
  ```
* Added support for storing lists and maps inside a `RealmValue` property. (Issue [#1504](https://github.com/realm/realm-dart/issues/1504))
  ```dart
  class _Container {
    late RealmValue anything;
  }

  realm.write(() {
    realm.add(Container(anything: RealmValue.from([1, 'foo', 3.14])));
  });

  final container = realm.all<Container>().first;

  final list = container.anything.asList(); // will throw if cast is invalid
  for (final item in containerValue) {
    switch (item.type) {
      case RealmValueType.int:
        print('Integer: ${item.value as int}');
        break;
      case RealmValueType.string:
        print('String: ${item.value as String}');
        break;
      case RealmValueType.double:
        print('Double: ${item.value as double}');
        break;
    }
  }

  final subscription = list.changes.listen((event) {
    // The list changed
  });
  ```
* Added `RealmValueType` enum that contains all the possible types that can be wrapped by a `RealmValue`. (PR [#1469](https://github.com/realm/realm-dart/pull/1469))
* Added support for accessing `Set` and `Map` types using the dynamic object API - `obj.dynamic.getSet/getMap`. (PR [#1533](https://github.com/realm/realm-dart/pull/1533))
* Added `RealmObjectBase.objectSchema` that returns the schema for this object. In most cases, this would be the schema defined in the model, but in case the Realm is opened as dynamic (by providing an empty collection for schemaObjects in the config) or using `FlexibleSyncConfiguration`, it may change as the schema on disk changes. (Issue [#1449](https://github.com/realm/realm-dart/issues/1449))
* Added `Realm.schemaChanges` that returns a stream of schema changes that can be listened to. Only dynamic and synchronized Realms will emit schema changes. (Issue [#1449](https://github.com/realm/realm-dart/issues/1449))
* Improve performance of object notifiers with complex schemas and very simple changes to process by as much as 20% (Core 14.2.0).
* Improve performance with very large number of notifiers as much as 75% (Core 14.2.0).

### Fixed
* If you have more than 8388606 links pointing to one specific object, the program will crash. (Core 14.0.0)
* A Realm generated on a non-apple ARM 64 device and copied to another platform (and vice-versa) were non-portable due to a sorting order difference. This impacts strings or binaries that have their first difference at a non-ascii character. These items may not be found in a set, or in an indexed column if the strings had a long common prefix (> 200 characters). (Core 14.0.0)
* Ctor arguments appear in random order on generated classes, if the realm model contains many properties. (PR [#1531](https://github.com/realm/realm-dart/pull/1531))
* Fixed an issue where removing realm objects from a List with more than 1000 items could crash. (Core 14.2.0)
* Fix a spurious crash related to opening a Realm on background thread while the process was in the middle of exiting. (Core v14.3.0)
* Fixed conflict resolution bug which may result in an crash when the AddInteger instruction on Mixed properties is merged against updates to a non-integer type. (Core v14.3.0)

### Compatibility
* Realm Studio: 15.0.0 or later.
* Fileformat: Generates files with format v24. Reads and automatically upgrade from fileformat v10. If you want to upgrade from an earlier file format version you will have to use RealmCore v13.x.y or earlier.

### Internal
* Using Core v14.3.0

## 1.9.0 (2024-02-02)

### Enhancements
* Added `User.changes` stream that allows subscribers to receive notifications when the User changes - for example when the user's custom data changes or when their authentication state changes. (PR [#1500](https://github.com/realm/realm-dart/pull/1500))
* Allow the query builder to construct >, >=, <, <= queries for string constants. This is a case sensitive lexicographical comparison. Improved performance of RQL queries on a non-linked string property using: >, >=, <, <=, operators and fixed behavior that a null string should be evaluated as less than everything, previously nulls were not matched. (Core 13.26.0-13-gd12c3)

### Fixed
* Creating an `AppConfiguration` with an empty appId will now throw an exception rather than crashing the app. (Issue [#1487](https://github.com/realm/realm-dart/issues/1487))
* Uploading the changesets recovered during an automatic client reset recovery may lead to 'Bad server version' errors and a new client reset. (Core 13.26.0-13-gd12c3)

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.26.0-13-gd12c3
* Drop work-around for pre-dart-2.19 bug. ([#1691](https://github.com/realm/realm-dart/pull/1691))

## 1.8.0 (2024-01-29)

### Enhancements
* Added `RealmObject.getBacklinks<SourceType>('sourceProperty')` which is a method allowing you to look up all objects of type `SourceType` which link to the current object via their `sourceProperty` property. (Issue [#1480](https://github.com/realm/realm-dart/issues/1480))
* Added `App.updateBaseUrl` method for updating the App's base URL for switching between cloud and edge servers. The current Sync Session(s) must be paused before calling this method and the user must log in again afterwards before the Sync Session can be resumed. (PR [#1454](https://github.com/realm/realm-dart/pull/1454))

### Fixed
* Fix a possible hang (or in rare cases crash) during notification handling. (Issue [#1492](https://github.com/realm/realm-dart/issues/1492))
* Fix Flutter app build on Linux. A contribution from [thiagokisaki](https://github.com/thiagokisaki). (PR [#1488](https://github.com/realm/realm-dart/pull/1488))
* App was not using the current baseUrl value from AppConfiguration when it is created and always used the cached value stored upon the first contact with the server. (Core XX.XX.X)


### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.26.0

## 1.7.0 (2024-01-23)

### Enhancements
* Reworked how creating an `App` instance works across isolates:
  * The `App(AppConfiguration)` constructor should only be used on the main isolate. Ideally, it should be called once as soon as your app launches. If you attempt to use it on a background isolate (as indicated by `Isolate.debugName` being different from `main`), a warning will be logged.
  * Added a new method - `App.getById` that allows you to obtain an already constructed app on a background isolate.
  (Issue [#1433](https://github.com/realm/realm-dart/issues/1433))
* Added support for fields of type `Map<String, T>` where `T` is any supported Realm type. You can define a model with a map like:
  ```dart
  @RealmModel()
  class _LotsOfMaps {
    late Map<String, _Person?> persons;
    late Map<String, bool> bools;
    late Map<String, DateTime> dateTimes;
    late Map<String, Decimal128> decimals;
    late Map<String, double> doubles;
    late Map<String, int> ints;
    late Map<String, ObjectId> objectIds;
    late Map<String, RealmValue> realmValues;
    late Map<String, String> strings;
    late Map<String, Uint8List> datas;
    late Map<String, Uuid> uuids;
  }
  ```

  The map keys may not contain `.` or start with `$`. (Issue [#685](https://github.com/realm/realm-dart/issues/685))
* Added a new exception - `MigrationRequiredException` that will be thrown when a local Realm is opened with a schema that differs from the schema on disk and no migration callback is supplied. Additionally, a `helpLink` property has been added to `RealmException` and its subclasses to provide a link to the documentation for the error. (Issue [#1448](https://github.com/realm/realm-dart/issues/1448))
* Downgrade minimum dependencies to Dart 3.0.0 and Flutter 3.10.0. (PR [#1457](https://github.com/realm/realm-dart/pull/1457))

### Fixed
* Fixed warnings being emitted by the realm generator requesting that `xyz.g.dart` be included with `part 'xyz.g.dart';` for `xyz.dart` files that import `realm` but don't have realm models defined. Those should not need generated parts and including the part file would have resulted in an empty file with `// ignore_for_file: type=lint` being generated. (PR [#1443](https://github.com/realm/realm-dart/pull/1443))
* Updated the minimum required CMake version for Flutter on Linux to 3.19. (Issue [#1381](https://github.com/realm/realm-dart/issues/1381))
* Errors in user-provided client reset callbacks, such as `RecoverOrDiscardUnsyncedChangesHandler.onBeforeReset/onAfterDiscard` would not be correctly propagated and the client reset exception would contain a message like `A fatal error occurred during client reset: 'User-provided callback failed'` but no details about the actual error. Now `SyncError` has an `innerError` field which contains the original error thrown in the callback. (PR [#1447](https://github.com/realm/realm-dart/pull/1447))
* Fixed a bug where the generator would not emit errors for invalid default values for collection properties. Default values for collection properties are not supported unless the default value is an empty collection. (PR [#1406](https://github.com/realm/realm-dart/pull/1406))
* Bad performance of initial Sync download involving many backlinks (Issue [#7217](https://github.com/realm/realm-core/issues/7217), Core 13.25.1)
* Exceptions thrown during bootstrap application will now be surfaced to the user via the sync error handler rather than terminating the program with an unhandled exception. (PR [#7197](https://github.com/realm/realm-core/pull/7197), Core 13.25.0).
* Exceptions thrown during bootstrap application could crash the sync client with an `!m_sess` assertion if the bootstrap was being applied during sync::Session activation. (Issue [#7196](https://github.com/realm/realm-core/issues/7196), Core 13.25.0).
* If a SyncSession was explicitly resumed via `App.reconnect()` while it was waiting to auto-resume after a non-fatal error and then another non-fatal error was received, the sync client could crash with a `!m_try_again_activation_timer` assertion. (Issue [#6961](https://github.com/realm/realm-core/issues/6961), Core 13.25.0)
* Fixed several causes of "decryption failed" exceptions that could happen when opening multiple encrypted Realm files in the same process while using Apple/linux and storing the Realms on an exFAT file system. (Issue [#7156](https://github.com/realm/realm-core/issues/7156), Core 13.24.1)
* Fixed deadlock which occurred when accessing the current user from the `App` from within a callback from the `User` listener (Issue [#7183](https://github.com/realm/realm-core/issues/7183), Core 13.24.1)
* Having a class name of length 57 would make client reset crash as a limit of 56 was wrongly enforced (57 is the correct limit) (Issue [#7176](https://github.com/realm/realm-core/issues/7176), Core 13.24.1)
* Automatic client reset recovery on flexible sync Realms would apply recovered changes in multiple write transactions, releasing the write lock in between. This had several observable negative effects:
  - Other threads reading from the Realm while a client reset was in progress could observe invalid mid-reset state.
  - Other threads could potentially write in the middle of a client reset, resulting in history diverging from the server.
  - The change notifications produced by client resets were not minimal and would report that some things changed which actually didn't.
  - All pending subscriptions were marked as Superseded and then recreating, resulting in anything waiting for subscriptions to complete firing early.
  (PR [#7161](https://github.com/realm/realm-core/pull/7161), Core 13.24.1).
* If the very first open of a flexible sync Realm triggered a client reset, the configuration had an initial subscriptions callback, both before and after reset callbacks, and the initial subscription callback began a read transaction without ending it (which is normally going to be the case), opening the frozen Realm for the after reset callback would trigger a BadVersion exception (PR [#7161](https://github.com/realm/realm-core/pull/7161), Core 13.24.1).
* Changesets have wrong timestamps if the local clock lags behind 2015-01-01T00:00:00Z. The sync client now throws an exception if that happens. (PR [#7180](https://github.com/realm/realm-core/pull/7180), Core 13.24.1)
* Handle `EOPNOTSUPP` when using `posix_fallocate()` and fallback to manually consume space. This should enable android users to open a Realm on restrictive filesystems. (PR [#7251](https://github.com/realm/realm-core/pull/7251), Core v13.26.0)
* Application may crash with `incoming_changesets.size() != 0` when a download message is mistaken for a bootstrap message. This can happen if the synchronization session is paused and resumed at a specific time. (PR [#7238](https://github.com/realm/realm-core/pull/7238), Core v13.26.0, since v11.8.0)

### Compatibility
* Realm Studio: 13.0.0 or later.
* Flutter: ^3.10.0
* Dart: ^3.0.0

### Internal
* Using Core v13.26.0.

## 1.6.1 (2023-11-30)

### Fixed
* Fixed an issue where connections to Atlas App Services would fail on Android with a certificate expiration error. (Issue [#1430](https://github.com/realm/realm-dart/issues/1430))
* Fixed an issue with the generator where having multiple generated classes in the same file would result in multiple `// ignore_for_file: type=lint` lines being added, which itself was generating a lint warning. (Issue [#1412](https://github.com/realm/realm-dart/issues/1412))
* Errors encountered while reapplying local changes for client reset recovery on partition-based sync Realms would result in the client reset attempt not being recorded, possibly resulting in an endless loop of attempting and failing to automatically recover the client reset. Flexible sync and errors from the server after completing the local recovery were handled correctly. (Core 13.24.0)
* During a client reset with recovery when recovering a move or set operation on a `List` that operated on indices that were not also added in the recovery, links to an object which had been deleted by another client while offline would be recreated by the recovering client. But the objects of these links would only have the primary key populated and all other fields would be default values. Now, instead of creating these zombie objects, the lists being recovered skip such deleted links. (Core 13.24.0)
* During a client reset recovery a Set of objects could be missing items, or an exception could be thrown that prevents recovery ex: "Requested index 1 calling get() on set 'source.collection' when max is 0". (Core 13.24.0)
* Automatic client reset recovery would duplicate insertions in a list when recovering a write which made an unrecoverable change to a list (i.e. modifying or deleting a pre-existing entry), followed by a subscription change, followed by a write which added an entry to the list. (Core 13.24.0)

### Compatibility
* Realm Studio: 13.0.0 or later.
* Flutter: ^3.13.0
* Dart: ^3.1.0

### Internal
* Using Core 13.24.0.

## 1.6.0 (2023-11-15)

### Enhancements
* Support for performing geo spatial queries using the new classes: `GeoPoint`, `GeoCircle`, `GeoBox` and `GeoPolygon`. See `GeoPoint` documentation on how to persist locations ([#1389](https://github.com/realm/realm-dart/pull/1389))
* Suppressing rules for a  *.g.dart files ([#1413](https://github.com/realm/realm-dart/pull/1413))
* Full text search supports searching for prefix only. Eg. "description TEXT 'alex*'" (Core upgrade)
* Unknown protocol errors received from the baas server will no longer cause the application to crash if a valid error action is also received. (Core upgrade)
* Added support for server log messages that are enabled by sync protocol version 10. AppServices request id will be provided in a server log message in a future server release. (Core upgrade)
* Simplified sync errors. The following sync errors and error codes are deprecated ([#1387](https://github.com/realm/realm-dart/pull/1387)):
   * `SyncClientError`, `SyncConnectionError`, `SyncSessionError`, `SyncWebSocketError`, `GeneralSyncError` - replaced by `SyncError`.
   * `SyncClientErrorCode`, `SyncConnectionErrorCode`, `SyncSessionErrorCode`, `SyncWebSocketErrorCode`, `GeneralSyncErrorCode, SyncErrorCategory` - replaced by `SyncErrorCode`.
* Throw an exception if `File::unlock` has failed, in order to inform the SDK that we are likely hitting some limitation on the OS filesystem, instead of crashing  the application and use the same file locking logic for all the platforms. (Core upgrade)
* Lift a restriction that prevents asymmetric objects from linking to non-embedded objects. ([#1403](https://github.com/realm/realm-dart/issues/1403))
* Add ISRG X1 Root certificate (used by lets-encrypt and hence MongoDB) to `SecurityContext` of the default `HttpClient`. This ensure we work out-of-the-box on older devices (in particular Android 7 and earlier), as well as some Windows machines. ([#1187](https://github.com/realm/realm-dart/issues/1187), [#1370](https://github.com/realm/realm-dart/issues/1370))
* Added new flexible sync API `RealmResults.subscribe()` and `RealmResults.unsubscribe()` as an easy way to create subscriptions and download data in background. Added named parameter to `MutableSubscriptionSet.clear({bool unnamedOnly = false})` for removing all the unnamed subscriptions. ([#1354](https://github.com/realm/realm-dart/pull/1354))
* Added `cancellationToken` parameter to `Session.waitForDownload()`, `Session.waitForUpload()` and `SubscriptionSet.waitForSynchronization()`. ([#1354](https://github.com/realm/realm-dart/pull/1354))

### Fixed
* Fixed iteration after `skip` bug ([#1409](https://github.com/realm/realm-dart/issues/1409))
* Crash when querying the size of a Object property through a link chain (Core upgrade, since v13.17.2)
* Deprecated `App.localAppName` and `App.localAppVersion`. They were not used by the server and were not needed to set them. ([#1387](https://github.com/realm/realm-dart/pull/1387))
* Fixed crash in slab allocator (`Assertion failed: ref + size <= next->first`). (Core upgrade, since 13.0.0)
* Sending empty UPLOAD messages may lead to 'Bad server version' errors and client reset. (Core upgrade, since v11.8.0)
* If a user was logged out while an access token refresh was in progress, the refresh completing would mark the user as logged in again and the user would be in an inconsistent state. (Core 13.21.0)
* Receiving a `write_not_allowed` error from the server would have led to a crash. (Core 13.22.0)
* Fix interprocess locking for concurrent realm file access resulting in a interprocess deadlock on FAT32/exFAT filesystems. (Core 13.23.0)
* Fixed RealmObject not overriding `hashCode`, which would lead to sets of RealmObjects potentially containing duplicates. ([#1418](https://github.com/realm/realm-dart/issues/1418))
* `realm.subscriptions.waitForSynchronization` will now correctly receive an error if a fatal session error occurs that would prevent it from ever completing. Previously the future would never resolve. (Core 13.23.3)
* Fixed FLX subscriptions not being sent to the server if the session was interrupted during bootstrapping. (Core 13.23.3)
* Fixed application crash with 'KeyNotFound' exception when subscriptions are marked complete after a client reset. (Core 13.23.3)
* A crash at a very specific time during a DiscardLocal client reset on a FLX Realm could leave subscriptions in an invalid state. (Core 13.23.4)

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Made binding a `sync::Session` exception safe so if a `MultipleSyncAgents` exception is thrown, the sync client can be torn down safely. (Core upgrade, since 13.4.1)
* Add information about the reason a synchronization session is used for to flexible sync client BIND message. (Core upgrade)
* Sync protocol version bumped to 10. (Core upgrade)
* Handle `badChangeset` error when printing changeset contents in debug. (Core upgrade)

* Using Core 13.23.4.

## 1.5.0 (2023-09-18)

### Enhancements
* Support efficient `skip` on `RealmResults` ([#1391](https://github.com/realm/realm-dart/pull/1391))
* Support efficient `indexOf` and `contains` on `RealmResults` ([#1394](https://github.com/realm/realm-dart/pull/1394))
* Support asymmetric objects. ([#1400](https://github.com/realm/realm-dart/pull/1400))

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.17.2

## 1.4.0 (2023-08-16)

### Enhancements
* Support ReamSet.freeze() ([#1342](https://github.com/realm/realm-dart/pull/1342))
* Added support for query on `RealmSet`. ([#1346](https://github.com/realm/realm-dart/pull/1346))
* Support for passing `List`, `Set` or `Iterable` arguments to queries with `IN`-operators. ([#1346](https://github.com/realm/realm-dart/pull/1346))

### Fixed
* Fixed an early unlock race condition during client reset callbacks. ([#1335](https://github.com/realm/realm-dart/pull/1335))
* Rare corruption of files on streaming format (often following compact, convert or copying to a new file). (Core upgrade, since v12.12.0)
* Trying to search a full-text indexes created as a result of an additive schema change (i.e. applying the differences between the local schema and a synchronized realm's schema) could have resulted in an IllegalOperation error with the error code `Column has no fulltext index`. (Core upgrade, since v13.2.0).
* Sync progress for DOWNLOAD messages from server state was updated wrongly. This may have resulted in an extra round-trip to the server. (Core upgrade, since v12.9.0)
* Fixes infinite-loop like issue with await-for-yield over realm set change streams. ([#1344](https://github.com/realm/realm-dart/issues/1344))
* Fixed issue with using flexibleSync in flutter test. ([#1366](https://github.com/realm/realm-dart/pull/1366))
* Fixed a realm generator issue, when used in concert with MobX. ([#1372](https://github.com/realm/realm-dart/pull/1372))
* Fix failed assertion for unknown app server errors (Core upgrade, since v12.9.0).
* Testing the size of a collection of links against zero would sometimes fail (sometimes = "difficult to explain"). (Core upgrade, since v13.15.1)
* `Session.getProgressStream` now returns a regular stream, instead of a broadcast stream. ([#1375](https://github.com/realm/realm-dart/pull/1375))
* Add ISRG X1 Root certificate (used by lets-encrypt and hence MongoDB) to `SecurityContext` of the default `HttpClient`. This ensure we work out-of-the-box on older devices (in particular Android 7 and earlier), as well as some Windows machines. ([#1187](https://github.com/realm/realm-dart/issues/1187), [#1370](https://github.com/realm/realm-dart/issues/1370))

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.17.2.

## 1.3.0 (2023-06-22)

### Enhancements
* Added support binary data type. ([#1320](https://github.com/realm/realm-dart/pull/1320))
* Extended `ClientResetError` to return the `backupFilePath` where the backup copy of the realm will be placed once the client reset process has completed. ([#1291](https://github.com/realm/realm-dart/pull/1291))
* Added `CompensatingWriteError` containing detailed error information about the writes that have been reverted by the server due to permissions or subscription view restrictions. The `Configuration.flexibleSync.syncErrorHandler` will be invoked with this error type when this error occurs ([#1291](https://github.com/realm/realm-dart/pull/1291)).
* Improve performance of elementAt, first, single and last on RealmResults ([#1261](https://github.com/realm/realm-dart/issues/1261), [#1262](https://github.com/realm/realm-dart/pull/1262), [#1267](https://github.com/realm/realm-dart/pull/1267)).

### Fixed
* The constructors of all `SyncError` types are deprecated. The sync errors will be created only internally ([#1291](https://github.com/realm/realm-dart/pull/1291)).
* Getting `Backlink` properties of unmanaged Realm objects will throw an error: "Using backlinks is only possible for managed objects" ([#1293](https://github.com/realm/realm-dart/pull/1293)).
* Properties in the frozen _before_ Realm instance in the client reset callbacks may have had properties reordered which could lead to exceptions if accessed. (Core upgrade, since v13.11.0)


### Compatibility
* Realm Studio: 13.0.0 or later.
* Dart ^3.0.2 and Flutter ^3.10.2

### Internal
* Synced realms will use async open to prevent overloading the server with schema updates. [#1369](https://github.com/realm/realm-dart/pull/1369))
* Using Core 13.15.1

## 1.2.0 (2023-06-08)

### Enhancements
  * Added support for Full-Text search (simple term) queries. ([#1300](https://github.com/realm/realm-dart/pull/1300))
  * To enable FTS queries on string properties, add the `@Indexed(RealmIndexType.fullText)` annotation.
  * To run queries, use the `TEXT` operator: `realm.all<Book>().query("description TEXT \$0", "fantasy novel")`.

### Fixed
* Fix the query parser, it needs to copy a list of arguments and own the memory. This will prevent errors like getting a different result from a query, if the list is modified after its creation and before the execution of the query itself. In the worst case scenario, if the memory is freed before the query is executed, this could lead to crashes, especially for string and binary data types. (Core upgrade, since core v12.5.0)
* Fixed a potential crash when opening the realm after failing to download a fresh FLX realm during an automatic client reset (Core upgrade, since core v12.3.0)
* Access token refresh for websockets was not updating the location metadata (Core upgrade, since core v13.9.3)
* Using both synchronous and asynchronous transactions on the same thread or scheduler could hit the assertion failure "!realm.is_in_transaction()" if one of the callbacks for an asynchronous transaction happened to be scheduled during a synchronous transaction (Core upgrade, since core v11.8.0)
* Fixed an issue where the generator would incorrectly consider a `DateTime` field a valid primary key ([#1300](https://github.com/realm/realm-dart/pull/1300)).

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.14.0.

## 1.1.0 (2023-05-30)

### Enhancements
* Add `RealmResults.isValid` ([#1231](https://github.com/realm/realm-dart/pull/1231)).
* Support `Decimal128` datatype ([#1192](https://github.com/realm/realm-dart/pull/1192)).
* Realm logging is extended to support logging of all Realm storage level messages. (Core upgrade).
* Realm.logger now prints by default to the console from the first Isolate that initializes a Realm in the application. ([#1226](https://github.com/realm/realm-dart/pull/1226)).
  Calling `Realm.logger.clearListeners()` or `Realm.logger.level = RealmLogLevel.off` will turn off logging. If that is the first isolate it will stop the default printing logger.
  The default logger can be replaced with a custom implementation using `Realm.logger = CustomLogger()` from the first Isolate.
  Any new spawned Isolates that work with Realm will get a new `Realm.logger` instance but will not `print` by default.
  `Realm.logger.level` allows changing the log level per isolate.
* Add logging at the Storage level (Core upgrade).
* Performance improvement for the following queries (Core upgrade):
    * Significant (~75%) improvement when counting (query count) the number of exact matches (with no other query conditions) on a String/int/Uuid/ObjectId property that has an index. This improvement will be especially noticeable if there are a large number of results returned (duplicate values).
    * Significant (~99%) improvement when querying for an exact match on a Timestamp property that has an index.
    * Significant (~99%) improvement when querying for a case insensitive match on a Mixed property that has an index.
    * Moderate (~25%) improvement when querying for an exact match on a Boolean property that has an index.
    * Small (~5%) improvement when querying for a case insensitive match on a Mixed property that does not have an index.

* Enable multiple processes to operate on an encrypted Realm simultaneously. (Core upgrade)

* Improve performance of equality queries on a non-indexed mixed property by about 30%. (Core upgrade)

* Improve performance of rolling back write transactions after making changes. If no KVO observers are used this is now constant time rather than taking time proportional to the number of changes to be rolled back. Rollbacks with KVO observers are 10-20% faster. (Core upgrade)
* New notifiers can now be registered in write transactions until changes have actually been made in the write transaction. This makes it so that new notifications can be registered inside change notifications triggered by beginning a write transaction (unless a previous callback performed writes). (Core upgrade)

* Very slightly improve performance of runtime thread checking on the main thread on Apple platforms. (Core upgrade)

### Fixed
* Fixed a bug that may have resulted in arrays being in different orders on different devices (Core upgrade).
* Fixed a crash when querying a mixed property with a string operator (contains/like/beginswith/endswith) or with case insensitivity (Core upgrade).
* Querying for equality of a string on an indexed mixed property was returning case insensitive matches. For example querying for `myIndexedMixed == "Foo"` would incorrectly match on values of "foo" or "FOO" etc (Core upgrade).
* Adding an index to a Mixed property on a non-empty table would crash with an assertion (Core upgrade).
* `SyncSession.pause()` could hold a reference to the database open after shutting down the sync session, preventing users from being able to delete the realm (Core upgrade).
* Fixed `RealmResultsChanges.isCleared` which was never set. It now returns `true` if the results collection is empty in the notification callback. This field is also marked as `deprecated` and will be removed in future. Use `RealmResultsChanges.results.isEmpty` instead.([#1265](https://github.com/realm/realm-dart/pull/1265)). ([#1278](https://github.com/realm/realm-dart/issues/1278)).

* Fix a stack overflow crash when using the query parser with long chains of AND/OR conditions. (Core upgrade)
* `SyncManager::immediately_run_file_actions()` no longer ignores the result of trying to remove a realm. This could have resulted in a client reset action being reported as successful when it actually failed on windows if the `Realm` was still open (Core upgrade).
* Fix a data race. If one thread committed a write transaction which increased the number of live versions above the previous highest seen during the current session at the same time as another thread began a read, the reading thread could read from a no-longer-valid memory mapping (Core upgrade).

* Fixed a crash or exception when doing a fulltext search for multiple keywords when the intersection of results is not equal. (Core upgrade).

* Don't report non ssl related errors during ssl handshake as fatal in default socket provider. (Core upgrade)

* Performing a query like "{1, 2, 3, ...} IN list" where the array is longer than 8 and all elements are smaller than some values in list, the program would crash (Core upgrade)
* Performing a large number of queries without ever performing a write resulted in steadily increasing memory usage, some of which was never fully freed due to an unbounded cache (Core upgrade)

* Exclusion of words in a full text search does not work (Core upgrade)

* Fixed a fatal error (reported to the sync error handler) during client reset (or automatic PBS to FLX migration) if the reset has been triggered during an async open and the schema being applied has added new classes. (Core upgrade), since automatic client resets were introduced in v11.5.0)
* Full text search would sometimes find words where the word only matches the beginning of the search token (Core upgrade)

* We could crash when removing backlinks in cases where forward links did not have a corresponding backlink due to corruption. We now silently ignore this inconsistency in release builds, allowing the app to continue. (Core upgrade)
* If you freeze a Results based on a collection of objects, the result would be invalid if you delete the collection (Core upgrade)

### Compatibility
* Fileformat: Generates files with format v23. Reads and automatically upgrade from fileformat v5.
* Realm Studio: 13.0.0 or later.
* Dart >=2.17.5 <4.0.0 (Flutter >=3.0.3) on Android, iOS, Linux, MacOS and Windows

### Internal
* Using Core 13.12.0.
* Lock file format: New format introduced for multi-process encryption. All processes accessing the file must be upgraded to the new format.

## 1.0.3 (2023-03-20)

### Enhancements
* Deprecated `SyncResolveError` and `SyncResolveErrorCode` ([#1182](https://github.com/realm/realm-dart/pull/1182)).
* Added `SyncWebSocketError` and `SyncWebSocketErrorCode` for web socket connection sync errors ([#1182](https://github.com/realm/realm-dart/pull/1182)).
* Added `FlexibleSyncConfiguration.shouldCompactCallback` support ([#1204](https://github.com/realm/realm-dart/pull/1204)).
* Added `RealmSet.asResults()` ([#1214](https://github.com/realm/realm-dart/pull/1214)).

### Fixed
* You may have a crash on Windows if you try to open a file with non-ASCII path (Core upgrade).
* Creating subscriptions with queries having unicode parameters causes a server error (Core upgrade).
* Fixed error message when trying to `switchUser` of the `App` to a user that has been logged out ([#1182](https://github.com/realm/realm-dart/pull/1182)).
* Fixed performance degradation on SubQueries (Core upgrade).
* Fixed several cases where wrong type of exception was thrown (Core upgrade).
* Fixed classification of InvalidQuery exception (Core upgrade).
* Fix crash if secure transport returns an error with a non-zero length. (Core upgrade).
* Fix error in `RealmSet<T>` when `T` is a realm object ([#1202](https://github.com/realm/realm-dart/pull/1212)).
* Fixes infinite-loop like issue with await-for-yield over change streams ([#1213](https://github.com/realm/realm-dart/pull/1213)).

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.6.0.

## 1.0.2 (2023-02-21)

### Fixed
* Fixed the sync client being stuck in a cycle if an integration error occurs by issuing a client reset (Core upgrade).
* Fixed Android binaries sizes.

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.4.2

## 1.0.1 (2023-02-14)

### Fixed
* Fix codesigning errors when publishing to the macOS App Store. ([#1153](https://github.com/realm/realm-dart/issues/1153))

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.4.0

## 1.0.0 (2023-02-07)

### GA release
We are proud to forge this release as 1.0. The Realm Flutter and Dart SDK is now being used by thousands of developers and has proven reliable.

### Enhancements
* Improved error information returned when the `realm_dart` library failed to load. ([#1143](https://github.com/realm/realm-dart/pull/1143))

### Fixed
* Improve performance of interprocess mutexes on iOS which don’t need to support reader-writer locking. The primary beneficiary of this is beginning and ending read transactions, which is now almost as fast as pre-v13.0.0 (Core upgrade).

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.4.0

## 0.11.0+rc (2023-01-30)

**This project is in Release Candidate stage.**

### Enhancements
* Add `App.reconnect()` providing a hint to Realm to reconnect all sync sessions.
* Add `Realm.refresh()` and `Realm.refreshAsync()` support. ([#1046](https://github.com/realm/realm-dart/pull/1046))
* Support change notifications property `isCleared` on list collections and sets. ([#1128](https://github.com/realm/realm-dart/pull/1128))

### Fixed
* `SyncSession.pause()` allow users to suspend a Realm's sync session until it is explicitly resumed with `SyncSession.resume()`. Previously it could be implicitly resumed in rare cases. (Core upgrade)
* Improve the performance of `Realm.freeze()` and friends (`RealmObject.freeze()`,`RealmList.freeze(), RealmResults.freeze(), RealmSet.freeze()`) by eliminating some redundant work around schema initialization and validation. (Core upgrade)
* Include more details if an error occurs when merging object. (Core upgrade)
* Value in List of Mixed would not be updated if new value is Binary and old value is StringData and the values otherwise matches. (Core upgrade)
* When client reset with recovery is used and the recovery does not actually result in any new local commits, the sync client may have gotten stuck in a cycle with a `A fatal error occurred during client reset: 'A previous 'Recovery' mode reset from <timestamp> did not succeed, giving up on 'Recovery' mode to prevent a cycle'` error message. (Core upgrade)
* Fixed diverging history in flexible sync if writes occur during bootstrap to objects that just came into view (Core upgrade)
* Fix several data races when opening cached frozen Realms. New frozen Realms were added to the cache and the lock released before they were fully initialized, resulting in races if they were immediately read from the cache on another thread (Core upgrade).
* Properties and types not present in the requested schema would be missing from the reported schema in several scenarios, such as if the Realm was being opened with a different schema version than the persisted one, and if the new tables or columns were added while the Realm instance did not have an active read transaction. (Core upgrade, since v13.2.0)
* If a client reset w/recovery or discard local is interrupted while the "fresh" realm is being downloaded, the sync client may crash (Core upgrade)
* Changesets from the server sent during FLX bootstrapping that are larger than 16MB can cause the sync client to crash with a LogicError. (Core upgrade)
* Online compaction may cause a single commit to take a long time. (Core upgrade, since v13.0.0)

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.3.0
* Added specific codes to `SyncResolveErrorCode` enum's items. ([#1131](https://github.com/realm/realm-dart/pull/1131).

## 0.10.0+rc (2023-01-23)

**This project is in Release Candidate stage.**

### Enhancements
* Add support for Realm set data type. ([#1102](https://github.com/realm/realm-dart/pull/1102))
* Exposed realm `writeCopy` API to copy a Realm file and optionally encrypt it with a different key. ([#1103](https://github.com/realm/realm-dart/pull/1103))

### Fixed
* Added an error for default values for Realm object references in the Realm generator. ([#1102](https://github.com/realm/realm-dart/pull/1102))
* `realm.deleteMany()` will handle efficiently ManagedRealmList instances. ([#1117](https://github.com/realm/realm-dart/pull/1171))

### Compatibility
* Realm Studio: 13.0.0 or later.

### Internal
* Using Core 13.2.0.

## 0.9.0+rc (2023-01-13)

**This project is in Release Candidate stage.**

### Breaking Changes
* File format version bumped.
* The layout of the lock-file has changed, the lock file format version is bumped and all participants in a multiprocess scenario needs to be up to date so they expect the same format. This requires an update of Studio. (Core upgrade)
* Writing to a frozen realm throws `RealmException` instead of `RealmError`. ([#974](https://github.com/realm/realm-dart/pull/974))

### Enhancements
* Support setting `maxNumberOfActiveVersions` when creating a `Configuration`. ([#1036](https://github.com/realm/realm-dart/pull/1036))
* Add List.move extension method that moves an element from one index to another. Delegates to ManagedRealmList.move for managed lists. This allows notifications to correctly report moves, as opposed to reporting moves as deletes + inserts. ([#1037](https://github.com/realm/realm-dart/issues/1037))
* Support setting `shouldDeleteIfMigrationNeeded` when creating a `Configuration.local`. ([#1049](https://github.com/realm/realm-dart/issues/1049))
* Add `unknown` error code to all SyncErrors: `SyncSessionErrorCode.unknown`, `SyncConnectionErrorCode.unknown`, `SyncClientErrorCode.unknown`, `GeneralSyncErrorCode.unknown`. Use `unknown` error code instead of throwing a RealmError. ([#1052](https://github.com/realm/realm-dart/pull/1052))
* Add support for `RealmValue` data type. This new type can represent any valid Realm data type, including objects. Lists of `RealmValue` are also supported, but `RealmValue` itself cannot contain collections. Please note that a property of type `RealmValue` cannot be nullable, but can contain null, represented by the value `RealmValue.nullValue()`. ([#1051](https://github.com/realm/realm-dart/pull/1051))
* Add support for querying using the model property names, even when the properties are mapped to a different name in the database. ([#697](https://github.com/realm/realm-dart/issues/697))
* `ClientResetError.resetRealm` now returns a bool to indicate if reset was initiated or not. ([#1067](https://github.com/realm/realm-dart/pull/1067))
* Support `SyncErrorCategory.resolve`, `SyncResolveError` and `SyncResolveErrorCode` for network resolution errors when sync.

### Fixed
* Support mapping into `SyncSessionErrorCode` for "Compensating write" with error code 231. ([#1022](https://github.com/realm/realm-dart/pull/1022))
* Errors from core will be raised correctly for `beginWriteAsync` and `commitAsync`. ([#1042](https://github.com/realm/realm-dart/pull/1042))
* The realm file will be shrunk if the larger file size is no longer needed. (Core upgrade)
* Most of the file growth caused by version pinning is eliminated. (Core upgrade)
* Fetching a user's profile while the user logs out would result in an assertion failure. (Core upgrade)
* Removed the ".tmp_compaction_space" file being left over after compacting a Realm on Windows. (Core upgrade).
* Restore fallback to full barrier when F_BARRIERSYNC is not available on Apple platforms. (Core upgrade, since v0.8.0+rc)
* Fixed wrong assertion on query error that could result in a crash. (Core upgrade)
* Writing to a read-only realm throws `RealmException` instead of blocking the isolate. ([#974](https://github.com/realm/realm-dart/pull/974))
* Fix no notification for write transaction that contains only change to backlink property. (Core upgrade)
* Fixed wrong assertion on query error that could result in a crash. (Core upgrade)
* Use random tmp directory for download. ([#1060](https://github.com/realm/realm-dart/issues/1060))
* Bump minimum Dart SDK version to 2.17.5 and Flutter SDK version to 3.0.3 due to an issue with the Dart virtual machine when implementing `Finalizable`. ([dart-lang/sdk#49075](https://github.com/dart-lang/sdk/issues/49075))
* Support install command in flutter projects that use unit and widget tests. ([#870](https://github.com/realm/realm-dart/issues/870))

### Compatibility
* Realm Studio: 13.0.0 or later.
* Fileformat: Generates files with format v23. Reads and automatically upgrades from fileformat v5.

### Internal
* Using Core 13.2.0.
* No longer use vcpkg ([#1069](https://github.com/realm/realm-dart/pull/1069))
* Upgraded analyzer dependency to ^5.0.0. ([#1072](https://github.com/realm/realm-dart/pull/1072))

## 0.8.0+rc (2022-11-14)

**This project is in Release Candidate stage.**

### Breaking Changes
* `FunctionsClient.call` no longer accepts a null for the optional `functionsArgs` parameter, but it is still optional. ([#1025](https://github.com/realm/realm-dart/pull/1025))

### Fixed
* Allow backlinks between files. ([#1015](https://github.com/realm/realm-dart/issues/1015))
* Fix issue with accessing properties after traversing a backlink. ([#1018](https://github.com/realm/realm-dart/issues/1018))
* Bootstraps will not be applied in a single write transaction - they will be applied 1MB of changesets at a time, or as configured by the SDK (Core upgrade).
* Fix database corruption and encryption issues on apple platforms. (Core upgrade)

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Using Core 12.12.0.

## 0.7.0+rc (2022-11-04)

**This project is in Release Candidate stage.**

### Breaking Changes
* SyncClientResetErrorHandler is renamed to ClientResetHandler. SyncClientResetError is renamed to ClientResetError. ManualSyncClientResetHandler is renamed to ManualRecoveryHandler.
* Default resync mode for `FlexibleSyncConfiguration` is changed from `manual` to `recoverOrDiscard`. In this mode Realm attempts to recover unsynced local changes and if that fails, then the changes are discarded. ([#925](https://github.com/realm/realm-dart/pull/925))
* Added `path` parameter to `Configuration.disconnectedSync`. This path is required to open the correct synced realm file. ([#1007](https://github.com/realm/realm-dart/pull/https://github.com/realm/realm-dart/pull/1007))

### Enhancements
* Added `MutableSubscriptionSet.removeByType` for removing subscriptions by their realm object type. ([#317](https://github.com/realm/realm-dart/issues/317))
* Added `User.functions`. This is the entry point for calling Atlas App functions. Functions allow you to define and execute server-side logic for your application. Atlas App functions are created on the server, written in modern JavaScript (ES6+) and executed in a serverless manner. When you call a function, you can dynamically access components of the current application as well as information about the request to execute the function and the logged in user that sent the request. ([#973](https://github.com/realm/realm-dart/pull/973))
* Support results of primitives, ie. `RealmResult<int>`. ([#162](https://github.com/realm/realm-dart/issues/162))
* Support notifications on all managed realm lists, including list of primitives, ie. `RealmList<int>.changes` is supported. ([#893](https://github.com/realm/realm-dart/pull/893))
* Support named backlinks on realm models. You can now add and annotate a realm object iterator field with `@Backlink(#fieldName)`. ([#996](https://github.com/realm/realm-dart/pull/996))
* Added Realm file compaction support. ([#1005](https://github.com/realm/realm-dart/pull/1005))
* Allow `@Indexed` attribute on all indexable type, and ensure appropriate indexes are created in the realm. ([#797](https://github.com/realm/realm-dart/issues/797))
* Add `parent` getter on embedded objects. ([#979](https://github.com/realm/realm-dart/pull/979))
* Support [Client Resets](https://www.mongodb.com/docs/atlas/app-services/sync/error-handling/client-resets/). Atlas App Services automatically detects the need for client resets and the realm client automatically performs it according to the configured callbacks for the type of client reset handlers set on `FlexibleSyncConfiguration`. A parameter `clientResetHandler` is added to `Configuration.flexibleSync`. Supported client reset handlers are `ManualRecoveryHandler`, `DiscardUnsyncedChangesHandler`, `RecoverUnsyncedChangesHandler` and `RecoverOrDiscardUnsyncedChangesHandler`. `RecoverOrDiscardUnsyncedChangesHandler` is the default strategy. ([#925](https://github.com/realm/realm-dart/pull/925)) An example usage of the default `clientResetHandler` is as follows:
```dart
      final config = Configuration.flexibleSync(user, [Task.schema],
        clientResetHandler: RecoverOrDiscardUnsyncedChangesHandler(
          // The following callbacks are optional.
          onBeforeReset: (beforeResetRealm) {
            // Executed right before a client reset is about to happen.
            // If an exception is thrown here the recovery and discard callbacks are not called.
          },
          onAfterRecovery: (beforeResetRealm, afterResetRealm) {
            // Executed right after an automatic recovery from a client reset has completed.
          },
          onAfterDiscard: (beforeResetRealm, afterResetRealm) {
            // Executed after an automatic recovery from a client reset has failed but the Discard has completed.
          },
          onManualResetFallback: (clientResetError) {
            // Handle the reset manually in case some of the callbacks above throws an exception
          },
        )
    );
```

### Fixed
* Fixed a wrong mapping for `AuthProviderType` returned by `User.provider` for google, facebook and apple credentials.
* Opening an unencrypted file with an encryption key would sometimes report a misleading error message that indicated that the problem was something other than a decryption failure (Core upgrade)
* Fix a rare deadlock which could occur when closing a synchronized Realm immediately after committing a write transaction when the sync worker thread has also just finished processing a changeset from the server. (Core upgrade)
* Fixed an issue with `Configuration.disconnectedSync` where changing the schema could result in migration exception. ([#999](https://github.com/realm/realm-dart/pull/999))
* Added a better library load failed message. ([#1006](https://github.com/realm/realm-dart/pull/1006))

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Using Core 12.11.0.

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

### Fixed
* Added more validations when using `User.apiKeys` to return more meaningful errors when the user cannot perform API key actions - e.g. when the user has been logged in with API key credentials or when the user has been logged out. (Issue [#950](https://github.com/realm/realm-dart/issues/950))
* Fixed `dart run realm_dart generate` and `flutter pub run realm generate` commands to exit with the correct error code on failure.
* Added more descriptive error messages when passing objects managed by another Realm as arguments to `Realm.add/delete/deleteMany`. (PR [#942](https://github.com/realm/realm-dart/pull/942))
* Fixed a bug where `list.remove` would not correctly remove the value if the value is the first element in the list. (PR [#975](https://github.com/realm/realm-dart/pull/975))

### Compatibility
* Realm Studio: 12.0.0 or later.

### Internal
* Using Core 12.9.0

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
  expect(realm.query<Person>('FALSEPREDICATE').query('TRUEPREDICATE'), isEmpty); //<-- Fails if a Person object exists
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
    changes.inserted // indexes of inserted objects
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
* Completely rewritten from the ground up with sound null safety and using Dart FFI

### Fixed
* Realm close stops internal scheduler.

### Internal
* Fix linter issues

### Compatibility
* Dart ^2.15 on Windows, MacOS and Linux

## 0.2.0-alpha Release notes (2022-01-27)

Notes: This release is a prerelease version. All API's might change without warning and no guarantees are given about stability.

### Enhancements
* Completely rewritten from the ground up with sound null safety and using Dart FFI

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
