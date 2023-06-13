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

Type _typeOf<T>() => T;

/// @nodoc
class Mapping<T> {
  const Mapping({this.indexable = false, this.canBePrimaryKey = false});

  final bool indexable;
  final bool canBePrimaryKey;

  // Types
  Type get type => T;
  Type get nullableType => _typeOf<T?>();
}

const _intMapping = Mapping<int>(indexable: true, canBePrimaryKey: true);
const _boolMapping = Mapping<bool>(indexable: true);

/// All supported `Realm` property types.
/// {@category Configuration}
enum RealmPropertyType {
  int(_intMapping),
  bool(_boolMapping),
  string(Mapping<String>(indexable: true, canBePrimaryKey: true)),
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
  objectid(Mapping<ObjectId>(indexable: true, canBePrimaryKey: true)),
  _16, // ignore: unused_field, constant_identifier_names
  uuid(Mapping<Uuid>(indexable: true, canBePrimaryKey: true));

  const RealmPropertyType([this.mapping = const Mapping<Never>()]);

  final Mapping<dynamic> mapping;
}

/// Describes the indexing mode for properties annotated with the @Indexed annotation.
enum RealmIndexType {
  /// Describes an index with no special capabilities. This type of index is
  /// suitable for equality searches as well as comparison operations for numeric values.
  regular,

  /// Describes a Full-Text index on a string property.
  ///
  /// The full-text index currently support this set of features:
  /// * Only token or word search, e.g. `query("bio TEXT \$0", "computer dancing")`
  ///   will find all objects that contains the words `computer` and `dancing` in their `bio` property
  /// * Tokens are diacritics- and case-insensitive, e.g. `query("bio TEXT \$0", "cafe dancing")`
  ///   and `query("bio TEXT \$0", "café DANCING")` will return the same set of matches.
  /// * Ignoring results with certain tokens is done using `-`, e.g. `query("bio TEXT \$0", "computer -dancing")`
  ///   will find all objects that contain `computer` but not `dancing`.
  /// * Tokens only consist of alphanumerical characters from ASCII and the Latin-1 supplement. All other characters
  ///   are considered whitespace. In particular words using `-` like `full-text` are split into two tokens.
  ///
  /// Note the following constraints before using full-text search:
  /// * Token prefix or suffix search like `query("bio TEXT \$0", "comp* *cing")` is not supported.
  /// * Only ASCII and Latin-1 alphanumerical chars are included in the index (most western languages).
  /// * Only boolean match is supported, i.e. "found" or "not found". It is not possible to sort results by "relevance".
  fullText
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
abstract class Decimal128 {}

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
  const RealmValue.uint8List(Uint8List binary) : this._(binary);

  /// Will throw [ArgumentError]
  factory RealmValue.from(Object? object) {
    if (object == null ||
        object is bool ||
        object is String ||
        object is int ||
        object is Float ||
        object is double ||
        object is RealmObjectMarker ||
        object is DateTime ||
        object is ObjectId ||
        object is Decimal128 ||
        object is Uuid ||
        object is Uint8List) {
      return RealmValue._(object);
    } else {
      throw ArgumentError.value(object, 'object', 'Unsupported type');
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
