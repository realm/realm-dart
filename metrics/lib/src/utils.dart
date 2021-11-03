extension IterableEx<T> on Iterable<T> {
  T? get firstOrNull =>
      cast<T?>().firstWhere((element) => true, orElse: () => null);
}

extension StringEx on String {
  String takeUntil(Pattern p) => substring(0, indexOf(p));
}
