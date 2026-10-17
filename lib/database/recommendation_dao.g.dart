// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_dao.dart';

// ignore_for_file: type=lint
mixin _$RecommendationDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserPreferencesTable get userPreferences => attachedDatabase.userPreferences;
  $RecommendationFeedbackTable get recommendationFeedback =>
      attachedDatabase.recommendationFeedback;
  RecommendationDaoManager get managers => RecommendationDaoManager(this);
}

class RecommendationDaoManager {
  final _$RecommendationDaoMixin _db;
  RecommendationDaoManager(this._db);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(
        _db.attachedDatabase,
        _db.userPreferences,
      );
  $$RecommendationFeedbackTableTableManager get recommendationFeedback =>
      $$RecommendationFeedbackTableTableManager(
        _db.attachedDatabase,
        _db.recommendationFeedback,
      );
}
