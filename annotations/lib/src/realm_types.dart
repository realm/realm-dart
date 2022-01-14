import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';

class Uuid {} // TODO!

class ObjectId {} // TODO!

class Decimal128 {} // TODO!

class RealmObjectMarker {
} // TODO! Hmm... this ties into the project split issue :-/

// Union type
class RealmAny {
  final dynamic value;
  T as<T>() => value as T; // better for code completion

  // This is private, so user cannot accidentally construct an invalid instance
  const RealmAny._(this.value);

  const RealmAny.bool(bool b) : this._(b);
  const RealmAny.string(String text) : this._(text);
  const RealmAny.int(int i) : this._(i);
  const RealmAny.float(Float f) : this._(f);
  const RealmAny.double(double d) : this._(d);
  const RealmAny.uint8List(Uint8List data) : this._(data);
  // TODO: RealmObjectMarker introduced to avoid dependency invertion.
  // It would be better if we could use RealmObject directly
  const RealmAny.realmObject(RealmObjectMarker o) : this._(o);
  const RealmAny.dateTime(DateTime timestamp) : this._(timestamp);
  const RealmAny.objectId(ObjectId id) : this._(id);
  const RealmAny.decimal128(Decimal128 decimal) : this._(decimal);
  const RealmAny.uuid(Uuid uuid) : this._(uuid);
}

// TODO!
class RealmInteger {
  void increment(int value) {} // TODO!
  void decrement(int value) => increment(-value);
  void reset() {} // TODO!
}

// TODO!
class RealmList<E> extends ListBase<E> {
  @override
  int length = 0;

  @override
  E operator [](int index) => throw UnimplementedError();

  @override
  void operator []=(int index, E value) {}
}

// TODO!
class RealmSet<E> extends SetBase<E> {
  @override
  bool add(E value) => throw UnimplementedError();

  @override
  bool contains(Object? element) => throw UnimplementedError();

  @override
  Iterator<E> get iterator => throw UnimplementedError();

  @override
  int get length => throw UnimplementedError();

  @override
  E? lookup(Object? element) => throw UnimplementedError();

  @override
  bool remove(Object? value) => throw UnimplementedError();

  @override
  Set<E> toSet() => throw UnimplementedError();
}

// TODO!
class RealmMap<E> extends MapBase<String, E> {
  @override
  E? operator [](Object? key) => throw UnimplementedError();

  @override
  void operator []=(String key, E value) {}

  @override
  void clear() {}

  @override
  Iterable<String> get keys => throw UnimplementedError();

  @override
  E? remove(Object? key) => throw UnimplementedError();
}
