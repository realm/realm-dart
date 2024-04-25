// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../credentials.dart'; // TODO: Remove this import
import '../realm_dart.dart'; // TODO: Remove this import
import '../scheduler.dart';
import '../user.dart'; // TODO: Remove this import
import 'app_handle.dart';
import 'convert.dart';
import 'credentials_handle.dart';
import 'error_handling.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_library.dart'; // TODO: Remove this import

class UserHandle extends HandleBase<realm_user> {
  UserHandle(Pointer<realm_user> pointer) : super(pointer, 24);

  AppHandle get app {
    return realmLib.realm_user_get_app(pointer).convert(AppHandle.new) ??
        (throw RealmException('User does not have an associated app. This is likely due to the user being logged out.'));
  }

  UserState get state {
    final nativeUserState = realmLib.realm_user_get_state(pointer);
    return UserState.values.fromIndex(nativeUserState);
  }

  String get id {
    final idPtr = invokeGetPointer(() => realmLib.realm_user_get_identity(pointer), "Error while getting user id");
    final userId = idPtr.cast<Utf8>().toDartString();
    return userId;
  }

  List<UserIdentity> get identities {
    return using((arena) {
      return _userGetIdentities(arena);
    });
  }

  List<UserIdentity> _userGetIdentities(Arena arena, {int expectedSize = 2}) {
    final actualCount = arena<Size>();
    final identitiesPtr = arena<realm_user_identity_t>(expectedSize);
    invokeGetBool(() => realmLib.realm_user_get_all_identities(pointer, identitiesPtr, expectedSize, actualCount));

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(identitiesPtr);
      return _userGetIdentities(arena, expectedSize: actualCount.value);
    }

    final result = <UserIdentity>[];
    for (var i = 0; i < actualCount.value; i++) {
      final identity = (identitiesPtr + i).ref;

      result.add(UserIdentityInternal.create(
          identity.id.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!, AuthProviderTypeInternal.getByValue(identity.provider_type)));
    }

