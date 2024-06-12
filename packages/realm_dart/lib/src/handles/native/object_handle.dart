// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: annotate_overrides

import 'dart:ffi';

import '../../realm_dart.dart';
import 'collection_handle_base.dart';
import 'convert_native.dart';
import 'error_handling.dart';
import 'ffi.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'notification_token_handle.dart';
import 'object_changes_handle.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';
import 'set_handle.dart';

import '../object_handle.dart' as intf;

class ObjectHandle extends RootedHandleBase<realm_object> implements intf.ObjectHandle {
  ObjectHandle(Pointer<realm_object> pointer, RealmHandle root) : super(root, pointer, 112);

  @override
  ObjectHandle createEmbedded(int propertyKey) {
    return ObjectHandle(realmLib.realm_set_embedded(pointer, propertyKey), root);
  }

  @override
  (ObjectHandle, int) get parent {
    return using((arena) {
      final parentPtr = arena<Pointer<realm_object>>();
      final classKeyPtr = arena<Uint32>();
      realmLib.realm_object_get_parent(pointer, parentPtr, classKeyPtr).raiseLastErrorIfFalse();

      final handle = ObjectHandle(parentPtr.value, root);

      return (handle, classKeyPtr.value);
    });
  }

  @override
  int get classKey => realmLib.realm_object_get_table(pointer);

  @override
  bool get isValid => realmLib.realm_object_is_valid(pointer);

  @override
  Link get asLink {
    final realmLink = realmLib.realm_object_as_link(pointer);
    return Link(realmLink);
  }

  // TODO: avoid taking the [realm] parameter
  @override
  Object? getValue(Realm realm, int propertyKey) {
    return using((arena) {
      final realmValue = arena<realm_value_t>();
      realmLib.realm_get_value(pointer, propertyKey, realmValue).raiseLastErrorIfFalse();
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_get_list(pointer, propertyKey),
        () => realmLib.realm_get_dictionary(pointer, propertyKey),
      );
    });
  }

  // TODO: value should be RealmValue, and perhaps this method should be combined
  // with setCollection?
  @override
  void setValue(int propertyKey, Object? value, bool isDefault) {
    using((arena) {
      final realmValue = value.toNative(arena);
      realmLib
          .realm_set_value(
            pointer,
            propertyKey,
            realmValue.ref,
            isDefault,
          )
          .raiseLastErrorIfFalse();
    });
  }

  @override
  ListHandle getList(int propertyKey) {
    return ListHandle(realmLib.realm_get_list(pointer, propertyKey), root);
  }

  @override
  SetHandle getSet(int propertyKey) {
    return SetHandle(realmLib.realm_get_set(pointer, propertyKey), root);
  }

  @override
  MapHandle getMap(int propertyKey) {
    return MapHandle(realmLib.realm_get_dictionary(pointer, propertyKey), root);
  }

  @override
  ResultsHandle getBacklinks(int sourceTableKey, int propertyKey) {
    return ResultsHandle(realmLib.realm_get_backlinks(pointer, sourceTableKey, propertyKey), root);
  }

  @override
  void setCollection(Realm realm, int propertyKey, RealmValue value) {
    createCollection(
      realm,
      value,
      () => realmLib.realm_set_list(pointer, propertyKey),
      () => realmLib.realm_set_dictionary(pointer, propertyKey),
    );
  }

  @override
  String objectToString() {
    return realmLib.realm_object_to_string(pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  @override
  void delete() {
    realmLib.realm_object_delete(pointer).raiseLastErrorIfFalse();
  }

  ObjectHandle? resolveIn(covariant RealmHandle frozenRealm) {
    return using((arena) {
      final resultPtr = arena<Pointer<realm_object>>();
      realmLib.realm_object_resolve_in(pointer, frozenRealm.pointer, resultPtr).raiseLastErrorIfFalse();
      return resultPtr == nullptr ? null : ObjectHandle(resultPtr.value, frozenRealm);
    });
  }

  @override
  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, [List<String>? keyPaths]) {
    return using((arena) {
      final kpNative = root.buildAndVerifyKeyPath(keyPaths, classKey);
      return NotificationTokenHandle(
        realmLib.realm_object_add_notification_callback(
          pointer,
          controller.toPersistentHandle(),
          realmLib.addresses.realm_dart_delete_persistent_handle,
          kpNative,
          Pointer.fromFunction(_objectChangeCallback),
        ),
        root,
      );
    });
  }

  @override
  // equals handled by HandleBase<T>
  // ignore: hash_and_equals
  int get hashCode => asLink.hash;
}

class Link implements intf.Link {
  final realm_link link;

  Link(this.link);

  @override
  int get targetKey => link.target;

  @override
  int get classKey => link.target_table;

  @override
  int get hash => Object.hash(targetKey, classKey);
}

void _objectChangeCallback(Pointer<Void> userdata, Pointer<realm_object_changes> data) {
  final NotificationsController controller = userdata.toObject();

  if (data == nullptr) {
    controller.onError(RealmError("Invalid notifications data received"));
    return;
  }

  try {
    final clonedData = realmLib.realm_clone(data.cast());
    if (clonedData == nullptr) {
      controller.onError(RealmError("Error while cloning notifications data"));
      return;
    }

    final changesHandle = ObjectChangesHandle(clonedData.cast());
    controller.onChanges(changesHandle);
  } catch (e) {
    controller.onError(RealmError("Error handling change notifications. Error: $e"));
  }
}
