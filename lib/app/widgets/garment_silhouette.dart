import 'package:flutter/material.dart';

import '../../core/wardrobe_values.dart';

/// A simple flat garment shape tinted with an item's colour. Shown where an
/// item has no photo (wardrobe grid, outfit builder, suggestions, gap ideas).
class GarmentSilhouette extends StatelessWidget {
  const GarmentSilhouette({
    super.key,
    required this.category,
    this.colour,
    this.dashed = false,
  });

  final ClothingCategory category;

  /// The item's main colour; a neutral grey when unknown.
  final WardrobeColour? colour;

  /// Draw an outline only (used for items you do not own yet).
  final bool dashed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(14),
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _SilhouettePainter(
          category,
          colour == null ? const Color(0xFFB9B8B0) : Color(colour!.argb),
          dashed,
        ),
      ),
    ),
  );
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter(this.category, this.fill, this.dashed);

  final ClothingCategory category;
  final Color fill;
  final bool dashed;

  /// Outlines in a 100 x 100 box.
  static final _shapes = <ClothingCategory, Path>{
    ClothingCategory.top: _polygon([
      [35, 14],
      [45, 14],
      [50, 22],
      [55, 14],
      [65, 14],
      [88, 28],
      [80, 42],
      [70, 36],
      [70, 88],
      [30, 88],
      [30, 36],
      [20, 42],
      [12, 28],
    ]),
    ClothingCategory.outerwear: _polygon([
      [38, 10],
      [50, 36],
      [62, 10],
      [78, 18],
      [84, 78],
      [72, 80],
      [70, 40],
      [70, 94],
      [30, 94],
      [30, 40],
      [28, 80],
      [16, 78],
      [22, 18],
    ]),
    ClothingCategory.bottom: _polygon([
      [32, 8],
      [68, 8],
      [72, 92],
      [54, 92],
      [50, 34],
      [46, 92],
      [28, 92],
    ]),
    ClothingCategory.onePiece: _polygon([
      [38, 8],
      [62, 8],
      [60, 34],
      [76, 92],
      [24, 92],
      [40, 34],
    ]),
    ClothingCategory.footwear: (Path()
      ..moveTo(10, 62)
      ..quadraticBezierTo(10, 48, 24, 48)
      ..lineTo(34, 48)
      ..quadraticBezierTo(42, 62, 58, 60)
      ..quadraticBezierTo(78, 60, 90, 66)
      ..lineTo(90, 74)
      ..lineTo(10, 74)
      ..close()),
    ClothingCategory.accessory: (Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(40, 10, 20, 80),
          const Radius.circular(6),
        ),
      )
      ..addOval(Rect.fromCircle(center: const Offset(50, 50), radius: 20))),
  };

  static Path _polygon(List<List<double>> points) {
    final path = Path()..moveTo(points.first[0], points.first[1]);
    for (final p in points.skip(1)) {
      path.lineTo(p[0], p[1]);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    final path = _shapes[category]!.transform(
      Matrix4.diagonal3Values(scale, scale, 1).storage,
    );
    final outline = Color.lerp(fill, Colors.black, 0.45)!;
    if (!dashed) {
      canvas.drawPath(path, Paint()..color = fill);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeJoin = StrokeJoin.round
        ..color = dashed ? outline.withValues(alpha: 0.6) : outline,
    );
    if (category == ClothingCategory.outerwear) {
      // Centre front line of the coat.
      canvas.drawLine(
        Offset(50 * scale, 36 * scale),
        Offset(50 * scale, 94 * scale),
        Paint()
          ..color = outline
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.category != category || old.fill != fill || old.dashed != dashed;
}
