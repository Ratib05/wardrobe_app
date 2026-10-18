import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../core/colour_match.dart';
import '../core/wardrobe_values.dart';

const _sampleSize = 160;

/// A colour must take at least this share of the votes to be suggested; busy
/// prints and multi-coloured items get no suggestion rather than a bad one.
const _minShare = 0.3;

/// A small RGB copy of a photo, for naming colours. Plain pixel maths: it
/// does not recognise what the item is.
class PhotoPixels {
  PhotoPixels(this.width, this.height, this.rgb);

  final int width;
  final int height;

  /// Row-major, three bytes (R, G, B) per pixel.
  final Uint8List rgb;

  Rgb _at(int x, int y) {
    final i = (y * width + x) * 3;
    return (r: rgb[i], g: rgb[i + 1], b: rgb[i + 2]);
  }

  /// Average colour of a small patch around a point; [fx] and [fy] are 0–1
  /// fractions of the photo's width and height.
  Rgb averageAt(double fx, double fy, {int radius = 3}) {
    final cx = (fx.clamp(0.0, 1.0) * (width - 1)).round();
    final cy = (fy.clamp(0.0, 1.0) * (height - 1)).round();
    var r = 0, g = 0, b = 0, n = 0;
    for (
      var y = math.max(0, cy - radius);
      y <= math.min(height - 1, cy + radius);
      y++
    ) {
      for (
        var x = math.max(0, cx - radius);
        x <= math.min(width - 1, cx + radius);
        x++
      ) {
        final p = _at(x, y);
        r += p.r;
        g += p.g;
        b += p.b;
        n++;
      }
    }
    return (r: (r / n).round(), g: (g / n).round(), b: (b / n).round());
  }

  /// The colour most of the middle of the photo is, or null if none clearly
  /// leads.
  WardrobeColour? mainColour() {
    final votes = <WardrobeColour, int>{};
    var total = 0;
    for (var y = height ~/ 4; y < height - height ~/ 4; y++) {
      for (var x = width ~/ 4; x < width - width ~/ 4; x++) {
        final best = closestColours(_at(x, y)).first.colour;
        votes[best] = (votes[best] ?? 0) + 1;
        total++;
      }
    }
    if (total == 0) return null;
    final top = votes.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.value / total >= _minShare ? top.key : null;
  }
}

/// Decodes and shrinks an image. Top-level so [Isolate.run] can call it.
PhotoPixels decodePhotoPixels(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Unreadable image');
  var image = img.bakeOrientation(decoded);
  if (math.max(image.width, image.height) > _sampleSize) {
    image = image.width >= image.height
        ? img.copyResize(
            image,
            width: _sampleSize,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            image,
            height: _sampleSize,
            interpolation: img.Interpolation.average,
          );
  }
  final rgb = Uint8List(image.width * image.height * 3);
  var i = 0;
  for (final p in image) {
    rgb[i++] = p.r.toInt();
    rgb[i++] = p.g.toInt();
    rgb[i++] = p.b.toInt();
  }
  return PhotoPixels(image.width, image.height, rgb);
}

/// Reads [file] into [PhotoPixels]; null if it cannot be read.
Future<PhotoPixels?> readPhotoPixels(File file) async {
  try {
    final bytes = await file.readAsBytes();
    return await Isolate.run(() => decodePhotoPixels(bytes));
  } catch (_) {
    return null;
  }
}
