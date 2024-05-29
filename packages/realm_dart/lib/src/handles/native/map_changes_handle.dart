// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';

import '../../collections.dart';
import 'ffi.dart';
import 'from_native.dart';
import 'handle_base.dart';
import 'realm_bindings.dart';
import 'realm_library.dart';

class MapChangesHandle extends HandleBase<realm_dictionary_changes> {
  MapChangesHandle(Pointer<realm_dictionary_changes> pointer) : super(pointer, 256);

  MapChanges get changes {
    return using((arena) {
      final outNumDeletions = arena<Size>();
      final outNumInsertions = arena<Size>();
      final outNumModifications = arena<Size>();
      final outCollectionWasDeleted = arena<Bool>();
      realmLib.realm_dictionary_get_changes(
        pointer,
        outNumDeletions,
        outNumInsertions,
        outNumModifications,
        outCollectionWasDeleted,
      );

      final deletionsCount = outNumDeletions != nullptr ? outNumDeletions.value : 0;
      final insertionCount = outNumInsertions != nullptr ? outNumInsertions.value : 0;
      final modificationCount = outNumModifications != nullptr ? outNumModifications.value : 0;

      final outDeletionIndexes = arena<realm_value>(deletionsCount);
      final outInsertionIndexes = arena<realm_value>(insertionCount);
      final outModificationIndexes = arena<realm_value>(modificationCount);
      final outCollectionWasCleared = arena<Bool>();

      realmLib.realm_dictionary_get_changed_keys(
        pointer,
        outDeletionIndexes,
        outNumDeletions,
        outInsertionIndexes,
        outNumInsertions,
        outModificationIndexes,
        outNumModifications,
        outCollectionWasCleared,
      );

      return MapChanges(outDeletionIndexes.toStringList(deletionsCount), outInsertionIndexes.toStringList(insertionCount),
          outModificationIndexes.toStringList(modificationCount), outCollectionWasCleared.value, outCollectionWasDeleted.value);
    });
  }
}
