// Copyright 2022 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import '../realm.dart';
import 'handles/session_handle.dart';
import 'user.dart';

/// An object encapsulating a synchronization session. Sessions represent the
/// communication between the client (and a local Realm file on disk), and the
/// server. Sessions are always created by the SDK and vended out through various
/// APIs. The lifespans of sessions associated with Realms are managed automatically.
/// {@category Sync}
class Session {
  final SessionHandle _handle;

  /// The on-disk path of the file backing the [Realm] this [Session] represents
  String get realmPath => handle.path;

  /// The session’s current state. This is different from [connectionState] since a
  /// session may be active, even if the connection is disconnected (e.g. due to the device
  /// being offline).
  SessionState get state => handle.state;

  /// The session’s current connection state. This is the physical state of the connection
  /// and is different from the session's logical state, which is returned by [state].
  ConnectionState get connectionState => handle.connectionState;

  /// The [User] that owns the [Realm] this [Session] is synchronizing.
  User get user => UserInternal.create(handle.user);

  Session._(this._handle);

  /// Pauses any synchronization with the server until the Realm is re-opened again
  /// after fully closing it or [resume] is called.
  void pause() => handle.pause();

  /// Attempts to resume the session and enable synchronization with the server.
  /// All sessions are active by default and calling this method is only necessary
  /// if [pause] was called previously.
  void resume() => handle.resume();

  /// Waits for the [Session] to finish all pending uploads.
  /// An optional [cancellationToken] can be used to cancel the wait operation.
  Future<void> waitForUpload([CancellationToken? cancellationToken]) => handle.waitForUpload(cancellationToken);

  /// Waits for the [Session] to finish all pending downloads.
  /// An optional [cancellationToken] can be used to cancel the wait operation.
  Future<void> waitForDownload([CancellationToken? cancellationToken]) => handle.waitForDownload(cancellationToken);

  /// Gets a [Stream] of [SyncProgress] that can be used to track upload or download progress.
  Stream<SyncProgress> getProgressStream(ProgressDirection direction, ProgressMode mode) {
    final controller = SessionProgressNotificationsController(this, direction, mode);
    return controller.createStream();
  }

  /// Gets a [Stream] of [ConnectionState] that can be used to be notified whenever the
  /// connection state changes.
  Stream<ConnectionStateChange> get connectionStateChanges {
    final controller = SessionConnectionStateController(this);
    return controller.createStream();
  }
}

/// A type containing information about the progress state at a given instant.
class SyncProgress {
  /// A value between 0.0 and 1.0 representing the estimated transfer progress. This value is precise for
  /// uploads, but will be based on historical data and certain heuristics applied by the server for downloads.
  ///
  /// Whenever the progress reporting mode is [ProgressMode.forCurrentlyOutstandingWork], that value
  /// will monotonically increase until it reaches 1.0. If the progress mode is [ProgressMode.reportIndefinitely], the
  /// value may either increase or decrease as new data needs to be transferred.
  final double progressEstimate;

  const SyncProgress._({required this.progressEstimate});

  static double _calculateProgress({required int transferred, required int transferable}) {
    if (transferable == 0 || transferred > transferable) {
      return 1;
    }

    return transferred / transferable;
  }
}

/// A type containing information about the transition of a connection state from one value to another.
class ConnectionStateChange {
  /// The connection state before the transition.
  final ConnectionState previous;

  /// The current connection state of the session.
  final ConnectionState current;

  ConnectionStateChange._(this.previous, this.current);
}

extension SessionInternal on Session {
  static Session create(SessionHandle handle) => Session._(handle);

  SessionHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access a Session that belongs to a closed Realm');
    }

    return _handle;
  }

  void raiseError(int errorCode, bool isFatal) => handle.raiseError(errorCode, isFatal);

  static SyncProgress createSyncProgress(int transferredBytes, int transferableBytes) =>
      SyncProgress._(progressEstimate: SyncProgress._calculateProgress(transferred: transferredBytes, transferable: transferableBytes));
}

abstract interface class ProgressNotificationsController {
  void onProgress(int transferredBytes, int transferableBytes);
}

/// @nodoc
class SessionProgressNotificationsController implements ProgressNotificationsController {
  final Session _session;
  final ProgressDirection _direction;
  final ProgressMode _mode;

  SyncSessionNotificationTokenHandle? _tokenHandle;
  late final StreamController<SyncProgress> _streamController;

  SessionProgressNotificationsController(this._session, this._direction, this._mode);

