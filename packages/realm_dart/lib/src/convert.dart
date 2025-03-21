extension NullableObjectEx<T> on T? {
  U? convert<U>(U Function(T) convertor) {
    final self = this;
    if (self == null) return null;
    return convertor(self);
  }
}
