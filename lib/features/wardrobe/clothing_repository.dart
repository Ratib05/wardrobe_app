import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import '../../services/image_storage.dart';

class ClothingRepository {
  ClothingRepository(this._db, this._images);

  final AppDatabase _db;
  final ImageStorage _images;

  Stream<int> watchActiveCount() => _db.clothingDao.watchActiveCount();

  Stream<List<ClothingItem>> watchItems({bool archived = false}) =>
      _db.clothingDao.watchItems(archived: archived);

  Future<ClothingItem?> getById(String id) => _db.clothingDao.getById(id);

  /// Items usable in outfits and recommendations.
  Future<List<ClothingItem>> availableItems() =>
      _db.clothingDao.availableItems();

  /// Creates or updates [item]. A [stagedImage] replaces the photo; if the
  /// item's imagePath changed or was cleared, the old file is removed after
  /// the database write succeeds.
  Future<void> save(ClothingItem item, {File? stagedImage}) async {
    final error = validateItemName(item.name);
    if (error != null) throw ValidationException(error);
    final previous = await getById(item.id);
    String? newPath;
    if (stagedImage != null) newPath = await _images.commit(stagedImage);
    final toSave = ClothingItem(
      id: item.id,
      name: item.name.trim(),
      category: item.category,
      subcategory: item.subcategory,
      primaryColour: item.primaryColour,
      secondaryColours: item.secondaryColours,
      pattern: item.pattern,
      material: item.material,
      fit: item.fit,
      styleTags: item.styleTags,
      formality: item.formality,
      seasons: item.seasons,
      occasions: item.occasions,
      brand: item.brand,
      size: item.size,
      condition: item.condition,
      imagePath: newPath ?? item.imagePath,
      isFavourite: item.isFavourite,
      isArchived: item.isArchived,
      hideFromSuggestions: item.hideFromSuggestions,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
    try {
      await _db.transaction(() => _db.clothingDao.upsert(toSave));
    } catch (_) {
      await _images.delete(newPath);
      rethrow;
    }
    final oldPath = previous?.imagePath;
    if (oldPath != null && oldPath != toSave.imagePath) {
      await _images.delete(oldPath);
    }
  }

  /// Creates one item per photo in [paths], all in [category], named from
  /// the file name and hidden from suggestions until the user fills them in.
  /// Photos that can't be read are skipped and returned by file name; the
  /// rest are saved in one transaction, so a failed write keeps nothing.
  Future<({int imported, List<String> skipped})> importPhotos(
    List<String> paths,
    ClothingCategory category, {
    void Function(int done, int total)? onProgress,
  }) async {
    final staged = <(String, File)>[];
    final skipped = <String>[];
    for (final path in paths) {
      try {
        staged.add((path, await _images.stage(path)));
      } on UnsupportedImageException {
        skipped.add(p.basename(path));
      } on FileSystemException {
        skipped.add(p.basename(path));
      }
      onProgress?.call(staged.length + skipped.length, paths.length);
    }
    final committed = <String>[];
    try {
      final now = DateTime.now();
      final items = <ClothingItem>[];
      for (final (i, (path, file)) in staged.indexed) {
        final imagePath = await _images.commit(file);
        committed.add(imagePath);
        // Spaced apart so "recently added" keeps a stable order.
        final created = now.add(Duration(milliseconds: i));
        items.add(
          ClothingItem(
            id: const Uuid().v4(),
            name: nameFromFileName(path),
            category: category,
            imagePath: imagePath,
            hideFromSuggestions: true,
            createdAt: created,
            updatedAt: created,
          ),
        );
      }
      await _db.transaction(() async {
        for (final item in items) {
          await _db.clothingDao.upsert(item);
        }
      });
    } catch (_) {
      for (final path in committed) {
        await _images.delete(path);
      }
      for (final (_, file) in staged) {
        await _images.discard(file);
      }
      rethrow;
    }
    return (imported: staged.length, skipped: skipped);
  }

  Future<void> setArchived(String id, bool archived) =>
      _db.clothingDao.setArchived(id, archived, DateTime.now());

  Future<void> setFavourite(String id, bool favourite) =>
      _db.clothingDao.setFavourite(id, favourite, DateTime.now());

  /// How many photos items reference and how many of those files are gone.
  Future<({int total, int missing})> photoStatus() async {
    final paths = await _db.clothingDao.allImagePaths();
    var missing = 0;
    for (final path in paths) {
      final file = _images.fileFor(path);
      if (file == null || !file.existsSync()) missing++;
    }
    return (total: paths.length, missing: missing);
  }

  Future<int> outfitCount(String id) => _db.clothingDao.outfitCount(id);

  /// Deletes the item (outfit links cascade) and then its photo file.
  Future<void> delete(String id) async {
    final item = await getById(id);
    await _db.clothingDao.deleteById(id);
    await _images.delete(item?.imagePath);
  }
}
