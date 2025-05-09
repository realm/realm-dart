// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../collections.dart';
import 'handle_base.dart';

abstract interface class MapChangesHandle extends HandleBase {
  MapChanges get changes;
}
