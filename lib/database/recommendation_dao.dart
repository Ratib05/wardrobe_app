import 'package:drift/drift.dart';

import '../core/wardrobe_values.dart';
import 'app_database.dart';

part 'recommendation_dao.g.dart';

@DriftAccessor(tables: [UserPreferences, RecommendationFeedback])
class RecommendationDao extends DatabaseAccessor<AppDatabase>
    with _$RecommendationDaoMixin {
  RecommendationDao(super.db);

  Stream<List<UserPreference>> watchPreferences() =>
      select(userPreferences).watch();

  Future<void> upsertPreference(UserPreferencesCompanion row) =>
      into(userPreferences).insertOnConflictUpdate(row);

  Future<void> deletePreference(PreferenceType type, String value) =>
      (delete(userPreferences)..where(
            (t) =>
                t.preferenceType.equalsValue(type) &
                t.preferenceValue.equals(value),
          ))
          .go();

  /// Oldest first (insertion order breaks timestamp ties).
  Future<List<FeedbackEntry>> allFeedback() =>
      (select(recommendationFeedback)..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
          ]))
          .get();

  Future<void> insertFeedback(RecommendationFeedbackCompanion row) =>
      into(recommendationFeedback).insert(row);

  /// Removes dismissals for one combination; returns how many were removed.
  Future<int> deleteDismissed(String fingerprint) =>
      (delete(recommendationFeedback)..where(
            (t) =>
                t.outfitFingerprint.equals(fingerprint) &
                t.feedbackType.equalsValue(FeedbackType.dismissed),
          ))
          .go();

  Future<int> deleteAllDismissed() => (delete(
    recommendationFeedback,
  )..where((t) => t.feedbackType.equalsValue(FeedbackType.dismissed))).go();
}
