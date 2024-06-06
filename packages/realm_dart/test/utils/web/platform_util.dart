// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import '../platform_util.dart' as intf;

class PlatformUtil implements intf.PlatformUtil {
  const PlatformUtil();

  @override
  noSuchMethod(Invocation invocation) => throw UnsupportedError('web not supported');
}
