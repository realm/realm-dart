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

import 'utils.dart';

enum TargetOsType {
  android,
  ios,
  linux,
  macos,
  windows,
}

// Cannot use Dart 2.17 enhanced enums, due to stupid issue with build_cli :-/
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
