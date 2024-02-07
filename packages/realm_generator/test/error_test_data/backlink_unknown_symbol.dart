import 'package:realm_common/realm_common.dart';

@RealmModel()
class _Source {
  _Target? target;
}

@RealmModel()
class _Target {
  @Backlink(#unknownSymbol)
  late Iterable<_Source> backlinks;
}
