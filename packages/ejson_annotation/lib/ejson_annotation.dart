// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Annotation to mark a class for extended json (ejson) serialization
const ejson = EJson();

/// Annotation to mark a class for extended json (ejson) serialization
class EJson<T> {
  final EJsonEncoder<T>? encoder;
  final EJsonDecoder<T>? decoder;
  const EJson()
      : encoder = null,
        decoder = null;
  const EJson.custom({required EJsonEncoder<T> this.encoder, required EJsonDecoder<T> this.decoder});
}

typedef EJsonDecoder<T> = T Function(EJsonValue ejson);

typedef EJsonEncoder<T> = EJsonValue Function(T object);

// while we wait for
// typedef EJsonValue = Null | String | bool | int | double | List<EJsonValue> | Map<String, EJsonValue>;
typedef EJsonValue = Object?;
