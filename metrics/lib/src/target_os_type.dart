import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.pascal)
enum TargetOsType {
  android,
  ios,
  linux,
  macos,
  // web, // not supported yet
  windows,
}
