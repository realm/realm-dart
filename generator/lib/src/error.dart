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
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_span/source_span.dart';

import 'element.dart';
import 'format_spans.dart';

class RealmInvalidGenerationSourceError extends InvalidGenerationSourceError {
  final FileSpan primarySpan;
  final String? primaryLabel;
  final Map<FileSpan, String> secondarySpans;

  RealmInvalidGenerationSourceError(
    String message, {
    required String todo,
    required Element element,
    FileSpan? primarySpan,
    this.primaryLabel,
    this.secondarySpans = const {},
  })  : primarySpan = primarySpan ?? element.span!,
        super(message, todo: todo, element: element);

  @override
  String toString() => formatSpans(
        message,
        element: element!, // is required, so safe
        todo: todo,
        primaryLabel: primaryLabel,
        primarySpan: primarySpan,
        secondarySpans: secondarySpans,
      );
}
