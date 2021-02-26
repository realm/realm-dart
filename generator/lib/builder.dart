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

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

import 'src/realm_object_generator.dart';

Builder generateRealmObjects(BuilderOptions options) => new SharedPartBuilder([RealmObjectGenerator()], 'RealmObjects', formatOutput: (output) {
  var formatter = new DartFormatter(pageWidth: 300);
  return formatter.format(output);
});

//Builder generateRealmObjects(BuilderOptions options) => new LibraryBuilder(RealmObjectGenerator(), generatedExtension: ".realm.g.dart");