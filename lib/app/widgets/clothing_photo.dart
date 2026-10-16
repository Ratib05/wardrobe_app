import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../providers.dart';

IconData categoryIcon(ClothingCategory category) => switch (category) {
  ClothingCategory.top => Icons.checkroom,
  ClothingCategory.bottom => Icons.straighten,
  ClothingCategory.onePiece => Icons.dry_cleaning,
  ClothingCategory.outerwear => Icons.ac_unit,
  ClothingCategory.footwear => Icons.hiking,
  ClothingCategory.accessory => Icons.watch,
};

/// An item's photo. Shows a category icon when there is no photo and a
/// "Photo missing" placeholder when the file is gone or unreadable.
/// Fills its parent unless [size] is given.
class ClothingPhoto extends ConsumerWidget {
  const ClothingPhoto(this.item, {super.key, this.size});

  final ClothingItem item;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    Widget placeholder(IconData icon, {String? text}) => ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: scheme.onSurfaceVariant),
            if (text != null && (size == null || size! >= 96))
              Text(text, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );

    Widget child;
    if (item.imagePath == null) {
      child = placeholder(categoryIcon(item.category));
    } else {
      final file = ref.watch(imageStorageProvider).fileFor(item.imagePath);
      if (file == null || !file.existsSync()) {
        child = placeholder(Icons.broken_image_outlined, text: 'Photo missing');
      } else {
        child = Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: 400,
          errorBuilder: (_, _, _) =>
              placeholder(Icons.broken_image_outlined, text: 'Photo missing'),
        );
      }
    }
    return size == null ? child : SizedBox(width: size, height: size, child: child);
  }
}
