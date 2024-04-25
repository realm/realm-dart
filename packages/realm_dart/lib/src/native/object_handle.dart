// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../realm_dart.dart'; // TODO: Remove this import
import 'error_handling.dart';
import 'handle_base.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'realm_bindings.dart';
import 'realm_core.dart'; // TODO: Remove this import
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';
import 'set_handle.dart';

class ObjectHandle extends RootedHandleBase<realm_object> {
  ObjectHandle(Pointer<realm_object> pointer, RealmHandle root) : super(root, pointer, 112);

  ObjectHandle createEmbedded(int propertyKey) {
    final objectPtr = invokeGetPointer(() => realmLib.realm_set_embedded(pointer, propertyKey));
    return ObjectHandle(objectPtr, root);
  }

  (ObjectHandle, int) get parent {
    return using((Arena arena) {
      final parentPtr = arena<Pointer<realm_object>>();
      final classKeyPtr = arena<Uint32>();
      invokeGetBool(() => realmLib.realm_object_get_parent(pointer, parentPtr, classKeyPtr));

      final handle = ObjectHandle(parentPtr.value, root);

      return (handle, classKeyPtr.value);
    });
  }

  int get classKey => realmLib.realm_object_get_table(pointer);

  bool get isValid => realmLib.realm_object_is_valid(pointer);

  // TODO: avoid taking the [realm] parameter
  Object? getValue(Realm realm, int propertyKey) {
    return using((Arena arena) {
      final realmValue = arena<realm_value_t>();
      invokeGetBool(() => realmLib.realm_get_value(pointer, propertyKey, realmValue));
      return realmValue.toDartValue(
        realm,
        () => realmLib.realm_get_list(pointer, propertyKey),
        () => realmLib.realm_get_dictionary(pointer, propertyKey),
      );
    });
  }

  // TODO: value should be RealmValue, and perhaps this method should be combined
  // with setCollection?
  void setValue(int propertyKey, Object? value, bool isDefault) {
    using((Arena arena) {
      final realmValue = toRealmValue(value, arena);
      invokeGetBool(
        () => realmLib.realm_set_value(
          pointer,
          propertyKey,
          realmValue.ref,
          isDefault,
        ),
      );
    });
  }

  ListHandle getList(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_list(pointer, propertyKey));
    return ListHandle(ptr, root);
  }

  SetHandle getSet(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_set(pointer, propertyKey));
    return SetHandle(ptr, root);
  }

  MapHandle getMap(int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_dictionary(pointer, propertyKey));
    return MapHandle(ptr, root);
  }

  ResultsHandle getBacklinks(int sourceTableKey, int propertyKey) {
    final ptr = invokeGetPointer(() => realmLib.realm_get_backlinks(pointer, sourceTableKey, propertyKey));
    return ResultsHandle(ptr, root);
  }

  void setCollection(Realm realm, int propertyKey, RealmValue value) {
    createCollection(
      realm,
      value,
      () => realmLib.realm_set_list(pointer, propertyKey),
      () => realmLib.realm_set_dictionary(pointer, propertyKey),
    );
  }

  String objectToString() {
    return realmLib.realm_object_to_string(pointer).cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  void delete() {
    invokeGetBool(() => realmLib.realm_object_delete(pointer));
  }

  ObjectHandle? resolveIn(RealmHandle frozenRealm) {
    return using((Arena arena) {
      final resultPtr = arena<Pointer<realm_object>>();
      invokeGetBool(() => realmLib.realm_object_resolve_in(pointer, frozenRealm.pointer, resultPtr));
      return resultPtr == nullptr ? null : ObjectHandle(resultPtr.value, frozenRealm);
    });
  }

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, [List<String>? keyPaths]) {
    return using((Arena arena) {
      final kpNative = buildAndVerifyKeyPath(keyPaths);
      final ptr = invokeGetPointer(() => realmLib.realm_object_add_notification_callback(
            pointer,
            controller.toPersistentHandle(),
            realmLib.addresses.realm_dart_delete_persistent_handle,
            kpNative,
            Pointer.fromFunction(_objectChangeCallback),
          ));

      return NotificationTokenHandle(ptr, root);
    });
  }

  Pointer<realm_key_path_array> buildAndVerifyKeyPath(List<String>? keyPaths) {
    return using((Arena arena) {
      if (keyPaths == null) {
        return nullptr;
      }

      final length = keyPaths.length;
      final keypathsNative = arena<Pointer<Char>>(length);

      for (int i = 0; i < length; i++) {
        keypathsNative[i] = keyPaths[i].toCharPtr(arena);
      }
      // TODO(kn):
      // call to classKey getter involves a native call, which is not ideal
      return invokeGetPointer(() => realmLib.realm_create_key_path_array(root.pointer, classKey, length, keypathsNative));
    });
  }
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

class ObjectChangesHandle extends HandleBase<realm_object_changes> {
  ObjectChangesHandle(Pointer<realm_object_changes> pointer) : super(pointer, 256);

  bool get isDeleted {
    return realmLib.realm_object_changes_is_deleted(pointer);
  }

  List<int> get properties {
    return using((arena) {
      final count = realmLib.realm_object_changes_get_num_modified_properties(pointer);

      final outModified = arena<realm_property_key_t>(count);
      realmLib.realm_object_changes_get_modified_properties(pointer, outModified, count);

      return outModified.asTypedList(count).toList();
    });
  }
}
