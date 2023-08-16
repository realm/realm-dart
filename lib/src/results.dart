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
import 'dart:async';
import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';

import 'collections.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the Realm that match the underlying query.
///
/// {@category Realm}
class RealmResults<T extends Object?> extends Iterable<T> with RealmEntity implements Finalizable {
  final RealmObjectMetadata? _metadata;
  final RealmResultsHandle _handle;

  final _supportsSnapshot = <T>[] is List<RealmObjectBase?>;

  RealmResults._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  /// Gets a value indicating whether this collection is still valid to use.
  bool get isValid => realmCore.resultsIsValid(this);

  /// Returns the element of type `T` at the specified [index].
  T operator [](int index) => elementAt(index);

  /// Returns the element of type `T` at the specified [index].
  @override
  T elementAt(int index) {
    if (this is RealmResults<RealmObjectBase>) {
      final handle = realmCore.resultsGetObjectAt(this, index);
      final accessor = RealmCoreAccessor(metadata, realm.isInMigration);
      return RealmObjectInternal.create(T, realm, handle, accessor) as T;
    } else {
      return realmCore.resultsGetElementAt(this, index) as T;
    }
  }

  /// `true` if the `Results` collection is empty.
  @override
  bool get isEmpty => length == 0;

  /// Returns a new `Iterator` that allows iterating the elements in this `RealmResults`.
  @override
  Iterator<T> get iterator {
    var results = this;
    if (_supportsSnapshot) {
      final handle = realmCore.resultsSnapshot(this);
      results = RealmResultsInternal.create<T>(handle, realm, _metadata);
    }
    return _RealmResultsIterator(results);
  }

  /// The number of values in this `Results` collection.
  @override
  int get length => realmCore.getResultsCount(this);

  @override
  T get first {
    if (length == 0) {
      throw RealmStateError('No element');
    }
    return this[0];
  }

  @override
  T get last {
    if (length == 0) {
      throw RealmStateError('No element');
    }
    return this[length - 1];
  }

  @override
  T get single {
    final l = length;
    if (l > 1) {
      throw RealmStateError('Too many elements');
    }
    if (l == 0) {
      throw RealmStateError('No element');
    }
    return this[0];
  }

  /// Creates a frozen snapshot of this query.
  RealmResults<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveResults(this);
  }

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmResultsChanges<T>> get changes {
    if (isFrozen) {
      throw RealmStateError('Results are frozen and cannot emit changes');
    }

    final controller = ResultsNotificationsController<T>(this);
    return controller.createStream();
  }
}

// The query operations on results only work for results of objects (core restriction),
// so we add it as an extension methods to allow the compiler to prevent misuse.
extension RealmResultsOfObject<T extends RealmObjectBase> on RealmResults<T> {
  /// Returns a new [RealmResults] filtered according to the provided query.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://www.mongodb.com/docs/realm/realm-query-language/)
  RealmResults<T> query(String query, [List<Object> args = const []]) {
    final handle = realmCore.queryResults(this, query, args);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }
}

class _SubscribedRealmResult<T extends RealmObject> extends RealmResults<T> {
  final String? subscriptionName;

  _SubscribedRealmResult._(RealmResults<RealmObject> results, {this.subscriptionName})
      : super._(
          results.handle,
          results.realm,
          results.metadata,
        );
}

extension RealmResultsOfRealmObject<T extends RealmObject> on RealmResults<T> {
  /// Adds this [RealmResults] query to the set of active subscriptions.
  /// The query will be joined via an OR statement with any existing queries for the same type.
  ///
  /// If a [name] is given this allows you to later refer to the subscription by name,
  /// e.g. when calling [MutableSubscriptionSet.removeByName].
  ///
  /// If [update] is specified to `true`, then any existing query
  /// with the same name will be replaced.
  /// Otherwise a [RealmException] is thrown, in case of duplicates.
  ///
  /// [WaitForSyncMode] specifies how to wait or not wait for subscribed objects to be downloaded.
  /// The default value is [WaitForSyncMode.onCreation].
  ///
  /// The [cancellationToken] is optional and can be used to cancel
  /// the waiting for objects to be downloaded.
  /// If the operation is cancelled, a [CancelledException] is thrown and the download
  /// continues in the background.
  /// In case of using [TimeoutCancellationToken] and the time limit is exceeded,
  /// a [TimeoutException] is thrown and the download continues in the background.
  ///
  /// {@category Sync}
  Future<RealmResults<T>> subscribe({
    String? name,
    WaitForSyncMode waitForSyncMode = WaitForSyncMode.firstTime,
    CancellationToken? cancellationToken,
    bool update = false,
  }) async {
    Subscription? existingSubscription = name == null ? realm.subscriptions.find(this) : realm.subscriptions.findByName(name);
    late Subscription updatedSubscription;
    realm.subscriptions.update((mutableSubscriptions) {
      updatedSubscription = mutableSubscriptions.add(this, name: name, update: update);
    });
    bool shouldWait = waitForSyncMode == WaitForSyncMode.always ||
        (waitForSyncMode == WaitForSyncMode.firstTime && subscriptionIsChanged(existingSubscription, updatedSubscription));

    return await CancellableFuture.from<RealmResults<T>>(() async {
      if (cancellationToken != null && cancellationToken.isCancelled) {
        throw cancellationToken.exception!;
      }
      if (shouldWait) {
        await realm.subscriptions.waitForSynchronization(cancellationToken);
        await realm.syncSession.waitForDownload(cancellationToken);
      }
      return _SubscribedRealmResult._(this, subscriptionName: name);
    }, cancellationToken);
  }

