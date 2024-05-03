// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import 'realm_bindings.dart';
import 'realm_handle.dart';
import 'realm_library.dart';
import 'results_handle.dart';
import 'rooted_handle.dart';

class QueryHandle extends RootedHandleBase<realm_query> {
  QueryHandle(Pointer<realm_query> pointer, RealmHandle root) : super(root, pointer, 256);

  ResultsHandle findAll() {
    try {
      return ResultsHandle(realmLib.realm_query_find_all(pointer), root);
    } finally {
      release();
    }
  }
}
