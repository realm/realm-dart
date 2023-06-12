import 'package:analyzer/dart/element/element.dart';
import 'package:ejson_annotation/ejson_annotation.dart';
import 'package:source_gen/source_gen.dart';

TypeChecker get typeChecker => TypeChecker.fromRuntime(EJson);

bool isEJsonAnnotated(Element element) =>
    typeChecker.hasAnnotationOfExact(element);
