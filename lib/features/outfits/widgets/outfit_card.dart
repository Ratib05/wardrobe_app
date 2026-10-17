import 'package:flutter/material.dart';

import '../../../app/widgets/clothing_photo.dart';
import '../outfit_repository.dart';

/// Summary of a saved outfit: name, photo strip, rating and favourite toggle.
class OutfitCard extends StatelessWidget {
  const OutfitCard({
    super.key,
    required this.outfit,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final OutfitWithItems outfit;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final o = outfit.outfit;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      o.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: o.isFavourite
                        ? 'Remove from favourites'
                        : 'Add to favourites',
                    icon: Icon(
                      o.isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: o.isFavourite ? Colors.redAccent : null,
                    ),
                    onPressed: onToggleFavourite,
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in outfit.items)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ClothingPhoto(item, size: 56),
                    ),
                ],
              ),
              if (o.rating != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Icon(
                          i <= o.rating! ? Icons.star : Icons.star_border,
                          size: 16,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
