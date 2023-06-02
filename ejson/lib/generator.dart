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

import 'package:build/build.dart';
import 'package:ejson/src/generator/generator.dart';
import 'package:source_gen/source_gen.dart';

enum EJsonError {
  tooManyAnnotatedConstructors,
  missingGetter,
  mismatchedGetterType,
}

extension on EJsonError {
  String get message => switch (this) {
        EJsonError.tooManyAnnotatedConstructors => 'Too many annotated constructors',
        EJsonError.missingGetter => 'Missing getter',
        EJsonError.mismatchedGetterType => 'Mismatched getter type',
      };

  Never raise() {
    throw EJsonSourceError(this);
  }
}

class EJsonSourceError extends InvalidGenerationSourceError {
  final EJsonError error;
  EJsonSourceError(this.error) : super(error.message);
}

Builder getEJsonGenerator([BuilderOptions? options]) {
  return SharedPartBuilder([EJsonGenerator()], 'ejson');
}
