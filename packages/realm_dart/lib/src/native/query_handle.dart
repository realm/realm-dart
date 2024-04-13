// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class QueryHandle extends RootedHandleBase<realm_query> {
  QueryHandle._(Pointer<realm_query> pointer, RealmHandle root) : super(root, pointer, 256);

  RealmResultsHandle findAll() {
    try {
      final resultsPointer = invokeGetPointer(() => realmLib.realm_query_find_all(pointer));
      return RealmResultsHandle._(resultsPointer, _root);
    } finally {
      release();
    }
  }
}
