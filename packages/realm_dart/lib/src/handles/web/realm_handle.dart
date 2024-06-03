// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import '../realm_handle.dart' as intf;

class RealmHandle implements intf.RealmHandle {
  factory RealmHandle.open(Configuration config) => throw UnsupportedError('web not supported');

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
