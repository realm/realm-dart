////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

import 'dart:ffi';
import 'dart:typed_data';
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';

/// All supported `Realm` property types.
/// {@category Configuration}
enum RealmPropertyType {
  int,
  bool,
  string,
  // ignore: unused_field, constant_identifier_names
  _3,
  binary,
  // ignore: unused_field, constant_identifier_names
  _5,
  mixed,
  // ignore: unused_field, constant_identifier_names
  _7,
  timestamp,
  float,
  double,
  decimal128,
  object,
  // ignore: unused_field, constant_identifier_names
  _13,
  linkingObjects,
  objectid,
  // ignore: unused_field, constant_identifier_names
  _16,
  uuid,
}

/// All supported `Realm` collection types.
/// {@category Configuration}
enum RealmCollectionType {
  none,
  list,
  set,
  dictionary,
}

/// A base class of all Realm errors.
/// {@category Realm}
class RealmError extends Error {
  final String? message;
  RealmError(String this.message);

  @override
  String toString() => "Realm error : $message";
}

/// Thrown if the operation is not supported.
/// {@category Realm}
class RealmUnsupportedSetError extends UnsupportedError implements RealmError {
  RealmUnsupportedSetError() : super('Cannot set late final field on realm object');
}

/// Thrown if the Realm operation is not allowed by the current state of the object.
class RealmStateError extends StateError implements RealmError {
  RealmStateError(super.message);
}
/// @nodoc
class Decimal128 {} // TODO Support decimal128 datatype https://github.com/realm/realm-dart/issues/725

/// @nodoc
class RealmObjectMarker {}

// Union type
/// @nodoc
class RealmAny {
  final dynamic value;
  T as<T>() => value as T; // better for code completion

  // This is private, so user cannot accidentally construct an invalid instance
  const RealmAny._(this.value);

  const RealmAny.bool(bool b) : this._(b);
  const RealmAny.string(String text) : this._(text);
  const RealmAny.int(int i) : this._(i);
  const RealmAny.float(Float f) : this._(f);
  const RealmAny.double(double d) : this._(d);
  const RealmAny.uint8List(Uint8List data) : this._(data);
  // TODO: RealmObjectMarker introduced to avoid dependency inversion.
  // It would be better if we could use RealmObject directly
  // https://github.com/realm/realm-dart/issues/701
  const RealmAny.realmObject(RealmObjectMarker o) : this._(o);
  const RealmAny.dateTime(DateTime timestamp) : this._(timestamp);
  const RealmAny.objectId(ObjectId id) : this._(id);
  const RealmAny.decimal128(Decimal128 decimal) : this._(decimal);
  const RealmAny.uuid(Uuid uuid) : this._(uuid);
}

/// Thrown when an error occurs during synchronization
/// {@category Sync}
class SyncError extends RealmError {
  /// The numeric code value indicating the type of the sync error.
  final int codeValue;

  /// The category of the sync error
  final SyncErrorCategory category;

  SyncError(String message, this.category, this.codeValue) : super(message);

  /// Creates a specific type of [SyncError] instance based on the [category] and the [code] supplied.
  static SyncError create(String message, SyncErrorCategory category, int code, {bool isFatal = false}) {
    switch (category) {
      case SyncErrorCategory.client:
        final SyncClientErrorCode errorCode = SyncClientErrorCode.fromInt(code);
        if (errorCode == SyncClientErrorCode.autoClientResetFailure) {
          return SyncClientResetError(message);
        }
        return SyncClientError(message, category, errorCode, isFatal: isFatal);
      case SyncErrorCategory.connection:
        return SyncConnectionError(message, category, SyncConnectionErrorCode.fromInt(code), isFatal: isFatal);
      case SyncErrorCategory.session:
        return SyncSessionError(message, category, SyncSessionErrorCode.fromInt(code), isFatal: isFatal);
      case SyncErrorCategory.system:
      case SyncErrorCategory.unknown:
      default:
        return GeneralSyncError(message, category, code);
    }
  }

  /// As a specific [SyncError] type.
  T as<T extends SyncError>() => this as T;

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $codeValue";
  }
}

/// An error type that describes a session-level error condition.
/// {@category Sync}
class SyncClientError extends SyncError {
  /// If true the received error is fatal.
  final bool isFatal;

  /// The [SyncClientErrorCode] value indicating the type of the sync error.
  SyncClientErrorCode get code => SyncClientErrorCode.fromInt(codeValue);

  SyncClientError(
    String message,
    SyncErrorCategory category,
    SyncClientErrorCode errorCode, {
    this.isFatal = false,
  }) : super(message, category, errorCode.code);

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $code isFatal: $isFatal";
  }
}

/// An error type that describes a client reset error condition.
/// {@category Sync}
class SyncClientResetError extends SyncError {
  /// If true the received error is fatal.
  final bool isFatal = true;

