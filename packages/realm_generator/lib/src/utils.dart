// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

String anOrA(String text) => 'aeiouy'.contains(text[0]) ? 'an' : 'a';

extension IterableEx<T> on Iterable<T> {
  T? get singleOrNull => cast<T?>().singleWhere((_) => true, orElse: () => null);
}

extension IterableOverNullableEx<T> on Iterable<T?> {
  Iterable<T> get whereNotNull => where((i) => i != null).cast<T>();
}
