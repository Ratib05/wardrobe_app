import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/app_exceptions.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/outfits/outfit_repository.dart';
import 'package:wardrobe_app/features/recommendations/engine/recommendation_engine.dart';
import 'package:wardrobe_app/features/recommendations/recommendation_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late OutfitRepository outfits;
  late RecommendationRepository repo;

  final wardrobe = [
    item(id: 't', category: ClothingCategory.top),
    item(id: 'b', category: ClothingCategory.bottom),
    item(id: 's', category: ClothingCategory.footwear),
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    outfits = OutfitRepository(db);
    repo = RecommendationRepository(db, outfits);
    for (final i in wardrobe) {
      await db.clothingDao.upsert(i);
    }
  });
  tearDown(() => db.close());

  test('preferring then avoiding a colour moves it to excluded only', () async {
    await repo.setPreference(PreferenceType.preferredColour, 'navy', true);
    await repo.setPreference(PreferenceType.excludedColour, 'navy', true);
    final p = await repo.watchPreferences().first;
    expect(p.preferredColours, isEmpty);
    expect(p.excludedColours, {WardrobeColour.navy});
    await repo.setPreference(PreferenceType.excludedColour, 'navy', false);
    expect((await repo.watchPreferences().first).excludedColours, isEmpty);
  });

  test('latest rating wins; dismiss can be undone', () async {
    await repo.recordFeedback('fp', FeedbackType.rated, rating: 2);
    await repo.recordFeedback('fp', FeedbackType.rated, rating: 4);
    expect((await repo.feedbackSummaries())['fp']!.latestRating, 4);
    await repo.recordFeedback('fp', FeedbackType.dismissed);
    expect((await repo.feedbackSummaries())['fp']!.dismissed, isTrue);
    await repo.undoDismiss('fp');
    expect((await repo.feedbackSummaries())['fp']!.dismissed, isFalse);
  });

  test('rating outside 1-5 is rejected', () async {
    await expectLater(
      repo.recordFeedback('fp', FeedbackType.rated, rating: 6),
      throwsA(isA<ValidationException>()),
    );
  });

  test('resetDismissed clears all dismissals', () async {
    await repo.recordFeedback('a', FeedbackType.dismissed);
    await repo.recordFeedback('b', FeedbackType.dismissed);
    expect(await repo.resetDismissed(), 2);
    final s = await repo.feedbackSummaries();
    expect(s.values.any((f) => f.dismissed), isFalse);
  });

  test('saveAsOutfit creates a favourite outfit and a liked row', () async {
    final rec = recommend(RecommendationRequest(items: wardrobe)).single;
    final id = await repo.saveAsOutfit(rec, name: 'Pick', favourite: true);
    final saved = (await outfits.getById(id))!;
    expect(saved.outfit.isFavourite, isTrue);
    expect(saved.items.map((i) => i.id).toSet(), {'t', 'b', 's'});
    final rows = await db.select(db.recommendationFeedback).get();
    expect(rows.single.feedbackType, FeedbackType.liked);
    expect((await repo.feedbackSummaries())[rec.fingerprint]!.liked, isTrue);
  });

  test('a saved outfit counts as liked even without feedback rows', () async {
    await outfits.save(name: 'Mine', itemIds: ['t', 'b', 's']);
    final fp = outfitFingerprint(['t', 'b', 's']);
    expect((await repo.feedbackSummaries())[fp]!.liked, isTrue);
  });
}
