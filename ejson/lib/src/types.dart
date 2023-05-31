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

// while we wait for
// typedef EJsonValue = Null | String | bool | int | double | List<EJsonValue> | Map<String, EJsonValue>;
typedef EJsonValue = Object?;

enum Key { min, max }

sealed class UndefinedOr<T> {
  const UndefinedOr();
}

final class Defined<T> extends UndefinedOr<T> {
  final T value;

  const Defined(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Defined<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Defined<$T>($value)';
}

final class Undefined<T> extends UndefinedOr<T> {
  const Undefined();

  @override
  operator ==(Object other) => other is Undefined<Object?>;

  @override
  String toString() => 'Undefined<$T>()';

  @override
  int get hashCode => (Undefined<Object?>).hashCode;
}

const undefined = Undefined();
