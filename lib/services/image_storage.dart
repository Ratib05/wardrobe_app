import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../core/app_exceptions.dart';
import 'storage_paths.dart';

const maxImageDimension = 1600;
const jpegQuality = 85;
const maxSourceBytes = 50 * 1024 * 1024;

const _unsupportedMessage =
    "This image format isn't supported. Use a JPEG, PNG or WebP photo.";

/// Decodes any supported image, makes it upright, shrinks it to at most
/// [maxImageDimension] on the longest side, strips all metadata (incl. GPS)
/// and re-encodes as JPEG. Top-level so [Isolate.run] can call it.
Uint8List processImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const UnsupportedImageException(_unsupportedMessage);
  }
  var image = img.bakeOrientation(decoded);
  final longest = math.max(image.width, image.height);
  if (longest > maxImageDimension) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxImageDimension)
        : img.copyResize(image, height: maxImageDimension);
  }
  image.exif = img.ExifData();
  return Uint8List.fromList(img.encodeJpg(image, quality: jpegQuality));
}

/// Rotates an image 90 degrees clockwise and re-encodes it as JPEG.
/// Top-level so [Isolate.run] can call it.
Uint8List rotateImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const UnsupportedImageException(_unsupportedMessage);
  }
  final rotated = img.copyRotate(decoded, angle: 90);
  return Uint8List.fromList(img.encodeJpg(rotated, quality: jpegQuality));
}

/// Stores clothing photos as files; the database keeps only the relative path.
class ImageStorage {
  ImageStorage(this._paths);

  final StoragePaths _paths;
  static const _uuid = Uuid();

  /// Processes [sourcePath] into a new file in temporary/.
  Future<File> stage(String sourcePath) async {
    final source = File(sourcePath);
    if (await source.length() > maxSourceBytes) {
      throw const UnsupportedImageException(
        'This image is too large (over 50 MB).',
      );
    }
    final bytes = await source.readAsBytes();
    final processed = await Isolate.run(() => processImageBytes(bytes));
    final staged = File(p.join(_paths.tempDir.path, '${_uuid.v4()}.jpg'));
    await staged.writeAsBytes(processed);
    return staged;
  }

  /// Writes a rotated (90 degrees clockwise) copy of [source] to temporary/
  /// and returns it; [source] is left untouched.
  Future<File> stageRotatedCopy(File source) async {
    final bytes = await source.readAsBytes();
    final rotated = await Isolate.run(() => rotateImageBytes(bytes));
    final staged = File(p.join(_paths.tempDir.path, '${_uuid.v4()}.jpg'));
    await staged.writeAsBytes(rotated);
    return staged;
  }

  /// Moves a staged file into images/clothing/ and returns its relative path.
  Future<String> commit(File staged) async {
    final name = p.basename(staged.path);
    await staged.rename(p.join(_paths.clothingImagesDir.path, name));
    return 'images/clothing/$name';
  }

  Future<void> discard(File staged) async {
    if (await staged.exists()) await staged.delete();
  }

  /// Deletes a stored photo; ignores null, missing and out-of-folder paths.
  Future<void> delete(String? relativePath) async {
    final file = fileFor(relativePath);
    if (file != null && await file.exists()) await file.delete();
  }

  /// The file for [relativePath], or null if absent or outside images/.
  File? fileFor(String? relativePath) {
    if (relativePath == null) return null;
    try {
      return _paths.imageFile(relativePath);
    } on ArgumentError {
      return null;
    }
  }
}
