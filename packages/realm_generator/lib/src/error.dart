// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_span/source_span.dart';

import 'element.dart';
import 'format_spans.dart';
import 'session.dart';
import 'utils.dart';

class RealmInvalidGenerationSourceError extends InvalidGenerationSourceError {
  final FileSpan? primarySpan;
  final String? primaryLabel;
  final Map<FileSpan, String> secondarySpans;
  bool color;

  RealmInvalidGenerationSourceError(
    super.message, {
    required super.todo,
    required Element element,
    FileSpan? primarySpan,
    bool? color,
    this.primaryLabel,
    Map<FileSpan, String> secondarySpans = const {},
  })  : primarySpan = primarySpan ?? element.span,
        secondarySpans = {...secondarySpans},
        color = color ?? session.color,
        super(element: element) {
    if (element is FieldElement || element is ConstructorElement) {
      final classElement = element.enclosingElement3!;
      this.secondarySpans.addAll({
        classElement.span!: "in realm model for '${session.mapping.entries.where((e) => e.value == classElement).singleOrNull?.key}'",
      });
    }
  }

  @override
  String toString() => format(color);

  String format([bool color = false]) => formatSpans(
        message,
        element: element!, // is required, so safe
        todo: todo,
        primaryLabel: primaryLabel,
        primarySpan: primarySpan,
        secondarySpans: secondarySpans,
        color: color,
      );
}
