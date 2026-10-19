import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/engine/gap_analysis.dart';
import 'package:wardrobe_app/features/recommendations/engine/scoring.dart';

import '../../../helpers.dart';

ClothingItem plain(String id, ClothingCategory c) => item(id: id, category: c);

ClothingItem neutral(String id, ClothingCategory c) => item(
  id: id,
  category: c,
  primaryColour: WardrobeColour.black,
  formality: Formality.casual,
);

void main() {
  test('nothing owned gives no suggestions', () {
    expect(analyseGaps(const GapRequest(items: [])), isEmpty);
    expect(canAnalyseGaps([]), isFalse);
    expect(canAnalyseGaps([plain('s', ClothingCategory.footwear)]), isFalse);
  });

  test('tops and bottoms without footwear need footwear', () {
    final items = [
      for (var i = 0; i < 3; i++) plain('t$i', ClothingCategory.top),
      for (var i = 0; i < 2; i++) plain('b$i', ClothingCategory.bottom),
    ];
    final result = analyseGaps(GapRequest(items: items));
    expect(result, isNotEmpty);
    expect(
      result.every((s) => s.category == ClothingCategory.footwear),
      isTrue,
    );
    expect(result.first.kind, GapKind.needed);
    expect(result.first.newOutfits, 6);
    expect(result.first.explanation, contains('6 outfits possible'));
  });

  test('a wardrobe that can make outfits only gets useful suggestions', () {
    final items = [
      for (var i = 0; i < 3; i++) neutral('t$i', ClothingCategory.top),
      for (var i = 0; i < 3; i++) neutral('b$i', ClothingCategory.bottom),
      neutral('s', ClothingCategory.footwear),
    ];
    final result = analyseGaps(GapRequest(items: items));
    expect(result, isNotEmpty);
    for (final s in result) {
      expect(s.kind, GapKind.useful);
      expect(s.newOutfits, greaterThanOrEqualTo(3));
    }
  });

  test('no dress suggestion when no dress is owned', () {
    final items = [
      for (var i = 0; i < 3; i++) neutral('t$i', ClothingCategory.top),
      for (var i = 0; i < 3; i++) neutral('b$i', ClothingCategory.bottom),
      neutral('s', ClothingCategory.footwear),
    ];
    final result = analyseGaps(GapRequest(items: items));
    expect(result.any((s) => s.category == ClothingCategory.onePiece), isFalse);
    expect(
      result.any((s) => s.category == ClothingCategory.accessory),
      isFalse,
    );
  });

  test('avoided colours are not suggested; preferred ones come first', () {
    final items = [
      plain('t', ClothingCategory.top),
      plain('b', ClothingCategory.bottom),
    ];
    final avoided = analyseGaps(
      GapRequest(
        items: items,
        preferences: const RecommendationPreferences(
          excludedColours: {WardrobeColour.black},
        ),
      ),
    );
    expect(avoided.any((s) => s.colour == WardrobeColour.black), isFalse);

    final preferred = analyseGaps(
      GapRequest(
        items: items,
        preferences: const RecommendationPreferences(
          preferredColours: {WardrobeColour.green},
        ),
      ),
    );
    expect(preferred.first.colour, WardrobeColour.green);
  });

  test('excluded keys are hidden', () {
    final items = [
      plain('t', ClothingCategory.top),
      plain('b', ClothingCategory.bottom),
    ];
    final first = analyseGaps(GapRequest(items: items)).first;
    final again = analyseGaps(
      GapRequest(items: items, excludedKeys: {first.key}),
    );
    expect(again.any((s) => s.key == first.key), isFalse);
  });

  test('at most two per category, deterministic', () {
    final items = [
      for (var i = 0; i < 3; i++) neutral('t$i', ClothingCategory.top),
      for (var i = 0; i < 3; i++) neutral('b$i', ClothingCategory.bottom),
      neutral('s', ClothingCategory.footwear),
    ];
    final a = analyseGaps(GapRequest(items: items));
    final b = analyseGaps(GapRequest(items: items.reversed.toList()));
    expect(a.map((s) => s.key), b.map((s) => s.key));
    for (final c in ClothingCategory.values) {
      expect(a.where((s) => s.category == c).length, lessThanOrEqualTo(2));
    }
  });

  group('neutral colours', () {
    final owned = [
      for (var i = 0; i < 3; i++) neutral('t$i', ClothingCategory.top),
      for (var i = 0; i < 3; i++) neutral('b$i', ClothingCategory.bottom),
      neutral('s', ClothingCategory.footwear),
    ];

    test('every plain neutral unlocks the same number of outfits', () {
      // The shortcut of trying one neutral per category relies on this.
      final counts = {
        for (final c in WardrobeColour.values.where((c) => c.isNeutral))
          outfitsUnlockedBy(
            items: owned,
            category: ClothingCategory.footwear,
            colour: c,
            formality: Formality.casual,
          ),
      };
      expect(counts, hasLength(1));
    });

    test('suggests the neutral you own fewest of, and says so', () {
      final shoes = analyseGaps(
        GapRequest(items: owned),
      ).firstWhere((s) => s.category == ClothingCategory.footwear);
      expect(shoes.colour, WardrobeColour.white); // black is already owned
      expect(shoes.explanation, endsWith('You have no white shoes yet.'));
    });

    test('only one plain neutral per category and formality', () {
      final result = analyseGaps(GapRequest(items: owned));
      for (final c in ClothingCategory.values) {
        expect(
          result.where((s) => s.category == c).length,
          lessThanOrEqualTo(1),
        );
      }
    });

    test('hiding a suggestion brings up the next neutral', () {
      final items = [
        plain('t', ClothingCategory.top),
        plain('b', ClothingCategory.bottom),
      ];
      final first = analyseGaps(GapRequest(items: items)).first;
      final again =
          analyseGaps(
            GapRequest(items: items, excludedKeys: {first.key}),
          ).where(
            (s) =>
                s.category == first.category && s.formality == first.formality,
          );
      expect(again, hasLength(1));
      expect(again.single.colour, isNot(first.colour));
      expect(again.single.colour.isNeutral, isTrue);
    });
  });

  test('archived items are ignored', () {
    final items = [
      item(id: 't', category: ClothingCategory.top, isArchived: true),
      item(id: 'b', category: ClothingCategory.bottom, isArchived: true),
    ];
    expect(analyseGaps(GapRequest(items: items)), isEmpty);
  });

  test('suggestions list the owned items they pair with', () {
    final items = [
      plain('t', ClothingCategory.top),
      plain('b', ClothingCategory.bottom),
    ];
    final first = analyseGaps(GapRequest(items: items)).first;
    expect(first.partners.map((p) => p.id).toSet(), {'t', 'b'});
    expect(first.partnerCount, 2);
  });

  test('outfitsUnlockedBy counts every valid outfit with the new item', () {
    final items = [
      plain('t1', ClothingCategory.top),
      plain('t2', ClothingCategory.top),
      plain('b', ClothingCategory.bottom),
    ];
    expect(
      outfitsUnlockedBy(items: items, category: ClothingCategory.footwear),
      2,
    );
    expect(
      outfitsUnlockedBy(items: items, category: ClothingCategory.onePiece),
      0,
    );
  });
}
