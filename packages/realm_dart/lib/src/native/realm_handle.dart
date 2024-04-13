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

  ObjectHandle createWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = _toRealmValue(primaryKey, arena);
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_create_with_primary_key(pointer, classKey, realmValue.ref));
      return ObjectHandle._(realmPtr, this);
    });
  }

  ObjectHandle create(int classKey) {
    final realmPtr = invokeGetPointer(() => realmLib.realm_object_create(pointer, classKey));
    return ObjectHandle._(realmPtr, this);
  }

  ObjectHandle getOrCreateWithPrimaryKey(int classKey, Object? primaryKey) {
    return using((Arena arena) {
      final realmValue = _toRealmValue(primaryKey, arena);
      final didCreate = arena<Bool>();
      final realmPtr = invokeGetPointer(() => realmLib.realm_object_get_or_create_with_primary_key(
            pointer,
            classKey,
            realmValue.ref,
            didCreate,
          ));
      return ObjectHandle._(realmPtr, this);
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

  ResultsHandle queryClass(int classKey, String query, List<Object?> args) {
    return using((arena) {
      final length = args.length;
      final argsPointer = arena<realm_query_arg_t>(length);
      for (var i = 0; i < length; ++i) {
        _intoRealmQueryArg(args[i], argsPointer.elementAt(i), arena);
      }
      final queryHandle = QueryHandle._(
          invokeGetPointer(
            () => realmLib.realm_query_parse(
              pointer,
              classKey,
              query.toCharPtr(arena),
              length,
              argsPointer,
            ),
          ),
          this);
      return queryHandle.findAll();
    });
  }

  RealmHandle freeze() => RealmHandle._(invokeGetPointer(() => realmLib.realm_freeze(pointer)));
}
