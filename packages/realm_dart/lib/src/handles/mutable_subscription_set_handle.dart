// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'results_handle.dart';
import 'subscription_handle.dart';
import 'subscription_set_handle.dart';

abstract interface class MutableSubscriptionSetHandle extends SubscriptionSetHandle {
  SubscriptionSetHandle commit();

  SubscriptionHandle insertOrAssignSubscription(ResultsHandle results, String? name, bool update);

  bool erase(SubscriptionHandle subscription);
  bool eraseByName(String name);
  bool eraseByResults(ResultsHandle results);

  void clear();
}
