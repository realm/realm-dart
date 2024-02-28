// Copyright 2023 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

library;

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:ejson_analyzer/ejson_analyzer.dart';
import 'package:ejson_generator/ejson_generator.dart';
import 'package:source_gen/source_gen.dart';

extension on EJsonError {
  String get message => switch (this) {
        EJsonError.tooManyAnnotatedConstructors => 'Too many annotated constructors',
        EJsonError.missingGetter => 'Missing getter',
        EJsonError.mismatchedGetterType => 'Mismatched getter type',
      };

  Never raise() {
    throw EJsonSourceError(this);
  }
}

class EJsonSourceError extends InvalidGenerationSourceError {
  final EJsonError error;
  EJsonSourceError(this.error) : super(error.message);
}

/// @nodoc
class EJsonGenerator extends Generator {
  const EJsonGenerator();

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    // find all classes with annotated constructors or classes directly annotated
    final annotated = library.classes.map((cls) => (cls, cls.constructors.where((ctor) => isEJsonAnnotated(ctor)))).where((element) {
      final (cls, ctors) = element;
      return ctors.isNotEmpty || isEJsonAnnotated(cls);
    });

    return annotated.map((x) {
      final (cls, ctors) = x;
      final className = cls.name;

      if (ctors.length > 1) {
        EJsonError.tooManyAnnotatedConstructors.raise();
      }

      if (ctors.isEmpty) {
        // TODO!
      }

      final ctor = ctors.single;

      for (final p in ctor.parameters) {
        final getter = cls.getGetter(p.name);
        if (getter == null) {
          EJsonError.missingGetter.raise();
        }
        if (!TypeChecker.fromStatic(p.type).isAssignableFromType(getter.returnType)) {
          EJsonError.mismatchedGetterType.raise();
        }
      }

      log.info('Generating EJson for $className');
      return '''
        EJsonValue encode$className($className value) {
          return {
            ${ctor.parameters.map((p) => "'${p.name}': value.${p.name}.toEJson()").join(',\n')}
          };
        }

        $className decode$className(EJsonValue ejson) {
          return switch (ejson) {
              ${decodePattern(ctor.parameters)} => $className${ctor.name.isEmpty ? '' : '.${ctor.name}'}(
              ${ctor.parameters.map((p) => "${p.isNamed ? '${p.name} : ' : ''}fromEJson(${p.name})").join(',\n')}
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
  return '''{
    ${parameters.map((p) => "'${p.name}': EJsonValue ${p.name}").join(',\n')} 
  }''';
}
