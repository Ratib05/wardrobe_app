// Deterministic scoring rules for outfit recommendations.
// Pure Dart: only imports lib/core (no Flutter, no database).
//
// Every factor returns a value in [0, 1]. Missing data scores a neutral 0.5
// so incomplete items are never treated as incompatible. A factor only
// supplies a [FactorScore.reason] when its value is at least 0.75 and the
// reason text is true for the items given.

import '../../../core/clothing_item.dart';
import '../../../core/wardrobe_values.dart';

enum ScoreFactor {
  colour(0.25),
  occasion(0.20),
  formality(0.15),
  style(0.15),
  season(0.10),
  preferences(0.10),
  feedback(0.05);

  const ScoreFactor(this.defaultWeight);
  final double defaultWeight;
}

const double neutralScore = 0.5;
const double reasonThreshold = 0.75;

class FactorScore {
  const FactorScore(this.value, [this.reason]);

  final double value;

  /// Plain-language explanation; set only when [value] >= 0.75.
  final String? reason;
}

class RecommendationPreferences {
  const RecommendationPreferences({
    this.preferredColours = const {},
    this.preferredStyles = const {},
    this.preferredFormalities = const {},
    this.excludedColours = const {},
    this.excludedStyles = const {},
  });

  final Set<WardrobeColour> preferredColours;
  final Set<StyleTag> preferredStyles;
  final Set<Formality> preferredFormalities;
  final Set<WardrobeColour> excludedColours;
  final Set<StyleTag> excludedStyles;

  bool get hasPreferred =>
      preferredColours.isNotEmpty ||
      preferredStyles.isNotEmpty ||
      preferredFormalities.isNotEmpty;
}

class FeedbackSummary {
  const FeedbackSummary({
    this.liked = false,
    this.dismissed = false,
    this.latestRating,
  });

  final bool liked;
  final bool dismissed;
  final int? latestRating;
}

/// Colour pairs that clash regardless of family rules.
const clashingColourPairs = <(WardrobeColour, WardrobeColour)>[
  (WardrobeColour.red, WardrobeColour.pink),
  (WardrobeColour.red, WardrobeColour.orange),
  (WardrobeColour.orange, WardrobeColour.pink),
  (WardrobeColour.red, WardrobeColour.green),
  (WardrobeColour.orange, WardrobeColour.purple),
];

bool _clashes(WardrobeColour a, WardrobeColour b) => clashingColourPairs.any(
  (p) => (p.$1 == a && p.$2 == b) || (p.$1 == b && p.$2 == a),
);

/// Neutral with anything 1.0; same colour or family 0.8; clash 0.0;
/// otherwise 0.5. A missing colour scores 0.5.
double colourPairScore(WardrobeColour? a, WardrobeColour? b) {
  if (a == null || b == null) return neutralScore;
  if (a.isNeutral || b.isNeutral) return 1.0;
  if (a == b || a.family == b.family) return 0.8;
  if (_clashes(a, b)) return 0.0;
  return neutralScore;
}

double _meanOverPairs(
  List<ClothingItem> items,
  double Function(ClothingItem, ClothingItem) pairScore,
) {
  var total = 0.0;
  var count = 0;
  for (var i = 0; i < items.length; i++) {
    for (var j = i + 1; j < items.length; j++) {
      total += pairScore(items[i], items[j]);
      count++;
    }
  }
  return count == 0 ? neutralScore : total / count;
}

FactorScore _withReason(double value, String reason) =>
    FactorScore(value, value >= reasonThreshold ? reason : null);

FactorScore colourScore(List<ClothingItem> items) {
  final value = _meanOverPairs(
    items,
    (a, b) => colourPairScore(a.primaryColour, b.primaryColour),
  );
  return _withReason(value, 'Colours are compatible');
}

