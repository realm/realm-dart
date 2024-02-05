import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  // Parse the build configuration passed to this CLI from Dart or Flutter.
  final buildConfig = await BuildConfig.fromArgs(args);
  final buildOutput = BuildOutput();

  print(buildConfig);
  print(buildConfig.targetOs);
  buildOutput.assets.add(
    Asset(
      id: 'package:realm_dart/realm_dart.dart',
      linkMode: LinkMode.dynamic,
      target: buildConfig.target,
      path: AssetAbsolutePath(
        buildConfig.packageRoot.resolve('binary/macos/librealm_dart.dylib'),
      ),
    ),
  );

  print(buildOutput);

  await buildOutput.writeToFile(outDir: buildConfig.outDir);
}
