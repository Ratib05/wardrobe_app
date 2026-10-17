import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/engine/scoring.dart';

import '../../../helpers.dart';

void main() {
  test('default weights sum to 1', () {
    final sum = ScoreFactor.values.fold(0.0, (s, f) => s + f.defaultWeight);
    expect(sum, closeTo(1.0, 1e-9));
  });

  test('colourPairScore', () {
    const c = WardrobeColour.values;
    expect(colourPairScore(WardrobeColour.black, WardrobeColour.red), 1.0);
    expect(colourPairScore(WardrobeColour.red, WardrobeColour.red), 0.8);
    expect(colourPairScore(WardrobeColour.blue, WardrobeColour.lightBlue), 0.8);
    expect(colourPairScore(WardrobeColour.red, WardrobeColour.pink), 0.0);
    expect(colourPairScore(WardrobeColour.pink, WardrobeColour.red), 0.0);
    expect(colourPairScore(WardrobeColour.blue, WardrobeColour.yellow), 0.5);
    expect(colourPairScore(null, WardrobeColour.red), 0.5);
    expect(c, isNotEmpty);
  });

  test('colourScore of neutrals is 1.0 with a reason', () {
    final s = colourScore([
      item(primaryColour: WardrobeColour.navy),
      item(primaryColour: WardrobeColour.white),
      item(primaryColour: WardrobeColour.black),
    ]);
    expect(s.value, 1.0);
    expect(s.reason, 'Colours are compatible');
  });

  test('occasionScore with a selected occasion', () {
    final s = occasionScore([
      item(occasions: {Occasion.work}),
      item(occasions: {Occasion.casual}),
      item(),
    ], Occasion.work);
    expect(s.value, 0.5);
    expect(s.reason, isNull);
  });

  test('occasionScore reasons are truthful', () {
    final all = occasionScore([
      item(occasions: {Occasion.work}),
      item(occasions: {Occasion.work, Occasion.casual}),
    ], Occasion.work);
    expect(all.reason, 'All items suit Work');
    final partial = occasionScore([
      item(occasions: {Occasion.work}),
      item(),
    ], Occasion.work);
    expect(partial.value, 0.75);
    expect(partial.reason, 'No item conflicts with Work');
  });

  test('occasionScore without a selection', () {
    final shared = occasionScore([
      item(occasions: {Occasion.work, Occasion.formal}),
      item(occasions: {Occasion.formal}),
    ], null);
    expect(shared.value, 1.0);
    expect(shared.reason, 'Items share an occasion: Formal');
    expect(
      occasionScore([
        item(occasions: {Occasion.work}),
      ], null).value,
      0.5,
    );
  });

  test('seasonScore', () {
    expect(
      seasonScore([
        item(seasons: {Season.summer}),
        item(seasons: {Season.winter}),
      ], null).value,
      0.0,
    );
    final s = seasonScore([
      item(seasons: {Season.spring, Season.summer}),
      item(seasons: {Season.summer}),
    ], null);
    expect(s.value, 1.0);
    expect(s.reason, 'Items share a season: Summer');
    expect(
      seasonScore([
        item(seasons: {Season.winter}),
      ], Season.winter).reason,
      'Suitable for Winter',
    );
  });

  test('formalityScore', () {
    expect(
      formalityScore([
        item(formality: Formality.casual),
        item(formality: Formality.formal),
      ]).value,
      0.25,
    );
    final same = formalityScore([
      item(formality: Formality.casual),
      item(formality: Formality.casual),
    ]);
    expect(same.value, 1.0);
    expect(same.reason, 'Formality levels are consistent');
    expect(
      formalityScore([item(formality: Formality.casual), item()]).value,
      0.5,
    );
  });

  test('styleScore', () {
    final same = styleScore([
      item(styleTags: {StyleTag.classic}),
      item(styleTags: {StyleTag.classic}),
    ]);
    expect(same.value, 1.0);
    expect(same.reason, 'Items share a style: Classic');
    expect(
      styleScore([
        item(styleTags: {StyleTag.classic}),
        item(styleTags: {StyleTag.sporty}),
      ]).value,
      0.0,
    );
    expect(
      styleScore([
        item(styleTags: {StyleTag.classic}),
        item(),
      ]).value,
      0.5,
    );
  });

  test('preferenceScore', () {
    final items = [
      item(primaryColour: WardrobeColour.navy),
      item(primaryColour: WardrobeColour.red),
    ];
    expect(
      preferenceScore(items, const RecommendationPreferences()).value,
      0.5,
    );
    expect(
      preferenceScore(
        items,
        const RecommendationPreferences(
          preferredColours: {WardrobeColour.navy},
        ),
      ).value,
      0.5,
    );
    final all = preferenceScore(
      items,
      const RecommendationPreferences(
        preferredColours: {WardrobeColour.navy, WardrobeColour.red},
      ),
    );
    expect(all.value, 1.0);
    expect(all.reason, 'Matches your preferences');
  });

  test('feedbackScore', () {
    expect(feedbackScore(null).value, 0.5);
    expect(feedbackScore(const FeedbackSummary(latestRating: 5)).value, 1.0);
    expect(
      feedbackScore(const FeedbackSummary(latestRating: 5)).reason,
      'You rated this 5/5',
    );
    expect(feedbackScore(const FeedbackSummary(latestRating: 1)).value, 0.0);
    final liked = feedbackScore(const FeedbackSummary(liked: true));
    expect(liked.value, 1.0);
    expect(liked.reason, 'You liked this combination');
  });

  test('items with no attributes are never penalised', () {
    final items = [item(), item(), item()];
    const prefs = RecommendationPreferences();
    final values = [
      colourScore(items).value,
      occasionScore(items, null).value,
      formalityScore(items).value,
      styleScore(items).value,
      seasonScore(items, null).value,
      preferenceScore(items, prefs).value,
      feedbackScore(null).value,
    ];
    expect(values, everyElement(0.5));
  });
}
