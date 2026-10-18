import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/services/photo_colours.dart';

Uint8List png(void Function(img.Image) draw, {int size = 100}) {
  final image = img.Image(width: size, height: size);
  draw(image);
  return Uint8List.fromList(img.encodePng(image));
}

img.Color rgb(int v) => img.ColorRgb8((v >> 16) & 255, (v >> 8) & 255, v & 255);

void main() {
  test('a solid photo gives that colour', () {
    final pixels = decodePhotoPixels(
      png((i) => img.fill(i, color: rgb(0x1F2A44))),
    );
    expect(pixels.mainColour(), WardrobeColour.navy);
  });

  test('an item centred on another background gives the item colour', () {
    final pixels = decodePhotoPixels(
      png((i) {
        img.fill(i, color: rgb(0xEEEEEE));
        img.fillRect(i, x1: 20, y1: 20, x2: 80, y2: 80, color: rgb(0x6B7A3A));
      }),
    );
    expect(pixels.mainColour(), WardrobeColour.olive);
  });

  test('a four-colour photo gives no suggestion', () {
    final pixels = decodePhotoPixels(
      png((i) {
        img.fillRect(i, x1: 0, y1: 0, x2: 50, y2: 50, color: rgb(0xC62828));
        img.fillRect(i, x1: 50, y1: 0, x2: 100, y2: 50, color: rgb(0x2E7D32));
        img.fillRect(i, x1: 0, y1: 50, x2: 50, y2: 100, color: rgb(0x1565C0));
        img.fillRect(i, x1: 50, y1: 50, x2: 100, y2: 100, color: rgb(0xFBC02D));
      }),
    );
    expect(pixels.mainColour(), isNull);
  });

  test('averageAt reads the tapped quadrant', () {
    final pixels = decodePhotoPixels(
      png((i) {
        img.fill(i, color: rgb(0xFFFFFF));
        img.fillRect(i, x1: 50, y1: 50, x2: 100, y2: 100, color: rgb(0xC62828));
      }),
    );
    final red = pixels.averageAt(0.8, 0.8);
    expect(red.r, greaterThan(180));
    expect(red.g, lessThan(60));
    final white = pixels.averageAt(0.2, 0.2);
    expect(white.g, greaterThan(240));
  });

  test('large photos are shrunk', () {
    final pixels = decodePhotoPixels(png((i) {}, size: 400));
    expect(pixels.width, lessThanOrEqualTo(160));
  });
}
