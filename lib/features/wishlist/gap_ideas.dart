import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import '../recommendations/engine/gap_analysis.dart';
import 'gap_providers.dart';
import 'wishlist_providers.dart';

/// Ideas that add fewer outfits than this are offered more quietly.
const strongIdeaMinOutfits = 6;

/// Purchase ideas that would unlock more outfits, as cards.
class GapIdeas extends ConsumerWidget {
  const GapIdeas({super.key});

  Future<void> _store(WidgetRef ref, GapSuggestion s, WishlistStatus status) =>
      ref
          .read(wishlistRepositoryProvider)
          .save(
            name: s.title,
            category: s.category,
            preferredColours: {s.colour},
            formality: s.formality,
            reason: s.explanation,
            status: status,
          );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(gapSuggestionsProvider);
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ErrorView(e),
      data: (r) {
        if (r.suggestions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              r.needClothing
                  ? 'Add some clothing first'
                  : 'No suggestions right now — your wardrobe covers '
                        'your outfit types.',
              style: const TextStyle(color: AppColors.muted),
            ),
          );
        }
        // Strong ideas first, then the low-value ones (engine order is kept
        // within each group).
        final strong = [
          for (final s in r.suggestions)
            if (_isStrong(s)) s,
        ];
        final weak = [
          for (final s in r.suggestions)
            if (!_isStrong(s)) s,
        ];
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final s in [...strong, ...weak])
              _IdeaCard(
                suggestion: s,
                strong: _isStrong(s),
                onAdd: () => _store(ref, s, WishlistStatus.planned),
                onDismiss: () => _store(ref, s, WishlistStatus.dismissed),
              ),
          ],
        );
      },
    );
  }

  static bool _isStrong(GapSuggestion s) =>
      s.kind == GapKind.needed || s.newOutfits >= strongIdeaMinOutfits;
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    required this.suggestion,
    required this.strong,
    required this.onAdd,
    required this.onDismiss,
  });

  final GapSuggestion suggestion;
  final bool strong;
  final VoidCallback onAdd;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    final add = strong
        ? FilledButton(onPressed: onAdd, child: const Text('Add to wishlist'))
        : OutlinedButton(
            onPressed: onAdd,
            child: const Text('Add to wishlist'),
          );
    return SizedBox(
      width: math.min(340, MediaQuery.sizeOf(context).width - 32),
      child: Card(
        key: Key('gap-${s.key}'),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: s.kind == GapKind.needed
                          ? AppColors.primary
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s.kind == GapKind.needed
                          ? 'Needed'
                          : '+${s.newOutfits} new outfits',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: s.kind == GapKind.needed
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(s.explanation),
              if (s.partners.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('PAIRS WITH', style: monoCaption(context)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in s.partners.take(5))
                      Tooltip(
                        message: p.name,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ClothingPhoto(p, size: 44),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  add,
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Not for me'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
