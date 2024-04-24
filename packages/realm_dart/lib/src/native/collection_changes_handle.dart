// Copyright 2024 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

part of 'realm_core.dart';

class CollectionChangesHandle extends HandleBase<realm_collection_changes> {
  CollectionChangesHandle._(Pointer<realm_collection_changes> pointer) : super(pointer, 256);

  CollectionChanges get changes {
    return using((arena) {
      final outNumDeletions = arena<Size>();
      final outNumInsertions = arena<Size>();
      final outNumModifications = arena<Size>();
      final outNumMoves = arena<Size>();
      final outCollectionCleared = arena<Bool>();
      final outCollectionWasDeleted = arena<Bool>();
      realmLib.realm_collection_changes_get_num_changes(
        pointer,
        outNumDeletions,
        outNumInsertions,
        outNumModifications,
        outNumMoves,
        outCollectionCleared,
        outCollectionWasDeleted,
      );

      final deletionsCount = outNumDeletions != nullptr ? outNumDeletions.value : 0;
      final insertionCount = outNumInsertions != nullptr ? outNumInsertions.value : 0;
      final modificationCount = outNumModifications != nullptr ? outNumModifications.value : 0;
      var moveCount = outNumMoves != nullptr ? outNumMoves.value : 0;

      final outDeletionIndexes = arena<Size>(deletionsCount);
      final outInsertionIndexes = arena<Size>(insertionCount);
      final outModificationIndexes = arena<Size>(modificationCount);
      final outModificationIndexesAfter = arena<Size>(modificationCount);
      final outMoves = arena<realm_collection_move_t>(moveCount);

      realmLib.realm_collection_changes_get_changes(
        pointer,
        outDeletionIndexes,
        deletionsCount,
        outInsertionIndexes,
        insertionCount,
        outModificationIndexes,
        modificationCount,
        outModificationIndexesAfter,
        modificationCount,
        outMoves,
        moveCount,
      );

      var elementZero = outMoves;
      List<Move> moves = List.filled(moveCount, Move(elementZero.ref.from, elementZero.ref.to));
      for (var i = 1; i < moveCount; i++) {
        final movePtr = outMoves + i;
        moves[i] = Move(movePtr.ref.from, movePtr.ref.to);
      }

      return CollectionChanges(
        outDeletionIndexes.toIntList(deletionsCount),
        outInsertionIndexes.toIntList(insertionCount),
        outModificationIndexes.toIntList(modificationCount),
        outModificationIndexesAfter.toIntList(modificationCount),
        moves,
        outCollectionCleared.value,
        outCollectionWasDeleted.value,
      );
    });
  }
}
