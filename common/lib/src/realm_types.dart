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

/// Enum with all supported types of properties of realm objects.
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

/// Supported collection types in realm library.
enum RealmCollectionType {
  none,
  list,
  set,
  dictionary,
}

class RealmError extends Error {}

class RealmUnsupportedSetError extends UnsupportedError implements RealmError {
  RealmUnsupportedSetError() : super('Cannot set late final field on realm object');
}

class Uuid {} // TODO!

class ObjectId {} // TODO!

class Decimal128 {} // TODO!

class RealmObjectMarker {}

// Union type
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
