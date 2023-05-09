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
abstract class Decimal128 {} // TODO Support decimal128 datatype https://github.com/realm/realm-dart/issues/725

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
  const RealmValue.decimal128(Decimal128 decimal) : this._(decimal);
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
        o is Decimal128 ||
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
  String toString() => 'RealmValue($value)';
}
