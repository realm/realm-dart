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

import 'package:source_span/source_span.dart';

class ExpandedContextSpan with SourceSpanMixin implements FileSpan {
  final FileSpan _span, _contextSpan;

  ExpandedContextSpan(this._span, Iterable<FileSpan> contextSpans) :
    _contextSpan = contextSpans.fold<FileSpan>(_span, (acc, c) => acc.expand(c));

  @override
  String get context =>  _contextSpan.context;

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