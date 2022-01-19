import 'realm_class.dart';
import 'native/realm_core.dart';

class RealmObjectChanges {
  final RealmObjectChangesHandle _handle;
  final Realm realm;

  RealmObjectChanges(this._handle, this.realm);

  int? _count;
  int get count => _count ??= realmCore.getObjectChangesCount(_handle);

  List<int>? _keys;
  List<int> get keys => _keys ??= realmCore.getObjectChanges(_handle, count);
}

class ObjectChanges<T extends RealmObject> extends RealmObjectChanges {
  T _object;
  ObjectChanges._(this._object, RealmObjectChangesHandle handle, Realm realm) : super(handle, realm);
  
  factory ObjectChanges(T object, RealmObjectChanges changes) {
    return ObjectChanges._(object, changes._handle, changes.realm);
  }

  List<String>? _properties;
  List<String> get properties => _properties ??= keys.map((k) => realm.metadata[_object.runtimeType]!.findByKey(k)).toList();
}

// TODO: Perhaps let generator generate typed RealmObjectChanges subtypes, 
// that can have a much nicer type safe interface

