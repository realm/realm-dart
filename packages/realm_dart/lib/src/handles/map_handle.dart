// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_class.dart';
import 'handle_base.dart';
import 'notification_token_handle.dart';
import 'object_handle.dart';
import 'realm_handle.dart';
import 'results_handle.dart';

abstract interface class MapHandle extends HandleBase {
  bool get isValid;
  ResultsHandle get keys;
  int get size;
  ResultsHandle get values;

  void clear();
  bool containsKey(String key);
  bool containsValue(Object? value);
  // TODO: avoid taking a [Realm] as parameter (wrong layer)
  Object? find(Realm realm, String key);
  int indexOf(Object? value);
  void insert(String key, Object? value);
  // TODO: avoid taking a [Realm] as parameter (wrong layer)
  void insertCollection(Realm realm, String key, RealmValue value);
  ObjectHandle insertEmbedded(String key);
  ResultsHandle query(String query, List<Object?> args);
  bool remove(String key);
  MapHandle? resolveIn(RealmHandle frozenRealm);
  NotificationTokenHandle subscribeForNotifications(NotificationsController controller);
}
