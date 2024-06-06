import 'dart:ffi';

import '../../realm_dart.dart';
import 'collection_changes_handle.dart';
import 'from_native.dart';
import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'rooted_handle.dart';

import '../notification_token_handle.dart' as intf;

class NotificationTokenHandle extends RootedHandleBase<realm_notification_token> implements intf.NotificationTokenHandle {
  NotificationTokenHandle(Pointer<realm_notification_token> pointer, RealmHandle root) : super(root, pointer, 32);
}

void collectionChangeCallback(Pointer<Void> userdata, Pointer<realm_collection_changes> data) {
  final NotificationsController controller = userdata.toObject();

  if (data == nullptr) {
    controller.onError(RealmError("Invalid notifications data received"));
    return;
  }

  try {
    final clonedData = realmLib.realm_clone(data.cast());
    if (clonedData == nullptr) {
      controller.onError(RealmError("Error while cloning notifications data"));
      return;
    }

    final changesHandle = CollectionChangesHandle(clonedData.cast());
    controller.onChanges(changesHandle);
  } catch (e) {
    controller.onError(RealmError("Error handling change notifications. Error: $e"));
  }
}
