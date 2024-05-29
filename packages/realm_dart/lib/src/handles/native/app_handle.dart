// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import '../../init.dart';
import '../../realm_class.dart';
import '../../scheduler.dart';
import 'convert.dart';
import 'convert_native.dart';
import 'credentials_handle.dart';
import 'error_handling.dart';
import 'ffi.dart';
import 'handle_base.dart';
import 'http_transport_handle.dart';
import 'realm_bindings.dart';
import 'realm_core.dart';
import 'realm_library.dart';
import 'user_handle.dart';

class AppHandle extends HandleBase<realm_app> {
  AppHandle(Pointer<realm_app> pointer) : super(pointer, 16);

  static bool _firstTime = true;
  factory AppHandle.from(AppConfiguration configuration) {
    // to avoid caching apps across hot restarts we clear the cache on the first
    // time the ctor is called in the root isolate.
    if (_firstTime && _isRootIsolate) {
      _firstTime = false;
      realmLib.realm_clear_cached_apps();
    }
    final httpTransportHandle = HttpTransportHandle.from(configuration.httpClient);
    final appConfigHandle = _createAppConfig(configuration, httpTransportHandle);
    return AppHandle(realmLib.realm_app_create_cached(appConfigHandle.pointer));
  }

  static AppHandle? get(String id, String? baseUrl) {
    return using((arena) {
      final outApp = arena<Pointer<realm_app>>();
      realmLib
          .realm_app_get_cached(
            id.toCharPtr(arena),
            baseUrl == null ? nullptr : baseUrl.toCharPtr(arena),
            outApp,
          )
          .raiseLastErrorIfFalse();
      return outApp.value.convert(AppHandle.new);
    });
  }

  UserHandle? get currentUser {
    return realmLib.realm_app_get_current_user(pointer).convert(UserHandle.new);
  }

  List<UserHandle> get users => using((arena) => _getUsers(arena));

  List<UserHandle> _getUsers(Arena arena, {int expectedSize = 2}) {
    final actualCount = arena<Size>();
    final usersPtr = arena<Pointer<realm_user>>(expectedSize);
    realmLib.realm_app_get_all_users(pointer, usersPtr, expectedSize, actualCount).raiseLastErrorIfFalse();

    if (expectedSize < actualCount.value) {
      // The supplied array was too small - resize it
      arena.free(usersPtr);
      return _getUsers(arena, expectedSize: actualCount.value);
    }

    final result = <UserHandle>[];
    for (var i = 0; i < actualCount.value; i++) {
      result.add(UserHandle((usersPtr + i).value));
    }

    return result;
  }

  Future<void> removeUser(UserHandle user) {
    final completer = Completer<void>();
    realmLib
        .realm_app_remove_user(
          pointer,
          user.pointer,
          realmLib.addresses.realm_dart_void_completion_callback,
          createAsyncCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        )
        .raiseLastErrorIfFalse();
    return completer.future;
  }

  void switchUser(UserHandle user) {
    using((arena) {
      realmLib
          .realm_app_switch_user(
            pointer,
            user.pointer,
          )
          .raiseLastErrorIfFalse();
    });
  }

  void reconnect() => realmLib.realm_app_sync_client_reconnect(pointer);

  String get baseUrl {
    final customDataPtr = realmLib.realm_app_get_base_url(pointer);
    return customDataPtr.cast<Utf8>().toRealmDartString(freeRealmMemory: true)!;
  }

