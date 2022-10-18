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
import 'package:source_span/source_span.dart';

String formatSpans(
  String message, {
  required Element element,
  required String todo,
  SourceSpan? primarySpan,
  String? primaryLabel,
  Map<SourceSpan, String> secondarySpans = const {},
  bool color = false,
}) {
  final buffer = StringBuffer(message);
  try {
    final span = primarySpan;
    if (span != null) {
      final formatted = secondarySpans.isEmpty && primaryLabel == null
          ? span.highlight(color: color)
          : span.highlightMultiple(
              primaryLabel ?? '!',
              secondarySpans,
              color: color,
            );
      buffer
        ..write('${'\n' * 2}in: ')
        ..writeln(span.start.toolString)
        ..write(formatted);
    }
  } catch (e) {
    // Source for `element` wasn't found, it must be in a summary with no
    // associated source. We can still give the name.
    buffer.writeln('\nCause: $element $e');
  }
  if (todo.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(todo);
  }
  return buffer.toString();
}
