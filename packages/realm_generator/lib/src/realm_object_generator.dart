// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

library realm_generator;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:realm_generator/src/utils.dart';
import 'package:source_gen/source_gen.dart';

import 'class_element_ex.dart';
import 'measure.dart';
import 'realm_model_info.dart';
import 'session.dart';

Future<ResolvedLibraryResult> _getResolvedLibrary(LibraryElement library, Resolver resolver) async {
  var attempts = 0;
  while (true) {
    try {
      final freshLibrary = await resolver.libraryFor(await resolver.assetIdForElement(library));
      final freshSession = freshLibrary.session;
      return await freshSession.getResolvedLibraryByElement(freshLibrary) as ResolvedLibraryResult;
    } catch (_) {
      ++attempts;
      if (attempts == 3) {
        log.severe('Internal error: Analysis session '
            'did not stabilize after $attempts attempts!');
        rethrow;
      }
    }
  }
}

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await measure(
      () async {
        final result = await _getResolvedLibrary(library.element, buildStep.resolver);

        return scopeSession(
          result,
          () {
            final codeLines = library.classes.realmInfo.expand((m) => m.toCode())..toList();
            if (codeLines.isEmpty) {
              return '';
            }
            return ['// coverage:ignore-file', '// ignore_for_file: type=lint', ...codeLines].join('\n');
          },
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
