import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/clothing_photo.dart';
import '../../../core/clothing_item.dart';
import '../../../core/wardrobe_values.dart';

/// The wardrobe as shelves, one per category that has items: a stack of the
/// newest photos, the category name and its item count, then "See all".
class WardrobeShelves extends StatelessWidget {
  const WardrobeShelves({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onSeeAll,
  });

  final List<ClothingItem> items;
  final ValueChanged<ClothingCategory> onOpen;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final newestFirst = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Column(
      children: [
        for (final c in ClothingCategory.values)
          if (newestFirst.any((i) => i.category == c))
            _Shelf(
              category: c,
              items: newestFirst.where((i) => i.category == c).toList(),
              onTap: () => onOpen(c),
            ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('see-all'),
          onPressed: onSeeAll,
          child: const Text('SEE ALL'),
        ),
      ],
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.category,
    required this.items,
    required this.onTap,
  });

  final ClothingCategory category;
  final List<ClothingItem> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = items.length;
    final stack = items.take(3).toList();
    return InkWell(
      key: Key('shelf-${category.name}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              height: 112,
              child: Stack(
                children: [
                  // Back to front so the newest photo sits on top.
                  for (var i = stack.length - 1; i >= 0; i--)
                    Positioned(
                      left: i * 22.0,
                      top: i * 4.0,
                      width: 84,
                      height: 104 - i * 8.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ClothingPhoto(stack[i]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.labelPlural,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$n ${n == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
