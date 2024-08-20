// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'collections.dart';
import 'handles/collection_changes_handle.dart';
import 'handles/handle_base.dart';
import 'handles/notification_token_handle.dart';
import 'handles/object_handle.dart';
import 'handles/results_handle.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the Realm that match the underlying query.
///
/// {@category Realm}
class RealmResults<T extends Object?> extends Iterable<T> with RealmEntity {
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

    var value = handle.elementAt(realm, _skipOffset + index);

    if (value is ObjectHandle) {
      late RealmObjectMetadata targetMetadata;
      late Type type;
      if (T == RealmValue) {
        (type, targetMetadata) = realm.metadata.getByClassKey(value.classKey);
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
  Stream<RealmResultsChanges<T>> get changes => _changesFor(null);

  Stream<RealmResultsChanges<T>> _changesFor([List<String>? keyPaths]) {
    if (isFrozen) {
      throw RealmStateError('Results are frozen and cannot emit changes');
    }

    final controller = ResultsNotificationsController<T>(this, keyPaths);
    return controller.createStream();
  }
}

// Query operations and keypath filtering on results only work for results of objects (core restriction),
// so we add it as an extension methods to allow the compiler to prevent misuse.
extension RealmResultsOfObject<T extends RealmObjectBase> on RealmResults<T> {
  /// Returns a new [RealmResults] filtered according to the provided query.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://www.mongodb.com/docs/realm/realm-query-language/)
  RealmResults<T> query(String query, [List<Object> args = const []]) {
    final handle = this.handle.queryResults(query, args);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }

  /// Allows listening for changes when the contents of this collection changes on one of the provided [keyPaths].
  /// If [keyPaths] is null, default notifications will be raised (same as [RealmResults.change]).
  /// If [keyPaths] is an empty list, only notifications related to the collection itself will be raised (such as adding or removing elements).
  Stream<RealmResultsChanges<T>> changesFor([List<String>? keyPaths]) => _changesFor(keyPaths);
}

/// @nodoc
//RealmResults package internal members
extension RealmResultsInternal on RealmResults {
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
  List<String>? keyPaths;

  ResultsNotificationsController(this.results, [List<String>? keyPaths]) {
    if (keyPaths != null) {
      this.keyPaths = keyPaths;
      results.realm.handle.verifyKeyPath(keyPaths, results._metadata?.classKey);
    }
  }

  @override
  NotificationTokenHandle subscribe() {
    return results.handle.subscribeForNotifications(this, keyPaths, results._metadata?.classKey);
  }

  Stream<RealmResultsChanges<T>> createStream() {
    streamController = StreamController<RealmResultsChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! CollectionChangesHandle) {
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
