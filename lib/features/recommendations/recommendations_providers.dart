import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/wardrobe_values.dart';
import '../outfits/outfit_providers.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'engine/recommendation_engine.dart';
import 'engine/scoring.dart';
import 'recommendation_repository.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>(
  (ref) => RecommendationRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(outfitRepositoryProvider),
  ),
);

final preferencesProvider = StreamProvider<RecommendationPreferences>(
  (ref) => ref.watch(recommendationRepositoryProvider).watchPreferences(),
);

typedef RecommendRunner =
    Future<List<Recommendation>> Function(RecommendationRequest request);

/// Runs the engine off the UI isolate (about 0.6 s for a 500-item wardrobe).
/// Tests override this with a direct call.
final recommendRunnerProvider = Provider<RecommendRunner>(
  (ref) =>
      (request) => Isolate.run(() => recommend(request)),
);

/// Optional occasion/season to favour. Records have value equality, so this
/// works as a provider family key.
typedef RecommendationFilters = ({Occasion? occasion, Season? season});

class RecommendationResults {
  const RecommendationResults(
    this.recommendations,
    this.emptyReason,
    this.savedFingerprints,
  );

  final List<Recommendation> recommendations;

  /// Why there are no recommendations (null when some exist or the reason is
  /// simply that all of them were dismissed).
  final String? emptyReason;

  /// Combinations already saved as outfits.
  final Set<String> savedFingerprints;
}

/// Recomputed when the wardrobe or preferences change; call
/// `ref.invalidate(recommendationsProvider)` after writing feedback.
final recommendationsProvider =
    FutureProvider.family<RecommendationResults, RecommendationFilters>((
      ref,
      filters,
    ) async {
      final items = await ref.watch(wardrobeItemsProvider(false).future);
      final prefs = await ref.watch(preferencesProvider.future);
      final feedback = await ref
          .read(recommendationRepositoryProvider)
          .feedbackSummaries();
      final saved = await ref
          .read(outfitRepositoryProvider)
          .savedFingerprints();
      final eligible = items.where((i) => isEligible(i, prefs)).toList();
      final recs = await ref.read(recommendRunnerProvider)(
        RecommendationRequest(
          items: eligible,
          preferences: prefs,
          feedback: feedback,
          occasion: filters.occasion,
          season: filters.season,
        ),
      );
      return RecommendationResults(
        recs,
        recs.isEmpty ? noResultsReason(eligible) : null,
        saved,
      );
    });
