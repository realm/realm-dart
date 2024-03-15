## 2.0.0-alpha.5 (2024-03-15)

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

### Enhancements
* Realm objects can now be serialized as [EJSON](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/)
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

* Improve performance of object notifiers with complex schemas and very simple changes to process by as much as 20% ([Core 14.2.0).
* Improve performance with very large number of notifiers as much as 75% (Core 14.2.0).
* Add support to synchronize collections embedded in Mixed properties and other collections (except sets) (Core v14.2.0-12-g95c6efce8).
* Improve performance of change notifications on nested collections somewhat (Core v14.2.0-12-g95c6efce8).
* Improve performance of aggregate operations on Dictionaries of objects, particularly when the dictionaries are empty (Core v14.2.0-12-g95c6efce8)

### Fixed
* If you have more than 8388606 links pointing to one specific object, the program will crash. (Core 14.0.0)
* A Realm generated on a non-apple ARM 64 device and copied to another platform (and vice-versa) were non-portable due to a sorting order difference. This impacts strings or binaries that have their first difference at a non-ascii character. These items may not be found in a set, or in an indexed column if the strings had a long common prefix (> 200 characters). (Core 14.0.0)
* Ctor arguments appear in random order on generated classes, if the realm model contains many properties. (PR [#1531](https://github.com/realm/realm-dart/pull/1531))
* Fixed an issue where removing realm objects from a List with more than 1000 items could crash. (Core 14.2.0)
* Fix a spurious crash related to opening a Realm on background thread while the process was in the middle of exiting (Core v14.2.0-12-g95c6efce8)

### Compatibility
* Realm Studio: 14.0.0 or later.
* Fileformat: Generates files with format v24. Reads and automatically upgrade from fileformat v10. If you want to upgrade from an earlier file format version you will have to use RealmCore v13.x.y or earlier.

### Internal
* Using Core v14.2.0-12-g95c6efce8

