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
import 'dart:ffi';
import '../realm.dart';
import 'native/realm_core.dart';
import 'user.dart';

/// An object encapsulating a synchronization session. Sessions represent the
/// communication between the client (and a local Realm file on disk), and the
/// server. Sessions are always created by the SDK and vended out through various
/// APIs. The lifespans of sessions associated with Realms are managed automatically.
/// {@category Sync}
class Session implements Finalizable {
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
  Future<void> waitForDownload([CancellationToken? cancellationToken]) => realmCore.sessionWaitForDownload(this, cancellationToken);

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

  void _raiseSessionError(SyncErrorCode errorCode, bool isFatal) {
    realmCore.raiseError(this, errorCode.code, isFatal);
  }
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

  const SyncProgress({required this.transferredBytes, required this.transferableBytes});
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
  @pragma('vm:never-inline')
  void keepAlive() {
    _handle.keepAlive();
  }

  static Session create(SessionHandle handle) => Session._(handle);

  SessionHandle get handle {
    if (_handle.released) {
      throw RealmClosedError('Cannot access a Session that belongs to a closed Realm');
    }

    return _handle;
  }

  void raiseError(SyncErrorCode errorCode, bool isFatal) {
    realmCore.raiseError(this, errorCode.code, isFatal);
  }

  static SyncProgress createSyncProgress(int transferredBytes, int transferableBytes) =>
      SyncProgress(transferredBytes: transferredBytes, transferableBytes: transferableBytes);
}

abstract interface class ProgressNotificationsController {
  void onProgress(int transferredBytes, int transferableBytes);
}

/// @nodoc
class SessionProgressNotificationsController implements ProgressNotificationsController {
  final Session _session;
  final ProgressDirection _direction;
  final ProgressMode _mode;

  RealmSyncSessionConnectionStateNotificationTokenHandle? _tokenHandle;
  late final StreamController<SyncProgress> _streamController;

  SessionProgressNotificationsController(this._session, this._direction, this._mode);

  Stream<SyncProgress> createStream() {
    _streamController = StreamController<SyncProgress>(onListen: _start, onCancel: _stop);
    return _streamController.stream;
  }

  @override
  void onProgress(int transferredBytes, int transferableBytes) {
    _streamController.add(SyncProgress(transferredBytes: transferredBytes, transferableBytes: transferableBytes));

    if (transferredBytes >= transferableBytes && _mode == ProgressMode.forCurrentlyOutstandingWork) {
      _streamController.close();
    }
  }

