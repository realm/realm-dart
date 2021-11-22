////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2021 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

library realm_generator;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

//import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:realm_annotations/realm_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';

extension ElementEx on Element {
  DartObject? annotatedWith(TypeChecker checker,
      {bool throwOnUnresolved = true}) {
    return checker.firstAnnotationOf(this,
        throwOnUnresolved: throwOnUnresolved);
  }
}

// NOTE: This is copied from `package:build_runner_core`.
// Hopefully it will be made public at some point.
String humanReadable(Duration duration) {
  if (duration < const Duration(seconds: 1)) {
    return '${duration.inMilliseconds}ms';
  }
  if (duration < const Duration(minutes: 1)) {
    return '${(duration.inMilliseconds / 1000.0).toStringAsFixed(1)}s';
  }
  if (duration < const Duration(hours: 1)) {
    final minutes = duration.inMinutes;
    final remaining = duration - Duration(minutes: minutes);
    return '${minutes}m ${remaining.inSeconds}s';
  }
  final hours = duration.inHours;
  final remaining = duration - Duration(hours: hours);
  return '${hours}h ${remaining.inMinutes}m';
}

FutureOr<T> meassure<T>(FutureOr<T> Function() action,
    {String tag = ''}) async {
  final stopwatch = Stopwatch()..start();
  try {
    return await action();
  } finally {
    stopwatch.stop();
    final time = humanReadable(stopwatch.elapsed);
    print('[$tag] completed, took $time');
  }
}

String lit(Object o) {
  if (o is String) return "'$o'";
  return o.toString();
}

String generateTemplate(Iterable<ClassElement> models) {
  return (() sync* {
    for (final model in models) {
      var className = model.name.substring(1);
      yield 'class $className extends RealmObject {';
      yield '  $className._constructor() : super._contructor();';
      yield '  $className();';
      yield '';
      final schemaProperties = <Object>[];
      for (final f in model.fields) {
        final type = f.type.getDisplayString(withNullability: true);
        final name = f.name;
        yield "  $type get $name => super['$name'] as $type;";
        yield "  set $name($type value) => super['$name'] = value;";
        schemaProperties.add("SchemaProperty('$name', type: '$type')");
      }
      yield "  static dynamic getSchema() => RealmObject.getSchema('$className', [${schemaProperties.join(',')},]);";
      yield '}';
    }
  }())
      .join('\n'); // uses StringBuffer internally
}

String generateCodeBuilder(Iterable<ClassElement> models) {
  final emitter = DartEmitter();
  final generated = StringBuffer();

  for (var model in models) {
    var className = model.name.substring(1);
    final c = Class((b) => b
      ..name = className
      ..extend = refer('RealmObject')
      ..constructors.addAll([
        Constructor((b) => b..name = '_constructor'),
        Constructor(),
      ])

      // getters
      ..methods.addAll(model.fields.map((f) => Method((b) => b
        ..name = f.name
        ..type = MethodType.getter
        ..returns = refer(f.type.getDisplayString(withNullability: true))
        ..lambda = true
        ..body = Code(
          'super[\'${f.name}\'] as ${f.type.getDisplayString(withNullability: true)}',
        ))))

      // setters
      ..methods.addAll(model.fields.map((f) => Method((b) => b
        ..name = f.name
        ..type = MethodType.setter
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'value'
          ..type = refer(f.type.getDisplayString(withNullability: true))))
        ..lambda = true
        ..body = Code('super[\'${f.name}\'] = value'))))

      // getSchema
      ..methods.add(Method((b) => b
        ..name = 'getSchema'
        ..static = true
        ..returns = refer('dynamic')
        ..body = refer('RealmObject.getSchema').call([
          literalString(className),
          literalList([
            for (final f in model.fields)
              refer('SchemaProperty').call(
                [literalString(f.name)],
                {
                  'type': literalString(
                      f.type.getDisplayString(withNullability: false))
                },
              )
          ]),
        ]).code)));

    final result = c.accept(emitter);
    generated.write(result);
  }
  return generated.toString();
}

