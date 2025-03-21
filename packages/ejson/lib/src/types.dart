// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

enum EJsonType {
  array,
  binary,
  boolean,
  databaseRef,
  date, // use this instead of timestamp
  decimal128,
  document,
  double,
  int32,
  int64,
  maxKey,
  minKey,
  nil, // aka. null
  objectId,
  string,
  symbol,
  undefined,
  // TODO: The following is not supported yet
  // code,
  // codeWithScope,
  // databasePointer, // deprecated
  // regularExpression,
  // timestamp, // This is not what you think, see https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-Timestamp
}

/// See [MaxKey](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-MaxKey)
/// and [MinKey](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-MinKey)
enum BsonKey { min, max }

/// See [DBRef](https://github.com/mongodb/specifications/blob/master/source/dbref.md)
/// This is not technically a BSON type, but a common convention.
final class DBRef<KeyT> {
  // Do we need to support the database name?
  final String collection;
  final KeyT id;

  const DBRef(this.collection, this.id);

  @override
  int get hashCode => Object.hash(collection, id);

  @override
  bool operator ==(Object other) => other is DBRef<KeyT> && collection == other.collection && id == other.id;
}

sealed class UndefinedOr<T> {
  const UndefinedOr();
}

final class Undefined<T> extends UndefinedOr<T> {
  const Undefined();

  @override
  int get hashCode => (Undefined<Object?>).hashCode;

  @override
  operator ==(Object other) => other is Undefined<Object?>;

  @override
  String toString() => 'Undefined<$T>()';
}

const undefined = Undefined<dynamic>();

final class Defined<T> extends UndefinedOr<T> {
  final T value;

  const Defined(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Defined<T> && value == other.value;

  @override
  String toString() => 'Defined<$T>($value)';
}
