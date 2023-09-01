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
  final int _skipOffset; // to support skip efficiently

  final _supportsSnapshot = <T>[] is List<RealmObjectBase?>;

  RealmResults._(this._handle, Realm realm, this._metadata, [this._skipOffset = 0]) {
    setRealm(realm);
    assert(length >= 0);
  }

  /// Gets a value indicating whether this collection is still valid to use.
  bool get isValid => realmCore.resultsIsValid(this);

  /// Returns the element of type `T` at the specified [index].
  T operator [](int index) => elementAt(index);

  /// Returns the element of type `T` at the specified [index].
  @override
  T elementAt(int index) {
    if (this is RealmResults<RealmObjectBase>) {
      final handle = realmCore.resultsGetObjectAt(this, _skipOffset + index);
      final accessor = RealmCoreAccessor(metadata, realm.isInMigration);
      return RealmObjectInternal.create(T, realm, handle, accessor) as T;
    } else {
      return realmCore.resultsGetElementAt(this, _skipOffset + index) as T;
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
  int get length => realmCore.getResultsCount(this) - _skipOffset;

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
    final handle = realmCore.queryResults(this, query, args);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
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

  _RealmResultsIterator(RealmResults<T> results, {int index = 0})
      : _results = results,
        _index = index - 1;

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
