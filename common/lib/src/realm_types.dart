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
import 'package:objectid/objectid.dart';
import 'package:sane_uuid/uuid.dart';

Type _typeOf<T>() => T;

/// @nodoc
class Mapping<T> {
  const Mapping({this.indexable = false});

  final bool indexable;

  // Types
  Type get type => T;
  Type get nullableType => _typeOf<T?>();
}

const _intMapping = Mapping<int>(indexable: true);
const _boolMapping = Mapping<bool>(indexable: true);

/// All supported `Realm` property types.
/// {@category Configuration}
enum RealmPropertyType {
  int(_intMapping),
  bool(_boolMapping),
  string(Mapping<String>(indexable: true)),
  _3, // ignore: unused_field, constant_identifier_names
  binary,
  _5, // ignore: unused_field, constant_identifier_names
  mixed(Mapping<RealmValue>(indexable: true)),
  _7, // ignore: unused_field, constant_identifier_names
  timestamp(Mapping<DateTime>(indexable: true)),
  float,
  double,
  decimal128,
  object,
  _13, // ignore: unused_field, constant_identifier_names
  linkingObjects,
  objectid(Mapping<ObjectId>(indexable: true)),
  _16, // ignore: unused_field, constant_identifier_names
  uuid(Mapping<Uuid>(indexable: true));

  const RealmPropertyType([this.mapping = const Mapping<Never>()]);

  final Mapping<dynamic> mapping;
}

/// All supported `Realm` collection types.
/// {@category Configuration}
enum RealmCollectionType {
  none,
  list,
  set,
  _3, // ignore: unused_field, constant_identifier_names
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

/// An error throw when operating on an object that has been closed.
/// {@category Realm}
class RealmClosedError extends RealmError {
  RealmClosedError(String message) : super(message);
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
abstract class RealmObjectBaseMarker {}

/// @nodoc
abstract class RealmObjectMarker implements RealmObjectBaseMarker {}

/// @nodoc
abstract class EmbeddedObjectMarker implements RealmObjectBaseMarker {}

/// A type that can represent any valid realm data type, except collections and embedded objects.
///
/// You can use [RealmValue] to declare fields on realm models, in which case it must be non-nullable,
/// but it can wrap a null-value. List of [RealmValue] (`List<RealmValue>`) are also legal.
///
/// [RealmValue] fields can be [Indexed]
///
/// ```dart
/// @RealmModel()
/// class _AnythingGoes {
///   @Indexed()
///   late RealmValue any;
///   late List<RealmValue> manyAny;
/// }
///
/// void main() {
///   final realm = Realm(Configuration.local([AnythingGoes.schema]));
///   realm.write(() {
///     final something = realm.add(AnythingGoes(any: RealmValue.string('text')));
///     something.manyAny.addAll([
///       null,
///       true,
///       'text',
///       42,
///       3.14,
///     ].map(RealmValue.from));
///   });
/// }
/// ```
class RealmValue {
  final Object? value;
  Type get type => value.runtimeType;
  T as<T>() => value as T; // better for code completion

  // This is private, so user cannot accidentally construct an invalid instance
  const RealmValue._(this.value);

  const RealmValue.nullValue() : this._(null);
  const RealmValue.bool(bool b) : this._(b);
  const RealmValue.string(String text) : this._(text);
  const RealmValue.int(int i) : this._(i);
  const RealmValue.double(double d) : this._(d);
  // TODO: RealmObjectMarker introduced to avoid dependency inversion. It would be better if we could use RealmObject directly. https://github.com/realm/realm-dart/issues/701
  const RealmValue.realmObject(RealmObjectMarker o) : this._(o);
  const RealmValue.dateTime(DateTime timestamp) : this._(timestamp);
  const RealmValue.objectId(ObjectId id) : this._(id);
  // const RealmValue.decimal128(Decimal128 decimal) : this._(decimal); // not supported yet
  const RealmValue.uuid(Uuid uuid) : this._(uuid);

  /// Will throw [ArgumentError]
  factory RealmValue.from(Object? o) {
    if (o == null ||
        o is bool ||
        o is String ||
        o is int ||
        o is Float ||
        o is double ||
        o is RealmObjectMarker ||
        o is DateTime ||
        o is ObjectId ||
        // o is Decimal128 || // not supported yet
        o is Uuid) {
      return RealmValue._(o);
    } else {
      throw ArgumentError.value(o, 'o', 'Unsupported type');
    }
  }

  @override
  operator ==(Object? other) {
    if (other is RealmValue) {
      return value == other.value;
    }
    return value == other;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RealmValue.from($value)';
}

/// The category of a [SyncError].
enum SyncErrorCategory {
  /// The error originated from the client
  client,

  /// The error originated from the connection
  connection,

  /// The error originated from the session
  session,

  /// Network resolution error
  resolve,

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

  /// Unknown Sync session error code
  unknown(9999);

  static final Map<int, SyncSessionErrorCode> _valuesMap = {for (var value in SyncSessionErrorCode.values) value.code: value};

  static SyncSessionErrorCode fromInt(int code) {
    return SyncSessionErrorCode._valuesMap[code] ?? SyncSessionErrorCode.unknown;
  }

  final int code;
  const SyncSessionErrorCode(this.code);
}

/// Protocol network resolution errors.
///
/// These errors will be reported via the error handlers of the affected sessions.
enum SyncResolveErrorCode {
  /// Host not found (authoritative).
  hostNotFound,

  /// Host not found (non-authoritative).
  hostNotFoundTryAgain,

  /// The query is valid but does not have associated address data.
  noData,

  /// A non-recoverable error occurred.
  noRecovery,

  /// The service is not supported for the given socket type.
  serviceNotFound,

  /// The socket type is not supported.
  socketTypeNotSupported,

  /// Unknown resolve errors
  unknown;
}
