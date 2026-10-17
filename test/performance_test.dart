import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/engine/gap_analysis.dart';
import 'package:wardrobe_app/features/recommendations/engine/recommendation_engine.dart';
import 'package:wardrobe_app/features/wardrobe/wardrobe_filter.dart';

import 'helpers.dart';

/// A reproducible 500-item wardrobe with realistic spread of attributes.
List<ClothingItem> largeWardrobe() {
  final random = Random(42);
  T pick<T>(List<T> values) => values[random.nextInt(values.length)];
  Set<T> some<T>(List<T> values, int max) => {
    for (var i = 0; i < random.nextInt(max + 1); i++) pick(values),
  };

  const counts = {
    ClothingCategory.top: 200,
    ClothingCategory.bottom: 120,
    ClothingCategory.onePiece: 40,
    ClothingCategory.footwear: 60,
    ClothingCategory.outerwear: 50,
    ClothingCategory.accessory: 30,
  };
  final items = <ClothingItem>[];
  counts.forEach((category, n) {
    for (var i = 0; i < n; i++) {
      items.add(
        item(
          id: '${category.name}-$i',
          name: '${category.label} $i',
          category: category,
          primaryColour: random.nextInt(10) == 0
              ? null
              : pick(WardrobeColour.values),
          formality: random.nextInt(5) == 0 ? null : pick(Formality.values),
          styleTags: some(StyleTag.values, 2),
          seasons: some(Season.values, 2),
          occasions: some(Occasion.values, 2),
          isFavourite: random.nextInt(10) == 0,
        ),
      );
    }
  });
  return items;
}

void main() {
  final items = largeWardrobe();

  Duration time(void Function() body) {
    final sw = Stopwatch()..start();
    body();
    return sw.elapsed;
  }

  test('500 items: filtering stays interactive', () {
    final elapsed = time(
      () => const WardrobeFilter(
        query: 'top',
        seasons: {Season.summer},
        sort: WardrobeSort.name,
      ).apply(items),
    );
    // ignore: avoid_print
    print('filter 500 items: ${elapsed.inMilliseconds} ms');
    expect(elapsed, lessThan(const Duration(milliseconds: 50)));
  });

  test('500 items: recommendations finish well under a second', () {
    late List<Recommendation> recs;
    final elapsed = time(
      () => recs = recommend(RecommendationRequest(items: items)),
    );
    // ignore: avoid_print
    print('recommend 500 items: ${elapsed.inMilliseconds} ms');
    expect(recs, hasLength(20));
    expect(elapsed, lessThan(const Duration(seconds: 1)));
  });

  test('500 items: gap analysis finishes within seconds', () {
    late List<GapSuggestion> gaps;
    final elapsed = time(() => gaps = analyseGaps(GapRequest(items: items)));
    // ignore: avoid_print
    print('gap analysis 500 items: ${elapsed.inMilliseconds} ms');
    expect(gaps.length, lessThanOrEqualTo(10));
    expect(elapsed, lessThan(const Duration(seconds: 10)));
  });
}
