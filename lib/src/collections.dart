import 'realm_class.dart';
import 'native/realm_core.dart';

/// Contains index information about objects that moved within the same collection.
class Move {
  /// The index in the old version of the collection.
  final int from;
  /// The index in the new version of the collection.
  final int to;

  const Move(this.from, this.to);
}

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
  final Realm realm;
  CollectionChanges? _values;

  RealmCollectionChanges(this._handle, this.realm);

  CollectionChanges get _changes => _values ??= realmCore.getCollectionChanges(_handle);

  /// The indices in the previous version of the collection which have been removed from this one.
  List<int> get deelted => _changes.deletions;

  /// The indices in the new collection which were added in this version.
  List<int> get inserted => _changes.insertions;

  /// The indices of the objects in the new collection which were modified in this version.
  List<int> get modified => _changes.modifications;
  
  /// The indices of the objects in the collection which moved.
  List<Move> get moves => _changes.moves;

  /// The indices in the new version of the collection which were modified. Conceptually, it contains the same entries as [modified] but after the 
  /// insertions and deletions have been accounted for.
  List<int> get newModified => _changes.modificationsAfter;
}

/// Describes the changes in a Realm results collection since the last time the notification callback was invoked.
class RealmResultsChanges<T extends RealmObject> extends RealmCollectionChanges {
  final RealmResults<T> results;
  RealmResultsChanges(this.results, RealmCollectionChanges changes) : super(changes._handle, changes.realm);
}
