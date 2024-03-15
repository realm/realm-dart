// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';
import 'package:source_gen/source_gen.dart';

const ignoredChecker = TypeChecker.fromRuntime(Ignored);

const indexedChecker = TypeChecker.fromRuntime(Indexed);

const mapToChecker = TypeChecker.fromRuntime(MapTo);

const primaryKeyChecker = TypeChecker.fromRuntime(PrimaryKey);

const backlinkChecker = TypeChecker.fromRuntime(Backlink);

const realmAnnotationChecker = TypeChecker.any([
  ignoredChecker,
  indexedChecker,
  mapToChecker,
  primaryKeyChecker,
]);

const realmModelChecker = TypeChecker.fromRuntime(RealmModel);
