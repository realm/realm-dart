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

library;

/// Annotation to mark a class for extended json (ejson) serialization
const ejson = EJson();

/// Annotation to mark a class for extended json (ejson) serialization
class EJson<T> {
  final EJsonEncoder<T>? encoder;
  final EJsonDecoder<T>? decoder;
  const EJson({this.encoder, this.decoder});
}

typedef EJsonDecoder<T> = T Function(EJsonValue ejson);

typedef EJsonEncoder<T> = EJsonValue Function(T object);

// while we wait for
// typedef EJsonValue = Null | String | bool | int | double | List<EJsonValue> | Map<String, EJsonValue>;
typedef EJsonValue = Object?;
