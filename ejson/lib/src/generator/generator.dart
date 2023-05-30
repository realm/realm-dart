import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ejson/ejson.dart';
import 'package:source_gen/source_gen.dart';

/// @nodoc
class EJsonGenerator extends GeneratorForAnnotation<EJson> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is ConstructorElement) {}
    return '';
  }
}
