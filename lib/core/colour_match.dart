// Names a pixel colour with the closest of the app's fixed colours. Pure Dart:
// no Flutter, no I/O. Distance is measured in CIELAB so "closest" matches
// what people see.

import 'dart:math' as math;

import 'wardrobe_values.dart';

typedef Rgb = ({int r, int g, int b});

typedef ColourMatch = ({WardrobeColour colour, double distance});

Rgb rgbOf(int argb) =>
    (r: (argb >> 16) & 0xFF, g: (argb >> 8) & 0xFF, b: argb & 0xFF);

/// Shades real garments show up as in photos, besides each colour's swatch.
/// A swatch alone misreads clothes (a real navy shirt is nearer the Charcoal
/// swatch than the Navy one). ponytail: this table is the tuning knob; add
/// shades here when a photo reads wrong.
const _photographedShades = <WardrobeColour, List<int>>{
  WardrobeColour.black: [0x1E1E1E, 0x2B2B2B],
  WardrobeColour.white: [0xEEEEEE, 0xF5F5F0],
  WardrobeColour.grey: [0x808080, 0xA9A9A9, 0xBDBDBD],
  WardrobeColour.navy: [0x1F2A44, 0x24304F, 0x14213D],
  WardrobeColour.charcoal: [0x4A4A4A, 0x555555],
  WardrobeColour.beige: [0xE0D2B8, 0xC8B79A],
  WardrobeColour.stone: [0xBDB3A0, 0xA89F8E],
  WardrobeColour.brown: [0x7B5B45, 0x8B6B4A],
  WardrobeColour.darkBrown: [0x4A3728],
  WardrobeColour.denim: [0x4F6D94, 0x6B87AD, 0x2F4767],
  WardrobeColour.red: [0xC62828, 0xE53935],
  WardrobeColour.burgundy: [0x6D1A2A, 0x5C1A25],
  WardrobeColour.pink: [0xF8BBD0, 0xF06292],
  WardrobeColour.orange: [0xF57C00],
  WardrobeColour.rust: [0xA0522D, 0x9C4A2A],
  WardrobeColour.yellow: [0xFBC02D, 0xF9E04B],
  WardrobeColour.green: [0x2E7D32, 0x43A047],
  WardrobeColour.olive: [0x6B7A3A, 0x5E6B33],
  WardrobeColour.blue: [0x1565C0, 0x2979C8],
  WardrobeColour.lightBlue: [0x9ACBEA, 0xB3E5FC],
  WardrobeColour.purple: [0x6A1B9A, 0x8E44AD],
};

typedef Lab = (double, double, double);

double _linear(int channel) {
  final c = channel / 255;
  return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4) * 1.0;
}

double _labF(double t) =>
    t > 0.008856 ? math.pow(t, 1 / 3) * 1.0 : 7.787 * t + 16 / 116;

Lab labOf(Rgb c) {
  final r = _linear(c.r), g = _linear(c.g), b = _linear(c.b);
  final x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  final y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  final fx = _labF(x), fy = _labF(y), fz = _labF(z);
  return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
}

double _distance(Lab a, Lab b) {
  final dl = a.$1 - b.$1, da = a.$2 - b.$2, db = a.$3 - b.$3;
  return math.sqrt(dl * dl + da * da + db * db);
}

/// Reference Lab values per colour (swatch first), built once.
final _references = <WardrobeColour, List<Lab>>{
  for (final c in WardrobeColour.values)
    if (c != WardrobeColour.multicolour)
      c: [
        labOf(rgbOf(c.argb)),
        for (final shade in _photographedShades[c] ?? const <int>[])
          labOf(rgbOf(shade)),
      ],
};

/// The colours nearest to [colour], closest first. Never Multicolour.
List<ColourMatch> closestColours(Rgb colour) => closestToLab(labOf(colour));

List<ColourMatch> closestToLab(Lab lab) {
  final matches = <ColourMatch>[
    for (final entry in _references.entries)
      (
        colour: entry.key,
        distance: entry.value
            .map((ref) => _distance(lab, ref))
            .reduce(math.min),
      ),
  ];
  matches.sort((a, b) => a.distance.compareTo(b.distance));
  return matches;
}

/// The runner-up when it is nearly as close as the best match, so the UI can
/// say "could also be …".
WardrobeColour? alternativeTo(List<ColourMatch> matches) {
  if (matches.length < 2) return null;
  final best = matches[0], next = matches[1];
  return next.distance <= best.distance * 1.5 + 2 ? next.colour : null;
}
