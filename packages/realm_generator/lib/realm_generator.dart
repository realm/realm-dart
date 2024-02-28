// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Usage
///
/// * Add a dependency to [realm](https://pub.dev/packages/realm) package or [realm_dart](https://pub.dev/packages/realm_dart) package to your application
/// * Run `dart run build_runner build` or `dart run build_runner build` to generate RealmObjects

library realm_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/realm_object_generator.dart';

export 'src/error.dart';

/// @nodoc
Builder generateRealmObjects([BuilderOptions? options]) {
  return PartBuilder(
    [RealmObjectGenerator()],
    '.realm.dart',
  );
}
