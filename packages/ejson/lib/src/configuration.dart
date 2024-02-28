// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

library;

import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:type_plus/type_plus.dart';

import 'decoding.dart';
import 'encoding.dart';

/// Register custom EJSON [encoder] and [decoder] for a [T].
void register<T>(EJsonEncoder<T> encoder, EJsonDecoder<T> decoder) {
  TypePlus.add<T>();
  customEncoders[T] = encoder;
  customDecoders[T] = decoder;
}
