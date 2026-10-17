import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/app_exceptions.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/wardrobe/clothing_repository.dart';
import 'package:wardrobe_app/features/wishlist/wishlist_repository.dart';
import 'package:wardrobe_app/services/image_storage.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late ClothingRepository clothing;
  late WishlistRepository repo;

  setUp(() async {
    final paths = await tempPaths();
    db = AppDatabase(NativeDatabase.memory());
    clothing = ClothingRepository(db, ImageStorage(paths));
    repo = WishlistRepository(db, clothing);
  });
  tearDown(() => db.close());

  test('parseBudgetCents', () {
    expect(parseBudgetCents(''), isNull);
    expect(parseBudgetCents('12.5'), 1250);
    expect(parseBudgetCents('12'), 1200);
    expect(parseBudgetCents('0.05'), 5);
    expect(() => parseBudgetCents('-3'), throwsA(isA<ValidationException>()));
    expect(() => parseBudgetCents('abc'), throwsA(isA<ValidationException>()));
  });

  test('save and read back', () async {
    final id = await repo.save(
      name: 'Brown boots',
      category: ClothingCategory.footwear,
      preferredColours: {WardrobeColour.brown},
      targetPriceCents: 12000,
      priority: WishlistPriority.high,
    );
    final got = (await repo.getById(id))!;
    expect(got.name, 'Brown boots');
    expect(got.status, WishlistStatus.planned);
    expect(got.priority, WishlistPriority.high);
    expect(got.preferredColours, {WardrobeColour.brown});
    expect(await repo.watch(WishlistStatus.planned).first, hasLength(1));
  });

  test('negative price and blank name are rejected', () async {
    await expectLater(
      repo.save(
        name: 'Boots',
        category: ClothingCategory.footwear,
        targetPriceCents: -1,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      repo.save(name: ' ', category: ClothingCategory.footwear),
      throwsA(isA<ValidationException>()),
    );
  });

  test('markPurchased adds the clothing item and links it', () async {
    final id = await repo.save(
      name: 'Boots',
      category: ClothingCategory.footwear,
    );
    final bought = item(
      id: 'new-item',
      name: 'Boots',
      category: ClothingCategory.footwear,
    );
    await repo.markPurchased(id, bought);
    expect((await clothing.getById('new-item')), isNotNull);
    final entry = (await repo.getById(id))!;
    expect(entry.status, WishlistStatus.purchased);
    expect(entry.purchasedItemId, 'new-item');
  });

  test('markPurchased with an invalid item leaves the entry planned', () async {
    final id = await repo.save(
      name: 'Boots',
      category: ClothingCategory.footwear,
    );
    final blank = item(id: 'x', name: ' ', category: ClothingCategory.footwear);
    await expectLater(
      repo.markPurchased(id, blank),
      throwsA(isA<ValidationException>()),
    );
    expect((await repo.getById(id))!.status, WishlistStatus.planned);
    expect(await clothing.getById('x'), isNull);
  });

  test('setStatus and delete', () async {
    final id = await repo.save(
      name: 'Boots',
      category: ClothingCategory.footwear,
    );
    await repo.setStatus(id, WishlistStatus.dismissed);
    expect(await repo.watch(WishlistStatus.dismissed).first, hasLength(1));
    await repo.delete(id);
    expect(await repo.all(), isEmpty);
  });
}
