import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wardrobe_app/services/storage_paths.dart';

void main() {
  late Directory root;
  late StoragePaths paths;

  setUp(() {
    root = Directory.systemTemp.createTempSync('wardrobe_paths_');
    paths = StoragePaths(root);
  });
  tearDown(() => root.deleteSync(recursive: true));

  test('prepare creates folders and empties temporary/', () async {
    Directory(paths.tempDir.path).createSync(recursive: true);
    File(p.join(paths.tempDir.path, 'old.tmp')).writeAsStringSync('x');
    await paths.prepare();
    expect(paths.dataDir.existsSync(), isTrue);
    expect(paths.clothingImagesDir.existsSync(), isTrue);
    expect(paths.tempDir.existsSync(), isTrue);
    expect(paths.tempDir.listSync(), isEmpty);
  });

  test('imageFile resolves inside images/', () {
    expect(
      paths.imageFile('images/clothing/a.jpg').path,
      p.join(root.path, 'images', 'clothing', 'a.jpg'),
    );
  });

  test('imageFile rejects traversal', () {
    expect(() => paths.imageFile('../secret.txt'), throwsArgumentError);
    expect(
      () => paths.imageFile('images/../data/wardrobe.db'),
      throwsArgumentError,
    );
  });
}
