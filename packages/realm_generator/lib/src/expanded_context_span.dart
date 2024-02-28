// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:source_span/source_span.dart';

class ExpandedContextSpan with SourceSpanMixin implements FileSpan {
  final FileSpan _span, _contextSpan;

  ExpandedContextSpan(this._span, Iterable<FileSpan> contextSpans) : _contextSpan = contextSpans.fold<FileSpan>(_span, (acc, c) => acc.expand(c));

  @override
  String get context => _contextSpan.context;

  @override
  FileLocation get end => _span.end;

  @override
  ExpandedContextSpan expand(FileSpan other) {
    final contextSpans = [_contextSpan];
    if (other is ExpandedContextSpan) {
      contextSpans.add(other._contextSpan);
    }
    return ExpandedContextSpan(_span.expand(other), contextSpans);
  }

  @override
  SourceFile get file => _span.file;

  @override
  FileLocation get start => _span.start;

  @override
  String get text => _span.text;
}