    return result;
  }

  Future<void> logOut() async {
    invokeGetBool(() => realmLib.realm_user_log_out(pointer), "Logout failed");
  }

  String? get deviceId {
    final deviceId = invokeGetPointer(() => realmLib.realm_user_get_device_id(pointer));
    return deviceId.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true, freeRealmMemory: true);
  }

  UserProfile get profileData {
    final data = invokeGetPointer(() => realmLib.realm_user_get_profile_data(pointer));
    final dynamic profileData = jsonDecode(data.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!);
    return UserProfile(profileData as Map<String, dynamic>);
  }

  String get refreshToken {
    final token = invokeGetPointer(() => realmLib.realm_user_get_refresh_token(pointer));
    return token.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  String get accessToken {
    final token = invokeGetPointer(() => realmLib.realm_user_get_access_token(pointer));
    return token.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  String get path {
    final syncConfigPtr = invokeGetPointer(() => realmLib.realm_flx_sync_config_new(pointer));
    try {
      final path = realmLib.realm_app_sync_client_get_default_file_path_for_realm(syncConfigPtr, nullptr);
      return path.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
    } finally {
      realmLib.realm_release(syncConfigPtr.cast());
    }
  }

  String? get customData {
    final customDataPtr = realmLib.realm_user_get_custom_data(pointer);
    return customDataPtr.cast<Utf8>().toRealmDartString(freeRealmMemory: true, treatEmptyAsNull: true);
  }

  Future<UserHandle> linkCredentials(AppHandle app, CredentialsHandle credentials) {
    final completer = Completer<UserHandle>();
    invokeGetBool(
      () => realmLib.realm_app_link_user(
        app.pointer,
        pointer,
        credentials.pointer,
        realmLib.addresses.realm_dart_user_completion_callback,
        createAsyncUserCallbackUserdata(completer),
        realmLib.addresses.realm_dart_userdata_async_free,
      ),
      "Link credentials failed",
    );
    return completer.future;
  }

  Future<ApiKey> createApiKey(AppHandle app, String name) {
    return using((Arena arena) {
      final namePtr = name.toCharPtr(arena);
      final completer = Completer<ApiKey>();
      invokeGetBool(
        () => realmLib.realm_app_user_apikey_provider_client_create_apikey(
          app.pointer,
          pointer,
          namePtr,
          realmLib.addresses.realm_dart_apikey_callback,
          _createAsyncApikeyCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        ),
      );

      return completer.future;
    });
  }

  Future<ApiKey> fetchApiKey(AppHandle app, ObjectId id) {
    return using((Arena arena) {
      final completer = Completer<ApiKey>();
      final nativeId = id.toNative(arena);
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_fetch_apikey(
            app.pointer,
            pointer,
            nativeId.ref,
            realmLib.addresses.realm_dart_apikey_callback,
            _createAsyncApikeyCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<List<ApiKey>> fetchAllApiKeys(AppHandle app) {
    return using((Arena arena) {
      final completer = Completer<List<ApiKey>>();
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_fetch_apikeys(
            app.pointer,
            pointer,
            realmLib.addresses.realm_dart_apikey_list_callback,
            _createAsyncApikeyListCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<void> deleteApiKey(AppHandle app, ObjectId id) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final nativeId = id.toNative(arena);
      invokeGetBool(() => realmLib.realm_app_user_apikey_provider_client_delete_apikey(
            app.pointer,
            pointer,
            nativeId.ref,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          ));

      return completer.future;
    });
  }

  Future<void> disableApiKey(AppHandle app, ObjectId objectId) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final nativeId = objectId.toNative(arena);

      invokeGetBool(
        () => realmLib.realm_app_user_apikey_provider_client_disable_apikey(
          app.pointer,
          pointer,
          nativeId.ref,
          realmLib.addresses.realm_dart_void_completion_callback,
          createAsyncCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        ),
      );

      return completer.future;
    });
  }

  Future<void> enableApiKey(AppHandle app, ObjectId objectId) {
    return using((Arena arena) {
      final completer = Completer<void>();
      final nativeId = objectId.toNative(arena);

      invokeGetBool(
        () => realmLib.realm_app_user_apikey_provider_client_enable_apikey(
          app.pointer,
          pointer,
          nativeId.ref,
          realmLib.addresses.realm_dart_void_completion_callback,
          createAsyncCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        ),
      );

      return completer.future;
    });
  }

  UserNotificationTokenHandle subscribeForNotifications(UserNotificationsController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Int32)>(_userChangeCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    final notificationToken = realmLib.realm_sync_user_on_state_change_register_callback(
      pointer,
      realmLib.addresses.realm_dart_user_change_callback,
      userdata.cast(),
      realmLib.addresses.realm_dart_userdata_async_free,
    );
    return UserNotificationTokenHandle(notificationToken);
  }
}

class UserNotificationTokenHandle extends HandleBase<realm_app_user_subscription_token> {
  UserNotificationTokenHandle(Pointer<realm_app_user_subscription_token> pointer) : super(pointer, 32);
}

void _userChangeCallback(Object userdata, int data) {
  final controller = userdata as UserNotificationsController;

  controller.onUserChanged();
}

Pointer<Void> _createAsyncApikeyCallbackUserdata<T extends Function>(Completer<ApiKey> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_user_apikey>,
        Pointer<realm_app_error>,
      )>(_appApiKeyCompletionCallback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

void _appApiKeyCompletionCallback(Pointer<Void> userdata, Pointer<realm_app_user_apikey> apiKey, Pointer<realm_app_error> error) {
  final Completer<ApiKey> completer = userdata.toObject();
  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }
  completer.complete(apiKey.ref.toDart());
}

Pointer<Void> _createAsyncApikeyListCallbackUserdata<T extends Function>(Completer<List<ApiKey>> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_user_apikey>,
        Size count,
        Pointer<realm_app_error>,
      )>(_appApiKeyArrayCompletionCallback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

void _appApiKeyArrayCompletionCallback(Pointer<Void> userdata, Pointer<realm_app_user_apikey> apiKey, int size, Pointer<realm_app_error> error) {
  final Completer<List<ApiKey>> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  final result = <ApiKey>[];
  for (var i = 0; i < size; i++) {
    result.add(apiKey[i].toDart());
  }

  completer.complete(result);
}
