//dart.library.cli is available only on dart desktop
//Dart: order imports correctly per the dart guidance
import 'src/realm_flutter.dart'
  if (dart.library.cli) 
     'src/realm_dart.dart';

export 'src/realm_flutter.dart'
  if (dart.library.cli) 
    'src/realm_dart.dart';  