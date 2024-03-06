// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/dart/element/element.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:source_gen/source_gen.dart';

TypeChecker get typeChecker => TypeChecker.fromRuntime(EJson);

EJson getEJsonAnnotation(Element element) => typeChecker.firstAnnotationOfExact(element) as EJson;
bool isEJsonAnnotated(Element element) => typeChecker.hasAnnotationOfExact(element);
