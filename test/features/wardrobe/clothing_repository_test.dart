import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/app_exceptions.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/wardrobe/clothing_repository.dart';
import 'package:wardrobe_app/services/image_storage.dart';
import 'package:wardrobe_app/services/storage_paths.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late StoragePaths paths;
  late ImageStorage images;
  late ClothingRepository repo;

  setUp(() async {
    paths = await tempPaths();
    db = AppDatabase(NativeDatabase.memory());
    images = ImageStorage(paths);
    repo = ClothingRepository(db, images);
  });
  tearDown(() => db.close());

  Future<File> stagedPhoto() async {
    final src = File(
      '${paths.root.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
    )..writeAsBytesSync(jpegBytes());
    return images.stage(src.path);
  }

  test('save then watch active vs archived', () async {
    await repo.save(item(id: 'a'));
    expect((await repo.watchItems().first).map((i) => i.id), ['a']);
    expect(await repo.watchItems(archived: true).first, isEmpty);
    await repo.setArchived('a', true);
    expect((await repo.watchItems(archived: true).first).map((i) => i.id), [
      'a',
    ]);
    expect(await db.clothingDao.watchActiveCount().first, 0);
  });

  test('blank name is rejected and nothing stored', () async {
    await expectLater(
      repo.save(item(name: ' ')),
      throwsA(isA<ValidationException>()),
    );
    expect(await repo.watchItems().first, isEmpty);
  });

  test('saving same id twice keeps one row with latest values', () async {
    await repo.save(item(id: 'a', name: 'One'));
    await repo.save(item(id: 'a', name: 'Two'));
    final all = await repo.watchItems().first;
    expect(all.map((i) => i.name), ['Two']);
  });

  test('availableItems excludes archived and needsRepair', () async {
    await repo.save(item(id: 'ok'));
    await repo.save(item(id: 'arch', isArchived: true));
    await repo.save(item(id: 'bad', condition: ItemCondition.needsRepair));
    expect((await repo.availableItems()).map((i) => i.id), ['ok']);
  });

  test('outfitCount and delete keep the outfit', () async {
    await repo.save(item(id: 'a'));
    await db
        .into(db.outfits)
        .insert(
          OutfitsCompanion.insert(
            id: 'o',
            name: 'O',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await db
        .into(db.outfitItems)
        .insert(
          OutfitItemsCompanion.insert(
            outfitId: 'o',
            clothingItemId: 'a',
            position: 0,
          ),
        );
    expect(await repo.outfitCount('a'), 1);
    await repo.delete('a');
    expect(await db.select(db.outfits).get(), hasLength(1));
    expect(await db.select(db.outfitItems).get(), isEmpty);
  });

  test('save with photo stores path; replacing deletes the old file', () async {
    await repo.save(item(id: 'a'), stagedImage: await stagedPhoto());
    final first = (await repo.getById('a'))!.imagePath!;
    expect(paths.imageFile(first).existsSync(), isTrue);
    await repo.save(
      (await repo.getById('a'))!,
      stagedImage: await stagedPhoto(),
    );
    final second = (await repo.getById('a'))!.imagePath!;
    expect(second, isNot(first));
    expect(paths.imageFile(first).existsSync(), isFalse);
    expect(paths.imageFile(second).existsSync(), isTrue);
  });

  test('delete removes the photo file', () async {
    await repo.save(item(id: 'a'), stagedImage: await stagedPhoto());
    final path = (await repo.getById('a'))!.imagePath!;
    await repo.delete('a');
    expect(paths.imageFile(path).existsSync(), isFalse);
  });

  test('failed save leaves no orphan photo', () async {
    final staged = await stagedPhoto();
    await db.customStatement(
      "CREATE TRIGGER boom BEFORE INSERT ON clothing_items BEGIN SELECT RAISE(ABORT, 'boom'); END",
    );
    await expectLater(
      repo.save(item(id: 'a'), stagedImage: staged),
      throwsA(anything),
    );
    expect(paths.clothingImagesDir.listSync(), isEmpty);
  });
}
