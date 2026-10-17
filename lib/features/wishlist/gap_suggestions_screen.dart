import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import '../recommendations/engine/gap_analysis.dart';
import 'gap_providers.dart';
import 'wishlist_providers.dart';

/// Potential purchases that would unlock more outfits.
class GapSuggestionsScreen extends ConsumerWidget {
  const GapSuggestionsScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe gaps')),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(e),
        data: (r) {
          if (r.suggestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  r.needClothing
                      ? 'Add some clothing first'
                      : 'No suggestions right now — your wardrobe covers '
                            'your outfit types.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: r.suggestions.length,
            itemBuilder: (context, i) {
              final s = r.suggestions[i];
              return Card(
                key: Key('gap-${s.key}'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(
                            label: Text(
                              s.kind == GapKind.needed
                                  ? 'Needed'
                                  : 'Adds ${s.newOutfits} outfits',
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(s.explanation),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () =>
                                _store(ref, s, WishlistStatus.planned),
                            child: const Text('Add to wishlist'),
                          ),
                          TextButton(
                            onPressed: () =>
                                _store(ref, s, WishlistStatus.dismissed),
                            child: const Text('Not for me'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
