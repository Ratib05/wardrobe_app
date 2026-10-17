import 'package:flutter/material.dart';

import '../../../app/widgets/clothing_photo.dart';
import '../engine/recommendation_engine.dart';

/// One suggested outfit: items, match label, reasons and actions.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.saved,
    required this.onSave,
    required this.onFavourite,
    required this.onRate,
    required this.onDismiss,
  });

  final Recommendation recommendation;

  /// Already saved as an outfit.
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onFavourite;
  final ValueChanged<int> onRate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in recommendation.items)
                  SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ClothingPhoto(item, size: 80),
                        ),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(recommendation.label.label),
              visualDensity: VisualDensity.compact,
            ),
            for (final reason in recommendation.reasons)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(reason, key: const Key('reason'))),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: saved ? null : onSave,
                  icon: Icon(saved ? Icons.check : Icons.bookmark_add_outlined),
                  label: Text(saved ? 'Saved' : 'Save'),
                ),
                IconButton(
                  tooltip: 'Favourite',
                  icon: const Icon(Icons.favorite_border),
                  onPressed: saved ? null : onFavourite,
                ),
                PopupMenuButton<int>(
                  tooltip: 'Rate',
                  icon: const Icon(Icons.star_border),
                  onSelected: onRate,
                  itemBuilder: (_) => [
                    for (var n = 1; n <= 5; n++)
                      PopupMenuItem(
                        value: n,
                        child: Text('$n star${n == 1 ? '' : 's'}'),
                      ),
                  ],
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
