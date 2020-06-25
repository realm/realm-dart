library realm_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';

import 'src/realm_object_generator.dart';

Builder generateRealmObjects(BuilderOptions options) => new SharedPartBuilder([RealmObjectGenerator()], 'RealmObjects', formatOutput: (output) {
  var formatter = new DartFormatter(pageWidth: 300);
  return formatter.format(output);
});

//Builder generateRealmObjects(BuilderOptions options) => new LibraryBuilder(RealmObjectGenerator(), generatedExtension: ".realm.g.dart");