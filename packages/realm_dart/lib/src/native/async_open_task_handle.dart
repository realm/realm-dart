import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';
import 'ffi.dart';
import 'package:realm_dart/src/native/error_handling.dart';
import 'package:realm_dart/src/native/realm_bindings.dart';

import '../realm_dart.dart';
import '../scheduler.dart';
import 'config_handle.dart';
import 'handle_base.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'session_handle.dart';

class AsyncOpenTaskHandle extends HandleBase<realm_async_open_task_t> {
  AsyncOpenTaskHandle(Pointer<realm_async_open_task_t> pointer) : super(pointer, 32);

  factory AsyncOpenTaskHandle.from(FlexibleSyncConfiguration config) {
    final configHandle = ConfigHandle.from(config);
    final asyncOpenTaskPtr = realmLib.realm_open_synchronized(configHandle.pointer).raiseLastErrorIfNull();
    return AsyncOpenTaskHandle(asyncOpenTaskPtr);
  }

  Future<RealmHandle> openAsync(CancellationToken? cancellationToken) {
    final completer = CancellableCompleter<RealmHandle>(cancellationToken);
    if (!completer.isCancelled) {
      final callback =
          Pointer.fromFunction<Void Function(Handle, Pointer<realm_thread_safe_reference> realm, Pointer<realm_async_error_t> error)>(_openRealmAsyncCallback);
      final userData = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle.pointer);
      realmLib.realm_async_open_task_start(
        pointer,
        realmLib.addresses.realm_dart_async_open_task_callback,
        userData.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      );
    }
    return completer.future;
  }

  void cancel() {
    realmLib.realm_async_open_task_cancel(pointer);
  }

  AsyncOpenTaskProgressNotificationTokenHandle registerProgressNotifier(
    RealmAsyncOpenProgressNotificationsController controller,
  ) {
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64, Double)>(syncProgressCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), scheduler.handle.pointer);
    return AsyncOpenTaskProgressNotificationTokenHandle(
      realmLib.realm_async_open_task_register_download_progress_notifier(
        pointer,
        realmLib.addresses.realm_dart_sync_progress_callback,
        userdata.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      ),
    );
  }
}

class AsyncOpenTaskProgressNotificationTokenHandle extends HandleBase<realm_async_open_task_progress_notification_token_t> {
  AsyncOpenTaskProgressNotificationTokenHandle(Pointer<realm_async_open_task_progress_notification_token_t> pointer) : super(pointer, 40);
}

void _openRealmAsyncCallback(Object userData, Pointer<realm_thread_safe_reference> realmSafePtr, Pointer<realm_async_error_t> error) {
  return using((arena) {
    final completer = userData as CancellableCompleter<RealmHandle>;
    if (completer.isCancelled) {
      return;
    }
    if (error != nullptr) {
      final err = arena<realm_error>();
      final lastError = realmLib.realm_get_async_error(error, err) ? err.ref.toDart() : null;
      completer.completeError(RealmException("Failed to open realm: ${lastError?.message ?? 'Error details missing.'}"));
      return;
    }

    completer.complete(RealmHandle(realmLib.realm_from_thread_safe_reference(realmSafePtr, scheduler.handle.pointer)));
  });
}
