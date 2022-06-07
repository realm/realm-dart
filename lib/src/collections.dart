import 'native/realm_core.dart';

/// Contains index information about objects that moved within the same collection.
class Move {
  /// The index in the old version of the collection.
  final int from;
  /// The index in the new version of the collection.
  final int to;

  const Move(this.from, this.to);
}

/// @nodoc
class CollectionChanges {
  final List<int> deletions;
  final List<int> insertions;
  final List<int> modifications;
  final List<int> modificationsAfter;
  final List<Move> moves;

  const CollectionChanges(this.deletions, this.insertions, this.modifications, this.modificationsAfter, this.moves);
}

/// Describes the changes in a Realm collection since the last time the notification callback was invoked.
class RealmCollectionChanges {
  final RealmCollectionChangesHandle _handle;
  CollectionChanges? _values;
  
  RealmCollectionChanges(this._handle);

  CollectionChanges get _changes => _values ??= realmCore.getCollectionChanges(_handle);

  /// The indexes in the previous version of the collection which have been removed from this one.
  List<int> get deleted => _changes.deletions;

  /// The indexes in the new collection which were added in this version.
  List<int> get inserted => _changes.insertions;

  /// The indexes of the objects in the new collection which were modified in this version.
  List<int> get modified => _changes.modifications;
  
  /// The indexes of the objects in the collection which moved.
  List<Move> get moved => _changes.moves;

  /// The indexes in the new version of the collection which were modified. Conceptually, it contains the same entries as [modified] but after the 
  /// insertions and deletions have been accounted for.
  List<int> get newModified => _changes.modificationsAfter;
}