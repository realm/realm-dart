// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'utils.dart';

enum TargetOsType {
  android,
  ios,
  linux,
  macos,
  windows,
}

// Cannot use Dart 2.17 enhanced enums, due to an issue with build_cli :-/
enum Flavor {
  flutter,
  dart,
}

extension FlavorEx on Flavor {
  String get packageName {
    switch (this) {
      case Flavor.dart:
        return 'realm_dart';
      case Flavor.flutter:
        return 'realm';
    }
  }
}

extension StringEx on String {
  TargetOsType? get asTargetOsType => TargetOsType.values.where((element) => element.toString().split('.').last == this).firstOrNull;
  Flavor? get asFlavor => Flavor.values.where((element) => element.toString() == this).firstOrNull;
}
