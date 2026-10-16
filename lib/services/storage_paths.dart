import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves every on-disk location from a single root directory.
/// Relative image paths in the database are always POSIX-style
/// (`images/clothing/ID.jpg`) so backups stay portable.
class StoragePaths {
  StoragePaths(this.root);

  final Directory root;

  Directory get dataDir => Directory(p.join(root.path, 'data'));
  File get databaseFile => File(p.join(dataDir.path, 'wardrobe.db'));
  Directory get imagesDir => Directory(p.join(root.path, 'images'));
  Directory get clothingImagesDir =>
      Directory(p.join(imagesDir.path, 'clothing'));
  Directory get tempDir => Directory(p.join(root.path, 'temporary'));

  static Future<StoragePaths> resolveDefault() async =>
      StoragePaths(await getApplicationSupportDirectory());

  /// Resolves a database-relative image path; throws [ArgumentError] if it
  /// would land outside the images folder.
  File imageFile(String relativePath) {
    final resolved = p.normalize(p.join(root.path, relativePath));
    if (!p.isWithin(imagesDir.path, resolved)) {
      throw ArgumentError.value(
          relativePath, 'relativePath', 'Outside images folder');
    }
    return File(resolved);
  }

  /// Creates the folder layout and empties temporary/ (leftover staging).
  Future<void> prepare() async {
    await dataDir.create(recursive: true);
    await clothingImagesDir.create(recursive: true);
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    await tempDir.create(recursive: true);
  }
}
