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

import 'dart:core';
import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:collection/collection.dart' as collection;

import 'collections.dart';
import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'results.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the collection or from the Realm.
///
/// {@category Realm}
abstract class RealmList<T extends Object?> with RealmEntity implements List<T>, Finalizable {
  late final RealmObjectMetadata? _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  /// Converts this [List] to a [RealmResults].
  RealmResults<T> asResults();

  factory RealmList._(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmList._(handle, realm, metadata);
  
  /// Creates an unmanaged RealmList from [items]
  factory RealmList(Iterable<T> items) => UnmanagedRealmList(items);

  /// Creates a frozen snapshot of this `RealmList`.
  RealmList<T> freeze();

  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmListChanges<T>> get changes;
}

class ManagedRealmList<T extends Object?> with RealmEntity, ListMixin<T> implements RealmList<T> {
  final RealmListHandle _handle;

  @override
  late final RealmObjectMetadata? _metadata;

  ManagedRealmList._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  int get length => realmCore.getListSize(handle);

  /// Setting the `length` is a required method on [List], but makes less sense
  /// for [RealmList]s. You can only decrease the length, increasing it doesn't
  /// do anything.
  @override
  set length(int newLength) {
    var l = length;
    if (newLength < l) {
      removeRange(newLength, l);
    } else {
      throw RealmException('You cannot increase length on a realm list without adding elements');
    }
  }

  @override
  void removeRange(int start, int end) {
    var cnt = end - start;
    while (cnt-- > 0) {
      removeAt(start);
    }
  }

  @override
  bool remove(covariant T element) {
    if (element is RealmObjectBase && !element.isManaged) {
      throw RealmStateError('Cannot call remove on a managed list with an element that is an unmanaged object');
    }
    final index = indexOf(element);
    if (index < 0) {
      return false;
    }

    removeAt(index);
    return true;
  }

  @override
  T operator [](int index) {
    if (index < 0) {
      throw RealmException("Index out of range $index");
    }

    try {
      var value = realmCore.listGetElementAt(this, index);
      if (value is RealmObjectHandle) {
        late RealmObjectMetadata targetMetadata;
        late Type type;
        if (T == RealmValue) {
          final tuple = realm.metadata.getByClassKey(realmCore.getClassKey(value));
          type = tuple.item1;
          targetMetadata = tuple.item2;
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
    } on Exception catch (e) {
      throw RealmException("Error getting value at index $index. Error: $e");
    }
  }

  @override
  void add(T element) {
    RealmListInternal.setValue(handle, realm, length, element);
  }

  @override
  void insert(int index, T element) {
    RealmListInternal.setValue(handle, realm, index, element, insert: true);
  }

  @override
  void operator []=(int index, T value) {
    RealmListInternal.setValue(handle, realm, index, value);
  }

  @override
  T removeAt(int index) {
    final result = this[index];
    realmCore.listRemoveElementAt(handle, index);
    return result;
  }

  /// Move the element at index [from] to index [to].
  void move(int from, int to) {
    realmCore.listMoveElement(handle, from, to);
  }

  /// Removes all objects from this list; the length of the list becomes zero.
  /// The objects are not deleted from the realm, but are no longer referenced from this list.
  @override
  void clear() => realmCore.listClear(handle);

  @override
  int indexOf(covariant T element, [int start = 0]) {
    if (element is RealmObjectBase && !element.isManaged) {
      throw RealmStateError('Cannot call indexOf on a managed list with an element that is an unmanaged object');
    }
    if (start < 0) start = 0;
    final index = realmCore.listFind(this, element);
    return index < start ? -1 : index; // to align with dart list semantics
  }

  @override
  bool get isValid => realmCore.listIsValid(this);

  @override
  RealmList<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveList(this)!;
  }

  @override
  RealmResults<T> asResults() => RealmResultsInternal.create<T>(realmCore.resultsFromList(this), realm, metadata);

  @override
  Stream<RealmListChanges<T>> get changes {
    if (isFrozen) {
      throw RealmStateError('List is frozen and cannot emit changes');
    }
    final controller = ListNotificationsController<T>(asManaged());
    return controller.createStream();
  }
}

class UnmanagedRealmList<T extends Object?> extends collection.DelegatingList<T> with RealmEntity implements RealmList<T> {
  UnmanagedRealmList([Iterable<T>? items]) : super(List<T>.from(items ?? <T>[]));

  @override
  RealmObjectMetadata? get _metadata => throw RealmException("Unmanaged lists don't have metadata associated with them.");

  @override
  set _metadata(RealmObjectMetadata? _) => throw RealmException("Unmanaged lists don't have metadata associated with them.");

  @override
  bool get isValid => true;

  @override
  RealmList<T> freeze() => throw RealmStateError("Unmanaged lists can't be frozen");

