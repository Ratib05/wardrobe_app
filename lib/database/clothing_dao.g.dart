// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_dao.dart';

// ignore_for_file: type=lint
mixin _$ClothingDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClothingItemsTable get clothingItems => attachedDatabase.clothingItems;
  $OutfitsTable get outfits => attachedDatabase.outfits;
  $OutfitItemsTable get outfitItems => attachedDatabase.outfitItems;
  ClothingDaoManager get managers => ClothingDaoManager(this);
}

class ClothingDaoManager {
  final _$ClothingDaoMixin _db;
  ClothingDaoManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db.attachedDatabase, _db.clothingItems);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db.attachedDatabase, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db.attachedDatabase, _db.outfitItems);
}
