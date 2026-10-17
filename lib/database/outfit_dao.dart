import 'package:drift/drift.dart';

import '../core/clothing_item.dart';
import 'app_database.dart';

part 'outfit_dao.g.dart';

/// A saved outfit with its items in display order.
class OutfitWithItems {
  const OutfitWithItems(this.outfit, this.items);

  final Outfit outfit;
  final List<ClothingItem> items;
}

@DriftAccessor(tables: [Outfits, OutfitItems, ClothingItems])
class OutfitDao extends DatabaseAccessor<AppDatabase> with _$OutfitDaoMixin {
  OutfitDao(super.db);

  JoinedSelectStatement<HasResultSet, dynamic> _joined() =>
      select(outfits).join([
        leftOuterJoin(outfitItems, outfitItems.outfitId.equalsExp(outfits.id)),
        leftOuterJoin(
          clothingItems,
          clothingItems.id.equalsExp(outfitItems.clothingItemId),
        ),
      ]);

  List<OutfitWithItems> _group(List<TypedResult> rows) {
    final byId = <String, (Outfit, List<ClothingItem>)>{};
    for (final row in rows) {
      final outfit = row.readTable(outfits);
      final entry = byId.putIfAbsent(outfit.id, () => (outfit, []));
      final item = row.readTableOrNull(clothingItems);
      if (item != null) entry.$2.add(item);
    }
    return [for (final e in byId.values) OutfitWithItems(e.$1, e.$2)];
  }

  /// Newest first; each outfit's items in position order.
  Stream<List<OutfitWithItems>> watchAll() {
    final query = _joined()
      ..orderBy([
        OrderingTerm.desc(outfits.createdAt),
        OrderingTerm.asc(outfits.id),
        OrderingTerm.asc(outfitItems.position),
      ]);
    return query.watch().map(_group);
  }

  Future<OutfitWithItems?> getById(String id) async {
    final query = _joined()
      ..where(outfits.id.equals(id))
      ..orderBy([OrderingTerm.asc(outfitItems.position)]);
    final grouped = _group(await query.get());
    return grouped.isEmpty ? null : grouped.single;
  }

  /// Inserts or updates the outfit and replaces its item links atomically.
  Future<void> saveOutfit(OutfitsCompanion outfit, List<String> itemIds) =>
      transaction(() async {
        await into(outfits).insertOnConflictUpdate(outfit);
        final id = outfit.id.value;
        await (delete(outfitItems)..where((t) => t.outfitId.equals(id))).go();
        for (var i = 0; i < itemIds.length; i++) {
          await into(outfitItems).insert(
            OutfitItemsCompanion.insert(
              outfitId: id,
              clothingItemId: itemIds[i],
              position: i,
            ),
          );
        }
      });

  Future<void> deleteById(String id) =>
      (delete(outfits)..where((t) => t.id.equals(id))).go();

  Future<void> updateFields(String id, OutfitsCompanion changes) =>
      (update(outfits)..where((t) => t.id.equals(id))).write(changes);
}
