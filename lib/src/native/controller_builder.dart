part of 'realm_core.dart';

typedef Subscriber = Pointer<realm_notification_token> Function(Pointer<Void>, StaticCallback, StaticFree, StaticError);

StreamController<T> _constructRealmNotificationStreamController<T>(
  Subscriber subscribe,
  Callback callback, {
  Free? free,
  Error? error,
}) {
  late StreamController<T> controller;

  late Pointer<Void> descriptor;
  RealmNotificationTokenHandle? token;
  void start() {
    descriptor = CallbackBridge.create(callback, free: free, error: error);
    token ??= RealmNotificationTokenHandle._(subscribe(
      descriptor,
      CallbackBridge.callback,
      // Not safe to pass CallbackBridge.free here yet, as it may be called from Finalizer thread,
      // if user forgets to cancel a StreamSubscription. Awaiting proper finalizers in dart 2.17.
      nullptr, // 1) <-- should be: CallbackBridge.free,
      CallbackBridge.error,
    ));
  }

  void stop() {
    final t = token;
    if (t != null) {
      t.releaseEarly();
      CallbackBridge.internal__free(descriptor); // compensate somewhat for 1)
      token = null;
    }
  }

  controller = StreamController<T>(
    onListen: start,
    onPause: stop,
    onResume: start,
    onCancel: stop,
  );

  return controller;
}
