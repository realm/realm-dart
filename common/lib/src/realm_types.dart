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

/// @nodoc
abstract class AsymmetricObjectMarker implements RealmObjectBaseMarker {}

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
  static const true_ = RealmValue.bool(true);
  static const false_ = RealmValue.bool(false);
  static const null_ = RealmValue.nullValue();

  final Object? value;
  Type get type => value.runtimeType;
  T as<T>() => value as T; // better for code completion

  List<RealmValue> get asList => as<List<RealmValue>>();
  Map<String, RealmValue> get asDictionary => as<Map<String, RealmValue>>();
  Set<RealmValue> get asSet => as<Set<RealmValue>>();

  T call<T>() => as<T>(); // is this useful?

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
  const RealmValue.dictionary(Map<String, RealmValue> dictionary) : this._(dictionary);
  const RealmValue.list(Iterable<RealmValue> list) : this._(list);
  const RealmValue.set(Set<RealmValue> set) : this._(set);

  static bool _isCollection(Object? value) => value is List<RealmValue> || value is Set<RealmValue> || value is Map<String, RealmValue>;

  /// Will throw [ArgumentError] if the type is not supported
  factory RealmValue.from(Object? object) {
    return switch (object) {
      Object? o
          when o == null ||
              o is bool ||
              o is String ||
              o is int ||
              o is double ||
              o is RealmObjectMarker ||
              o is DateTime ||
              o is ObjectId ||
              o is Decimal128 ||
              o is Uuid ||
              o is Uint8List =>
        RealmValue._(o),
      Map<String, RealmValue> d => RealmValue.dictionary(d),
      Map<String, dynamic> d => RealmValue.dictionary(Map.fromEntries(d.entries.map((e) => MapEntry(e.key, RealmValue.from(e.value))))),
      List<RealmValue> l => RealmValue.list(l),
      List<dynamic> l => RealmValue.list(l.map((o) => RealmValue.from(o)).toList()),
      Set<RealmValue> s => RealmValue.set(s),
      Set<dynamic> s => RealmValue.set(s.map((o) => RealmValue.from(o)).toSet()),
      _ => throw ArgumentError.value(object.runtimeType, 'object', 'Unsupported type'),
    };
  }

  RealmValue operator [](Object? index) {
    final v = value;
    return switch (index) {
          int i when v is List<RealmValue> => v[i], // throws on range error
          String s when v is Map<String, RealmValue> => v[s],
          Iterable<Object?> l when _isCollection(v) => this[l.first][l.skip(1)],
          _ => throw ArgumentError.value(index, 'index', 'Unsupported type'),
        } ??
        const RealmValue.nullValue();
  }

  void operator []=(Object? index, RealmValue value) {
    final v = this.value;
    switch (index) {
      case int i when v is List<RealmValue>:
        v[i] = value;
        break;
      case String s when v is Map<String, RealmValue>:
        v[s] = value;
        break;
      case Iterable<Object?> l when _isCollection(v):
        this[l.first][l.skip(1)] = value;
        break;
      default:
        throw ArgumentError.value(index, 'index', 'Unsupported type');
    }
  }

  RealmValue lookup<T>(T item) {
    final v = value as Set<RealmValue>?;
    if (v == null) throw ArgumentError.value(item, 'item', 'Unsupported type'); // TODO: Wrong exception
    return v.lookup(item) ?? const RealmValue.nullValue();
  }

  bool add<T>(T item) {
    if (_isCollection(item)) throw ArgumentError.value(item, 'item', 'Unsupported type'); // TODO: Wrong exception
    final v = value as Set<RealmValue>?;
    if (v == null) throw ArgumentError.value(item, 'item', 'Unsupported type'); // TODO: Wrong exception
    return v.add(RealmValue.from(item));
  }

  bool remove<T>(T item) {
    final v = value as Set<RealmValue>?;
    if (v == null) throw ArgumentError.value(item, 'item', 'Unsupported type'); // TODO: Wrong exception
    return v.remove(item);
  }

  @override
  operator ==(Object? other) {
    if (identical(this, other)) return true;
    if (other is! RealmValue) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RealmValue($value)';
}

void demo() {
  final any = RealmValue.from([
    1,
    2,
    {
      'x': {1, 2}
    },
  ]);

  if (any[2]['x'].lookup(1) != const RealmValue.nullValue()) {}

  // access list element at index 2,
  // then map element with key 'x',
  // then set element 1, if it exists
  // assuming an int, or null if not found
  final x = any[2]['x'].lookup(1).as<int?>();
  assert(x == 1);

  // or, a bit shorter
  final y = any[2]['x'].lookup(1)<int?>();
  assert(y == 1);

  // or, if you are sure
  int z = any[2]['x'].lookup(1)(); // <-- shortest
  assert(z == 1);

  // or, using a list of indexes
  final u = any[[2, 'x']]();
  assert(u == RealmValue.from({1, 2}));

  // which allows for a different layout
  int v = any[[
    2,
    'x',
  ]]
      .lookup(1)();
  assert(v == 1);

  any[1] = RealmValue.from({'z': 'foo'}); // replace int with a map
  any[2]['x'].add(3); // add an element to the set
  any[2]['x'] = RealmValue.from(1); // replace set with an int
  any[2]['y'] = RealmValue.from(true); // add a new key to the map
}
