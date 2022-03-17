import 'package:realm_common/realm_common.dart';
import '../../../lib/realm.dart'; //For partial file references

part 'missing_underscore.g.dart';

@RealmModel()
class _Bad {
  late Other other;
}

@RealmModel()
class _Other {}
