import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/colour_match.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

WardrobeColour nameOf(int rgb) => closestColours((
  r: (rgb >> 16) & 255,
  g: (rgb >> 8) & 255,
  b: rgb & 255,
)).first.colour;

void main() {
  test('every swatch matches itself', () {
    for (final c in WardrobeColour.values) {
      if (c == WardrobeColour.multicolour) continue;
      expect(closestColours(rgbOf(c.argb)).first.colour, c, reason: c.label);
    }
  });

  test('realistic garment shades get the right name', () {
    expect(nameOf(0x22304F), WardrobeColour.navy);
    expect(nameOf(0x242424), WardrobeColour.black);
    expect(nameOf(0x4C4C4C), WardrobeColour.charcoal);
    expect(nameOf(0x66733A), WardrobeColour.olive);
    expect(nameOf(0x701C2C), WardrobeColour.burgundy);
    expect(nameOf(0x5472A0), WardrobeColour.denim);
    expect(nameOf(0x8CA6C6), WardrobeColour.lightDenim);
    expect(nameOf(0xDDCDB0), WardrobeColour.beige);
    expect(nameOf(0xA5502C), WardrobeColour.rust);
    expect(nameOf(0xF0F0F0), WardrobeColour.white);
    expect(nameOf(0xF2E9D5), WardrobeColour.cream);
    expect(nameOf(0xC4A070), WardrobeColour.tan);
    expect(nameOf(0x1E4A2A), WardrobeColour.forestGreen);
    expect(nameOf(0xD2A21A), WardrobeColour.mustard);
  });

  test('Multicolour is never returned', () {
    expect(
      closestColours(
        rgbOf(WardrobeColour.multicolour.argb),
      ).map((m) => m.colour),
      isNot(contains(WardrobeColour.multicolour)),
    );
  });

  test('results are ordered closest first', () {
    final d = closestColours(rgbOf(0x1976D2)).map((m) => m.distance).toList();
    expect(d, [...d]..sort());
  });

  test('alternativeTo names a close runner-up only', () {
    expect(
      alternativeTo(closestColours(rgbOf(WardrobeColour.red.argb))),
      isNull,
    );
    // Between navy and denim-ish blue: ambiguous.
    final ambiguous = closestColours((r: 0x2D, g: 0x3E, b: 0x68));
    expect(alternativeTo(ambiguous), isNotNull);
  });
}
