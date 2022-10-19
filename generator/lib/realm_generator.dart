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

/// Usage
///
/// * Add a dependency to [realm](https://pub.dev/packages/realm) package or [realm_dart](https://pub.dev/packages/realm_dart) package to your application
/// * Run `flutter pub run build_runner build` or `dart run build_runner build` to generate RealmObjects

library realm_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/realm_object_generator.dart';

export 'src/error.dart';

/// @nodoc
Builder generateRealmObjects([BuilderOptions? options]) {
  print("generateRealmObjects called");
  return SharedPartBuilder(
      [RealmObjectGenerator()],
      'realm_objects',
    );
}
