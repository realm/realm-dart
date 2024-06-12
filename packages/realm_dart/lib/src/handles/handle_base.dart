// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

abstract class HandleBase {
  bool get released;
  bool get isUnowned;
  void releaseCore();
  void release();
}
