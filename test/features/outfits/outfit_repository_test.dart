import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/app_exceptions.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/outfits/outfit_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late OutfitRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = OutfitRepository(db);
    for (final id in ['a', 'b', 'c']) {
      await db.clothingDao.upsert(item(id: id, name: 'Item $id'));
    }
  });
  tearDown(() => db.close());

  test('save then getById returns items in the given order', () async {
    final id = await repo.save(name: 'Office', itemIds: ['c', 'a', 'b']);
    final got = (await repo.getById(id))!;
    expect(got.outfit.name, 'Office');
    expect(got.items.map((i) => i.id), ['c', 'a', 'b']);
  });

  test('re-saving replaces links and keeps createdAt', () async {
    final id = await repo.save(name: 'Office', itemIds: ['a', 'b']);
    final first = (await repo.getById(id))!.outfit.createdAt;
    await repo.save(id: id, name: 'Office 2', itemIds: ['b', 'c']);
    final got = (await repo.getById(id))!;
    expect(got.items.map((i) => i.id), ['b', 'c']);
    expect(got.outfit.name, 'Office 2');
    expect(got.outfit.createdAt, first);
  });

  test(
    'duplicate ids are rejected and the previous outfit is unchanged',
    () async {
      final id = await repo.save(name: 'Office', itemIds: ['a', 'b']);
      await expectLater(
        repo.save(id: id, name: 'Bad', itemIds: ['a', 'a']),
        throwsA(isA<ValidationException>()),
      );
      final got = (await repo.getById(id))!;
      expect(got.outfit.name, 'Office');
      expect(got.items.map((i) => i.id), ['a', 'b']);
    },
  );

  test('delete removes outfit and links but keeps clothing', () async {
    final id = await repo.save(name: 'Office', itemIds: ['a', 'b']);
    await repo.delete(id);
    expect(await repo.getById(id), isNull);
    expect(await db.select(db.outfitItems).get(), isEmpty);
    expect(await db.select(db.clothingItems).get(), hasLength(3));
  });

  test('favourite and rating', () async {
    final id = await repo.save(name: 'Office', itemIds: ['a', 'b']);
    await repo.setFavourite(id, true);
    await repo.setRating(id, 4);
    final o = (await repo.getById(id))!.outfit;
    expect(o.isFavourite, isTrue);
    expect(o.rating, 4);
  });

  test('watchAll lists newest first', () async {
    await repo.save(name: 'First', itemIds: ['a', 'b']);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.save(name: 'Second', itemIds: ['b', 'c']);
    final all = await repo.watchAll().first;
    expect(all.map((o) => o.outfit.name), ['Second', 'First']);
  });
}
