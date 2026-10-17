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

/// Custom score weights (fractions summing to 1); null means the defaults.
final scoreWeightsProvider = StreamProvider<Map<ScoreFactor, double>?>(
  (ref) => ref.watch(recommendationRepositoryProvider).watchWeights(),
);

typedef RecommendRunner =
    Future<({List<Recommendation> top, int total})> Function(
      RecommendationRequest request,
    );

/// Runs the engine off the UI isolate (about 0.6 s for a 500-item wardrobe).
/// Tests override this with a direct call.
final recommendRunnerProvider = Provider<RecommendRunner>(
  (ref) =>
      (request) => Isolate.run(() => recommendWithTotal(request)),
);

/// Optional filters. Records have value equality, so this works as a
/// provider family key.
typedef RecommendationFilters = ({
  Occasion? occasion,
  Season? season,
  Formality? formality,
  String? mustIncludeId,
});

const noRecommendationFilters = (
  occasion: null,
  season: null,
  formality: null,
  mustIncludeId: null,
);

class RecommendationResults {
  const RecommendationResults(
    this.recommendations,
    this.emptyReason,
    this.savedFingerprints,
    this.total,
  );

  final List<Recommendation> recommendations;

  /// How many valid combinations were ranked (more than are shown).
  final int total;

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
      final weights = await ref.watch(scoreWeightsProvider.future);
      final eligible = items.where((i) => isEligible(i, prefs)).toList();
      final must = filters.mustIncludeId == null
          ? null
          : items.where((i) => i.id == filters.mustIncludeId).firstOrNull;
      final result = await ref.read(recommendRunnerProvider)(
        RecommendationRequest(
          items: eligible,
          preferences: prefs,
          feedback: feedback,
          occasion: filters.occasion,
          season: filters.season,
          formality: filters.formality,
          weights: weights,
          mustInclude: must,
        ),
      );
      return RecommendationResults(
        result.top,
        result.top.isEmpty ? noResultsReason(eligible) : null,
        saved,
        result.total,
      );
    });
