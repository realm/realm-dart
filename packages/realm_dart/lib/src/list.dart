// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:collection';
import 'dart:core';

import 'package:collection/collection.dart' as collection;

import 'collections.dart';
import 'handles/collection_changes_handle.dart';
import 'handles/handle_base.dart';
import 'handles/list_handle.dart';
import 'handles/notification_token_handle.dart';
import 'handles/object_handle.dart';
import 'realm_class.dart';
import 'realm_object.dart';
import 'results.dart';

/// Instances of this class are live collections and will update as new elements are either
/// added to or deleted from the collection or from the Realm.
///
/// {@category Realm}
abstract class RealmList<T extends Object?> with RealmEntity implements List<T> {
  late final RealmObjectMetadata? _metadata;

  /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  /// Converts this [List] to a [RealmResults].
  RealmResults<T> asResults();

  factory RealmList._(ListHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmList._(handle, realm, metadata);

  /// Creates an unmanaged RealmList from [items]
  factory RealmList(Iterable<T> items) => UnmanagedRealmList(items);

  /// Creates a frozen snapshot of this `RealmList`.
  RealmList<T> freeze();

  //TODO Should we have a base collection class so we can move those methods there?
  /// Allows listening for changes when the contents of this collection changes.
  Stream<RealmListChanges<T>> get changes;

  /// Allows listening for changes when the contents of this collection changes on one of the provided [keyPaths].
  Stream<RealmListChanges<T>> changesFor([List<String>? keyPaths]);
}

class ManagedRealmList<T extends Object?> with RealmEntity, ListMixin<T> implements RealmList<T> {
  final ListHandle _handle;

  @override
  late final RealmObjectMetadata? _metadata;

  ManagedRealmList._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  int get length => handle.size;

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
      var value = handle.elementAt(realm, index);
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
    handle.removeAt(index);
    return result;
  }

  /// Move the element at index [from] to index [to].
  void move(int from, int to) {
    handle.move(from, to);
  }

  /// Removes all objects from this list; the length of the list becomes zero.
  /// The objects are not deleted from the realm, but are no longer referenced from this list.
  @override
  void clear() => handle.clear();

  @override
  int indexOf(covariant T element, [int start = 0]) {
    if (element is RealmObjectBase && !element.isManaged) {
      throw RealmStateError('Cannot call indexOf on a managed list with an element that is an unmanaged object');
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
    final index = handle.indexOf(element);
    return index < start ? -1 : index; // to align with dart list semantics
  }

  @override
  bool get isValid => handle.isValid;

  @override
  RealmList<T> freeze() {
    if (isFrozen) {
      return this;
    }

    final frozenRealm = realm.freeze();
    return frozenRealm.resolveList(this)!;
  }

  @override
  RealmResults<T> asResults() => RealmResultsInternal.create<T>(handle.asResults(), realm, metadata);

  @override
  Stream<RealmListChanges<T>> get changes => changesFor(null);

  @override
  Stream<RealmListChanges<T>> changesFor([List<String>? keyPaths]) {
    if (isFrozen) {
      throw RealmStateError('List is frozen and cannot emit changes');
    }
    //TODO Also this is just called ListNotificationController, while the set one is called RealmSetNotificationController
    final controller = ListNotificationsController<T>(asManaged(), keyPaths);
    return controller.createStream();
  }
}

//TODO I would move this before the managed, so it's consistent with the maps and list
class UnmanagedRealmList<T extends Object?> extends collection.DelegatingList<T> with RealmEntity implements RealmList<T> {
  final List<T> _base;

  UnmanagedRealmList([Iterable<T>? items]) : this._(List<T>.from(items ?? <T>[]));

  UnmanagedRealmList._(super.items) : _base = items;

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

  @override
  Stream<RealmListChanges<T>> changesFor([List<String>? keyPaths]) => throw RealmStateError("Unmanaged lists don't support changes");

  @override
  bool operator ==(Object? other) {
    return _base == other;
  }

  @override
  int get hashCode => _base.hashCode;
}

// The query operations on lists, only work for list of objects (core restriction),
// so we add these as an extension methods to allow the compiler to prevent misuse.
extension RealmListOfObject<T extends RealmObjectBase> on RealmList<T> {
  /// Filters the list and returns a new [RealmResults] according to the provided [query] (with optional [arguments]).
  ///
  /// Only works for lists of [RealmObject]s or [EmbeddedObject]s.
  ///
  /// For more details about the syntax of the Realm Query Language, refer to the documentation: https://www.mongodb.com/docs/realm/realm-query-language/.
  RealmResults<T> query(String query, [List<Object?> arguments = const []]) {
    final handle = asManaged().handle.query(query, arguments);
    return RealmResultsInternal.create<T>(handle, realm, _metadata);
  }
}

/// @nodoc
extension RealmListInternal<T extends Object?> on RealmList<T> {
  ManagedRealmList<T> asManaged() => this is ManagedRealmList<T> ? this as ManagedRealmList<T> : throw RealmStateError('$this is not managed');

  ListHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a list that belongs to a closed Realm');
    }

    return result;
  }

  RealmObjectMetadata? get metadata => asManaged()._metadata;

  static RealmList<T> createFromList<T>(List<T> items) {
    return UnmanagedRealmList._(items);
  }

  static RealmList<T> create<T extends Object?>(ListHandle handle, Realm realm, RealmObjectMetadata? metadata) => RealmList<T>._(handle, realm, metadata);

  static void setValue(ListHandle handle, Realm realm, int index, Object? value, {bool update = false, bool insert = false}) {
    if (index < 0) {
      throw RealmException("Index can not be negative: $index");
    }

    final length = handle.size;
    if (index > length) {
      throw RealmException('Index can not exceed the size of the list: $index, size: $length');
    }

    try {
      if (value is EmbeddedObject) {
        if (value.isManaged) {
          throw RealmError("Can't add to list an embedded object that is already managed");
        }

        final objHandle = insert || index >= length ? handle.insertEmbeddedAt(index) : handle.setEmbeddedAt(index);
        realm.manageEmbedded(objHandle, value);
        return;
      }

      if (value is RealmValue && value.type.isCollection) {
        handle.addOrUpdateCollectionAt(realm, index, value, insert || index >= length);
        return;
      }

      realm.addUnmanagedRealmObjectFromValue(value, update);

      handle.addOrUpdateAt(index, value, insert || index >= length);
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

  /// `true` if the underlying list was deleted.
  bool get isCollectionDeleted => changes.isDeleted;
}

/// @nodoc
class ListNotificationsController<T extends Object?> extends NotificationsController {
  final ManagedRealmList<T> list;
  late final StreamController<RealmListChanges<T>> streamController;
  List<String>? keyPaths;

  ListNotificationsController(this.list, [List<String>? keyPaths]) {
    if (keyPaths != null) {
      this.keyPaths = keyPaths;

      if (keyPaths.any((element) => element.isEmpty || element.trim().isEmpty)) {
        throw RealmException("A key path cannot be empty or consisting only of white spaces");
      }

      list.realm.handle.verifyKeyPath(keyPaths, list._metadata?.classKey);
    }
  }

  @override
  NotificationTokenHandle subscribe() {
    return list.handle.subscribeForNotifications(this, keyPaths, list._metadata?.classKey);
  }

  Stream<RealmListChanges<T>> createStream() {
    streamController = StreamController<RealmListChanges<T>>(onListen: start, onCancel: stop);
    return streamController.stream;
  }

  @override
  void onChanges(HandleBase changesHandle) {
    if (changesHandle is! CollectionChangesHandle) {
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
