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

abstract class SubscriptionSet with IterableMixin<Subscription> {
  Realm _realm;
  SubscriptionSetHandle _handle;

  SubscriptionSet._(this._realm, this._handle);

  Subscription? find<T extends RealmObject>(RealmResults<T> query) {
    return realmCore.findSubscriptionByQuery(this, query).convert(Subscription._);
  }

  Subscription? findByName(String name) {
    return realmCore.findSubscriptionByName(this, name).convert(Subscription._);
  }

  Future<SubscriptionSetState> _waitForStateChange(SubscriptionSetState state) async {
    final result = await realmCore.waitForSubscriptionSetStateChange(this, state);
    realmCore.refreshSubscriptionSet(this);
    return result;
  }

  Future<SubscriptionSetState> waitForSynchronization() => _waitForStateChange(SubscriptionSetState.complete);

  @override
  int get length => realmCore.getSubscriptionSetSize(this);

  @override
  Subscription elementAt(int index) {
    return Subscription._(realmCore.subscriptionAt(this, index));
  }

  Subscription operator [](int index) => elementAt(index);

  @override
  _SubscriptionIterator get iterator => _SubscriptionIterator._(this);

  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action);

  int get version => realmCore.subscriptionSetGetVersion(this);

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
    final mutableSubscriptions = MutableSubscriptionSet._(realm, _handle, realmCore.subscriptionSetMakeMutable(this));
    action(mutableSubscriptions);
    _handle = realmCore.subscriptionSetCommit(mutableSubscriptions);
  }
}

class MutableSubscriptionSet extends SubscriptionSet {
  final MutableSubscriptionSetHandle _mutableHandle;

  MutableSubscriptionSet._(Realm realm, SubscriptionSetHandle handle, this._mutableHandle) : super._(realm, handle);

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    action(this); // or should we just throw?
  }

  bool addOrUpdate<T extends RealmObject>(RealmResults<T> query, {String? name}) {
    return realmCore.insertOrAssignSubscription(this, query, name);
  }

  void remove<T extends RealmObject>(RealmResults<T> query) {
    return realmCore.eraseSubscriptionByQuery(this, query);
  }

  void removeByName(String name) {
    return realmCore.eraseSubscriptionByName(this, name);
  }

  void removeAll() {
    return realmCore.clearSubscriptionSet(this);
  }
}

extension MutableSubscriptionSetInternal on MutableSubscriptionSet {
  MutableSubscriptionSetHandle get mutableHandle => _mutableHandle;
}
