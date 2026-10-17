import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_exceptions.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import '../outfits/outfit_repository.dart';
import 'engine/recommendation_engine.dart';
import 'engine/scoring.dart';

/// Stores preferences and feedback, and turns recommendations into outfits.
class RecommendationRepository {
  RecommendationRepository(this._db, this._outfits);

  final AppDatabase _db;
  final OutfitRepository _outfits;

  Stream<RecommendationPreferences> watchPreferences() =>
      _db.recommendationDao.watchPreferences().map(_toPreferences);

  RecommendationPreferences _toPreferences(List<UserPreference> rows) {
    Set<T> values<T extends Enum>(PreferenceType type, List<T> all) {
      final byName = all.asNameMap();
      return {
        for (final r in rows)
          if (r.preferenceType == type && byName[r.preferenceValue] != null)
            byName[r.preferenceValue]!,
      };
    }

    return RecommendationPreferences(
      preferredColours: values(
        PreferenceType.preferredColour,
        WardrobeColour.values,
      ),
      preferredStyles: values(PreferenceType.preferredStyle, StyleTag.values),
      preferredFormalities: values(
        PreferenceType.preferredFormality,
        Formality.values,
      ),
      excludedColours: values(
        PreferenceType.excludedColour,
        WardrobeColour.values,
      ),
      excludedStyles: values(PreferenceType.excludedStyle, StyleTag.values),
    );
  }

  /// Custom score weights as fractions summing to 1, or null for defaults.
  Stream<Map<ScoreFactor, double>?> watchWeights() =>
      _db.recommendationDao.watchPreferences().map((rows) {
        final byName = ScoreFactor.values.asNameMap();
        final raw = <ScoreFactor, double>{
          for (final r in rows)
            if (r.preferenceType == PreferenceType.scoreWeight &&
                byName[r.preferenceValue] != null)
              byName[r.preferenceValue]!: r.weight ?? 0,
        };
        if (raw.isEmpty) return null;
        final full = {
          for (final f in ScoreFactor.values)
            f: raw[f] ?? f.defaultWeight * 100,
        };
        final sum = full.values.fold(0.0, (a, b) => a + b);
        if (sum <= 0) return null;
        return {for (final e in full.entries) e.key: e.value / sum};
      });

  /// Stores relative weights (any non-negative scale; normalised on read).
  Future<void> setWeights(Map<ScoreFactor, double> raw) {
    if (raw.values.any((w) => w < 0) || raw.values.every((w) => w == 0)) {
      throw const ValidationException('Give at least one factor some weight');
    }
    return _db.transaction(() async {
      final dao = _db.recommendationDao;
      await dao.deleteByType(PreferenceType.scoreWeight);
      for (final e in raw.entries) {
        await dao.upsertPreference(
          UserPreferencesCompanion(
            preferenceType: const Value(PreferenceType.scoreWeight),
            preferenceValue: Value(e.key.name),
            weight: Value(e.value),
            createdAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> resetWeights() =>
      _db.recommendationDao.deleteByType(PreferenceType.scoreWeight);

  static PreferenceType? _opposite(PreferenceType type) => switch (type) {
    PreferenceType.preferredColour => PreferenceType.excludedColour,
    PreferenceType.excludedColour => PreferenceType.preferredColour,
    PreferenceType.preferredStyle => PreferenceType.excludedStyle,
    PreferenceType.excludedStyle => PreferenceType.preferredStyle,
    PreferenceType.preferredFormality || PreferenceType.scoreWeight => null,
  };

  /// Turns a preference on or off. Preferring and avoiding the same colour
  /// or style are mutually exclusive.
  Future<void> setPreference(PreferenceType type, String value, bool enabled) =>
      _db.transaction(() async {
        final dao = _db.recommendationDao;
        if (!enabled) return dao.deletePreference(type, value);
        final opposite = _opposite(type);
        if (opposite != null) await dao.deletePreference(opposite, value);
        await dao.upsertPreference(
          UserPreferencesCompanion(
            preferenceType: Value(type),
            preferenceValue: Value(value),
            createdAt: Value(DateTime.now()),
          ),
        );
      });

  /// Per-combination feedback keyed by fingerprint. Saved outfits count as
  /// liked.
  Future<Map<String, FeedbackSummary>> feedbackSummaries() async {
    final liked = <String>{};
    final dismissed = <String>{};
    final ratings = <String, int>{};
    for (final f in await _db.recommendationDao.allFeedback()) {
      final fp = f.outfitFingerprint;
      switch (f.feedbackType) {
        case FeedbackType.saved:
        case FeedbackType.liked:
          liked.add(fp);
        case FeedbackType.dismissed:
          dismissed.add(fp);
        case FeedbackType.rated:
          final r = f.rating;
          if (r != null) ratings[fp] = r; // oldest first, so last wins
      }
    }
    liked.addAll(await _outfits.savedFingerprints());
    return {
      for (final fp in {...liked, ...dismissed, ...ratings.keys})
        fp: FeedbackSummary(
          liked: liked.contains(fp),
          dismissed: dismissed.contains(fp),
          latestRating: ratings[fp],
        ),
    };
  }

  Future<void> recordFeedback(
    String fingerprint,
    FeedbackType type, {
    int? rating,
  }) async {
    if (type == FeedbackType.rated &&
        (rating == null || rating < 1 || rating > 5)) {
      throw const ValidationException('Rating must be between 1 and 5');
    }
    await _db.recommendationDao.insertFeedback(
      RecommendationFeedbackCompanion(
        id: Value(const Uuid().v4()),
        outfitFingerprint: Value(fingerprint),
        feedbackType: Value(type),
        rating: Value(rating),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> undoDismiss(String fingerprint) =>
      _db.recommendationDao.deleteDismissed(fingerprint);

  /// Brings back every dismissed combination; returns how many were reset.
  Future<int> resetDismissed() => _db.recommendationDao.deleteAllDismissed();

  /// Saves a recommendation as an outfit and records the feedback together.
  Future<String> saveAsOutfit(
    Recommendation recommendation, {
    required String name,
    bool favourite = false,
  }) => _db.transaction(() async {
    final id = await _outfits.save(
      name: name,
      itemIds: [for (final i in recommendation.items) i.id],
      isFavourite: favourite,
    );
    await recordFeedback(
      recommendation.fingerprint,
      favourite ? FeedbackType.liked : FeedbackType.saved,
    );
    return id;
  });
}
