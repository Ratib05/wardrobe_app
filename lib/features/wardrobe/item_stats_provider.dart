import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../outfits/outfit_providers.dart';
import '../recommendations/engine/recommendation_engine.dart';
import '../recommendations/recommendations_providers.dart';
import 'wardrobe_providers.dart';

typedef ItemStats = ({int savedOutfits, int validCombos});

/// Numbers shown on an item's edit screen: how many saved outfits contain it
/// and how many valid outfit combinations the recommendation rules can build
/// with it (0 while the item is hidden, archived or in repair).
final itemStatsProvider = FutureProvider.autoDispose.family<ItemStats, String>((
  ref,
  id,
) async {
  final saved = await ref.read(clothingRepositoryProvider).outfitCount(id);
  ref.watch(outfitsProvider);
  final items = await ref.watch(wardrobeItemsProvider(false).future);
  final prefs = await ref.watch(preferencesProvider.future);
  final eligible = items.where((i) => isEligible(i, prefs)).toList();
  final item = eligible.where((i) => i.id == id).firstOrNull;
  final combos = item == null
      ? 0
      : recommend(
          RecommendationRequest(
            items: eligible,
            preferences: prefs,
            mustInclude: item,
            limit: 1 << 30,
          ),
        ).length;
  return (savedOutfits: saved, validCombos: combos);
});
