import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_exceptions.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import '../../database/outfit_dao.dart';
import '../recommendations/engine/recommendation_engine.dart'
    show outfitFingerprint;
import 'outfit_rules.dart';

export '../../database/outfit_dao.dart' show OutfitWithItems;

class OutfitRepository {
  OutfitRepository(this._db);

  final AppDatabase _db;

  Stream<List<OutfitWithItems>> watchAll() => _db.outfitDao.watchAll();

  Future<OutfitWithItems?> getById(String id) => _db.outfitDao.getById(id);

  /// Creates (no [id]) or updates an outfit; links are replaced in a single
  /// transaction. Returns the outfit id.
  Future<String> save({
    String? id,
    required String name,
    required List<String> itemIds,
    Occasion? occasion,
    Season? season,
    int? rating,
    bool isFavourite = false,
    String? notes,
  }) async {
    final error = validateOutfit(name, itemIds);
    if (error != null) throw ValidationException(error);
    final now = DateTime.now();
    final existing = id == null ? null : await getById(id);
    final outfitId = id ?? const Uuid().v4();
    await _db.outfitDao.saveOutfit(
      OutfitsCompanion(
        id: Value(outfitId),
        name: Value(name.trim()),
        occasion: Value(occasion),
        season: Value(season),
        rating: Value(rating),
        isFavourite: Value(isFavourite),
        notes: Value(notes),
        createdAt: Value(existing?.outfit.createdAt ?? now),
        updatedAt: Value(now),
      ),
      itemIds,
    );
    return outfitId;
  }

  /// Fingerprints of every saved outfit's item combination.
  Future<Set<String>> savedFingerprints() async {
    final byOutfit = await _db.outfitDao.itemIdsByOutfit();
    return {for (final ids in byOutfit.values) outfitFingerprint(ids)};
  }

  Future<void> delete(String id) => _db.outfitDao.deleteById(id);

  Future<void> setFavourite(String id, bool favourite) =>
      _db.outfitDao.updateFields(
        id,
        OutfitsCompanion(
          isFavourite: Value(favourite),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setRating(String id, int? rating) => _db.outfitDao.updateFields(
    id,
    OutfitsCompanion(rating: Value(rating), updatedAt: Value(DateTime.now())),
  );
}
