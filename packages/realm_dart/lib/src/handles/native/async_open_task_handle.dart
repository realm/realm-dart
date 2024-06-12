import 'dart:ffi';

import 'package:cancellation_token/cancellation_token.dart';
import 'ffi.dart';
import 'error_handling.dart';
import 'realm_bindings.dart';

import '../../realm_dart.dart';
import 'config_handle.dart';
import 'handle_base.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'scheduler_handle.dart';
import 'session_handle.dart';

import '../async_open_task_handle.dart' as intf;

class AsyncOpenTaskHandle extends HandleBase<realm_async_open_task_t> implements intf.AsyncOpenTaskHandle {
  AsyncOpenTaskHandle(Pointer<realm_async_open_task_t> pointer) : super(pointer, 32);

  factory AsyncOpenTaskHandle.from(FlexibleSyncConfiguration config) {
    final configHandle = ConfigHandle.from(config);
    final asyncOpenTaskPtr = realmLib.realm_open_synchronized(configHandle.pointer).raiseLastErrorIfNull();
    return AsyncOpenTaskHandle(asyncOpenTaskPtr);
  }

  @override
  Future<RealmHandle> openAsync(CancellationToken? cancellationToken) {
    final completer = CancellableCompleter<RealmHandle>(cancellationToken);
    if (!completer.isCancelled) {
      final callback =
          Pointer.fromFunction<Void Function(Handle, Pointer<realm_thread_safe_reference> realm, Pointer<realm_async_error_t> error)>(_openRealmAsyncCallback);
      final userData = realmLib.realm_dart_userdata_async_new(completer, callback.cast(), schedulerHandle.pointer);
      realmLib.realm_async_open_task_start(
        pointer,
        realmLib.addresses.realm_dart_async_open_task_callback,
        userData.cast(),
        realmLib.addresses.realm_dart_userdata_async_free,
      );
    }
    return completer.future;
  }

  @override
  void cancel() {
    realmLib.realm_async_open_task_cancel(pointer);
  }

  @override
  AsyncOpenTaskProgressNotificationTokenHandle registerProgressNotifier(
    RealmAsyncOpenProgressNotificationsController controller,
  ) {
    final callback = Pointer.fromFunction<Void Function(Handle, Uint64, Uint64, Double)>(syncProgressCallback);
    final userdata = realmLib.realm_dart_userdata_async_new(controller, callback.cast(), schedulerHandle.pointer);
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

class AsyncOpenTaskProgressNotificationTokenHandle extends HandleBase<realm_async_open_task_progress_notification_token_t>
    implements intf.AsyncOpenTaskProgressNotificationTokenHandle {
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

    completer.complete(RealmHandle(realmLib.realm_from_thread_safe_reference(realmSafePtr, schedulerHandle.pointer)));
  });
}
