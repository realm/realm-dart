// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_dart.dart';
import 'handle_base.dart';
import 'notification_token_handle.dart';
import 'object_handle.dart';
import 'realm_handle.dart';
import 'results_handle.dart';

abstract interface class ListHandle extends HandleBase {
  bool get isValid;
  int get size;

  // TODO: Consider splitting into two methods
  void addOrUpdateAt(int index, Object? value, bool insert);
  // TODO: avoid taking the [realm] parameter
  void addOrUpdateCollectionAt(Realm realm, int index, RealmValue value, bool insert);
  ResultsHandle asResults();
  void clear();
  void deleteAll();
  // TODO: avoid taking the [realm] parameter
  Object? elementAt(Realm realm, int index);
  int indexOf(Object? value);
  ObjectHandle insertEmbeddedAt(int index);
  void move(int from, int to);
  ResultsHandle query(String query, List<Object?> args);
  void removeAt(int index);
  ListHandle? resolveIn(RealmHandle frozenRealm);
  ObjectHandle setEmbeddedAt(int index);
  NotificationTokenHandle subscribeForNotifications(NotificationsController controller);
}
