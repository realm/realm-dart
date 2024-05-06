// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import '../init.dart';
import '../logging.dart';
import '../realm_class.dart'; // TODO: Remove this import
import '../scheduler.dart';
import 'convert.dart';
import 'credentials_handle.dart';
import 'error_handling.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_core.dart'; // TODO: Remove this import
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
    final httpTransportHandle = _createHttpTransport(configuration.httpClient);
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
        .raiseLastErrorIfFalse("Remove user failed");
    return completer.future;
  }

  void switchUser(UserHandle user) {
    using((arena) {
      realmLib
          .realm_app_switch_user(
            pointer,
            user.pointer,
          )
          .raiseLastErrorIfFalse("Switch user failed");
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
          .raiseLastErrorIfFalse("Update base URL failed");
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
        .raiseLastErrorIfFalse("Refresh custom data failed");
    return completer.future;
  }

  String get id {
    return realmLib.realm_app_get_app_id(pointer).cast<Utf8>().toRealmDartString()!;
  }

  Future<UserHandle> logIn(CredentialsHandle credentials) async {
    final completer = Completer<UserHandle>();
    realmLib
        .realm_app_log_in_with_credentials(
          pointer,
          credentials.pointer,
          realmLib.addresses.realm_dart_user_completion_callback,
          createAsyncUserCallbackUserdata(completer),
          realmLib.addresses.realm_dart_userdata_async_free,
        )
        .raiseLastErrorIfFalse("Login failed");
    return await completer.future;
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

  Future<void> confirmUser(String token, String tokenId) async {
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
    return await completer.future;
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

  Future<void> logOut(UserHandle? user) {
    final completer = Completer<void>();
    if (user == null) {
      realmLib
          .realm_app_log_out_current_user(
            pointer,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse("Logout failed");
    } else {
      realmLib
          .realm_app_log_out(
            pointer,
            user.pointer,
            realmLib.addresses.realm_dart_void_completion_callback,
            createAsyncCallbackUserdata(completer),
            realmLib.addresses.realm_dart_userdata_async_free,
          )
          .raiseLastErrorIfFalse("Logout failed");
    }
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
        .raiseLastErrorIfFalse("Delete user failed");
    return completer.future;
  }

  bool immediatelyRunFileActions(String realmPath) {
    return using((arena) {
      final didRun = arena<Bool>();
      realmLib
          .realm_sync_immediately_run_file_actions(
            pointer,
            realmPath.toCharPtr(arena),
            didRun,
          )
          .raiseLastErrorIfFalse("An error occurred while resetting the Realm. Check if the file is in use: '$realmPath'");
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

// TODO:
// We need a pure Dart equivalent of:
// ```dart
// ServiceBinding.rootIsolateToken != null
// ```
// to get rid of this hack.
final bool _isRootIsolate = Isolate.current.debugName == 'main';

class _HttpTransportHandle extends HandleBase<realm_http_transport> {
  _HttpTransportHandle(Pointer<realm_http_transport> pointer) : super(pointer, 24);
}

_HttpTransportHandle _createHttpTransport(HttpClient httpClient) {
  final requestCallback = Pointer.fromFunction<Void Function(Handle, realm_http_request, Pointer<Void>)>(_requestCallback);
  final requestCallbackUserdata = realmLib.realm_dart_userdata_async_new(httpClient, requestCallback.cast(), scheduler.handle.pointer);
  return _HttpTransportHandle(realmLib.realm_http_transport_new(
    realmLib.addresses.realm_dart_http_request_callback,
    requestCallbackUserdata.cast(),
    realmLib.addresses.realm_dart_userdata_async_free,
  ));
}

void _requestCallback(Object userData, realm_http_request request, Pointer<Void> requestContext) {
  //
  // The request struct only survives until end-of-call, even though
  // we explicitly call realm_http_transport_complete_request to
  // mark request as completed later.
  //
  // Therefore we need to copy everything out of request before returning.
  // We cannot clone request on the native side with realm_clone,
  // since realm_http_request does not inherit from WrapC.

  final client = userData as HttpClient;

  client.connectionTimeout = Duration(milliseconds: request.timeout_ms);

  final url = Uri.parse(request.url.cast<Utf8>().toRealmDartString()!);

  final body = request.body.cast<Utf8>().toRealmDartString(length: request.body_size);

  final headers = <String, String>{};
  for (int i = 0; i < request.num_headers; ++i) {
    final header = request.headers[i];
    final name = header.name.cast<Utf8>().toRealmDartString()!;
    final value = header.value.cast<Utf8>().toRealmDartString()!;
    headers[name] = value;
  }

  _requestCallbackAsync(client, request.method, url, body, headers, requestContext);
  // The request struct dies here!
}

Future<void> _requestCallbackAsync(
  HttpClient client,
  int requestMethod,
  Uri url,
  String? body,
  Map<String, String> headers,
  Pointer<Void> requestContext,
) async {
  await using((arena) async {
    final responsePointer = arena<realm_http_response>();
    final responseRef = responsePointer.ref;
    final method = HttpMethod.values[requestMethod];

    try {
      // Build request
      late HttpClientRequest request;

      switch (method) {
        case HttpMethod.delete:
          request = await client.deleteUrl(url);
          break;
        case HttpMethod.put:
          request = await client.putUrl(url);
          break;
        case HttpMethod.patch:
          request = await client.patchUrl(url);
          break;
        case HttpMethod.post:
          request = await client.postUrl(url);
          break;
        case HttpMethod.get:
          request = await client.getUrl(url);
          break;
      }

      for (final header in headers.entries) {
        request.headers.add(header.key, header.value);
      }

      if (body != null) {
        request.add(utf8.encode(body));
      }

      Realm.logger.log(LogLevel.debug, "HTTP Transport: Executing ${method.name} $url");

      final stopwatch = Stopwatch()..start();

      // Do the call..
      final response = await request.close();

      stopwatch.stop();
      Realm.logger.log(LogLevel.debug, "HTTP Transport: Executed ${method.name} $url: ${response.statusCode} in ${stopwatch.elapsedMilliseconds} ms");

      final responseBody = await response.fold<List<int>>([], (acc, l) => acc..addAll(l)); // gather response

      // Report back to core
      responseRef.status_code = response.statusCode;
      responseRef.body = responseBody.toCharPtr(arena);
      responseRef.body_size = responseBody.length;

      int headerCnt = 0;
      response.headers.forEach((name, values) {
        headerCnt += values.length;
      });

      responseRef.headers = arena<realm_http_header>(headerCnt);
      responseRef.num_headers = headerCnt;

      int index = 0;
      response.headers.forEach((name, values) {
        for (final value in values) {
          final headerRef = (responseRef.headers + index).ref;
          headerRef.name = name.toCharPtr(arena);
          headerRef.value = value.toCharPtr(arena);
          index++;
        }
      });

      responseRef.custom_status_code = CustomErrorCode.noError.code;
    } on SocketException catch (socketEx) {
      Realm.logger.log(LogLevel.warn, "HTTP Transport: SocketException executing ${method.name} $url: $socketEx");
      responseRef.custom_status_code = CustomErrorCode.timeout.code;
    } on HttpException catch (httpEx) {
      Realm.logger.log(LogLevel.warn, "HTTP Transport: HttpException executing ${method.name} $url: $httpEx");
      responseRef.custom_status_code = CustomErrorCode.unknownHttp.code;
    } catch (ex) {
      Realm.logger.log(LogLevel.error, "HTTP Transport: Exception executing ${method.name} $url: $ex");
      responseRef.custom_status_code = CustomErrorCode.unknown.code;
    } finally {
      realmLib.realm_http_transport_complete_request(requestContext, responsePointer);
    }
  });
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

Pointer<Void> createAsyncCallbackUserdata<T extends Function>(Completer<void> completer) {
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

_AppConfigHandle _createAppConfig(AppConfiguration configuration, _HttpTransportHandle httpTransport) {
  return using((arena) {
    final appId = configuration.appId.toCharPtr(arena);
    final handle = _AppConfigHandle(realmLib.realm_app_config_new(appId, httpTransport.pointer));

    realmLib.realm_app_config_set_platform_version(handle.pointer, Platform.operatingSystemVersion.toCharPtr(arena));

    realmLib.realm_app_config_set_sdk(handle.pointer, 'Dart'.toCharPtr(arena));
    realmLib.realm_app_config_set_sdk_version(handle.pointer, libraryVersion.toCharPtr(arena));

    final deviceName = getDeviceName();
    realmLib.realm_app_config_set_device_name(handle.pointer, deviceName.toCharPtr(arena));

    final deviceVersion = getDeviceVersion();
    realmLib.realm_app_config_set_device_version(handle.pointer, deviceVersion.toCharPtr(arena));

    realmLib.realm_app_config_set_framework_name(handle.pointer, (isFlutterPlatform ? 'Flutter' : 'Dart VM').toCharPtr(arena));
    realmLib.realm_app_config_set_framework_version(handle.pointer, Platform.version.toCharPtr(arena));

    realmLib.realm_app_config_set_base_url(handle.pointer, configuration.baseUrl.toString().toCharPtr(arena));

    realmLib.realm_app_config_set_default_request_timeout(handle.pointer, configuration.defaultRequestTimeout.inMilliseconds);

    realmLib.realm_app_config_set_bundle_id(handle.pointer, getBundleId().toCharPtr(arena));

    realmLib.realm_app_config_set_base_file_path(handle.pointer, configuration.baseFilePath.path.toCharPtr(arena));
    realmLib.realm_app_config_set_metadata_mode(handle.pointer, configuration.metadataPersistenceMode.index);

    if (configuration.metadataEncryptionKey != null && configuration.metadataPersistenceMode == MetadataPersistenceMode.encrypted) {
      realmLib.realm_app_config_set_metadata_encryption_key(handle.pointer, configuration.metadataEncryptionKey!.toUint8Ptr(arena));
    }

    return handle;
  });
}
