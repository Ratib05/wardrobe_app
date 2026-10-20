import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/count_chip.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/garment_silhouette.dart';
import '../../core/clothing_item.dart';
import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import '../wardrobe/wardrobe_providers.dart';
import '../recommendations/engine/gap_analysis.dart';
import 'gap_providers.dart';
import 'wishlist_providers.dart';

/// Ideas that add fewer outfits than this are offered more quietly.
const strongIdeaMinOutfits = 6;

/// Purchase ideas that would unlock more outfits, as cards.
class GapIdeas extends ConsumerStatefulWidget {
  const GapIdeas({super.key});

  @override
  ConsumerState<GapIdeas> createState() => _GapIdeasState();

  static bool _isStrong(GapSuggestion s) =>
      s.kind == GapKind.needed ||
      (s.category != ClothingCategory.outerwear &&
          s.newOutfits >= strongIdeaMinOutfits);
}

class _GapIdeasState extends ConsumerState<GapIdeas> {
  GapTarget _target = noGapTarget;

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

  /// Pills for picking one value; each shows how many available items match.
  Widget _pills<T>(
    String label,
    List<T> values,
    String Function(T) name,
    int Function(T) count,
    T? selected,
    void Function(T?) onPick,
    int total,
  ) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        CountChip(
          key: Key('plan-$label-any'),
          label: 'Any',
          count: total,
          selected: selected == null,
          onTap: () => onPick(null),
        ),
        for (final v in values) ...[
          const SizedBox(width: 8),
          CountChip(
            key: Key('plan-$label-${name(v)}'),
            label: name(v),
            count: count(v),
            selected: selected == v,
            onTap: () => onPick(v),
          ),
        ],
      ],
    ),
  );

  Widget _planFor() {
    final items = [
      for (final i in ref.watch(wardrobeItemsProvider(false)).value ?? const [])
        if (i.isAvailable) i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PLAN FOR', style: monoCaption(context)),
        const SizedBox(height: 8),
        _pills<Occasion>(
          'occasion',
          Occasion.values,
          (o) => o.label,
          (o) => items.where((i) => i.occasions.contains(o)).length,
          _target.occasion,
          (o) => setState(
            () => _target = (occasion: o, formality: _target.formality),
          ),
          items.length,
        ),
        const SizedBox(height: 8),
        _pills<Formality>(
          'formality',
          Formality.values,
          (f) => f.label,
          (f) => items.where((i) => i.formality == f).length,
          _target.formality,
          (f) => setState(
            () => _target = (occasion: _target.occasion, formality: f),
          ),
          items.length,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(gapSuggestionsProvider(_target));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_planFor(), _results(results)],
    );
  }

  Widget _results(AsyncValue<GapResults> results) {
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
                  : _target == noGapTarget
                  ? 'No suggestions right now — your wardrobe covers '
                        'your outfit types.'
                  : 'Your wardrobe already covers these outfits.',
              style: const TextStyle(color: AppColors.muted),
            ),
          );
        }
        // Strong ideas first, then the low-value ones (engine order is kept
        // within each group).
        final strong = [
          for (final s in r.suggestions)
            if (GapIdeas._isStrong(s)) s,
        ];
        final weak = [
          for (final s in r.suggestions)
            if (!GapIdeas._isStrong(s)) s,
        ];
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final s in [...strong, ...weak])
              _IdeaCard(
                suggestion: s,
                strong: GapIdeas._isStrong(s),
                onAdd: () => _store(ref, s, WishlistStatus.planned),
                onDismiss: () => _store(ref, s, WishlistStatus.dismissed),
              ),
          ],
        );
      },
    );
  }
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

  /// An owned item as its photo; the item to buy as a dashed outline.
  Widget _tile(ClothingItem i) => Tooltip(
    message: isGapItem(i) ? suggestion.title : i.name,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isGapItem(i)
          ? SizedBox(
              key: const Key('gap-new-item'),
              width: 56,
              height: 56,
              child: GarmentSilhouette(
                category: i.category,
                colour: i.primaryColour,
                dashed: true,
              ),
            )
          : ClothingPhoto(i, size: 56),
    ),
  );

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
                          : s.category == ClothingCategory.outerwear
                          ? 'Over ${s.newOutfits} outfits'
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
              if (s.examples.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('EXAMPLE OUTFITS', style: monoCaption(context)),
                for (final outfit in s.examples) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final i in outfit) _tile(i)],
                  ),
                ],
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
