import '../realm.dart';
import 'native/realm_core.dart';

class RealmCollectionChanges {
  final RealmCollectionChangesHandle _handle;
  final Realm realm;

  RealmCollectionChanges(this._handle, this.realm);
}

class RealmResultsChanges<T> {
  final RealmResults<T> results;
  final RealmCollectionChanges _changes;

  RealmResultsChanges(this.results, this._changes);
}

class RealmListChanges<T> {
  final RealmList<T> list;
  final RealmCollectionChanges _changes;

  RealmListChanges(this.list, this._changes);
}
