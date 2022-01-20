part of 'realm_core.dart';

StreamController<T> _constructRealmNotificationStreamController<T>(
  Pointer<realm_notification_token> Function() subscribe,
) {
  late StreamController<T> controller;

  Pointer<realm_notification_token>? token;
  void start() {
    token ??= subscribe();
  }

  void stop() {
    final t = token;
    if (t != null) {
      _realmLib.realm_release(t.cast());
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
