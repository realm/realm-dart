import 'package:realm_common/realm_common.dart';

@RealmModel()
class _IncompatibleSource {
  _AnotherTarget? target;
}

@RealmModel()
class _Target {
  @Backlink(#target)
  late Iterable<_IncompatibleSource> backlinks;
}

@RealmModel()
class _AnotherTarget {}
