// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';

class AnnotationValue {
  final Annotation annotation;
  final DartObject value;
  AnnotationValue(this.annotation, this.value);
}
