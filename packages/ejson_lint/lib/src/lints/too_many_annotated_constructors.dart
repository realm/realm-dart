// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/error/error.dart' as error;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:ejson_analyzer/ejson_analyzer.dart';

abstract class EJsonLintRule extends DartLintRule {
  EJsonLintRule({required super.code});

  @override
  Future<void> startUp(CustomLintResolver resolver, CustomLintContext context) async {
    return await super.startUp(resolver, context);
  }
}

class TooManyAnnotatedConstructors extends DartLintRule {
  TooManyAnnotatedConstructors()
      : super(
          code: const LintCode(
            name: 'too_many_annotated_constructors',
            problemMessage: 'Only one constructor can be annotated',
            errorSeverity: error.ErrorSeverity.ERROR,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final cls = node.declaredElement;
      if (cls == null) return; // not resolved;

      final annotatedConstructors = cls.constructors.where((ctor) => isEJsonAnnotated(ctor));
      if (annotatedConstructors.length > 1) {
        for (final ctor in annotatedConstructors) {
          reporter.atElement(ctor, code);
        }
      }
    });
  }
}
