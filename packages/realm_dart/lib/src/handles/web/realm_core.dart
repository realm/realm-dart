// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../realm_core.dart' as intf;
import 'web_not_supported.dart';

const realmCore = RealmCore();

class RealmCore implements intf.RealmCore {
  const RealmCore();

  @override
  noSuchMethod(Invocation invocation) => webNotSupported();
}
