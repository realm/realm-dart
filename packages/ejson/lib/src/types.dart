// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

enum EJsonType {
  array,
  binary,
  boolean,
  date,
  decimal128,
  document,
  double,
  int32,
  int64,
  maxKey,
  minKey,
  objectId,
  string,
  symbol,
  nil, // aka. null
  undefined,
  // TODO: The following is not supported yet
  // code,
  // codeWithScope,
  // databasePointer,
  // databaseRef,
  // regularExpression,
  // timestamp, // This is not what you think, see https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-Timestamp
}

/// See [MaxKey](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-MaxKey)
/// and [MinKey](https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/#mongodb-bsontype-MinKey)
enum Key { min, max }

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

const undefined = Undefined();

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
