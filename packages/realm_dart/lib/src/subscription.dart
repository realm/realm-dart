// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:core';
import 'dart:ffi';

import 'native/convert.dart';
import 'native/mutable_subscription_set_handle.dart';
import 'native/subscription_handle.dart';
import 'native/subscription_set_handle.dart';
import 'realm_class.dart';
import 'results.dart';

/// A class representing a single query subscription. The server will continuously
/// evaluate the query that the app subscribed to and will send data
/// that matches it as well as remove data that no longer does.
/// {@category Sync}
final class Subscription implements Finalizable {
  final SubscriptionHandle _handle;

  Subscription._(this._handle);

  late final ObjectId _id = _handle.id;

  /// Name of the [Subscription], if one was provided at creation time.
  String? get name => _handle.name;

  /// Class name of objects the [Subscription] refers to.
  ///
  /// If your types are remapped using [MapTo], the value
  /// returned will be the mapped-to value - i.e. the one that Realm uses internally
  /// rather than the name of the generated Dart class.
  String get objectClassName => _handle.objectClassName;

  /// Query string that describes the [Subscription].
  ///
  /// Objects matched by the query will be sent to the device by the server.
  String get queryString => _handle.queryString;

  /// Timestamp when this [Subscription] was created.
  DateTime get createdAt => _handle.createdAt;

  /// Timestamp when this [Subscription] was last updated.
  DateTime get updatedAt => _handle.updatedAt;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Subscription) return false;
    return _handle.equalTo(other._handle);
  }
}

extension SubscriptionInternal on Subscription {
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  SubscriptionHandle get handle => _handle;
  ObjectId get id => _id;
}

final class _SubscriptionIterator implements Iterator<Subscription> {
  int _index = -1;
  final SubscriptionSet _subscriptions;

  _SubscriptionIterator._(this._subscriptions);

  @override
  Subscription get current => _subscriptions.elementAt(_index);

  @override
  bool moveNext() => ++_index < _subscriptions.length;
}

/// {@category Sync}
enum SubscriptionSetState {
  /// This subscription set has not been persisted and has not been sent to the server.
  /// This state is only valid for MutableSubscriptionSets
  _uncommitted, // ignore: unused_field

  /// The subscription set has been persisted locally but has not been acknowledged by the server yet.
  pending,

  /// The server is currently sending the initial state that represents this subscription set to the client.
  _bootstrapping, // ignore: unused_field

  /// This subscription set is the active subscription set that is currently being synchronized with the server.
  complete,

  /// An error occurred while processing this subscription set on the server. Check error_str() for details.
  error,

  /// The server responded to a later subscription set to this one and this one has been
  /// trimmed from the local storage of subscription sets.
  superseded,
}

/// A collection representing the set of active subscriptions for a [Realm] instance.
///
/// This is used in combination with [FlexibleSyncConfiguration] to
/// declare the set of queries you want to synchronize with the server. You can access and
/// read the subscription set freely, but mutating it must happen in an [update]
/// block.
///
/// Any changes to the subscription set will be persisted locally and be available the next
/// time the application starts up - i.e. it's not necessary to subscribe for the same query
/// every time. Updating the subscription set can be done while offline, and only the latest
/// update will be sent to the server whenever connectivity is restored.
///
/// It is strongly recommended that you batch updates as much as possible and request the
/// dataset your application needs upfront. Updating the set of active subscriptions for a
/// Realm is an expensive operation server-side, even if there's very little data that needs
/// downloading.
/// {@category Sync}
sealed class SubscriptionSet with Iterable<Subscription> implements Finalizable {
  final Realm _realm;
  SubscriptionSetHandle __handle;
  SubscriptionSetHandle get _handle => __handle.nullPtrAsNull ?? (throw RealmClosedError('Cannot access a SubscriptionSet that belongs to a closed Realm'));
  set _handle(SubscriptionSetHandle value) => __handle = value;

  SubscriptionSet._(this._realm, this.__handle);

  /// Finds an existing [Subscription] in this set by its query
  ///
  /// The [query] is represented by the corresponding [RealmResults] object.
  Subscription? find<T extends RealmObject>(RealmResults<T> query) => _handle.findByResults(query.handle).convert(Subscription._);

  /// Finds an existing [Subscription] in this set by name.
  Subscription? findByName(String name) => _handle.findByName(name).convert(Subscription._);

  Future<SubscriptionSetState> _waitForStateChange(SubscriptionSetState state, [CancellationToken? cancellationToken]) async {
    final result = await _handle.waitForStateChange(state, cancellationToken);
    _handle.refresh();
    return result;
  }

