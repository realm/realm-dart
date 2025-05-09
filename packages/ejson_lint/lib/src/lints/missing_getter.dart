// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:ejson_analyzer/ejson_analyzer.dart';

class MissingGetter extends DartLintRule {
  MissingGetter()
      : super(
          code: const LintCode(
            name: 'missing_getter',
            problemMessage: 'Missing getter for constructor parameter',
            errorSeverity: error.ErrorSeverity.ERROR,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addConstructorDeclaration((node) {
      final ctor = node.declaredElement;
      if (ctor == null) return; // not resolved;
      if (isEJsonAnnotated(ctor)) {
        final cls = ctor.enclosingElement3 as ClassElement;
        for (final param in ctor.parameters) {
          final getter = cls.getGetter(param.name);
          if (getter == null) reporter.atElement(param, code);
        }
      }
    });
  }
}