  Future<void> updateBaseUrl(Uri? baseUrl) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_update_base_url(
            pointer,
            baseUrl?.toString().toCharPtr(arena) ?? nullptr,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> refreshCustomData(UserHandle user) {
    final completer = Completer<void>();
    realmLib
        .realm_app_refresh_custom_data(
          pointer,
          user.pointer,
          realmLib.addresses.realm_dart_void_completion_callback,
          createAsyncCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        )
        .raiseLastErrorIfFalse();
    return completer.future;
  }

  String get id {
    return realmLib.realm_app_get_app_id(pointer).cast<Utf8>().toRealmDartString()!;
  }

  Future<UserHandle> logIn(CredentialsHandle credentials) {
    final completer = Completer<UserHandle>();
    realmLib
        .realm_app_log_in_with_credentials(
          pointer,
          credentials.pointer,
          realmLib.addresses.realm_dart_user_completion_callback,
          createAsyncUserCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        )
        .raiseLastErrorIfFalse();
    return completer.future;
  }

  Future<void> registerUser(String email, String password) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_register_email(
            pointer,
            email.toCharPtr(arena),
            password.toRealmString(arena).ref,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> confirmUser(String token, String tokenId) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_confirm_user(
            pointer,
            token.toCharPtr(arena),
            tokenId.toCharPtr(arena),
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> resendConfirmation(String email) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_resend_confirmation_email(
            pointer,
            email.toCharPtr(arena),
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> completeResetPassword(String password, String token, String tokenId) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_reset_password(
            pointer,
            password.toRealmString(arena).ref,
            token.toCharPtr(arena),
            tokenId.toCharPtr(arena),
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> requestResetPassword(String email) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_send_reset_password_email(
            pointer,
            email.toCharPtr(arena),
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> callResetPasswordFunction(String email, String password, String? argsAsJSON) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_call_reset_password_function(
            pointer,
            email.toCharPtr(arena),
            password.toRealmString(arena).ref,
            argsAsJSON != null ? argsAsJSON.toCharPtr(arena) : nullptr,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> retryCustomConfirmationFunction(String email) {
    final completer = Completer<void>();
    using((arena) {
      realmLib
          .realm_app_email_password_provider_client_retry_custom_confirmation(
            pointer,
            email.toCharPtr(arena),
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
    });
    return completer.future;
  }

  Future<void> deleteUser(UserHandle user) {
    final completer = Completer<void>();
    realmLib
        .realm_app_delete_user(
          pointer,
          user.pointer,
          realmLib.addresses.realm_dart_void_completion_callback,
          createAsyncCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        )
        .raiseLastErrorIfFalse();
    return completer.future;
  }

  bool resetRealm(String realmPath) {
    return using((arena) {
      final didRun = arena<Bool>();
      realmLib
          .realm_sync_immediately_run_file_actions(
            pointer,
            realmPath.toCharPtr(arena),
            didRun,
          )
          .raiseLastErrorIfFalse();
      return didRun.value;
    });
  }

  Future<String> callAppFunction(UserHandle user, String functionName, String? argsAsJSON) {
    return using((arena) {
      final completer = Completer<String>();
      realmLib
          .realm_app_call_function(
            pointer,
            user.pointer,
            functionName.toCharPtr(arena),
            argsAsJSON?.toCharPtr(arena) ?? nullptr,
            nullptr,
            realmLib.addresses.realm_dart_return_string_callback,
            createAsyncFunctionCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse();
      return completer.future;
    });
  }
}

Pointer<Void> createAsyncFunctionCallbackUserdata(Completer<String> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<Char>,
        Pointer<realm_app_error>,
      )>(_callAppFunctionCallback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

void _callAppFunctionCallback(Pointer<Void> userdata, Pointer<Char> response, Pointer<realm_app_error> error) {
  final Completer<String> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  final stringResponse = response.cast<Utf8>().toRealmDartString()!;
  completer.complete(stringResponse);
}

Pointer<Void> createAsyncCallbackUserdata(Completer<void> completer) {
  final callback = Pointer.fromFunction<
      Void Function(
        Pointer<Void>,
        Pointer<realm_app_error>,
      )>(_voidCompletionCallback);

  final userdata = realmLib.realm_dart_userdata_async_new(
    completer,
    callback.cast(),
    scheduler.handle.pointer,
  );

  return userdata.cast();
}

void _voidCompletionCallback(Pointer<Void> userdata, Pointer<realm_app_error> error) {
  final Completer<void> completer = userdata.toObject();

  if (error != nullptr) {
    completer.completeWithAppError(error);
    return;
  }

  completer.complete();
}

class _AppConfigHandle extends HandleBase<realm_app_config> {
  _AppConfigHandle(Pointer<realm_app_config> pointer) : super(pointer, 8);
}

_AppConfigHandle _createAppConfig(AppConfiguration configuration, HttpTransportHandle httpTransport) {
  return using((arena) {
    final appId = configuration.appId.toCharPtr(arena);
    final handle = _AppConfigHandle(realmLib.realm_app_config_new(appId, httpTransport.pointer));

    realmLib.realm_app_config_set_platform_version(handle.pointer, Platform.operatingSystemVersion.toCharPtr(arena));

    realmLib.realm_app_config_set_sdk(handle.pointer, 'Dart'.toCharPtr(arena));
    realmLib.realm_app_config_set_sdk_version(handle.pointer, libraryVersion.toCharPtr(arena));

    final deviceName = realmCore.getDeviceName();
    realmLib.realm_app_config_set_device_name(handle.pointer, deviceName.toCharPtr(arena));

    final deviceVersion = realmCore.getDeviceVersion();
    realmLib.realm_app_config_set_device_version(handle.pointer, deviceVersion.toCharPtr(arena));

    realmLib.realm_app_config_set_framework_name(handle.pointer, (isFlutterPlatform ? 'Flutter' : 'Dart VM').toCharPtr(arena));
    realmLib.realm_app_config_set_framework_version(handle.pointer, Platform.version.toCharPtr(arena));

    realmLib.realm_app_config_set_base_url(handle.pointer, configuration.baseUrl.toString().toCharPtr(arena));

    realmLib.realm_app_config_set_default_request_timeout(handle.pointer, configuration.defaultRequestTimeout.inMilliseconds);

    realmLib.realm_app_config_set_bundle_id(handle.pointer, realmCore.getBundleId().toCharPtr(arena));

    realmLib.realm_app_config_set_base_file_path(handle.pointer, configuration.baseFilePath.path.toCharPtr(arena));
    realmLib.realm_app_config_set_metadata_mode(handle.pointer, configuration.metadataPersistenceMode.index);

    if (configuration.metadataEncryptionKey != null && configuration.metadataPersistenceMode == MetadataPersistenceMode.encrypted) {
      realmLib.realm_app_config_set_metadata_encryption_key(handle.pointer, configuration.metadataEncryptionKey!.toUint8Ptr(arena));
    }

    return handle;
  });
}

// TODO:
// We need a pure Dart equivalent of:
// ```dart
// ServiceBinding.rootIsolateToken != null
// ```
// to get rid of this hack.
final bool _isRootIsolate = Isolate.current.debugName == 'main';
