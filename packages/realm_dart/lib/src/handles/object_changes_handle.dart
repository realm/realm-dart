// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'handle_base.dart';

abstract interface class ObjectChangesHandle extends HandleBase {
  bool get isDeleted;
  List<int> get properties;
}
