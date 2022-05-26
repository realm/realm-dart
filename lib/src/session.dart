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

import '../realm.dart';
import 'native/realm_core.dart';
import 'user.dart';

/// An object encapsulating a synchronization session. Sessions represent the
/// communication between the client (and a local Realm file on disk), and the
/// server. Sessions are always created by the SDK and vended out through various
/// APIs. The lifespans of sessions associated with Realms are managed automatically.
/// {@category Sync}
class Session {
  final SessionHandle _handle;

  /// The on-disk path of the file backing the [Realm] this [Session] represents
  String get realmPath => realmCore.sessionGetPath(this);

  /// The session’s current state. This is different from [connectionState] since a
  /// session may be active, even if the connection is disconnected (e.g. due to the device
  /// being offline).
  SessionState get state => realmCore.sessionGetState(this);

  /// The session’s current connection state. This is the physical state of the connection
  /// and is different from the session's logical state, which is returned by [state].
  ConnectionState get connectionState => realmCore.sessionGetConnectionState(this);

  /// The [User] that owns the [Realm] this [Session] is synchronizing.
  User get user => UserInternal.create(realmCore.sessionGetUser(this));

  Session._(this._handle);

  /// Pauses any synchronization with the server until the Realm is re-opened again
  /// after fully closing it or [resume] is called.
  void pause() => realmCore.sessionPause(this);

  /// Attempts to resume the session and enable synchronization with the server.
  /// All sessions are active by default and calling this method is only necessary
  /// if [pause] was called previously.
  void resume() => realmCore.sessionResume(this);

  /// Waits for the [Session] to finish all pending uploads.
  Future<void> waitForUpload() => realmCore.sessionWaitForUpload(this);

  /// Waits for the [Session] to finish all pending downloads.
  Future<void> waitForDownload() => realmCore.sessionWaitForDownload(this);

  /// Gets a [Stream] of [SyncProgress] that can be used to track upload or download progress.
  Stream<SyncProgress> getProgressStream(ProgressDirection direction, ProgressMode mode) {
    final controller = SessionProgressNotificationsController(this, direction, mode);
    return controller.createStream();
  }

  void _raiseSessionError(SyncErrorCategory category, int errorCode, bool isFatal) {
    realmCore.raiseError(this, category, errorCode, isFatal);
  }
}

/// The current state of a [Session] object
enum SessionState {
  /// The session is connected to the MongoDB Realm server and is actively transferring data.
  active,

  /// The session is not currently communicating with the server.
  inactive,
}

/// The current connection state of a [Session] object
enum ConnectionState {
  /// The session is disconnected from the MongoDB Realm server.
  disconnected,

  /// The session is connecting to the MongoDB Realm server.
  connecting,

  /// The session is connected to the MongoDB Realm server.
  connected,
}

/// The transfer direction (upload or download) tracked by a given progress notification subscription.
enum ProgressDirection {
  /// Monitors upload progress.
  upload,

  /// Monitors download progress.
  download
}

/// The desired behavior of a progress notification subscription.
enum ProgressMode {
  /// The callback will be called forever, or until it is unregistered by closing the `Stream<SyncProgress>`.
  /// Notifications will always report the latest number of transferred bytes, and the most up-to-date number of
  /// total transferable bytes.
  reportIndefinitely,

  /// The callback will, upon registration, store the total number of bytes to be transferred. When invoked, it will
  /// always report the most up-to-date number of transferable bytes out of that original number of transferable bytes.
  /// When the number of transferred bytes reaches or exceeds the number of transferable bytes, the callback will
  /// be unregistered.
  forCurrentlyOutstandingWork,
}

/// A type containing information about the progress state at a given instant.
class SyncProgress {
  /// The number of bytes that have been transferred since subscribing for progress notifications.
  final int transferredBytes;

  /// The total number of bytes that have to be transferred since subscribing for progress notifications.
  /// The difference between that number and [transferredBytes] gives you the number of bytes not yet
  /// transferred. If the difference is 0, then all changes at the instant the callback fires have been
  /// successfully transferred.
  final int transferableBytes;

  SyncProgress._(this.transferredBytes, this.transferableBytes);
}

extension SessionInternal on Session {
  static Session create(SessionHandle handle) => Session._(handle);

  SessionHandle get handle => _handle;
}

extension SessionDevInternal on Session {
  void raiseSessionError(SyncErrorCategory category, int errorCode, bool isFatal) {
    _raiseSessionError(category, errorCode, isFatal);
  }
}

/// @nodoc
class SessionProgressNotificationsController {
  final Session _session;
  final ProgressDirection _direction;
  final ProgressMode _mode;

  int? _token;
  late final StreamController<SyncProgress> _streamController;

  SessionProgressNotificationsController(this._session, this._direction, this._mode);

  Stream<SyncProgress> createStream() {
    _streamController = StreamController<SyncProgress>.broadcast(onListen: _start, onCancel: _stop);
    return _streamController.stream;
  }

  void onProgress(int transferredBytes, int transferableBytes) {
    _streamController.add(SyncProgress._(transferredBytes, transferableBytes));

    if (transferredBytes >= transferableBytes && _mode == ProgressMode.forCurrentlyOutstandingWork) {
      _streamController.close();
    }
  }

  void _start() {
    if (_token != null) {
      throw RealmStateError("Session progress subscription already started");
    }

    _token = realmCore.sessionRegisterProgressNotifier(_session, _direction, _mode, this);
  }

  void _stop() {
    if (_token == null) {
      return;
    }

    realmCore.sessionUnregisterProgressNotifier(_session, _token!);
    _token = null;
  }
}
