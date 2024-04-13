// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';

import 'collections.dart';
import 'native/handle_base.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the Realm that match the underlying query.
///
/// {@category Realm}
class RealmResults<T extends Object?> extends Iterable<T> with RealmEntity implements Finalizable {
  final RealmObjectMetadata? _metadata;
  final ResultsHandle _handle;
  final int _skipOffset; // to support skip efficiently

  final _supportsSnapshot = <T>[] is List<RealmObjectBase?>;

  RealmResults._(this._handle, Realm realm, this._metadata, [this._skipOffset = 0]) {
    setRealm(realm);
    assert(length >= 0);
  }

  /// Gets a value indicating whether this collection is still valid to use.
  bool get isValid => handle.isValid();

  /// Returns the element of type `T` at the specified [index].
  T operator [](int index) => elementAt(index);

  /// Returns the element of type `T` at the specified [index].
  @override
  T elementAt(int index) {
    // TODO: this is identical to list[] - consider refactoring to combine them.
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1);
    }

    var value = realmCore.resultsGetElementAt(this, _skipOffset + index);

    if (value is ObjectHandle) {
      late RealmObjectMetadata targetMetadata;
      late Type type;
      if (T == RealmValue) {
        (type, targetMetadata) = realm.metadata.getByClassKey(value.getClassKey());
      } else {
        targetMetadata = _metadata!;
        type = T;
      }
      value = realm.createObject(type, value, targetMetadata);
    }

    if (T == RealmValue) {
      value = RealmValue.from(value);
    }

    return value as T;
  }

  @pragma('vm:prefer-inline')
  int _indexOf(T element, int start, String methodName) {
    if (element is RealmObjectBase && !element.isManaged) {
      throw RealmStateError('Cannot call $methodName on a results with an element that is an unmanaged object');
    }

    if (element is RealmValue) {
      if (element.type.isCollection) {
        return -1;
      }

      if (element.value is RealmObjectBase && !(element.value as RealmObjectBase).isManaged) {
        return -1;
      }
    }

    if (start < 0) start = 0;
    start += _skipOffset;
    final index = handle.find(element);
    return index < start ? -1 : index; // to align with dart list semantics
  }

  /// Returns the `index` of the first occurrence of the specified [element] in this collection,
  /// or `-1` if the collection does not contain the element.
  int indexOf(covariant T element, [int start = 0]) => _indexOf(element, start, 'indexOf');

  /// `true` if the `Results` collection contains the specified [element].
  @override
  bool contains(covariant T element) => _indexOf(element, 0, 'contains') >= 0;

  /// `true` if the `Results` collection is empty.
  @override
  bool get isEmpty => length == 0;

  /// Returns a new `Iterator` that allows iterating the elements in this `RealmResults`.
  @override
  Iterator<T> get iterator {
    var results = this;
    if (_supportsSnapshot) {
      final handle = this.handle.snapshot();
      results = RealmResultsInternal.create<T>(handle, realm, _metadata, _skipOffset);
    }
    return _RealmResultsIterator(results);
  }

  /// The number of values in this `Results` collection.
  @override
  int get length => handle.count - _skipOffset;

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

  @override
  RealmResults<T> skip(int count) {
    RangeError.checkValueInInterval(count, 0, length, "count");
    return RealmResults<T>._(_handle, realm, _metadata, _skipOffset + count);
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
    final handle = this.handle.queryResults(query, args);
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
  /// The default value is [WaitForSyncMode.firstTime].
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
    final subscriptions = realm.subscriptions;
    Subscription? existingSubscription = name == null ? subscriptions.find(this) : subscriptions.findByName(name);
    late Subscription updatedSubscription;
    subscriptions.update((mutableSubscriptions) {
      updatedSubscription = mutableSubscriptions.add(this, name: name, update: update);
    });
    bool shouldWait = waitForSyncMode == WaitForSyncMode.always ||
        (waitForSyncMode == WaitForSyncMode.firstTime && subscriptionIsChanged(existingSubscription, updatedSubscription));

    return await CancellableFuture.from<RealmResults<T>>(() async {
      if (cancellationToken != null && cancellationToken.isCancelled) {
        throw cancellationToken.exception!;
      }
      if (shouldWait) {
        await subscriptions.waitForSynchronization(cancellationToken);
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
    return existingSubscription == null ||
        existingSubscription.objectClassName != updatedSubscription.objectClassName ||
        existingSubscription.queryString != updatedSubscription.queryString;
  }
}

/// @nodoc
//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  ResultsHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access Results that belongs to a closed Realm');
    }

    return _handle;
  }

  RealmObjectMetadata get metadata => _metadata!;

  static RealmResults<T> create<T extends Object?>(ResultsHandle handle, Realm realm, RealmObjectMetadata? metadata, [int skip = 0]) =>
      RealmResults<T>._(handle, realm, metadata, skip);
}

/// Describes the changes in a Realm results collection since the last time the notification callback was invoked.
class RealmResultsChanges<T extends Object?> extends RealmCollectionChanges {
  /// The results collection being monitored for changes.
  final RealmResults<T> results;

  RealmResultsChanges._(super.handle, this.results);

  @override
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
  T get current => _current ??= _results[_index];

  @override
  bool moveNext() {
    int length = _results.length;
    _current = null;
    _index++;
    if (_index >= length) {
      return false;
    }
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
