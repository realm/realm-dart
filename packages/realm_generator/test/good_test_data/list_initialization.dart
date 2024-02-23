import 'package:realm_common/realm_common.dart';

part 'list_initialization.realm.dart';

@RealmModel()
class _Person {
  late List<_Person> children;

  final List<int> initList = <int>[];
  final initListWithType = <int>[];
  final List<int> initListConst = const [];

  final Set<int> initSet = {};
  final initSetWithType = <int>{};
  final Set<int> initSetConst = const {};

  final Map<String, int> initMap = {};
  final initMapWithType = <String, int>{};
  final Map<String, int> initMapConst = const {};
}
