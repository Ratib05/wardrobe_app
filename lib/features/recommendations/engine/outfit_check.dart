// "Outfit check": scores a hand-built outfit with the same rules and weights
// the recommendation engine uses, and explains the result truthfully.
// Pure Dart: only imports lib/core and the engine.

import '../../../core/clothing_item.dart';
import '../../../core/wardrobe_values.dart';
import 'scoring.dart';

typedef CheckNote = ({String text, bool good});

class OutfitCheck {
  const OutfitCheck(this.score, this.notes);

  /// 0–100.
  final int score;

  /// Strengths (factor reasons) first, then weaknesses (factors below 0.5).
  final List<CheckNote> notes;
}

const _weakness = {
  ScoreFactor.colour: 'Colours may clash',
  ScoreFactor.occasion: 'Items suit different occasions',
  ScoreFactor.formality: 'Formality levels are far apart',
  ScoreFactor.style: "Items don't share a style",
  ScoreFactor.season: 'Items suit different seasons',
  ScoreFactor.preferences: "Doesn't match your preferences",
};

OutfitCheck outfitCheck(
  List<ClothingItem> items, {
  Occasion? occasion,
  Season? season,
  RecommendationPreferences preferences = const RecommendationPreferences(),
  Map<ScoreFactor, double>? weights,
}) {
  final factors = <ScoreFactor, FactorScore>{
    ScoreFactor.colour: colourScore(items),
    ScoreFactor.occasion: occasionScore(items, occasion),
    ScoreFactor.formality: formalityScore(items),
    ScoreFactor.style: styleScore(items),
    ScoreFactor.season: seasonScore(items, season),
    ScoreFactor.preferences: preferenceScore(items, preferences),
    ScoreFactor.feedback: feedbackScore(null),
  };
  var total = 0.0, weightSum = 0.0;
  for (final f in ScoreFactor.values) {
    final w = weights?[f] ?? f.defaultWeight;
    total += w * factors[f]!.value;
    weightSum += w;
  }
  final notes = <CheckNote>[
    for (final f in ScoreFactor.values)
      if (factors[f]!.reason != null) (text: factors[f]!.reason!, good: true),
    for (final f in ScoreFactor.values)
      if (_weakness[f] != null && factors[f]!.value < 0.5)
        (text: _weakness[f]!, good: false),
  ];
  return OutfitCheck(
    weightSum == 0 ? 0 : (total / weightSum * 100).round(),
    notes,
  );
}

enum ShoeFit {
  strong('Strong fit'),
  good('Good fit'),
  formal('Slightly formal'),
  casual('Slightly casual');

  const ShoeFit(this.label);
  final String label;
}

typedef RankedShoe = ({ClothingItem shoe, ShoeFit? fit, int score});

/// Orders [shoes] by how well they go with the rest of the outfit. With
/// nothing else chosen yet there is nothing to compare, so shoes are listed
/// by name without a fit label.
List<RankedShoe> rankShoes(
  List<ClothingItem> shoes,
  List<ClothingItem> others, {
  Occasion? occasion,
  RecommendationPreferences preferences = const RecommendationPreferences(),
  Map<ScoreFactor, double>? weights,
}) {
  int byName(ClothingItem a, ClothingItem b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  if (others.isEmpty) {
    return [
      for (final s in (shoes.toList()..sort(byName)))
        (shoe: s, fit: null, score: 0),
    ];
  }
  final levels = [
    for (final o in others)
      if (o.formality != null) o.formality!.index,
  ];
  final reference = levels.isEmpty
      ? null
      : levels.reduce((a, b) => a + b) / levels.length;
  final ranked = [
    for (final s in shoes)
      (
        shoe: s,
        score: outfitCheck(
          [...others, s],
          occasion: occasion,
          preferences: preferences,
          weights: weights,
        ).score,
      ),
  ];
  ranked.sort((a, b) {
    final c = b.score.compareTo(a.score);
    return c != 0 ? c : byName(a.shoe, b.shoe);
  });
  return [
    for (final r in ranked)
      (shoe: r.shoe, fit: _fit(r.shoe, reference, r.score), score: r.score),
  ];
}

ShoeFit? _fit(ClothingItem shoe, double? reference, int score) {
  if (shoe.formality != null && reference != null) {
    final gap = shoe.formality!.index - reference;
    if (gap >= 1) return ShoeFit.formal;
    if (gap <= -1) return ShoeFit.casual;
  }
  return score >= 75 ? ShoeFit.strong : ShoeFit.good;
}
