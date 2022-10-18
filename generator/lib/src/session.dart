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
import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';

const _sessionKey = #SessionKey;

// in case multiple libs are processed concurrently, we make session zone local
Session get session => Zone.current[_sessionKey] as Session;

FutureOr<T> scopeSession<T>(
  ResolvedLibraryResult resolvedLibrary,
  FutureOr<T> Function() fn, {
  String? prefix,
  String? suffix,
  bool color = false,
}) async {
  final s = Session._(
    resolvedLibrary,
    prefix: prefix,
    suffix: suffix,
    color: color,
  );
  return await runZonedGuarded(
    fn,
    (e, st) => throw e,
    zoneValues: {_sessionKey: s},
  )!;
}

class Session {
  final ResolvedLibraryResult resolvedLibrary;
  final Pattern prefix;
  final String suffix;
  final bool color;
  final mapping = <String, ClassElement>{};

  Session._(this.resolvedLibrary, {String? prefix, String? suffix, this.color = false})
      : prefix = prefix ?? RegExp(r'[_$]'), // defaults to _ or $
        suffix = suffix ?? '';

  TypeProvider get typeProvider => resolvedLibrary.typeProvider;
  TypeSystem get typeSystem => resolvedLibrary.element.typeSystem;
}
