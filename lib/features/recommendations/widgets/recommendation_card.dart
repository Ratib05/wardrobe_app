import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/clothing_photo.dart';
import '../engine/recommendation_engine.dart';
import '../engine/scoring.dart';

const _factorLabels = {
  ScoreFactor.colour: 'Colour harmony',
  ScoreFactor.occasion: 'Occasion',
  ScoreFactor.formality: 'Formality',
  ScoreFactor.style: 'Style',
  ScoreFactor.season: 'Season',
  ScoreFactor.preferences: 'Your preferences',
  ScoreFactor.feedback: 'Past feedback',
};

/// One suggested outfit: rank, title, items, score, an expandable
/// "Why this outfit" section and the actions.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
    required this.saved,
    required this.onSave,
    required this.onFavourite,
    required this.onRate,
    required this.onDismiss,
  });

  final Recommendation recommendation;
  final int rank;

  /// Already saved as an outfit.
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onFavourite;
  final ValueChanged<int> onRate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#$rank', style: monoCaption(context)),
                      Text(
                        rec.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${rec.points} / 100',
                      key: const Key('score'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(rec.label.label, style: monoCaption(context)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in rec.items)
                  SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ClothingPhoto(item, size: 96),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.category.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: monoCaption(context),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: Key('why-${rec.fingerprint}'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: const Text(
                  'Why this outfit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  for (final f in ScoreFactor.values)
                    _FactorBar(
                      label: _factorLabels[f]!,
                      points: rec.factorPoints(f),
                      max: rec.maxPoints(f),
                      value: rec.factors[f]!.value,
                    ),
                  const SizedBox(height: 8),
                  for (final reason in rec.reasons)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(
                            child: Text(reason, key: const Key('reason')),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: saved ? null : onFavourite,
                          icon: const Icon(Icons.favorite_border, size: 18),
                          label: const Text('Favourite'),
                        ),
                        PopupMenuButton<int>(
                          tooltip: 'Rate',
                          onSelected: onRate,
                          itemBuilder: (_) => [
                            for (var n = 1; n <= 5; n++)
                              PopupMenuItem(
                                value: n,
                                child: Text('$n star${n == 1 ? '' : 's'}'),
                              ),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_border,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Rate',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('not-for-me'),
                  onPressed: onDismiss,
                  child: const Text('Not for me'),
                ),
                FilledButton.icon(
                  key: const Key('save-outfit'),
                  onPressed: saved ? null : onSave,
                  icon: Icon(
                    saved ? Icons.check : Icons.bookmark_add_outlined,
                    size: 18,
                  ),
                  label: Text(saved ? 'Saved' : 'Save outfit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  const _FactorBar({
    required this.label,
    required this.points,
    required this.max,
    required this.value,
  });

  final String label;
  final int points;
  final int max;
  final double value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 130, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.placeholder,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$points/$max',
            textAlign: TextAlign.right,
            style: monoCaption(context),
          ),
        ),
      ],
    ),
  );
}
