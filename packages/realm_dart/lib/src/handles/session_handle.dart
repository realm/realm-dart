// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:cancellation_token/cancellation_token.dart';

import '../session.dart';
import 'handle_base.dart';
import 'user_handle.dart';

abstract interface class SessionHandle extends HandleBase {
  String get path;
  ConnectionState get connectionState;

  UserHandle get user;

  SessionState get state;

  void pause();

  void resume();

  void raiseError(int errorCode, bool isFatal);

  Future<void> waitForUpload([CancellationToken? cancellationToken]);
  Future<void> waitForDownload([CancellationToken? cancellationToken]);
  SyncSessionNotificationTokenHandle subscribeForConnectionStateNotifications(SessionConnectionStateController controller);

  SyncSessionNotificationTokenHandle subscribeForProgressNotifications(
    ProgressDirection direction,
    ProgressMode mode,
    SessionProgressNotificationsController controller,
  );
}

abstract interface class SyncSessionNotificationTokenHandle extends HandleBase {}