  /// Unsubscribe from this query result. It returns immediately
  /// without waiting for synchronization.
  ///
  /// If the subscription is unnamed, the subscription matching
  /// the query will be removed.
  /// Return `false` if the [RealmResults] is not created by [subscribe].
  ///
  /// {@category Sync}
  bool unsubscribe() {
    bool unsubscribed = false;
    if (realm.config is! FlexibleSyncConfiguration) {
      throw RealmError('unsubscribe is only allowed on Realms opened with a FlexibleSyncConfiguration');
    }
    if (this is _SubscribedRealmResult<T>) {
      final subscriptionName = (this as _SubscribedRealmResult<T>).subscriptionName;
      realm.subscriptions.update((mutableSubscriptions) {
        if (subscriptionName != null) {
          unsubscribed = mutableSubscriptions.removeByName(subscriptionName);
        } else {
          unsubscribed = mutableSubscriptions.removeByQuery(this);
        }
      });
    }
    return unsubscribed;
  }

  bool subscriptionIsChanged(Subscription? existingSubscription, Subscription updatedSubscription) {
    bool changed = existingSubscription == null ||
        existingSubscription.objectClassName != updatedSubscription.objectClassName ||
        existingSubscription.queryString != updatedSubscription.queryString;
    return changed;
  }
}

/// @nodoc
//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  RealmResultsHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access Results that belongs to a closed Realm');
    }

    return _handle;
  }

  RealmObjectMetadata get metadata => _metadata!;

  static RealmResults<T> create<T extends Object?>(
    RealmResultsHandle handle,
    Realm realm,
    RealmObjectMetadata? metadata,
  ) =>
      RealmResults<T>._(handle, realm, metadata);
}

/// Describes the changes in a Realm results collection since the last time the notification callback was invoked.
class RealmResultsChanges<T extends Object?> extends RealmCollectionChanges {
  /// The results collection being monitored for changes.
  final RealmResults<T> results;

  RealmResultsChanges._(super.handle, this.results);

  @override
  @Deprecated("`isCleared` is deprecated. Use `isEmpty` of the results collection instead.")
  bool get isCleared => results.isEmpty;
}

/// @nodoc
class ResultsNotificationsController<T extends Object?> extends NotificationsController {
  final RealmResults<T> results;
  late final StreamController<RealmResultsChanges<T>> streamController;

  ResultsNotificationsController(this.results);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeResultsNotifications(results, this);
  }

  Stream<RealmResultsChanges<T>> createStream() {
    streamController = StreamController<RealmResultsChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmCollectionChangesHandle) {
      throw RealmError("Invalid changes handle. RealmCollectionChangesHandle expected");
    }

    final changes = RealmResultsChanges._(changesHandle, results);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}

class _RealmResultsIterator<T extends Object?> implements Iterator<T> {
  final RealmResults<T> _results;
  int _index;
  T? _current;

  _RealmResultsIterator(RealmResults<T> results)
      : _results = results,
        _index = -1;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    int length = _results.length;
    _index++;
    if (_index >= length) {
      _current = null;
      return false;
    }
    _current = _results[_index];

    return true;
  }
}

///
/// Behavior when waiting for subscribed objects to be synchronized/downloaded.
///
enum WaitForSyncMode {
  /// Waits until the objects have been downloaded from the server
  /// the first time the subscription is created. If the subscription
  /// already exists, the [RealmResults] is returned immediately.
  firstTime,

  /// Always waits until the objects have been downloaded from the server.
  always,

  /// Never waits for the download to complete, but keeps downloading the
  /// objects in the background.
  never,
}
