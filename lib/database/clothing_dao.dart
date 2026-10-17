import 'package:drift/drift.dart';

import '../core/clothing_item.dart';
import '../core/wardrobe_values.dart';
import 'app_database.dart';

part 'clothing_dao.g.dart';

@DriftAccessor(tables: [ClothingItems, OutfitItems])
class ClothingDao extends DatabaseAccessor<AppDatabase>
    with _$ClothingDaoMixin {
  ClothingDao(super.db);

  /// Number of non-archived items.
  Stream<int> watchActiveCount() {
    final count = clothingItems.id.count();
    final query = selectOnly(clothingItems)
      ..addColumns([count])
      ..where(clothingItems.isArchived.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Stream<List<ClothingItem>> watchItems({required bool archived}) => (select(
    clothingItems,
  )..where((t) => t.isArchived.equals(archived))).watch();

  Future<ClothingItem?> getById(String id) =>
      (select(clothingItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Not archived and not marked Needs repair.
  Future<List<ClothingItem>> availableItems() =>
      (select(clothingItems)..where(
            (t) =>
                t.isArchived.equals(false) &
                t.condition.equalsValue(ItemCondition.needsRepair).not(),
          ))
          .get();

  Future<void> upsert(ClothingItem item) =>
      into(clothingItems).insertOnConflictUpdate(item.toInsertable());

  Future<void> setArchived(String id, bool archived, DateTime now) =>
      (update(clothingItems)..where((t) => t.id.equals(id))).write(
        ClothingItemsCompanion(
          isArchived: Value(archived),
          updatedAt: Value(now),
        ),
      );

  Future<void> setFavourite(String id, bool favourite, DateTime now) =>
      (update(clothingItems)..where((t) => t.id.equals(id))).write(
        ClothingItemsCompanion(
          isFavourite: Value(favourite),
          updatedAt: Value(now),
        ),
      );

  Future<int> outfitCount(String id) {
    final count = outfitItems.outfitId.count();
    final query = selectOnly(outfitItems)
      ..addColumns([count])
      ..where(outfitItems.clothingItemId.equals(id));
    return query.map((row) => row.read(count) ?? 0).getSingle();
  }

  /// Every non-null photo path referenced by an item (including archived).
  Future<List<String>> allImagePaths() async {
    final query = selectOnly(clothingItems)
      ..addColumns([clothingItems.imagePath])
      ..where(clothingItems.imagePath.isNotNull());
    final rows = await query.get();
    return [for (final r in rows) r.read(clothingItems.imagePath)!];
  }

  Future<void> deleteById(String id) =>
      (delete(clothingItems)..where((t) => t.id.equals(id))).go();
}
