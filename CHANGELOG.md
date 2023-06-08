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
