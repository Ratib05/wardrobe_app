// Deterministic outfit recommendation engine.
// Pure Dart: only imports lib/core and the sibling scoring file, so it can be
// tested without Flutter or a database. Identical inputs always give
// identical results (every ordering ends in a unique tie-break).

import '../../../core/clothing_item.dart';
import '../../../core/outfit_templates.dart';
import '../../../core/wardrobe_values.dart';
import 'scoring.dart';

/// Stable identifier for a combination: sorted item ids joined with `|`.
String outfitFingerprint(Iterable<String> itemIds) =>
    (itemIds.toList()..sort()).join('|');

/// Available, and not excluded by the user's avoided colours or styles.
bool isEligible(ClothingItem item, RecommendationPreferences preferences) {
  if (!item.isAvailable) return false;
  final colour = item.primaryColour;
  if (colour != null && preferences.excludedColours.contains(colour)) {
    return false;
  }
  return !item.styleTags.any(preferences.excludedStyles.contains);
}

enum MatchLabel {
  strong('Strong match'),
  good('Good match'),
  possible('Possible match');

  const MatchLabel(this.label);
  final String label;

  static MatchLabel of(double score) {
    if (score >= 0.75) return strong;
    if (score >= 0.55) return good;
    return possible;
  }
}

class Recommendation {
  const Recommendation({
    required this.fingerprint,
    required this.template,
    required this.items,
    required this.score,
    required this.factors,
    required this.reasons,
  });

  final String fingerprint;
  final OutfitTemplate template;
  final List<ClothingItem> items;
  final double score;
  final Map<ScoreFactor, FactorScore> factors;
  final List<String> reasons;

  MatchLabel get label => MatchLabel.of(score);
}

class RecommendationRequest {
  const RecommendationRequest({
    required this.items,
    this.preferences = const RecommendationPreferences(),
    this.feedback = const {},
    this.occasion,
    this.season,
    this.limit = 20,
    this.maxPerCategory = 15,
    this.maxOuterwear = 6,
    this.weights,
    this.mustInclude,
  });

  final List<ClothingItem> items;
  final RecommendationPreferences preferences;

  /// Keyed by outfit fingerprint.
  final Map<String, FeedbackSummary> feedback;
  final Occasion? occasion;
  final Season? season;
  final int limit;
  final int maxPerCategory;
  final int maxOuterwear;
  final Map<ScoreFactor, double>? weights;

  /// When set, only combinations containing this item are generated (used by
  /// gap analysis to evaluate an item the user does not own yet). It bypasses
  /// eligibility and the per-category cap.
  final ClothingItem? mustInclude;
}

const _fallbackReason = 'Meets the basic outfit rules';

/// Orders a category's items so the cap keeps the most relevant ones:
/// favourites, then occasion match, then season match, then id.
// ponytail: per-category cap keeps favourites first; beyond the cap other
// items never appear. Add rotation or a "more" option if that is noticed.
List<ClothingItem> _capped(
  List<ClothingItem> items,
  int cap,
  Occasion? occasion,
  Season? season,
) {
  int rank(ClothingItem i) =>
      (i.isFavourite ? 4 : 0) +
      (occasion != null && i.occasions.contains(occasion) ? 2 : 0) +
      (season != null && i.seasons.contains(season) ? 1 : 0);
  final sorted = [...items]
    ..sort((a, b) {
      final r = rank(b).compareTo(rank(a));
      return r != 0 ? r : a.id.compareTo(b.id);
    });
  return sorted.length > cap ? sorted.sublist(0, cap) : sorted;
}

