// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:cancellation_token/cancellation_token.dart';

import '../subscription.dart';
import 'handle_base.dart';
import 'mutable_subscription_set_handle.dart';
import 'results_handle.dart';
import 'subscription_handle.dart';

abstract class SubscriptionSetHandle extends HandleBase {
  void refresh();

  int get size;

  Exception? get error;

  SubscriptionHandle operator [](int index);

  SubscriptionHandle? findByName(String name);

  SubscriptionHandle? findByResults(ResultsHandle results);

  int get version;
  SubscriptionSetState get state;

  MutableSubscriptionSetHandle toMutable();

  Future<SubscriptionSetState> waitForStateChange(SubscriptionSetState notifyWhen, [CancellationToken? cancellationToken]);
}
