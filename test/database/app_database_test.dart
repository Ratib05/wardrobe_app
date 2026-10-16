import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';

import '../helpers.dart';

AppDatabase memoryDb() => AppDatabase(NativeDatabase.memory());

Future<void> insertItem(AppDatabase db, ClothingItem i) =>
    db.into(db.clothingItems).insert(i.toInsertable());

OutfitsCompanion outfit(String id) => OutfitsCompanion.insert(
  id: id,
  name: 'Outfit $id',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('EnumSetConverter sorts and skips unknown names', () {
    const c = EnumSetConverter(Season.values);
    expect(c.toSql({Season.winter, Season.autumn}), '["autumn","winter"]');
    expect(c.fromSql('["summer","monsoon"]'), {Season.summer});
  });

  test('ClothingItem round-trips', () async {
    final i = item(
      id: 'a',
      seasons: {Season.winter, Season.autumn},
      styleTags: {StyleTag.classic},
      primaryColour: WardrobeColour.navy,
    );
    await insertItem(db, i);
    final row = await db.select(db.clothingItems).getSingle();
    expect(row.seasons, {Season.autumn, Season.winter});
    expect(row.styleTags, {StyleTag.classic});
    expect(row.primaryColour, WardrobeColour.navy);
    expect(row.condition, ItemCondition.good);
  });

  test('outfit_items enforces FK and uniqueness', () async {
    await insertItem(db, item(id: 'a'));
    await db.into(db.outfits).insert(outfit('o1'));
    await expectLater(
      db
          .into(db.outfitItems)
          .insert(
            OutfitItemsCompanion.insert(
              outfitId: 'o1',
              clothingItemId: 'missing',
              position: 0,
            ),
          ),
      throwsA(anything),
    );
    final link = OutfitItemsCompanion.insert(
      outfitId: 'o1',
      clothingItemId: 'a',
      position: 0,
    );
    await db.into(db.outfitItems).insert(link);
    await expectLater(db.into(db.outfitItems).insert(link), throwsA(anything));
  });

  test(
    'deleting an item cascades links, keeps outfit, nulls wishlist link',
    () async {
      await insertItem(db, item(id: 'a'));
      await db.into(db.outfits).insert(outfit('o1'));
      await db
          .into(db.outfitItems)
          .insert(
            OutfitItemsCompanion.insert(
              outfitId: 'o1',
              clothingItemId: 'a',
              position: 0,
            ),
          );
      await db
          .into(db.wishlistItems)
          .insert(
            WishlistItemsCompanion.insert(
              id: 'w1',
              name: 'Boots',
              category: ClothingCategory.footwear,
              purchasedItemId: const Value('a'),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await (db.delete(db.clothingItems)..where((t) => t.id.equals('a'))).go();
      expect(await db.select(db.outfitItems).get(), isEmpty);
      expect(await db.select(db.outfits).get(), hasLength(1));
      expect(
        (await db.select(db.wishlistItems).getSingle()).purchasedItemId,
        isNull,
      );
    },
  );

  test('deleting an outfit removes its links', () async {
    await insertItem(db, item(id: 'a'));
    await db.into(db.outfits).insert(outfit('o1'));
    await db
        .into(db.outfitItems)
        .insert(
          OutfitItemsCompanion.insert(
            outfitId: 'o1',
            clothingItemId: 'a',
            position: 0,
          ),
        );
    await (db.delete(db.outfits)..where((t) => t.id.equals('o1'))).go();
    expect(await db.select(db.outfitItems).get(), isEmpty);
  });

  test('outfit rating must be 1-5', () async {
    await expectLater(
      db.into(db.outfits).insert(outfit('o1').copyWith(rating: const Value(6))),
      throwsA(anything),
    );
  });
}
