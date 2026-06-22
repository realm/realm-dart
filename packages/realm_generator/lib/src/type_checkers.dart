// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:realm_common/realm_common.dart';
import 'package:source_gen/source_gen.dart';

const ignoredChecker = TypeChecker.typeNamed(Ignored, inPackage: 'realm_common');

const indexedChecker = TypeChecker.typeNamed(Indexed, inPackage: 'realm_common');

const mapToChecker = TypeChecker.typeNamed(MapTo, inPackage: 'realm_common');

const primaryKeyChecker = TypeChecker.typeNamed(PrimaryKey, inPackage: 'realm_common');

const backlinkChecker = TypeChecker.typeNamed(Backlink, inPackage: 'realm_common');

const realmAnnotationChecker = TypeChecker.any([
  ignoredChecker,
  indexedChecker,
  mapToChecker,
  primaryKeyChecker,
]);

const realmModelChecker = TypeChecker.typeNamed(RealmModel, inPackage: 'realm_common');
