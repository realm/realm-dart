// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/src/handles/handle_base.dart';

import '../realm_class.dart';
import 'notification_token_handle.dart';
import 'realm_handle.dart';
import 'results_handle.dart';

abstract interface class SetHandle extends HandleBase {
  ResultsHandle get asResults;

  ResultsHandle query(String query, List<Object?> args);

  bool insert(Object? value);

  // TODO: avoid taking the [realm] parameter
  Object? elementAt(Realm realm, int index);
  bool find(Object? value);

  bool remove(Object? value);

  void clear();
  int get size;

  bool get isValid;

  void deleteAll();

  SetHandle? resolveIn(RealmHandle frozenRealm);

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, List<String>? keyPaths, int? classKey);
}
