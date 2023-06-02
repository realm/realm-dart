////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 Realm Inc.
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
  // timestamp, // Why? Isn't this just a date?
}

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
  bool operator ==(Object other) =>
      identical(this, other) || other is Defined<T> && value == other.value;

  @override
  String toString() => 'Defined<$T>($value)';
}