  void _start() {
    if (_tokenHandle != null) {
      throw RealmStateError("Session progress subscription already started.");
    }
    _tokenHandle = realmCore.sessionRegisterProgressNotifier(_session, _direction, _mode, this);
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
  RealmSyncSessionConnectionStateNotificationTokenHandle? _token;

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
    _token = realmCore.sessionRegisterConnectionStateNotifier(_session, this);
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

/// The category of a [SyncError].
@Deprecated("There are no more error categories for sync errors")
enum SyncErrorCategory {
  /// The error originated from the client
  client,

  /// The error originated from the connection
  connection,

  /// The error originated from the session
  session,

  /// Web socket error
  webSocket,

  /// Another low-level system error occurred
  system,

  /// The category is unknown
  unknown,
}

/// Protocol errors discovered by the client.
///
/// These errors will terminate the network connection
/// (disconnect all sessions  associated with the affected connection),
/// and the error will be reported via the connection state change listeners of the affected sessions.
@Deprecated("Use SyncErrorCode enum instead")
enum SyncClientErrorCode {
  /// Connection closed (no error)
  connectionClosed(100),

  /// Unknown type of input message
  unknownMessage(101),

  /// Bad syntax in input message head
  badSyntax(102),

  /// Limits exceeded in input message
  limitsExceeded(103),

  /// Bad session identifier in input message
  badSessionIdent(104),

  /// Bad input message order
  badMessageOrder(105),

  /// Bad client file identifier (IDENT)
  badClientFileIdent(106),

  /// Bad progress information (DOWNLOAD)
  badProgress(107),

  /// Bad syntax in changeset header (DOWNLOAD)
  badChangesetHeaderSyntax(108),

  /// Bad changeset size in changeset header (DOWNLOAD)
  badChangesetSize(109),

  /// Bad origin file identifier in changeset header (DOWNLOAD)
  badOriginFileIdent(110),

  /// Bad server version in changeset header (DOWNLOAD)
  badServerVersion(111),

  /// Bad changeset (DOWNLOAD)
  badChangeset(112),

  /// Bad request identifier (MARK)
  badRequestIdent(113),

  /// Bad error code (ERROR),
  badErrorCode(114),

  /// Bad compression (DOWNLOAD)
  badCompression(115),

  /// Bad last integrated client version in changeset header (DOWNLOAD)
  badClientVersion(116),

  /// SSL server certificate rejected
  sslServerCertRejected(117),

  /// Timeout on reception of PONG respone message
  pongTimeout(118),

  /// Bad client file identifier salt (IDENT)
  badClientFileIdentSalt(119),

  /// Bad file identifier (ALLOC)
  badFileIdent(120),

  /// Sync connection was not fully established in time
  connectTimeout(121),

  /// Bad timestamp (PONG)
  badTimestamp(122),

  /// Bad or missing protocol version information from server
  badProtocolFromServer(123),

  /// Protocol version negotiation failed: Client is too old for server
  clientTooOldForServer(124),

  /// Protocol version negotiation failed: Client is too new for server
  clientTooNewForServer(125),

  /// Protocol version negotiation failed: No version supported by both client and server
  protocolMismatch(126),

  /// Bad values in state message (STATE)
  badStateMessage(127),

  /// Requested feature missing in negotiated protocol version
  missingProtocolFeature(128),

  /// Failed to establish HTTP tunnel with configured proxy
  httpTunnelFailed(131),

  /// A fatal error was encountered which prevents completion of a client reset
  autoClientResetFailure(132),

  /// Unknown Sync client error code
  unknown(9999);

  static final Map<int, SyncClientErrorCode> _valuesMap = {for (var value in SyncClientErrorCode.values) value.code: value};

  static SyncClientErrorCode fromInt(int code) {
    return SyncClientErrorCode._valuesMap[code] ?? SyncClientErrorCode.unknown;
  }

  final int code;

  const SyncClientErrorCode(this.code);
}

/// Protocol connection errors discovered by the server, and reported to the client
///
/// These errors will be reported via the error handlers of the affected sessions.
@Deprecated("Use SyncErrorCode enum instead")
enum SyncConnectionErrorCode {
  // Connection level and protocol errors
  /// Connection closed (no error)
  connectionClosed(100),

  /// Other connection level error
  otherError(101),

  /// Unknown type of input message
  unknownMessage(102),

  /// Bad syntax in input message head
  badSyntax(103),

  /// Limits exceeded in input message
  limitsExceeded(104),

  /// Wrong protocol version (CLIENT) (obsolete)
  wrongProtocolVersion(105),

  /// Bad session identifier in input message
  badSessionIdent(106),

  /// Overlapping reuse of session identifier (BIND)
  reuseOfSessionIdent(107),

  /// Client file bound in other session (IDENT)
  boundInOtherSession(108),

  /// Bad input message order
  badMessageOrder(109),

  /// Error in decompression (UPLOAD)
  badDecompression(110),

  /// Bad syntax in a changeset header (UPLOAD)
  badChangesetHeaderSyntax(111),

  /// Bad size specified in changeset header (UPLOAD)
  badChangesetSize(112),

  /// Connected with wrong wire protocol - should switch to FLX sync
  switchToFlxSync(113),

  /// Connected with wrong wire protocol - should switch to PBS
  switchToPbs(114),

  /// Unknown Sync connection error code
  unknown(9999);

  static final Map<int, SyncConnectionErrorCode> _valuesMap = {for (var value in SyncConnectionErrorCode.values) value.code: value};

  static SyncConnectionErrorCode fromInt(int code) {
    return SyncConnectionErrorCode._valuesMap[code] ?? SyncConnectionErrorCode.unknown;
  }

  final int code;
  const SyncConnectionErrorCode(this.code);
}

/// Protocol session errors discovered by the server, and reported to the client
///
/// These errors will be reported via the error handlers of the affected sessions.
@Deprecated("Use SyncErrorCode enum instead")
enum SyncSessionErrorCode {
  /// Session closed (no error)
  sessionClosed(200),

  /// Other session level error
  otherSessionError(201),

  /// Access token expired
  tokenExpired(202),

  /// Bad user authentication (BIND)
  badAuthentication(203),

  /// Illegal Realm path (BIND)
  illegalRealmPath(204),

  /// No such Realm (BIND)
  noSuchRealm(205),

  /// Permission denied (BIND)
  permissionDenied(206),

  /// Bad server file identifier (IDENT) (obsolete!)
  badServerFileIdent(207),

  /// Bad client file identifier (IDENT)
  badClientFileIdent(208),

  /// Bad server version (IDENT, UPLOAD, TRANSACT)
  badServerVersion(209),

  /// Bad client version (IDENT, UPLOAD)
  badClientVersion(210),

  /// Diverging histories (IDENT)
  divergingHistories(211),

  /// Bad changeset (UPLOAD)
  badChangeset(212),

  /// Partial sync disabled (BIND)
  partialSyncDisabled(214),

  /// Unsupported session-level feature
  unsupportedSessionFeature(215),

  /// Bad origin file identifier (UPLOAD)
  badOriginFileIdent(216),

  /// Synchronization no longer possible for client-side file
  badClientFile(217),

  /// Server file was deleted while session was bound to it
  serverFileDeleted(218),

  /// Client file has been blacklisted (IDENT)
  clientFileBlacklisted(219),

  /// User has been blacklisted (BIND)
  userBlacklisted(220),

  /// Serialized transaction before upload completion
  transactBeforeUpload(221),

  /// Client file has expired
  clientFileExpired(222),

  /// User mismatch for client file identifier (IDENT)
  userMismatch(223),

  /// Too many sessions in connection (BIND)
  tooManySessions(224),

  /// Invalid schema change (UPLOAD)
  invalidSchemaChange(225),

  /// Client query is invalid/malformed (IDENT, QUERY)
  badQuery(226),

  /// Client tried to create an object that already exists outside their (()UPLOAD)
  objectAlreadyExists(227),

  /// Server permissions for this file ident have changed since the last time it (used) (IDENT)
  serverPermissionsChanged(228),

  /// Client tried to open a session before initial sync is complete (BIND)
  initialSyncNotCompleted(229),

  /// Client attempted a write that is disallowed by permissions, or modifies an object
  /// outside the current query - requires client reset (UPLOAD)
  writeNotAllowed(230),

  /// Client attempted a write that is disallowed by permissions, or modifies an object
  /// outside the current query, and the server undid the modification (UPLOAD)
  compensatingWrite(231),

  /// Bad progress information (ERROR)
  sessionBadProgress(233),

  /// Unknown Sync session error code
  unknown(9999);

  static final Map<int, SyncSessionErrorCode> _valuesMap = {for (var value in SyncSessionErrorCode.values) value.code: value};

  static SyncSessionErrorCode fromInt(int code) {
    return SyncSessionErrorCode._valuesMap[code] ?? SyncSessionErrorCode.unknown;
  }

  final int code;
  const SyncSessionErrorCode(this.code);
}

/// Web socket errors.
///
/// These errors will be reported via the error handlers of the affected sessions.
@Deprecated("Use SyncErrorCode instead")
enum SyncWebSocketErrorCode {
  /// Web socket resolution failed
  websocketResolveFailed(4400),

  /// Web socket connection closed by the client
  websocketConnectionClosedClient(4401),

  /// Web socket connection closed by the server
  websocketConnectionClosedServer(4402),

  /// Unknown resolve errors
  unknown(9999);

  static final Map<int, SyncWebSocketErrorCode> _valuesMap = {for (var value in SyncWebSocketErrorCode.values) value.code: value};

  static SyncWebSocketErrorCode fromInt(int code) {
    return SyncWebSocketErrorCode._valuesMap[code] ?? SyncWebSocketErrorCode.unknown;
  }

  final int code;
  const SyncWebSocketErrorCode(this.code);
}

enum SyncErrorCode {
  /// Connection closed by the server
  connectionClosed(ErrorCodesConstants.connectionClosed),

  invariantFailed(ErrorCodesConstants.syncProtocolInvariantFailed),
  negotiationFailed(ErrorCodesConstants.syncProtocolNegotiationFailed),

  /// Bad changeset (UPLOAD)
  badChangeset(ErrorCodesConstants.badChangeset),

  /// SSL server certificate rejected
  sslServerCertRejected(ErrorCodesConstants.tlsHandshakeFailed),

  /// Sync connection was not fully established in time
  connectTimeout(ErrorCodesConstants.syncConnectFailed),

  /// A fatal error was encountered which prevents completion of a client reset
  autoClientResetFailure(ErrorCodesConstants.autoClientResetFailed),

  /// Connected with wrong wire protocol - should switch to FLX sync
  switchToFlxSync(ErrorCodesConstants.wrongSyncType),

  runtimeError(ErrorCodesConstants.runtimeError),

  /// Illegal Realm path (BIND)
  illegalRealmPath(ErrorCodesConstants.badSyncPartitionValue),

  /// Illegal Realm path (BIND)
  permissionDenied(ErrorCodesConstants.syncPermissionDenied),
  syncClientResetRequired(ErrorCodesConstants.syncClientResetRequired),

  /// User mismatch for client file identifier (IDENT)
  userMismatch(ErrorCodesConstants.syncUserMismatch),

  /// Invalid schema change (UPLOAD)
  invalidSchemaChange(ErrorCodesConstants.syncInvalidSchemaChange),

  /// Client query is invalid/malformed (IDENT, QUERY)
  badQuery(ErrorCodesConstants.invalidSubscriptionQuery),

  /// Client tried to create an object that already exists outside their (()UPLOAD)
  objectAlreadyExists(ErrorCodesConstants.objectAlreadyExists),

  /// Server permissions for this file ident have changed since the last time it (used) (IDENT)
  serverPermissionsChanged(ErrorCodesConstants.syncServerPermissionsChanged),

  /// Client attempted a write that is disallowed by permissions, or modifies an object
  /// outside the current query - requires client reset (UPLOAD)
  writeNotAllowed(ErrorCodesConstants.syncWriteNotAllowed),

  /// Client attempted a write that is disallowed by permissions, or modifies an object
  /// outside the current query, and the server undid the modification (UPLOAD)
  compensatingWrite(ErrorCodesConstants.syncCompensatingWrite),

  /// Unknown Sync client error code
  unknown(9999);

  static final Map<int, SyncErrorCode> _valuesMap = {for (var value in SyncErrorCode.values) value.code: value};

  static SyncErrorCode fromInt(int code) {
    return SyncErrorCode._valuesMap[code] ?? SyncErrorCode.unknown;
  }

  final int code;

  const SyncErrorCode(this.code);
}
