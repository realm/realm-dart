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

import 'dart:collection';

import 'native/realm_core.dart';
import 'realm_class.dart';
import 'util.dart';

class Subscription {
  final SubscriptionHandle _handle;

  Subscription._(this._handle);
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

  Future<SubscriptionSetState> waitForStateChange(SubscriptionSetState state) async {
    return SubscriptionSetState.values[await realmCore.waitForSubscriptionSetStateChange(this, state)];
  }

  @override
  int get length => realmCore.getSubscriptionSetSize(this);

  @override
  Subscription elementAt(int index) {
    return Subscription._(realmCore.subscriptionAt(this, index));
  }

  Subscription operator[](int index) => elementAt(index);

  @override
  _SubscriptionIterator get iterator => _SubscriptionIterator._(this);

  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action);

  int get version => realmCore.subscriptionSetVersion(this);

  SubscriptionSetState get state => SubscriptionSetState.values[realmCore.subscriptionSetState(this)];
}

extension SubscriptionSetInternal on SubscriptionSet {
  Realm get realm => _realm;
  SubscriptionSetHandle get handle => _handle;

  static SubscriptionSet create(Realm realm, SubscriptionSetHandle handle) => MutableSubscriptionSet._(realm, handle);
}

class MutableSubscriptionSet extends SubscriptionSet {
  MutableSubscriptionSetHandle? _mutableHandle;

  MutableSubscriptionSet._(Realm realm, SubscriptionSetHandle handle) : super._(realm, handle);

  @override
  void update(void Function(MutableSubscriptionSet mutableSubscriptions) action) {
    assert(_mutableHandle == null);
    var commit = false;
    try {
      _mutableHandle = realmCore.makeSubscriptionSetMutable(this);
      action(this);
      commit = true;
    } finally {
      if (commit) {
        _handle = realmCore.subscriptionSetCommit(this);
      }
      // _mutableHandle.release(); // TODO: Release early
      _mutableHandle = null;
    }
  }

  bool addOrUpdate<T extends RealmObject>(RealmResults<T> query, {String? name, bool update = true}) {
    assert(_mutableHandle != null);
    return realmCore.insertOrAssignSubscription(this, query, name);
  }

  void remove<T extends RealmObject>(RealmResults<T> query) {
    assert(_mutableHandle != null);
    return realmCore.eraseSubscriptionByQuery(this, query);
  }

  void removeByName(String name) {
    assert(_mutableHandle != null);
    return realmCore.eraseSubscriptionByName(this, name);
  }

  void removeAll() {
    assert(_mutableHandle != null);
    return realmCore.clearSubscriptionSet(this);
  }
}

extension MutableSubscriptionSetInternal on MutableSubscriptionSet {
  MutableSubscriptionSetHandle get mutableHandle => _mutableHandle!;
}
