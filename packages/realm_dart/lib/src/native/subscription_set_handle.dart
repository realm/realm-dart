// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class SubscriptionSetHandle extends RootedHandleBase<realm_flx_sync_subscription_set> {
  @override
  bool get shouldRoot => true;

  SubscriptionSetHandle._(Pointer<realm_flx_sync_subscription_set> pointer, RealmHandle root) : super(root, pointer, 128);

  void refresh() => invokeGetBool(() => _realmLib.realm_sync_subscription_set_refresh(_pointer));

  int get size => _realmLib.realm_sync_subscription_set_size(_pointer);

  Exception? get error {
    final error = _realmLib.realm_sync_subscription_set_error_str(_pointer);
    final message = error.cast<Utf8>().toRealmDartString(treatEmptyAsNull: true);
    return message == null ? null : RealmException(message);
  }

  SubscriptionHandle operator [](int index) => SubscriptionHandle._(invokeGetPointer(() => _realmLib.realm_sync_subscription_at(_pointer, index)));

  SubscriptionHandle? findByName(String name) {
    return using((arena) {
      final result = _realmLib.realm_sync_find_subscription_by_name(
        _pointer,
        name.toCharPtr(arena),
      );
      return result == nullptr ? null : SubscriptionHandle._(result);
    });
  }

  SubscriptionHandle? findByResults(RealmResults results) {
    final result = _realmLib.realm_sync_find_subscription_by_results(
      _pointer,
      results.handle._pointer,
    );
    return result == nullptr ? null : SubscriptionHandle._(result);
  }

  int get version => _realmLib.realm_sync_subscription_set_version(_pointer);

  SubscriptionSetState get state => SubscriptionSetState.values[_realmLib.realm_sync_subscription_set_state(_pointer)];

  MutableSubscriptionSetHandle toMutable() =>
      MutableSubscriptionSetHandle._(invokeGetPointer(() => _realmLib.realm_sync_make_subscription_set_mutable(_pointer)), _root);

  static void _stateChangeCallback(Object userdata, int state) {
    final completer = userdata as CancellableCompleter<SubscriptionSetState>;
    if (!completer.isCancelled) {
      completer.complete(SubscriptionSetState.values[state]);
    }
  }

  Future<SubscriptionSetState> waitForStateChange(SubscriptionSetState notifyWhen, [CancellationToken? cancellationToken]) {
    final completer = CancellableCompleter<SubscriptionSetState>(cancellationToken);
    if (!completer.isCancelled) {
      final callback = Pointer.fromFunction<Void Function(Handle, Int32)>(_stateChangeCallback);
      final userdata = _realmLib.realm_dart_userdata_async_new(completer, callback.cast(), scheduler.handle._pointer);
      _realmLib.realm_sync_on_subscription_set_state_change_async(_pointer, notifyWhen.index,
          _realmLib.addresses.realm_dart_sync_on_subscription_state_changed_callback, userdata.cast(), _realmLib.addresses.realm_dart_userdata_async_free);
    }
    return completer.future;
  }
}
