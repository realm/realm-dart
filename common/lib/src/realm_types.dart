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

/// An error type that describes a session-level error condition.
/// /// {@category Sync}
class SessionError extends SyncError {
  /// If true the received error is fatal.
  final bool isFatal;

  SessionError(
    String message,
    SyncErrorCategory category, {
    this.isFatal = false,
    int code = 0,
  }) : super(message, category, code);
}

/// Thrown or reporeted if an error occurs during synchronization
/// {@category Sync}
class SyncError extends RealmError {
  /// The code of the error
  final int code; // TODO: this should be an enum

  /// The category of the error
  final SyncErrorCategory category;

  SyncError(super.message, this.category, this.code);
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

/// @nodoc
class Decimal128 {} // TODO!

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
  // TODO: RealmObjectMarker introduced to avoid dependency invertion.
  // It would be better if we could use RealmObject directly
  const RealmAny.realmObject(RealmObjectMarker o) : this._(o);
  const RealmAny.dateTime(DateTime timestamp) : this._(timestamp);
  const RealmAny.objectId(ObjectId id) : this._(id);
  const RealmAny.decimal128(Decimal128 decimal) : this._(decimal);
  const RealmAny.uuid(Uuid uuid) : this._(uuid);
}
