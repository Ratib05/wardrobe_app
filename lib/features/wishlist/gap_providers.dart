import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../recommendations/engine/gap_analysis.dart';
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

final gapSuggestionsProvider = FutureProvider<GapResults>((ref) async {
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
    ),
  );
  return GapResults(suggestions, needClothing: false);
});
