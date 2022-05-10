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

import 'dart:async';
import 'dart:collection';

import 'native/realm_core.dart';
import 'realm_class.dart';
import 'util.dart';

class Subscription {
  final SubscriptionHandle _handle;

  Subscription._(this._handle);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Subscription) return false;
    return realmCore.subscriptionEquals(this, other);
  }
}

extension SubscriptionInternal on Subscription {
  SubscriptionHandle get handle => _handle;
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

enum SubscriptionSetState {
  uncommitted,
  pending,
  bootstrapping,
  complete,
  error,
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
abstract class SubscriptionSet with IterableMixin<Subscription> {
  Realm _realm;
  SubscriptionSetHandle _handle;

  SubscriptionSet._(this._realm, this._handle);

  /// Finds an existing [Subscription] in this set by its query
  ///
  /// The [query] is represented by the corresponding [RealmResults] object.
  /// Finds a subscription by query.
  ///
  /// If the Subscription set does not contain a subscription with the provided query,
  /// return null
  Subscription? find<T extends RealmObject>(RealmResults<T> query) {
    return realmCore.findSubscriptionByQuery(this, query).convert(Subscription._);
  }

  /// Finds an existing [Subscription] in this set by name.
  ///
  /// If the Subscription set does not contain a subscription with the provided name,
  /// return null
  Subscription? findByName(String name) {
    return realmCore.findSubscriptionByName(this, name).convert(Subscription._);
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
  /// [SubscriptionSetState.error], the returned future will be throw an
  /// error.
  Future<SubscriptionSetState> waitForSynchronization() => _waitForStateChange(SubscriptionSetState.complete);

  @override
  int get length => realmCore.getSubscriptionSetSize(this);

  @override
  Subscription elementAt(int index) {
    return Subscription._(realmCore.subscriptionAt(this, index));
  }

  /// Gets the [Subscription] at the specified index in the set.
  Subscription operator [](int index) => elementAt(index);

  @override
  _SubscriptionIterator get iterator => _SubscriptionIterator._(this);

  /// Update the subscription set and send the request to the server in the background.
  ///
  /// Calling [update] is a prerequisite for mutating the subscription set,
  /// using a [MutableSubscriptionSet] parsed to [action].
  ///
  /// If you want to wait for the server to acknowledge and send back the data that matches the updated
  /// subscriptions, use [waitForSynchronization].
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action);

  /// Gets the version of the subscription set.
  int get version => realmCore.subscriptionSetGetVersion(this);

  /// Gets the state of the subscription set.
  SubscriptionSetState get state => realmCore.subscriptionSetGetState(this);
}

extension SubscriptionSetInternal on SubscriptionSet {
  Realm get realm => _realm;
  SubscriptionSetHandle get handle => _handle;

  static SubscriptionSet create(Realm realm, SubscriptionSetHandle handle) => _ImmutableSubscriptionSet._(realm, handle);
}

class _ImmutableSubscriptionSet extends SubscriptionSet {
  _ImmutableSubscriptionSet._(Realm realm, SubscriptionSetHandle handle) : super._(realm, handle);

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    final mutableSubscriptions = MutableSubscriptionSet._(realm, realmCore.subscriptionSetMakeMutable(this));
    try {
      action(mutableSubscriptions);
      _handle = realmCore.subscriptionSetCommit(mutableSubscriptions);
    } finally {
      // Release as early as possible, as we cannot start new update, until this is released!
      mutableSubscriptions._handle.release();
    }
  }
}

/// A mutable view to a [SubscriptionSet]. Obtained by calling [SubscriptionSet.update].
class MutableSubscriptionSet extends SubscriptionSet {
  final MutableSubscriptionSetHandle _handle;

  MutableSubscriptionSet._(Realm realm, this._handle) : super._(realm, _handle);

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    action(this); // or should we just throw?
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
  Subscription add<T extends RealmObject>(RealmResults<T> query, {String? name, bool update = false}) {
    return Subscription._(realmCore.insertOrAssignSubscription(this, query, name, update));
  }

  // TODO: Make this public when C-API is in place (see: https://github.com/realm/realm-core/issues/5475)
  bool _remove(Subscription subscription) {
    return realmCore.eraseSubscription(this, subscription);
  }

  /// Remove any [query] from the set that matches.
  bool removeByQuery<T extends RealmObject>(RealmResults<T> query) {
    return realmCore.eraseSubscriptionByQuery(this, query);
  }

  /// Remove any [query] from the set that matches by [name]
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
