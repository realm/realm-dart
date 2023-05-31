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

/// Annotation to mark a class for extended json (ejson) serialization
const ejson = EJson();

/// Annotation to mark a property to be ignored wrt. ejson serialization
const ignore = Ignore();

/// Annotation to mark a class for extended json (ejson) serialization
class EJson {
  const EJson();
}

/// Annotation to mark a property to be ignored wrt. ejson serialization
class Ignore {
  const Ignore();
}

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
