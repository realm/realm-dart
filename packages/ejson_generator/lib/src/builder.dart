// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

enum EJsonError {
  tooManyAnnotatedConstructors,
  missingGetter,
  mismatchedGetterType,
}

Builder getEJsonGenerator([BuilderOptions? options]) {
  return SharedPartBuilder([EJsonGenerator()], 'ejson');
}
