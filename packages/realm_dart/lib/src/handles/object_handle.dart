// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_class.dart';
import 'handle_base.dart';
import 'list_handle.dart';
import 'map_handle.dart';
import 'notification_token_handle.dart';
import 'realm_handle.dart';
import 'results_handle.dart';
import 'set_handle.dart';

abstract interface class ObjectHandle extends HandleBase {
  ObjectHandle createEmbedded(int propertyKey);
  (ObjectHandle, int) get parent;

  int get classKey;

  bool get isValid;

  Link get asLink;

  // TODO: avoid taking the [realm] parameter
  Object? getValue(Realm realm, int propertyKey);

  // TODO: value should be RealmValue, and perhaps this method should be combined
  // with setCollection?
  void setValue(int propertyKey, Object? value, bool isDefault);
  ListHandle getList(int propertyKey);
  SetHandle getSet(int propertyKey);
  MapHandle getMap(int propertyKey);
  ResultsHandle getBacklinks(int sourceTableKey, int propertyKey);

  void setCollection(Realm realm, int propertyKey, RealmValue value);

  String objectToString();
  void delete();

  ObjectHandle? resolveIn(RealmHandle frozenRealm);

  NotificationTokenHandle subscribeForNotifications(NotificationsController controller, [List<String>? keyPaths]);

  @override
  // equals handled by HandleBase<T>
  // ignore: hash_and_equals
  int get hashCode => asLink.hash;
}

abstract class Link {
  int get targetKey;
  int get classKey;
  int get hash;
}
