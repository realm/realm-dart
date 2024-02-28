// Copyright 2021 MongoDB, Inc.
// SPDX-License-Identifier: Apache-2.0

///
import 'dart:io';
import 'package:tar/tar.dart';
import 'package:path/path.dart' as path;

class Archive {
// Create an archive of files
  Future<void> archive(Directory sourceDir, File outputFile) async {
    if (!await sourceDir.exists()) {
      throw Exception("Source directory $sourceDir does not exist");
    }

    await findEntries(sourceDir).transform(tarWriter).transform(gzip.encoder).pipe(outputFile.openWrite());
    print("\nArchive ${outputFile.absolute.path} created");
  }

  // Extracts files from an archive
  Future<void> extract(File archive, Directory outputDir) async {
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final reader = TarReader(archive.openRead().transform(gzip.decoder));
    while (await reader.moveNext()) {
      final entry = reader.current;
      final header = entry.header;

      var outputPath = path.join(outputDir.absolute.path, entry.name);
      if (!path.isWithin(outputDir.absolute.path, outputPath)) {
        throw Exception("${entry.name} is outside of the archive");
      }

      if (header.typeFlag == TypeFlag.reg) {
        final outputFile = File(outputPath);
        print("extracting ${header.name}");
        await outputFile.create(recursive: true);
        await entry.contents.pipe(outputFile.openWrite());
      }
    }

    print("\nArchive ${archive.absolute.path} extracted to ${outputDir.absolute.path}");
  }

  Stream<TarEntry> findEntries(Directory root) async* {
    await for (final entry in root.list(recursive: true)) {
      var name = path.relative(entry.path, from: root.path);
      if (entry is Directory) {
        continue;
      }

      final stat = await entry.stat();
      print("archiving $name");
      yield TarEntry(
          TarHeader(
              name: name,
              typeFlag: entry is File ? TypeFlag.reg : TypeFlag.dir,
              mode: stat.mode,
              modified: stat.modified,
              accessed: stat.accessed,
              changed: stat.changed,
              size: stat.size),
          // Use entry.openRead() to obtain an input stream for the file that the
          // writer will use later.
          entry is File ? entry.openRead() : Stream.empty());
    }
  }
}