/// Shared by occasion and season: either a chosen value that items should
/// suit, or (none chosen) whether the tagged items have a value in common.
FactorScore _tagScore<T extends Enum>({
  required List<Set<T>> tags,
  required List<T> order,
  required T? selected,
  required String Function(T) allSuit,
  required String Function(T) noConflict,
  required String Function(T) share,
}) {
  if (selected != null) {
    if (tags.isEmpty) return const FactorScore(neutralScore);
    var total = 0.0;
    for (final t in tags) {
      total += t.isEmpty ? neutralScore : (t.contains(selected) ? 1.0 : 0.0);
    }
    final value = total / tags.length;
    if (value < reasonThreshold) return FactorScore(value);
    final allTagged = tags.every((t) => t.contains(selected));
    return FactorScore(
      value,
      allTagged ? allSuit(selected) : noConflict(selected),
    );
  }
  final tagged = tags.where((t) => t.isNotEmpty).toList();
  if (tagged.length < 2) return const FactorScore(neutralScore);
  final common = tagged.skip(1).fold<Set<T>>({
    ...tagged.first,
  }, (acc, t) => acc.intersection(t));
  if (common.isEmpty) return const FactorScore(0.0);
  final first = order.firstWhere(common.contains);
  return FactorScore(1.0, share(first));
}

FactorScore occasionScore(List<ClothingItem> items, Occasion? selected) =>
    _tagScore<Occasion>(
      tags: [for (final i in items) i.occasions],
      order: Occasion.values,
      selected: selected,
      allSuit: (o) => 'All items suit ${o.label}',
      noConflict: (o) => 'No item conflicts with ${o.label}',
      share: (o) => 'Items share an occasion: ${o.label}',
    );

FactorScore seasonScore(List<ClothingItem> items, Season? selected) =>
    _tagScore<Season>(
      tags: [for (final i in items) i.seasons],
      order: Season.values,
      selected: selected,
      allSuit: (s) => 'Suitable for ${s.label}',
      noConflict: (s) => 'No item conflicts with ${s.label}',
      share: (s) => 'Items share a season: ${s.label}',
    );

/// 1 - (highest level - lowest level) / 4, over items with a known level.
FactorScore formalityScore(List<ClothingItem> items) {
  final levels = [
    for (final i in items)
      if (i.formality != null) i.formality!.index,
  ];
  if (levels.length < 2) return const FactorScore(neutralScore);
  levels.sort();
  final spread = levels.last - levels.first;
  return _withReason(
    1 - spread / (Formality.values.length - 1),
    'Formality levels are consistent',
  );
}

/// Pairs sharing a style tag score 1.0, others 0.0; a pair with an untagged
/// item scores 0.5.
FactorScore styleScore(List<ClothingItem> items) {
  final value = _meanOverPairs(items, (a, b) {
    if (a.styleTags.isEmpty || b.styleTags.isEmpty) return neutralScore;
    return a.styleTags.intersection(b.styleTags).isEmpty ? 0.0 : 1.0;
  });
  if (value < reasonThreshold) return FactorScore(value);
  // Name the style that the most items carry (ties: enum order).
  StyleTag? best;
  var bestCount = 1;
  for (final tag in StyleTag.values) {
    final count = items.where((i) => i.styleTags.contains(tag)).length;
    if (count > bestCount) {
      best = tag;
      bestCount = count;
    }
  }
  return FactorScore(
    value,
    best == null ? null : 'Items share a style: ${best.label}',
  );
}

/// Share of items matching a preferred colour, style or formality; 0.5 when
/// no preferences are set.
FactorScore preferenceScore(
  List<ClothingItem> items,
  RecommendationPreferences preferences,
) {
  if (!preferences.hasPreferred || items.isEmpty) {
    return const FactorScore(neutralScore);
  }
  var matches = 0;
  for (final i in items) {
    final colour = i.primaryColour;
    if ((colour != null && preferences.preferredColours.contains(colour)) ||
        i.styleTags.any(preferences.preferredStyles.contains) ||
        (i.formality != null &&
            preferences.preferredFormalities.contains(i.formality))) {
      matches++;
    }
  }
  return _withReason(matches / items.length, 'Matches your preferences');
}

/// Latest rating r gives (r - 1) / 4; otherwise a like or save gives 1.0.
FactorScore feedbackScore(FeedbackSummary? feedback) {
  if (feedback == null) return const FactorScore(neutralScore);
  final rating = feedback.latestRating;
  if (rating != null) {
    final value = (rating - 1) / 4;
    return FactorScore(
      value,
      value >= reasonThreshold ? 'You rated this $rating/5' : null,
    );
  }
  if (feedback.liked) {
    return const FactorScore(1.0, 'You liked this combination');
  }
  return const FactorScore(neutralScore);
}
