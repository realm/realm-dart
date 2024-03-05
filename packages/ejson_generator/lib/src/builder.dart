// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

enum EJsonError {
  tooManyAnnotatedConstructors,
  tooManyConstructorsOnAnnotatedClass,
  noExplicitConstructor,
  missingGetter,
  mismatchedGetterType,
}

Builder getEJsonGenerator([BuilderOptions? options]) {
  return SharedPartBuilder([EJsonGenerator()], 'ejson');
}