  @override
  RealmResults<T> asResults() => throw RealmStateError("Unmanaged lists can't be converted to results");

  @override
  Stream<RealmListChanges<T>> get changes => throw RealmStateError("Unmanaged lists don't support changes");
}

// The query operations on lists, as well as the ability to subscribe for notifications,
// only work for list of objects (core restriction), so we add these as an extension methods
// to allow the compiler to prevent misuse.
extension RealmListOfObject<T extends RealmObjectBase> on RealmList<T> {
  /// Filters the list and returns a new [RealmResults] according to the provided [query] (with optional [arguments]).
  ///
  /// Only works for lists of [RealmObject]s or [EmbeddedObject]s.
  ///
  /// The Realm Dart and Realm Flutter SDKs supports querying based on a language inspired by [NSPredicate](https://academy.realm.io/posts/nspredicate-cheatsheet/)
  /// and [Predicate Programming Guide.](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/AdditionalChapters/Introduction.html#//apple_ref/doc/uid/TP40001789)
  RealmResults<T> query(String query, [List<Object> arguments = const []]) {
    final handle = realmCore.queryList(asManaged(), query, arguments);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }
}

/// @nodoc
extension RealmListInternal<T extends Object?> on RealmList<T> {
  @pragma('vm:never-inline')
  void keepAlive() {
    final self = this;
    if (self is ManagedRealmList<T>) {
      realm.keepAlive();
      self._handle.keepAlive();
    }
  }

  ManagedRealmList<T> asManaged() => this is ManagedRealmList<T> ? this as ManagedRealmList<T> : throw RealmStateError('$this is not managed');

  RealmListHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a list that belongs to a closed Realm');
    }

    return result;
  }

  RealmObjectMetadata? get metadata => asManaged()._metadata;

  static RealmList<T> create<T extends Object?>(RealmListHandle handle, Realm realm, RealmObjectMetadata? metadata) => RealmList<T>._(handle, realm, metadata);

  static void setValue(RealmListHandle handle, Realm realm, int index, Object? value, {bool update = false, bool insert = false}) {
    if (index < 0) {
      throw RealmException("Index can not be negative: $index");
    }

    final length = realmCore.getListSize(handle);
    if (index > length) {
      throw RealmException('Index can not exceed the size of the list: $index, size: $length');
    }

    try {
      if (value is EmbeddedObject) {
        if (value.isManaged) {
          throw RealmError("Can't add to list an embedded object that is already managed");
        }

        final objHandle =
            insert || index >= length ? realmCore.listInsertEmbeddedObjectAt(realm, handle, index) : realmCore.listSetEmbeddedObjectAt(realm, handle, index);
        realm.manageEmbedded(objHandle, value);
        return;
      }

      if (value is RealmValue) {
        value = value.value;
      }

      if (value is RealmObject && !value.isManaged) {
        realm.add<RealmObject>(value, update: update);
      }

      if (insert || index >= length) {
        realmCore.listInsertElementAt(handle, index, value);
      } else {
        realmCore.listSetElementAt(handle, index, value);
      }
    } on Exception catch (e) {
      throw RealmException("Error setting value at index $index. Error: $e");
    }
  }
}

/// Describes the changes in a Realm list collection since the last time the notification callback was invoked.
class RealmListChanges<T extends Object?> extends RealmCollectionChanges {
  /// The collection being monitored for changes.
  final RealmList<T> list;

  RealmListChanges._(super.handle, this.list);
}

/// @nodoc
class ListNotificationsController<T extends Object?> extends NotificationsController {
  final ManagedRealmList<T> list;
  late final StreamController<RealmListChanges<T>> streamController;

  ListNotificationsController(this.list);

  @override
  RealmNotificationTokenHandle subscribe() {
    return realmCore.subscribeListNotifications(list, this);
  }

  Stream<RealmListChanges<T>> createStream() {
    streamController = StreamController<RealmListChanges<T>>(onListen: start, onPause: stop, onResume: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! RealmCollectionChangesHandle) {
      throw RealmError("Invalid changes handle. RealmCollectionChangesHandle expected");
    }

    final changes = RealmListChanges._(changesHandle, list);
    streamController.add(changes);
  }

  @override
  void onError(RealmError error) {
    streamController.addError(error);
  }
}

extension ListExtension<T> on List<T> {
  /// Move the element at index [from] to index [to].
  void move(int from, int to) {
    RangeError.checkValidIndex(from, this, 'from', length);
    RangeError.checkValidIndex(to, this, 'to', length);
    if (to == from) return; // no-op
    final self = this;
    if (self is ManagedRealmList<T>) {
      self.move(from, to);
    } else {
      insert(to, removeAt(from));
    }
  }
}
