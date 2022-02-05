import 'dart:async';

import 'realm_class.dart';
import 'native/realm_core.dart';

class Move {
  final int from, to;
  const Move(this.from, this.to);
}

class Range {
  final int from, to;
  const Range(this.from, this.to);
}

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

class IndexChanges {
  final List<int> deletions, insertions, modifications, modificationsAfter, moves;
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

  //TODO: revisit public API
  Counts? _counts;
  Counts get counts => _counts ??= Counts._(_handle);

  IndexChanges? _changes;
  IndexChanges get changes => _changes ??= IndexChanges._(_handle, counts);
}

class RealmResultsChanges<T> extends RealmCollectionChanges {
  final RealmResults<T> results;
  RealmResultsChanges(this.results, RealmCollectionChanges changes) : super(changes._handle, changes.realm);
}

