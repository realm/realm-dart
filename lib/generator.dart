import 'package:build/build.dart';
import 'package:ejson/src/generator/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder getEJsonGenerator(BuilderOptions options) {
  return SharedPartBuilder([EJsonGenerator()], 'ejson');
}
