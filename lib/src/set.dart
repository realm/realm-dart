////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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

import 'native/realm_core.dart';
import 'realm_class.dart';
import 'realm_object.dart';

/// RealmSet is a collection that contains no duplicate elements.
abstract class RealmSet<T extends Object?> extends SetBase<T> with RealmEntity implements Finalizable {
  RealmObjectMetadata? _metadata;

   /// Gets a value indicating whether this collection is still valid to use.
  ///
  /// Indicates whether the [Realm] instance hasn't been closed,
  /// if it represents a to-many relationship
  /// and it's parent object hasn't been deleted.
  bool get isValid;

  factory RealmSet(Set<T> items) => UnmanagedRealmSet(items);
}

class UnmanagedRealmSet<T extends Object?> extends collection.DelegatingSet<T> with RealmEntity implements RealmSet<T> {
  UnmanagedRealmSet([Set<T>? items]) : super(items ?? <T>{});

  @override
  RealmObjectMetadata? get _metadata => throw RealmException("Unmanaged Realm sets don't have metadata associated with them.");

  @override
  set _metadata(RealmObjectMetadata? _) => throw RealmException("Unmanaged Realm sets don't have metadata associated with them.");

  @override
  bool get isValid => true;
}

class ManagedRealmSet<T extends Object?> with RealmEntity, SetMixin<T> implements RealmSet<T> {
  final RealmSetHandle _handle;

  ManagedRealmSet._(this._handle, Realm realm, this._metadata) {
    setRealm(realm);
  }

  @override
  late final RealmObjectMetadata? _metadata;
  
  @override
  bool get isValid => realmCore.realmSetIsValid(this);

  @override
  bool add(T value) => realmCore.realmSetInsert(_handle, value);

  /// Get the value at @a index.
  ///
  /// Note that elements in a RealmSet move around arbitrarily when other elements are
  /// inserted/removed.
  @override
  T elementAt(int index) {
    RangeError.checkNotNegative(index, "index");
    final len = length;
    if (index > len) {
      throw RangeError.index(index, this, "index", null, len);
    }

    return realmCore.realmSetGetElementAt(this, index) as T;
  }

  @override
  bool contains(covariant T element) => realmCore.realmSetContains(this, element);

  @override
  T? lookup(covariant T element) => contains(element) ? element : null;

  @override
  bool remove(covariant T value) => realmCore.realmSetErase(this, value);

  @override
  Iterator<T> get iterator => _RealmSetIterator(this);

  @override
  Set<T> toSet() => this;

  @override
  void clear() => realmCore.realmSetClear(_handle);

  @override
  int get length => realmCore.realmSetSize(this);
}

/// @nodoc
extension RealmSetInternal<T extends Object?> on RealmSet<T> {
  ManagedRealmSet<T> asManaged() => this is ManagedRealmSet<T> ? this as ManagedRealmSet<T> : throw RealmStateError('$this is not managed');

  RealmSetHandle get handle {
    final result = asManaged()._handle;
    if (result.released) {
      throw RealmClosedError('Cannot access a RealmSet that belongs to a closed Realm');
    }

    return result;
  }

  static RealmSet<T> create<T extends Object?>(RealmSetHandle handle, Realm realm, RealmObjectMetadata? metadata) => ManagedRealmSet<T>._(handle, realm, metadata);
}

class _RealmSetIterator<T extends Object?> implements Iterator<T> {
  final RealmSet<T> _set;
  int _index;
  T? _current;

  _RealmSetIterator(this._set)
        : _index = -1;

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    _index++;
    if (_index >= _set.length) {
      _current = null;
      return false;
    }
    _current = _set.elementAt(_index);

    return true;
  }
}