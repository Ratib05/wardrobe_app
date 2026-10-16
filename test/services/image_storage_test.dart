import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wardrobe_app/core/app_exceptions.dart';
import 'package:wardrobe_app/services/image_storage.dart';

import '../helpers.dart';

void main() {
  test('large images are shrunk to 1600 px longest side', () {
    final out = processImageBytes(jpegBytes(width: 3000, height: 1500));
    final decoded = img.decodeJpg(out)!;
    expect([decoded.width, decoded.height], [1600, 800]);
  });

  test('EXIF orientation is applied', () {
    final source = img.Image(width: 200, height: 100);
    source.exif.imageIfd.orientation = 6;
    final out = processImageBytes(img.encodeJpg(source));
    final decoded = img.decodeJpg(out)!;
    expect([decoded.width, decoded.height], [100, 200]);
  });

  test('metadata is stripped', () {
    final source = img.Image(width: 20, height: 20);
    source.exif.imageIfd.make = 'SecretCam';
    final out = processImageBytes(img.encodeJpg(source));
    expect(img.decodeJpg(out)!.exif.isEmpty, isTrue);
    expect(latin1.decode(out).contains('SecretCam'), isFalse);
  });

  test('non-images throw UnsupportedImageException', () {
    expect(
      () => processImageBytes(utf8.encode('hello') as dynamic),
      throwsA(isA<UnsupportedImageException>()),
    );
  });

  test(
    'stage + commit stores under images/clothing and empties temporary',
    () async {
      final paths = await tempPaths();
      final storage = ImageStorage(paths);
      final source = File('${paths.root.path}/in.jpg')
        ..writeAsBytesSync(jpegBytes());
      final staged = await storage.stage(source.path);
      expect(staged.existsSync(), isTrue);
      final rel = await storage.commit(staged);
      expect(rel, matches(RegExp(r'^images/clothing/[0-9a-f-]+\.jpg$')));
      expect(paths.imageFile(rel).existsSync(), isTrue);
      expect(paths.tempDir.listSync(), isEmpty);
    },
  );

  test('delete ignores null, missing and out-of-folder paths', () async {
    final storage = ImageStorage(await tempPaths());
    await storage.delete(null);
    await storage.delete('images/clothing/missing.jpg');
    await storage.delete('../x');
  });
}
