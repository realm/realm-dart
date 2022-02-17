import 'realm_class.dart';
import 'native/realm_core.dart';

class Move {
  final int from;
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

class RealmCollectionChanges {
  final RealmCollectionChangesHandle _handle;
  final Realm realm;
  CollectionChanges? _values;

  RealmCollectionChanges(this._handle, this.realm);

  CollectionChanges get _changes => _values ??= realmCore.getCollectionChanges(_handle);

  List<int> get deletions => _changes.deletions;
  List<int> get insertions => _changes.insertions;
  List<int> get modifications => _changes.modifications;
  List<int> get modificationsAfter => _changes.modificationsAfter;
  List<Move> get moves => _changes.moves;
}

class RealmResultsChanges<T extends RealmObject> extends RealmCollectionChanges {
  final RealmResults<T> results;
  RealmResultsChanges(this.results, RealmCollectionChanges changes) : super(changes._handle, changes.realm);
}
