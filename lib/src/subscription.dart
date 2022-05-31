////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2022 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

import 'dart:core';
import 'dart:collection';

import 'native/realm_core.dart';
import 'realm_class.dart';

/// A class representing a single query subscription. The server will continuously
/// evaluate the query that the app subscribed to and will send data
/// that matches it as well as remove data that no longer does.
/// {@category Sync}
class Subscription {
  final SubscriptionHandle _handle;

  Subscription._(this._handle);

  late final ObjectId _id = realmCore.subscriptionId(this);

  /// Name of the [Subscription], if one was provided at creation time.
  String? get name => realmCore.subscriptionName(this);

  /// Class name of objects the [Subscription] refers to.
  ///
  /// If your types are remapped using [MapTo], the value
  /// returned will be the mapped-to value - i.e. the one that Realm uses internally
  /// rather than the name of the generated Dart class.
  String get objectClassName => realmCore.subscriptionObjectClassName(this);

  /// Query string that describes the [Subscription].
  ///
  /// Objects matched by the query will be sent to the device by the server.
  String get queryString => realmCore.subscriptionQueryString(this);

  /// Timestamp when this [Subscription] was created.
  DateTime get createdAt => realmCore.subscriptionCreatedAt(this);

  /// Timestamp when this [Subscription] was last updated.
  DateTime get updatedAt => realmCore.subscriptionUpdatedAt(this);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Subscription) return false;
    // TODO: Don't work, issue with C-API
    // return realmCore.subscriptionEquals(this, other);
    return id == other.id; // <-- do this instead
  }
}

extension SubscriptionInternal on Subscription {
  SubscriptionHandle get handle => _handle;
  ObjectId get id => _id;
}

class _SubscriptionIterator implements Iterator<Subscription> {
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
/// Realm is an expensive operation serverside, even if there's very little data that needs
/// downloading.
/// {@category Sync}
abstract class SubscriptionSet with IterableMixin<Subscription> {
  Realm _realm;
  SubscriptionSetHandle _handle;

  SubscriptionSet._(this._realm, this._handle);

  /// Finds an existing [Subscription] in this set by its query
  ///
  /// The [query] is represented by the corresponding [RealmResults] object.
  Subscription? find<T extends RealmObject>(RealmResults<T> query) {
    final result = realmCore.findSubscriptionByResults(this, query);
    return result == null ? null : Subscription._(result);
  }

  /// Finds an existing [Subscription] in this set by name.
  Subscription? findByName(String name) {
    final result = realmCore.findSubscriptionByName(this, name);
    return result == null ? null : Subscription._(result);
  }

  Future<SubscriptionSetState> _waitForStateChange(SubscriptionSetState state) async {
    final result = await realmCore.waitForSubscriptionSetStateChange(this, state);
    realmCore.refreshSubscriptionSet(this);
    return result;
  }

  /// Waits for the server to acknowledge the subscription set and return the matching objects.
  ///
  /// If the [state] of the subscription set is [SubscriptionSetState.complete]
  /// the returned [Future] will complete immediately. If the state is
  /// [SubscriptionSetState.error], the returned future will throw an
  /// error.
  Future<void> waitForSynchronization() async {
    final result = await _waitForStateChange(SubscriptionSetState.complete);
    if (result == SubscriptionSetState.error) {
      throw RealmException('Synchronization Failed');
    }
  }

  @override
  int get length => realmCore.getSubscriptionSetSize(this);

  @override
  Subscription elementAt(int index) {
    RangeError.checkValidRange(index, null, length);
    return Subscription._(realmCore.subscriptionAt(this, index));
  }

  /// Gets the [Subscription] at the specified index in the set.
  Subscription operator [](int index) => elementAt(index);

  @override
  _SubscriptionIterator get iterator => _SubscriptionIterator._(this);

  /// Update the subscription set and send the request to the server in the background.
  ///
  /// Calling [update] is a prerequisite for mutating the subscription set,
  /// using a [MutableSubscriptionSet] passed to the [action].
  ///
  /// If you want to wait for the server to acknowledge and send back the data that matches the updated
  /// subscriptions, use [waitForSynchronization].
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action);

  /// Gets the version of the subscription set.
  int get version => realmCore.subscriptionSetGetVersion(this);

  /// Gets the state of the subscription set.
  SubscriptionSetState get state {
    final state = realmCore.subscriptionSetGetState(this);
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
  Realm get realm => _realm;
  SubscriptionSetHandle get handle => _handle;

  static SubscriptionSet create(Realm realm, SubscriptionSetHandle handle) => ImmutableSubscriptionSet._(realm, handle);
}

class ImmutableSubscriptionSet extends SubscriptionSet {
  ImmutableSubscriptionSet._(super.realm, super.handle) : super._();

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    final mutableSubscriptions = MutableSubscriptionSet._(realm, realmCore.subscriptionSetMakeMutable(this));
    final oldHandle = _handle;
    try {
      action(mutableSubscriptions);
      _handle = realmCore.subscriptionSetCommit(mutableSubscriptions);
    } finally {
      // Release as early as possible, as we cannot start new update, until this is released!
      mutableSubscriptions._handle.release();
      oldHandle.release();
    }
  }
}

/// A mutable view to a [SubscriptionSet]. Obtained by calling [SubscriptionSet.update].
/// {@category Sync}
class MutableSubscriptionSet extends SubscriptionSet {
  final MutableSubscriptionSetHandle _handle;

  MutableSubscriptionSet._(Realm realm, this._handle) : super._(realm, _handle);

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
  /// If [update] is specified to [true], then any existing query will be replaced.
  /// Otherwise a [RealmException] is thrown, in case of duplicates.
  /// {@category Sync}
  Subscription add<T extends RealmObject>(RealmResults<T> query, {String? name, bool update = false}) {
    return Subscription._(realmCore.insertOrAssignSubscription(this, query, name, update));
  }

  /// Remove the [subscription] from the set, if it exists.
  bool remove(Subscription subscription) {
    return realmCore.eraseSubscriptionById(this, subscription);
  }

  /// Remove the [query] from the set, if it exists.
  bool removeByQuery<T extends RealmObject>(RealmResults<T> query) {
    return realmCore.eraseSubscriptionByResults(this, query);
  }

  /// Remove the [query] from the set that matches by [name], if it exists.
  bool removeByName(String name) {
    return realmCore.eraseSubscriptionByName(this, name);
  }

  /// Clear the subscription set.
  void clear() {
    realmCore.clearSubscriptionSet(this);
  }
}

extension MutableSubscriptionSetInternal on MutableSubscriptionSet {
  MutableSubscriptionSetHandle get handle => _handle;
}