  /// Waits for the server to acknowledge the subscription set and return the matching objects.
  ///
  /// If the [state] of the subscription set is [SubscriptionSetState.complete]
  /// the returned [Future] will complete immediately. If the state is
  /// [SubscriptionSetState.error], the returned future will throw an
  /// error.
  /// An optional [cancellationToken] can be used to cancel the wait operation.
  Future<void> waitForSynchronization([CancellationToken? cancellationToken]) async {
    final result = await _waitForStateChange(SubscriptionSetState.complete, cancellationToken);
    if (result == SubscriptionSetState.error) {
      throw error!;
    }
  }

  /// Returns the error if the subscription set is in the [SubscriptionSetState.error] state.
  Exception? get error => _handle.error;

  @override
  int get length => _handle.size;

  @override
  Subscription elementAt(int index) {
    RangeError.checkValidRange(index, null, length);
    return Subscription._(_handle[index]);
  }

  /// Gets the [Subscription] at the specified index in the set.
  Subscription operator [](int index) => elementAt(index);

  @override
  Iterator<Subscription> get iterator => _SubscriptionIterator._(this);

  /// Updates the subscription set and send the request to the server in the background.
  ///
  /// Calling [update] is a prerequisite for mutating the subscription set,
  /// using a [MutableSubscriptionSet] passed to the [action].
  ///
  /// If you want to wait for the server to acknowledge and send back the data that matches the updated
  /// subscriptions, use [waitForSynchronization].
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action);

  /// Gets the version of the subscription set.
  int get version => _handle.version;

  /// Gets the state of the subscription set.
  SubscriptionSetState get state {
    final state = _handle.state;
    switch (state) {
      case SubscriptionSetState._uncommitted:
      case SubscriptionSetState._bootstrapping:
        return SubscriptionSetState.pending;
      default:
        return state;
    }
  }
}

extension SubscriptionSetInternal on SubscriptionSet {
  @pragma('vm:never-inline')
  void keepAlive() {
    _realm.keepAlive();
    _handle.keepAlive();
  }

  SubscriptionSetHandle get handle => _handle;

  static SubscriptionSet create(Realm realm, SubscriptionSetHandle handle) => ImmutableSubscriptionSet._(realm, handle);
}

final class ImmutableSubscriptionSet extends SubscriptionSet {
  ImmutableSubscriptionSet._(super.realm, super.handle) : super._();

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    final old = _handle;
    final mutable = _handle.toMutable();
    try {
      action(MutableSubscriptionSet._(_realm, mutable));
      _handle = mutable.commit();
    } finally {
      // Release as early as possible, as we cannot start new update, until this is released!
      mutable.release();
      old.release();
    }
  }
}

/// A mutable view to a [SubscriptionSet]. Obtained by calling [SubscriptionSet.update].
/// {@category Sync}
final class MutableSubscriptionSet extends SubscriptionSet {
  @override
  MutableSubscriptionSetHandle get _handle => super._handle as MutableSubscriptionSetHandle;

  MutableSubscriptionSet._(super.realm, MutableSubscriptionSetHandle super.handle) : super._();

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    action(this);
  }

  /// Adds a [query] to the set of active subscriptions.
  ///
  /// The query will be joined via an OR statement with any existing queries for the same type.
  ///
  /// If a [name] is given, then this will be used to match with any existing query,
  /// otherwise the [query] itself is used for matching.
  ///
  /// If [update] is specified to `true`, then any existing query will be replaced.
  /// Otherwise a [RealmException] is thrown, in case of duplicates.
  /// {@category Sync}
  Subscription add<T extends RealmObject>(RealmResults<T> query, {String? name, bool update = false}) =>
      Subscription._(_handle.insertOrAssignSubscription(query.handle, name, update));

  /// Removes the [subscription] from the set, if it exists.
  bool remove(Subscription subscription) => _handle.erase(subscription._handle);

  /// Removes the [query] from the set, if it exists.
  bool removeByQuery<T extends RealmObject>(RealmResults<T> query) => _handle.eraseByResults(query.handle);

  /// Removes the subscription from the set that matches by [name], if it exists.
  bool removeByName(String name) => _handle.eraseByName(name);

  /// Removes the subscriptions from the set that matches by type, if it exists.
  bool removeByType<T extends RealmObject>() {
    final name = _realm.schema.singleWhere((e) => e.type == T).name;
    var result = false;
    for (var i = length - 1; i >= 0; i--) {
      // reverse iteration to avoid index shifting
      final subscription = this[i];
      if (subscription.objectClassName == name) {
        result |= remove(subscription);
      }
    }
    return result;
  }

  /// Clears the subscription set.
  /// If [unnamedOnly] is `true`, then only unnamed subscriptions will be removed.
  void clear({bool unnamedOnly = false}) {
    if (unnamedOnly) {
      for (var i = length - 1; i >= 0; i--) {
        final subscription = this[i];
        if (subscription.name == null) {
          remove(subscription);
        }
      }
    } else {
      _handle.clear();
    }
  }
}
