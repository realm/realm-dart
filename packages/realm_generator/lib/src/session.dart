// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';

const _sessionKey = #SessionKey;

// in case multiple libs are processed concurrently, we make session zone local
Session get session => Zone.current[_sessionKey] as Session;

Future<T> scopeSession<T>(
  ResolvedLibraryResult resolvedLibrary,
  FutureOr<T> Function() fn, {
  String? prefix,
  String? suffix,
  bool color = false,
}) async {
  final s = Session(
    resolvedLibrary,
    prefix: prefix,
    suffix: suffix,
    color: color,
  );
  return await runZonedGuarded(
    fn,
    (e, st) => Error.throwWithStackTrace(e, st),
    zoneValues: {_sessionKey: s},
  )!;
}

class Session {
  final ResolvedLibraryResult resolvedLibrary;
  final Pattern prefix;
  final String suffix;
  final bool color;
  final mapping = <String, ClassElement>{}; // shared

  Session(this.resolvedLibrary, {String? prefix, String? suffix, this.color = false})
      : prefix = prefix ?? RegExp(r'[_$]'), // defaults to _ or $
        suffix = suffix ?? '';

  TypeProvider get typeProvider => resolvedLibrary.typeProvider;
  TypeSystem get typeSystem => resolvedLibrary.element.typeSystem;
}
