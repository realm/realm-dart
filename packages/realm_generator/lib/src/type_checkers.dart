// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'package:source_gen/source_gen.dart';

const _realmCommonUrl = 'package:realm_common/realm_common.dart';

const ignoredChecker = TypeChecker.fromUrl('$_realmCommonUrl#Ignored');

const indexedChecker = TypeChecker.fromUrl('$_realmCommonUrl#Indexed');

const mapToChecker = TypeChecker.fromUrl('$_realmCommonUrl#MapTo');

const primaryKeyChecker = TypeChecker.fromUrl('$_realmCommonUrl#PrimaryKey');

const backlinkChecker = TypeChecker.fromUrl('$_realmCommonUrl#Backlink');

const realmAnnotationChecker = TypeChecker.any([
  ignoredChecker,
  indexedChecker,
  mapToChecker,
  primaryKeyChecker,
]);

const realmModelChecker = TypeChecker.fromUrl('$_realmCommonUrl#RealmModel');
