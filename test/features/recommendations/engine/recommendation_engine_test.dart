import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/engine/recommendation_engine.dart';
import 'package:wardrobe_app/features/recommendations/engine/scoring.dart';

import '../../../helpers.dart';

ClothingItem top(String id, {WardrobeColour? colour, bool archived = false}) =>
    item(
      id: id,
      category: ClothingCategory.top,
      primaryColour: colour,
      isArchived: archived,
    );
ClothingItem bottom(String id) =>
    item(id: id, category: ClothingCategory.bottom);
ClothingItem shoes(String id) =>
    item(id: id, category: ClothingCategory.footwear);
ClothingItem coat(String id) =>
    item(id: id, category: ClothingCategory.outerwear);

void main() {
  test('too few categories gives no results and a reason', () {
    final items = [top('t'), bottom('b')];
    expect(recommend(RecommendationRequest(items: items)), isEmpty);
    expect(noResultsReason(items), 'To get recommendations, add: Footwear.');
    expect(noResultsReason([]), 'Add some clothing to get recommendations.');
    expect(noResultsReason([top('t'), bottom('b'), shoes('s')]), isNull);
  });

  test(
    'archived and needs-repair items never appear; excluded colours removed',
    () {
      final items = [
        top('t1'),
        top('t-old', archived: true),
        item(
          id: 't-bad',
          category: ClothingCategory.top,
          condition: ItemCondition.needsRepair,
        ),
        top('t-red', colour: WardrobeColour.red),
        bottom('b'),
        shoes('s'),
      ];
      final recs = recommend(
        RecommendationRequest(
          items: items,
          preferences: const RecommendationPreferences(
            excludedColours: {WardrobeColour.red},
          ),
        ),
      );
      final ids = recs.expand((r) => r.items.map((i) => i.id)).toSet();
      expect(ids, {'t1', 'b', 's'});
    },
  );

  test('results are valid: distinct items covering the template', () {
    final items = [
      top('t'),
      bottom('b'),
      shoes('s'),
      coat('c'),
      item(id: 'd', category: ClothingCategory.onePiece),
    ];
    final recs = recommend(RecommendationRequest(items: items));
    expect(recs, hasLength(4)); // T1 with/without coat, T2 with/without coat
    for (final r in recs) {
      final ids = r.items.map((i) => i.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final cats = r.items.map((i) => i.category).toSet();
      expect(cats.containsAll(r.template.required), isTrue);
    }
  });

  test('dress with coat gives two results', () {
    final items = [
      item(id: 'd', category: ClothingCategory.onePiece),
      shoes('s'),
      coat('c'),
    ];
    expect(recommend(RecommendationRequest(items: items)), hasLength(2));
  });

  test('shuffled input gives identical order and scores', () {
    final items = [
      for (var i = 0; i < 4; i++) top('t$i', colour: WardrobeColour.values[i]),
      for (var i = 0; i < 3; i++) bottom('b$i'),
      for (var i = 0; i < 2; i++) shoes('s$i'),
    ];
    final a = recommend(RecommendationRequest(items: items));
    final b = recommend(RecommendationRequest(items: items.reversed.toList()));
    expect(b.map((r) => r.fingerprint), a.map((r) => r.fingerprint));
    expect(b.map((r) => r.score), a.map((r) => r.score));
  });

  test('ties are ordered by fingerprint', () {
    final recs = recommend(
      RecommendationRequest(
        items: [top('t'), bottom('b'), shoes('s2'), shoes('s1')],
      ),
    );
    expect(recs.map((r) => r.score).toSet(), hasLength(1));
    expect(
      recs.map((r) => r.fingerprint).toList(),
      recs.map((r) => r.fingerprint).toList()..sort(),
    );
  });

  test('dismissed combinations are absent; liked ones rank first', () {
    final items = [top('t'), bottom('b'), shoes('s1'), shoes('s2')];
    final fp1 = outfitFingerprint(['t', 'b', 's1']);
    final fp2 = outfitFingerprint(['t', 'b', 's2']);
    final dismissed = recommend(
      RecommendationRequest(
        items: items,
        feedback: {fp1: const FeedbackSummary(dismissed: true)},
      ),
    );
    expect(dismissed.map((r) => r.fingerprint), [fp2]);
    final liked = recommend(
      RecommendationRequest(
        items: items,
        feedback: {fp2: const FeedbackSummary(liked: true)},
      ),
    );
    expect(liked.first.fingerprint, fp2);
  });

  test('every reason comes from a factor scoring at least 0.75', () {
    final items = [
      top('t', colour: WardrobeColour.navy),
      bottom('b'),
      shoes('s'),
    ];
    for (final r in recommend(RecommendationRequest(items: items))) {
      final fromFactors = r.factors.values
          .where((f) => f.reason != null)
          .map((f) => f.reason!)
          .toSet();
      for (final reason in r.reasons) {
        if (reason == 'Meets the basic outfit rules') {
          expect(fromFactors, isEmpty);
        } else {
          expect(fromFactors, contains(reason));
        }
      }
      expect(
        r.factors.values
            .where((f) => f.reason != null)
            .every((f) => f.value >= 0.75),
        isTrue,
      );
      expect(r.reasons.length, lessThanOrEqualTo(3));
    }
  });

  test('candidate generation is capped per category', () {
    final items = [
      for (var i = 0; i < 30; i++) ...[
        top('t$i'),
        bottom('b$i'),
        shoes('s$i'),
        coat('c$i'),
      ],
    ];
    final recs = recommend(RecommendationRequest(items: items, limit: 1 << 30));
    expect(recs, hasLength(15 * 15 * 15 * 7));
  });

  test('favourites survive the cap', () {
    final items = [
      for (var i = 0; i < 20; i++) top('t${i.toString().padLeft(2, '0')}'),
      item(id: 'z-fav', category: ClothingCategory.top, isFavourite: true),
      bottom('b'),
      shoes('s'),
    ];
    final recs = recommend(RecommendationRequest(items: items, limit: 1 << 30));
    expect(recs.any((r) => r.items.any((i) => i.id == 'z-fav')), isTrue);
  });

  test('match labels', () {
    expect(MatchLabel.of(0.8), MatchLabel.strong);
    expect(MatchLabel.of(0.6), MatchLabel.good);
    expect(MatchLabel.of(0.3), MatchLabel.possible);
  });

  test('engine imports no Flutter, Drift or database code', () {
    final dir = Directory('lib/features/recommendations/engine');
    for (final f in dir.listSync().whereType<File>()) {
      final imports = f.readAsLinesSync().where(
        (l) => l.trimLeft().startsWith('import '),
      );
      for (final line in imports) {
        expect(line, isNot(contains('package:flutter')), reason: f.path);
        expect(line, isNot(contains('package:drift')), reason: f.path);
        expect(line, isNot(contains('/database/')), reason: f.path);
        expect(line, isNot(contains('/services/')), reason: f.path);
      }
    }
  });
}