/// Generates, validates, scores and ranks outfits from [request.items].
List<Recommendation> recommend(RecommendationRequest request) {
  final weights = {
    for (final f in ScoreFactor.values)
      f: request.weights?[f] ?? f.defaultWeight,
  };

  final byCategory = <ClothingCategory, List<ClothingItem>>{};
  for (final item in request.items) {
    if (!isEligible(item, request.preferences)) continue;
    byCategory.putIfAbsent(item.category, () => []).add(item);
  }
  final pools = {
    for (final e in byCategory.entries)
      e.key: _capped(
        e.value,
        e.key == ClothingCategory.outerwear
            ? request.maxOuterwear
            : request.maxPerCategory,
        request.occasion,
        request.season,
      ),
  };

  final must = request.mustInclude;
  if (must != null) pools[must.category] = [must];

  final results = <Recommendation>[];
  for (final template in outfitTemplates) {
    if (must != null &&
        !template.required.contains(must.category) &&
        !template.optional.contains(must.category)) {
      continue;
    }
    final required = (template.required.toList()
      ..sort((a, b) => a.index.compareTo(b.index)));
    final lists = [
      for (final c in required) pools[c] ?? const <ClothingItem>[],
    ];
    if (lists.any((l) => l.isEmpty)) continue;
    final coats = template.optional.contains(ClothingCategory.outerwear)
        ? pools[ClothingCategory.outerwear] ?? const <ClothingItem>[]
        : const <ClothingItem>[];

    // Outerwear is optional, except when it is the item being evaluated.
    final coatOptions = must?.category == ClothingCategory.outerwear
        ? <ClothingItem?>[...coats]
        : <ClothingItem?>[null, ...coats];

    void walk(int depth, List<ClothingItem> chosen) {
      if (depth == lists.length) {
        for (final coat in coatOptions) {
          final outfit = [...chosen, ?coat];
          final rec = _score(template, outfit, request, weights);
          if (rec != null) results.add(rec);
        }
        return;
      }
      for (final item in lists[depth]) {
        walk(depth + 1, [...chosen, item]);
      }
    }

    walk(0, const []);
  }

  results.sort((a, b) {
    final c = b.score.compareTo(a.score);
    return c != 0 ? c : a.fingerprint.compareTo(b.fingerprint);
  });
  return results.length > request.limit
      ? results.sublist(0, request.limit)
      : results;
}

Recommendation? _score(
  OutfitTemplate template,
  List<ClothingItem> items,
  RecommendationRequest request,
  Map<ScoreFactor, double> weights,
) {
  final fingerprint = outfitFingerprint(items.map((i) => i.id));
  final feedback = request.feedback[fingerprint];
  if (feedback?.dismissed ?? false) return null;

  final factors = <ScoreFactor, FactorScore>{
    ScoreFactor.colour: colourScore(items),
    ScoreFactor.occasion: occasionScore(items, request.occasion),
    ScoreFactor.formality: formalityScore(items),
    ScoreFactor.style: styleScore(items),
    ScoreFactor.season: seasonScore(items, request.season),
    ScoreFactor.preferences: preferenceScore(items, request.preferences),
    ScoreFactor.feedback: feedbackScore(feedback),
  };
  var score = 0.0;
  for (final f in ScoreFactor.values) {
    score += weights[f]! * factors[f]!.value;
  }

  // Top three reasons by weighted contribution (ties: factor order).
  final withReason =
      [
        for (final f in ScoreFactor.values)
          if (factors[f]!.reason != null) f,
      ]..sort((a, b) {
        final c = (weights[b]! * factors[b]!.value).compareTo(
          weights[a]! * factors[a]!.value,
        );
        return c != 0 ? c : a.index.compareTo(b.index);
      });
  final reasons = [for (final f in withReason.take(3)) factors[f]!.reason!];

  return Recommendation(
    fingerprint: fingerprint,
    template: template,
    items: items,
    score: score,
    factors: factors,
    reasons: reasons.isEmpty ? const [_fallbackReason] : reasons,
  );
}

/// Why no recommendation can be made from [availableItems] (already
/// filtered to eligible items), or null if the wardrobe could form an outfit.
String? noResultsReason(List<ClothingItem> availableItems) {
  if (availableItems.isEmpty) {
    return 'Add some clothing to get recommendations.';
  }
  final present = availableItems.map((i) => i.category).toSet();
  Set<ClothingCategory>? fewest;
  for (final t in outfitTemplates) {
    final missing = t.required.difference(present);
    if (fewest == null || missing.length < fewest.length) fewest = missing;
  }
  if (fewest == null || fewest.isEmpty) return null;
  final labels = (fewest.toList()..sort((a, b) => a.index.compareTo(b.index)))
      .map((c) => c.label)
      .join(', ');
  return 'To get recommendations, add: $labels.';
}