  /// The [SyncClientResetError] has error code of [SyncClientErrorCode.autoClientResetFailure]
  SyncClientErrorCode get code => SyncClientErrorCode.autoClientResetFailure;

  SyncClientResetError(String message) : super(message, SyncErrorCategory.client, SyncClientErrorCode.autoClientResetFailure.code);

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $code isFatal: $isFatal";
  }
}

/// An error type that describes a connection-level error condition.
/// {@category Sync}
class SyncConnectionError extends SyncError {
  /// If true the received error is fatal.
  final bool isFatal;

  /// The [SyncConnectionErrorCode] value indicating the type of the sync error.
  SyncConnectionErrorCode get code => SyncConnectionErrorCode.fromInt(codeValue);

  SyncConnectionError(
    String message,
    SyncErrorCategory category,
    SyncConnectionErrorCode errorCode, {
    this.isFatal = false,
  }) : super(message, category, errorCode.code);

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $code isFatal: $isFatal";
  }
}

/// An error type that describes a session-level error condition.
/// {@category Sync}
class SyncSessionError extends SyncError {
  /// If true the received error is fatal.
  final bool isFatal;

  /// The [SyncSessionErrorCode] value indicating the type of the sync error.
  SyncSessionErrorCode get code => SyncSessionErrorCode.fromInt(codeValue);

  SyncSessionError(
    String message,
    SyncErrorCategory category,
    SyncSessionErrorCode errorCode, {
    this.isFatal = false,
  }) : super(message, category, errorCode.code);

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $code isFatal: $isFatal";
  }
}

/// A general or unknown sync error
class GeneralSyncError extends SyncError {
  /// The numeric value indicating the type of the general sync error.
  int get code => codeValue;

  GeneralSyncError(String message, SyncErrorCategory category, int code) : super(message, category, code);

  @override
  String toString() {
    return "SyncError message: $message category: $category code: $code";
  }
}

/// The category of a [SyncError].
enum SyncErrorCategory {
  /// The error originated from the client
  client,

  /// The error originated from the connection
  connection,

  /// The error originated from the session
  session,

  /// Another low-level system error occurred
  system,

  /// The category is unknown
  unknown,
}

/// General sync error codes
enum GeneralSyncErrorCode {
  // A general sync error code
  unknown(9999);

  static final Map<int, GeneralSyncErrorCode> _valuesMap = {for (var value in GeneralSyncErrorCode.values) value.code: value};

  static GeneralSyncErrorCode fromInt(int code) {
    final mappedCode = GeneralSyncErrorCode._valuesMap[code];
    if (mappedCode == null) {
      throw RealmError("Unknown GeneralSyncErrorCode");
    }

    return mappedCode;
  }

  final int code;
  const GeneralSyncErrorCode(this.code);
}

/// Protocol errors discovered by the client.
///
/// These errors will terminate the network connection
/// (disconnect all sessions  associated with the affected connection),
/// and the error will be reported via the connection state change listeners of the affected sessions.
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
  autoClientResetFailure(132);

  static final Map<int, SyncClientErrorCode> _valuesMap = {for (var value in SyncClientErrorCode.values) value.code: value};

  static SyncClientErrorCode fromInt(int code) {
    final mappedCode = SyncClientErrorCode._valuesMap[code];
    if (mappedCode == null) {
      throw RealmError("Unknown SyncClientErrorCode");
    }

    return mappedCode;
  }

  final int code;

  const SyncClientErrorCode(this.code);
}

/// Protocol connection errors discovered by the server, and reported to the client
///
/// These errors will be reported via the error handlers of the affected sessions.
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
  switchToPbs(114);

  static final Map<int, SyncConnectionErrorCode> _valuesMap = {for (var value in SyncConnectionErrorCode.values) value.code: value};

  static SyncConnectionErrorCode fromInt(int code) {
    final mappedCode = SyncConnectionErrorCode._valuesMap[code];
    if (mappedCode == null) {
      throw RealmError("Unknown SyncConnectionErrorCode");
    }

    return mappedCode;
  }

  final int code;
  const SyncConnectionErrorCode(this.code);
}

/// Protocol session errors discovered by the server, and reported to the client
///
/// These errors will be reported via the error handlers of the affected sessions.
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

  /// Client attempted a write that is disallowed by permissions, or modifies an object outside the current query - requires client reset (UPLOAD)
  writeNotAllowed(230);

  static final Map<int, SyncSessionErrorCode> _valuesMap = {for (var value in SyncSessionErrorCode.values) value.code: value};

  static SyncSessionErrorCode fromInt(int code) {
    final mappedCode = SyncSessionErrorCode._valuesMap[code];
    if (mappedCode == null) {
      throw RealmError("Unknown SyncSessionErrorCode");
    }

    return mappedCode;
  }

  final int code;
  const SyncSessionErrorCode(this.code);
}
