// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_dart/realm.dart';

import '../realm_handle.dart' as intf;
import 'handle_base.dart';

class RealmHandle extends HandleBase implements intf.RealmHandle {
  factory RealmHandle.open(Configuration config) => webNotSupported();
}