  Stream<SyncProgress> createStream() {
    _streamController = StreamController<SyncProgress>(onListen: _start, onCancel: _stop);
    return _streamController.stream;
  }

  @override
  void onProgress(int transferredBytes, int transferableBytes) {
    _streamController.add(SyncProgress._(progressEstimate: SyncProgress._calculateProgress(transferred: transferredBytes, transferable: transferableBytes)));

    if (transferredBytes >= transferableBytes && _mode == ProgressMode.forCurrentlyOutstandingWork) {
      _streamController.close();
    }
  }

  void _start() {
    if (_tokenHandle != null) {
      throw RealmStateError("Session progress subscription already started.");
    }
    _tokenHandle = _session.handle.subscribeForProgressNotifications(_direction, _mode, this);
  }

  void _stop() {
    _tokenHandle?.release();
    _tokenHandle = null;
  }
}

/// @nodoc
class SessionConnectionStateController {
  final Session _session;
  late final StreamController<ConnectionStateChange> _streamController;
  SyncSessionNotificationTokenHandle? _token;

  SessionConnectionStateController(this._session);

  Stream<ConnectionStateChange> createStream() {
    _streamController = StreamController<ConnectionStateChange>(onListen: _start, onCancel: _stop);
    return _streamController.stream;
  }

  void onConnectionStateChange(ConnectionState oldState, ConnectionState newState) {
    _streamController.add(ConnectionStateChange._(oldState, newState));
  }

  void _start() {
    if (_token != null) {
      throw RealmStateError("Session connection state subscription already started");
    }
    _token = _session.handle.subscribeForConnectionStateNotifications(this);
  }

  void _stop() {
    _token?.release();
    _token = null;
  }
}

/// The current state of a [Session] object
enum SessionState {
  /// The session is connected to  MongoDB Atlas and is actively transferring data.
  active,

  /// The session is not currently communicating with the server.
  inactive,
}

/// The current connection state of a [Session] object
enum ConnectionState {
  /// The session is disconnected from MongoDB Atlas.
  disconnected,

  /// The session is connecting to MongoDB Atlas.
  connecting,

  /// The session is connected to MongoDB Atlas.
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

/// Error code enumeration, indicating the type of [SyncError].
enum SyncErrorCode {
  /// Unrecognized error code. It usually indicates incompatibility between the App Services server and client SDK versions.
  runtimeError,

  /// The partition value specified by the user is not valid - i.e. its the wrong type or is encoded incorrectly.
  badPartitionValue,

  /// A fundamental invariant in the communication between the client and the server was not upheld. This typically indicates
  /// a bug in the synchronization layer and should be reported at https://github.com/realm/realm-core/issues.
  protocolInvariantFailed,

  /// The changeset is invalid.
  badChangeset,

  /// The client attempted to create a subscription for a query is invalid/malformed.
  invalidSubscriptionQuery,

  /// A client reset has occurred. This error code will only be reported via a [ClientResetError] and only
  /// in the case manual client reset handling is required - either via [ManualRecoveryHandler] or when
  /// `onManualReset` is invoked on one of the automatic client reset handlers.
  clientReset,

  /// The client attempted to upload an invalid schema change - either an additive schema change
  /// when developer mode is <c>off</c> or a destructive schema change.
  invalidSchemaChange,

  /// Permission to Realm has been denied.
  permissionDenied,

  /// The server permissions for this file have changed since the last time it was used.
  serverPermissionsChanged,

  /// The user for this session doesn't match the user who originally created the file. This can happen
  /// if you explicitly specify the Realm file path in the configuration and you open the Realm first with
  /// user A, then with user B without changing the on-disk path.
  userMismatch,

  /// Client attempted a write that is disallowed by permissions, or modifies an object
  /// outside the current query - this will result in a [CompensatingWriteError].
  writeNotAllowed,

  /// Automatic client reset has failed. This will only be reported via [ClientResetError]
  /// when an automatic client reset handler was used but it failed to perform the client reset operation -
  /// typically due to a breaking schema change in the server schema or due to an exception occurring in the
  /// before or after client reset callbacks.
  autoClientResetFailed,

  /// The wrong sync type was used to connect to the server. This means that you're trying to connect
  /// to an app configured to use partition sync.
  wrongSyncType,

  /// Client attempted a write that is disallowed by permissions, or modifies an
  /// object outside the current query, and the server undid the modification.
  compensatingWrite;
}
