// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:type_plus/type_plus.dart';

import 'decoding.dart';
import 'encoding.dart';

/// Register custom EJSON [encoder] and [decoder] for a type [T].
/// The last registered codec pair for a given type [T] will be used.
void register<T>(EJsonEncoder<T> encoder, EJsonDecoder<T> decoder, {Iterable<Type>? superTypes}) {
  TypePlus.add<T>(superTypes: superTypes);
  customEncoders[T] = encoder;
  customDecoders[T] = decoder;
}
