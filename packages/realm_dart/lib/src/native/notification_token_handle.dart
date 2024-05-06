import 'dart:ffi';

import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'rooted_handle.dart';

class NotificationTokenHandle extends RootedHandleBase<realm_notification_token> {
  NotificationTokenHandle(Pointer<realm_notification_token> pointer, RealmHandle root) : super(root, pointer, 32);
}

