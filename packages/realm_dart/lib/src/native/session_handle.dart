// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';
import 'package:ffi/ffi.dart';

import '../realm_dart.dart';
import '../scheduler.dart';
import '../session.dart'; // TODO: Remove this import
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_core.dart'; // TODO: Remove this import
import 'realm_handle.dart';
import 'realm_library.dart';
import 'rooted_handle.dart';
import 'user_handle.dart';

class SessionHandle extends RootedHandleBase<realm_sync_session_t> {
  @override
  bool get shouldRoot => true;

  SessionHandle(Pointer<realm_sync_session_t> pointer, RealmHandle root) : super(root, pointer, 24);

  String get path {
    return realmLib.realm_sync_session_get_file_path(pointer).cast<Utf8>().toRealmDartString()!;
  }

  ConnectionState get connectionState {
    final value = realmLib.realm_sync_session_get_connection_state(pointer);
    return ConnectionState.values[value];
  }

  UserHandle get user {
    return UserHandle(realmLib.realm_sync_session_get_user(pointer));
  }

  SessionState get state {
    final value = realmLib.realm_sync_session_get_state(pointer);
    return _convertCoreSessionState(value);
  }

  SessionState _convertCoreSessionState(int value) {
    switch (value) {
      case 0: // RLM_SYNC_SESSION_STATE_ACTIVE
      case 1: // RLM_SYNC_SESSION_STATE_DYING
        return SessionState.active;
      case 2: // RLM_SYNC_SESSION_STATE_INACTIVE
      case 3: // RLM_SYNC_SESSION_STATE_WAITING_FOR_ACCESS_TOKEN
      case 4: // RLM_SYNC_SESSION_STATE_PAUSED
        return SessionState.inactive;
      default:
        throw Exception("Unexpected SessionState: $value");
    }
  }

  void pause() {
    realmLib.realm_sync_session_pause(pointer);
  }

  void resume() {
    realmLib.realm_sync_session_resume(pointer);
  }

  void raiseError(int errorCode, bool isFatal) {
    using((arena) {
      final message = "Simulated session error".toCharPtr(arena);
      realmLib.realm_sync_session_handle_error_for_testing(pointer, errorCode, message, isFatal);
    });
  }

  Future<void> waitForUpload([CancellationToken? cancellationToken]) {
    final completer = CancellableCompleter<void>(cancellationToken);
    if (!completer.isCancelled) {
      final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_error_t>)>(_waitCompletionCallback);
      final userdata = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_sync_session_wait_for_upload_completion(
        pointer,
        realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      );
    }
    return completer.future;
  }

  Future<void> waitForDownload([CancellationToken? cancellationToken]) {
    final completer = CancellableCompleter<void>(cancellationToken);
    if (!completer.isCancelled) {
      final callback = Pointer.fromFunction<Void Function(Handle, Pointer<realm_error_t>)>(_waitCompletionCallback);
      final userdata = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_sync_session_wait_for_download_completion(
        pointer,
        realmLib.addresses.realm_dart_sync_wait_for_completion_callback,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      );
    }
    return completer.future;
  }

  static void _waitCompletionCallback(Object userdata, Pointer<realm_error_t> errorCode) {
    final completer = userdata as CancellableCompleter<void>;
    if (completer.isCancelled) {
      return;
    }
    if (errorCode != nullptr) {
      // Throw RealmException instead of RealmError to be recoverable by the user.
      completer.completeError(RealmException(errorCode.toDart().toString()));
    } else {
      completer.complete();
    }
  }

  SyncSessionNotificationTokenHandle subscribeForConnectionStateNotifications(SessionConnectionStateController controller) {
    final callback = Pointer.fromFunction<Void Function(Handle, Int32, Int32)>(_onConnectionStateChange);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    return SyncSessionNotificationTokenHandle(
      realmLib.realm_sync_session_register_connection_state_change_callback(
        pointer,
        realmLib.addresses.realm_dart_sync_connection_state_changed_callback,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      ),
    );
  }

  SyncSessionNotificationTokenHandle subscribeForProgressNotifications(
    ProgressDirection direction,
    ProgressMode mode,
    SessionProgressNotificationsController controller,
  ) {
    final isStreaming = mode == ProgressMode.reportIndefinitely;
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64, Double)>(syncProgressCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    return SyncSessionNotificationTokenHandle(
      realmLib.realm_sync_session_register_progress_notifier(
        pointer,
        realmLib.addresses.realm_dart_sync_progress_callback,
        direction.index,
        isStreaming,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      ),
    );
  }
}

class SyncSessionNotificationTokenHandle extends HandleBase<realm_sync_session_connection_state_notification_token> {
  SyncSessionNotificationTokenHandle(Pointer<realm_sync_session_connection_state_notification_token> pointer) : super(pointer, 32);
}

void _onConnectionStateChange(Object userdata, int oldState, int newState) {
  final controller = userdata as SessionConnectionStateController;

  controller.onConnectionStateChange(ConnectionState.values[oldState], ConnectionState.values[newState]);
}

void syncProgressCallback(Object userdata, int transferred, int transferable, double estimate) {
  final controller = userdata as ProgressNotificationsController;

  controller.onProgress(transferred, transferable);
}