String generateStringBuffer(Iterable<ClassElement> models) {
  final generated = StringBuffer();
  final getSchemaPropertyBuffer = StringBuffer();

  for (var schemaClass in models) {
    var className = schemaClass.name.substring(1);

    /// The `const dynamic type = ...` is there to remove the warning of unused_element for the Realm data model class in the user dart file
    getSchemaPropertyBuffer.writeln("""
            static dynamic getSchema() {
              const dynamic type = ${schemaClass.name};
              return RealmObject.getSchema('$className', [
            """);

    //Class._constructor() is used from native code when creating new instances of this type
    //Class() constructor is used to be able to create new detached objects and add them to the realm
    generated.writeln("""class $className extends RealmObject {
          // ignore_for_file: unused_element, unused_local_variable
          $className._constructor() : super.constructor();
          $className();
        """);

    for (var field in schemaClass.fields) {
      if (field.type.element!.name == "dynamic") {
        throw Exception(
            "Class '${schemaClass.name}' has a dynamic type field '${field.name}'");
      }

      var fieldTypeName = field.type.element!.name;
      if (fieldTypeName!.startsWith('_')) {
        fieldTypeName = fieldTypeName.substring(1);
      }

      // else if (field.type.isDartCoreInt) {

      // }
      // else if (field.type.isDartCoreDouble) {

      // }
      // else if (field.type.isDartCoreBool) {

      // }

      for (var meta in field.metadata) {
        if (meta.element!.enclosingElement!.name != "RealmProperty") {
          continue;
        }

        //copy the @RealmProperty anotation
        var realmPropertyDefiniton = meta.toSource();
        generated.writeln("$realmPropertyDefiniton");

        String? listTypeArumentName = "";
        if (fieldTypeName == "List") {
          InterfaceType fieldType = field.type as InterfaceType;
          var listTypeArument = fieldType.typeArguments[0].element;
          listTypeArumentName = listTypeArument!.name;
          var isDartType = listTypeArumentName == "String" ||
              listTypeArumentName == "int" ||
              listTypeArumentName == "double" ||
              listTypeArumentName == "bool";

          // if (field.type.element.name == "dynamic") {
          //   throw new Exception("Class '${schemaClass.name}' has a List<dynamic> type field '${field.displayName}'");
          // }

          //TODO: could read the source and try to extract the type T from List<T>
          //the source is available here or from
          //String source = field.source.contents.data;
          //see also [AnalysisContext.getContents]
          //also field.session has an
          //int offs = field.declaration.nameOffset;
          //field.declaration.linkedNode.parent.childEntities.first.typeArguments.arguments.single.name.name == 'Car' //when List<Car>
          //field.session.getParsedUnit(field.source.fullName)

          if (!isDartType && !listTypeArumentName!.startsWith("_")) {
            throw Exception(
                "Field ${schemaClass.name}.${field.name} has an inavlid type ${field.type.toString()}. Type parameter name should start with '_' and be a RealmObject schema type");
          }

          if (listTypeArumentName!.startsWith("_")) {
            listTypeArumentName = listTypeArumentName.substring(1);
          }

          //generate
          //String get make => super['make'];
          generated.writeln(
              "$fieldTypeName<$listTypeArumentName> get ${field.name} => this.super_get<$listTypeArumentName>('${field.name}');");

          //generate
          //set name(String value) => super["name"] = value;
          generated.writeln(
              "set ${field.name}($fieldTypeName<$listTypeArumentName> value) => this.super_set<$listTypeArumentName>('${field.name}', value);");
        } else {
          //generate
          //String get make => super['make'];
          generated.writeln(
              "$fieldTypeName get ${field.name} => super['${field.name}'] as $fieldTypeName;");

          //generate
          //set name(String value) => super["name"] = value;
          generated.writeln(
              "set ${field.name}($fieldTypeName value) => super['${field.name}'] = value;");
        }
        //empty line between fields
        generated.writeln();

        //generte get _schema property
        //generated.writeln("dynamic get _schema {");
        //generated.writeln("var schema = RealmObject.getSchema('${className}', [");

        //infer the type of the object
        var schemaPropertyDefinition = "SchemaProperty('${field.name}', ";

        //if not RealmProperty.type is given. Try to infer the type
        if (!realmPropertyDefiniton.contains("type:")) {
          //normalize string to realm string
          if (field.type.isDartCoreString) {
            fieldTypeName = "string";
          }

          var inferredTypeDefinition = "type: '$fieldTypeName',";
          if (fieldTypeName == "List") {
            if (listTypeArumentName == "String") {
              listTypeArumentName = "string";
            }
            inferredTypeDefinition = "type: '$listTypeArumentName[]',";
          }

          //schemaPropertyName.replaceFirst(")", ")")
          schemaPropertyDefinition += inferredTypeDefinition;
          //schemaPropertyDefinition = "SchemaProperty('${field.name}', ${inferredTypeDefinition},";
          //schemaPropertyDefinition = schemaPropertyDefinition.replaceFirst(",", ",${inferredTypeDefinition},");
          //schemaPropertyDefinition = schemaPropertyDefinition.replaceFirst(', ', ' ');
        }

        var schemaPropertyName = realmPropertyDefiniton.replaceFirst(
            "@RealmProperty(", schemaPropertyDefinition);
        schemaPropertyName = schemaPropertyName.replaceFirst(",)", ")");
        getSchemaPropertyBuffer.writeln("$schemaPropertyName,");
      }
    }

    getSchemaPropertyBuffer.writeln("]);");
    getSchemaPropertyBuffer.writeln("}");

    //end class
    generated.writeln(getSchemaPropertyBuffer.toString());
    generated.writeln("}");
  }

  //String fileName = library.element.definingCompilationUnit.librarySource.shortName;
  //fileName = fileName.replaceAll(".dart", ".g.dart");

  // String generated = """part '${fileName}'; \n
  //                   """;
  //return generated;
  return generated.toString();
}

class RealmObjectGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    return await meassure(() async {
      final schemaClasses = await meassure(() async {
        final explicitModels = library
            .annotatedWith(const TypeChecker.fromRuntime(RealmModel))
            .map((a) => a.element)
            .whereType<ClassElement>();

        final realmPropertyChecker =
            const TypeChecker.fromRuntime(RealmProperty);
        final implicitModels = library.classes.where(
          (c) => c.fields
              .where((f) => realmPropertyChecker.firstAnnotationOf(f) != null)
              .isNotEmpty,
        );

        final models = explicitModels.followedBy(implicitModels).toSet();

        // TODO.. maybe lift this restriction
        return models.where((m) => m.name.startsWith('_'));
      }, tag: 'analyze');

      var before = await meassure(
        () async => generateStringBuffer(schemaClasses),
        tag: 'generate (before)',
      );
      var codeBuilder = await meassure(
        () async => generateCodeBuilder(schemaClasses),
        tag: 'generate (code builder)',
      );
      var template = await meassure(
        () async => generateTemplate(schemaClasses),
        tag: 'generate (template)',
      );
      before = await meassure(
        () async => generateStringBuffer(schemaClasses),
        tag: 'generate (before again)',
      );
      codeBuilder = await meassure(
        () async => generateCodeBuilder(schemaClasses),
        tag: 'generate (code builder again)',
      );
      template = await meassure(
        () async => generateTemplate(schemaClasses),
        tag: 'generate (template again)',
      );

      //print(DartFormatter().format(after));
      return template;
    }, tag: 'generate');
  }
}
