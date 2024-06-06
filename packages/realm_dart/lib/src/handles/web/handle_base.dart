// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../handle_base.dart' as intf;
import 'web_not_supported.dart';

export 'web_not_supported.dart';

class HandleBase implements intf.HandleBase {
  @override
  noSuchMethod(Invocation invocation) => webNotSupported();
}
