////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
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

library realm_generator;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'class_element_ex.dart';
import 'package:realm_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

import 'meassure.dart';
import 'realm_model_info.dart';
import 'session.dart';

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await meassure(
      () async {
        return await scopeSession(
          (await library.element.session.getResolvedLibraryByElement(library.element)) as ResolvedLibraryResult,
          () async => library.classes.realmInfo.expand((m) => m.toCode()).join('\n'),
          color: stdout.supportsAnsiEscapes,
        );
      },
      tag: 'generate',
    );
  }
}

extension on Iterable<ClassElement> {
  Iterable<RealmModelInfo> get realmInfo => map((m) => m.realmInfo).whereNotNull;
}
