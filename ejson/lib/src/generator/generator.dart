import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ejson/ejson.dart';
import 'package:source_gen/source_gen.dart';

/// @nodoc
class EJsonGenerator extends Generator {
  const EJsonGenerator();

  TypeChecker get typeChecker => TypeChecker.fromRuntime(EJson);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final ctors = library.classes.map(
      (c) => c.constructors.singleWhere(
        (c) =>
            typeChecker.firstAnnotationOf(c, throwOnUnresolved: false) != null,
      ),
    );
    return ctors.map((ctor) {
      final className = ctor.enclosingElement.name;

      log.info('Generating EJson for $className');
      return '''
        EJsonValue encode$className($className value) {
          return {
            ${ctor.parameters.map((p) => "'${p.name}': value.${p.name}.toEJson()").join('\n')}
          };
        }

        $className decode$className(EJsonValue ejson) {
          return switch (ejson) {
            ${decodePattern(ctor.parameters)} => $className${ctor.name.isEmpty ? '' : '.${ctor.name}'}(
              ${ctor.parameters.map((p) => "${p.isNamed ? '${p.name} : ' : ''}${p.name}.to<${p.type}>()").join(',\n')}
            ),
            _ => raiseInvalidEJson(ejson),
          };
        }

        extension ${className}EJsonEncoderExtension on $className {
          @pragma('vm:prefer-inline')
          EJsonValue toEJson() => encode$className(this);
        }
      ''';
    }).join('\n\n');
  }
}

String decodePattern(Iterable<ParameterElement> parameters) {
  if (parameters.isEmpty) {
    return 'Map m when m.isEmpty';
  }
  return parameters
      .map((p) => "{'${p.name}': EJsonValue ${p.name}}")
      .join(',\n');
}
