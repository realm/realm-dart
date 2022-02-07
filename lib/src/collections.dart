import 'realm_class.dart';
import 'native/realm_core.dart';

class Move {
  final int from, to;
  const Move(this.from, this.to);
}

// Hidden from public use.
class Counts {
  final int deletions, insertions, modifications, moves;
  const Counts(this.deletions, this.insertions, this.modifications, this.moves);

  factory Counts._(RealmCollectionChangesHandle changesHandle) {
    return realmCore.getCollectionChangesCounts(changesHandle);
  }

  @override
  String toString() => //
      '[ "deletions" : $deletions, '
      '"insertions" : $insertions, '
      '"modifications" : $modifications, '
      '"moves" : $moves ]';

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Counts) return true;
    return deletions == other.deletions && //
        insertions == other.insertions &&
        modifications == other.modifications &&
        moves == other.moves;
  }
}

// Hidden from public use.
class IndexChanges {
  final List<int> deletions, insertions, modifications, modificationsAfter;
  final List<Move> moves;
  IndexChanges(this.deletions, this.insertions, this.modifications, this.modificationsAfter, this.moves);

  factory IndexChanges._(RealmCollectionChangesHandle changesHandle, Counts maxCounts) {
    return realmCore.getCollectionChanges(changesHandle, maxCounts);
  }

  @override
  String toString() => //
      '[ "deletions" : $deletions, '
      '"insertions" : $insertions, '
      '"modifications" : $modifications, '
      '"modificationsAfter" : $modificationsAfter, '
      '"moves" : $moves ]';
}

class RealmCollectionChanges {
  final RealmCollectionChangesHandle _handle;
  final Realm realm;

  RealmCollectionChanges(this._handle, this.realm);

  Counts? __counts;
  Counts get _counts => __counts ??= Counts._(_handle);

  IndexChanges? __indexChanges;
  IndexChanges get _indexChanges => __indexChanges ??= IndexChanges._(_handle, _counts);

  List<int> get deletions => _indexChanges.deletions;
  List<int> get insertions => _indexChanges.insertions;
  List<int> get modifications => _indexChanges.modifications;
  List<int> get modificationsAfter => _indexChanges.modificationsAfter;
  List<Move> get moves => _indexChanges.moves;
}

class RealmResultsChanges<T extends RealmObject> extends RealmCollectionChanges {
  final RealmResults<T> results;
  RealmResultsChanges(this.results, RealmCollectionChanges changes) : super(changes._handle, changes.realm);
}
