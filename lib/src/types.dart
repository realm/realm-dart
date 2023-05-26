// while we wait for
// typedef EJsonValue = Null | String | bool | int | double | List<EJsonValue> | Map<String, EJsonValue>;
typedef EJsonValue = Object?;

enum Key { min, max }

sealed class UndefinedOr<T> {
  const UndefinedOr();
}

final class Defined<T> extends UndefinedOr<T> {
  final T value;

  const Defined(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Defined<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Defined<$T>($value)';
}

final class Undefined<T> extends UndefinedOr<T> {
  const Undefined();

  @override
  operator ==(Object other) => other is Undefined<Object?>;

  @override
  String toString() => 'Undefined<$T>()';

  @override
  int get hashCode => (Undefined<Object?>).hashCode;
}

const undefined = Undefined();
