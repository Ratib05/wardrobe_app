import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../core/wardrobe_values.dart';
import '../recommendations/engine/gap_analysis.dart';
import '../recommendations/engine/recommendation_engine.dart' show isEligible;
import '../recommendations/recommendations_providers.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'wishlist_providers.dart';
import 'wishlist_repository.dart';

typedef GapRunner = Future<List<GapSuggestion>> Function(GapRequest request);

/// Runs the analysis off the UI isolate. Tests override this with a direct call.
final gapRunnerProvider = Provider<GapRunner>(
  (ref) =>
      (request) => Isolate.run(() => analyseGaps(request)),
);

final allWishlistProvider = StreamProvider<List<WishlistItem>>(
  (ref) => ref.watch(wishlistRepositoryProvider).watchAll(),
);

class GapResults {
  const GapResults(this.suggestions, {required this.needClothing});

  final List<GapSuggestion> suggestions;

  /// True when there is nothing to analyse yet (no tops, bottoms or dresses).
  final bool needClothing;
}

/// The event being planned for; both parts optional.
typedef GapTarget = ({Occasion? occasion, Formality? formality});

const noGapTarget = (occasion: null, formality: null);

final gapSuggestionsProvider = FutureProvider.family<GapResults, GapTarget>((
  ref,
  target,
) async {
  final items = await ref.watch(wardrobeItemsProvider(false).future);
  final prefs = await ref.watch(preferencesProvider.future);
  final wishlist = await ref.watch(allWishlistProvider.future);
  if (!canAnalyseGaps(items)) {
    return const GapResults([], needClothing: true);
  }
  final suggestions = await ref.read(gapRunnerProvider)(
    GapRequest(
      items: items,
      preferences: prefs,
      excludedKeys: wishlistGapKeys(wishlist),
      occasion: target.occasion,
      formality: target.formality,
    ),
  );
  return GapResults(suggestions, needClothing: false);
});

/// For each planned wishlist entry, how many valid outfits it would unlock.
// ponytail: computed on the UI isolate; a handful of entries is quick. Move
// it behind the gap runner if a large wishlist ever makes the page stutter.
final wishlistUnlocksProvider = FutureProvider<Map<String, int>>((ref) async {
  final items = await ref.watch(wardrobeItemsProvider(false).future);
  final prefs = await ref.watch(preferencesProvider.future);
  final planned = await ref.watch(
    wishlistProvider(WishlistStatus.planned).future,
  );
  final owned = [
    for (final i in items)
      if (isEligible(i, prefs)) i,
  ];
  return {
    for (final w in planned)
      w.id: outfitsUnlockedBy(
        items: owned,
        category: w.category,
        colour: w.preferredColours.length == 1
            ? w.preferredColours.first
            : null,
        formality: w.formality,
        preferences: prefs,
      ),
  };
});
