// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class RealmHandle extends HandleBase<shared_realm> {
  int _counter = 0;

  final Map<int, WeakReference<RootedHandleBase>> _children = {};

  RealmHandle._(Pointer<shared_realm> pointer) : super(pointer, 24);

  RealmHandle._unowned(super.pointer) : super.unowned();

  int addChild(RootedHandleBase child) {
    final id = _counter++;
    _children[id] = WeakReference(child);
    rootedHandleFinalizer.attach(this, FinalizationToken(this, id), detach: this);
    return id;
  }

  void removeChild(int id) {
    final child = _children.remove(id);
    if (child != null) {
      final target = child.target;
      if (target != null) {
        rootedHandleFinalizer.detach(target);
      }
    }
  }

  @override
  void releaseCore() {
    for (final child in _children.values.toList()) {
      child.target?.release();
    }
  }

  RealmObjectHandle createWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = _toRealmValue(primaryKey, arena);
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_create_with_primary_key(pointer, classKey, realmValue.ref));
      return RealmObjectHandle._(realmPtr, this);
    });
  }

  RealmObjectHandle create(int classKey) {
    final realmPtr = invokeGetPointer(() => realmLib.realm_object_create(pointer, classKey));
    return RealmObjectHandle._(realmPtr, this);
  }

  RealmObjectHandle getOrCreateWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = _toRealmValue(primaryKey, arena);
      final didCreate = arena<Bool>();
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_get_or_create_with_primary_key(
            pointer,
            classKey,
            realmValue.ref,
            didCreate,
          ));
      return RealmObjectHandle._(realmPtr, this);
    });
  }

  bool compact() {
    return using((arena) {
      final outDidCompact = arena<Bool>();
      invokeGetBool(() => realmLib.realm_compact(pointer, outDidCompact));
      return outDidCompact.value;
    });
  }

  void writeCopy(Configuration config) {
    final configHandle = ConfigHandle(config);
    invokeGetBool(() => realmLib.realm_convert_with_config(pointer, configHandle.pointer, false));
  }
}
