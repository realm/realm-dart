// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../handle_base.dart' as intf;

class HandleBase implements intf.HandleBase {
  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
