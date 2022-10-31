import 'package:realm_common/realm_common.dart';

@RealmModel()
class _NotASource {
  late int notALink;
}

@RealmModel()
class _Target {
  @Backlink(#notALink)
  late Iterable<_NotASource> backlinks;
}
