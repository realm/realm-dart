// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'lints/mismatched_getter_type.dart';
import 'lints/missing_getter.dart';
import 'lints/too_many_annotated_constructors.dart';

PluginBase createPlugin() => _EJsonLinter();

class _EJsonLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        TooManyAnnotatedConstructors(),
        MissingGetter(),
        MismatchedGetterType(),
      ];
}
