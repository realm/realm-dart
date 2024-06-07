// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/src/handles/handle_base.dart';
import 'package:realm_dart/src/handles/notification_token_handle.dart';

import '../realm_class.dart';
import 'object_handle.dart';
import 'realm_handle.dart';

abstract interface class ResultsHandle extends HandleBase {
  ResultsHandle queryResults(String query, List<Object> args);

  int find(Object? value);

  ObjectHandle getObjectAt(int index);

  int get count;

  bool isValid();

  void deleteAll();
  ResultsHandle snapshot();
  ResultsHandle resolveIn(RealmHandle realmHandle);

  Object? elementAt(Realm realm, int index);
  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, List<String>? keyPaths, int? classKey);

  void verifyKeyPath(List<String> keyPaths, int? classKey);
}
