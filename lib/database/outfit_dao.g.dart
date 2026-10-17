// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_dao.dart';

// ignore_for_file: type=lint
mixin _$OutfitDaoMixin on DatabaseAccessor<AppDatabase> {
  $OutfitsTable get outfits => attachedDatabase.outfits;
  $ClothingItemsTable get clothingItems => attachedDatabase.clothingItems;
  $OutfitItemsTable get outfitItems => attachedDatabase.outfitItems;
  OutfitDaoManager get managers => OutfitDaoManager(this);
}

class OutfitDaoManager {
  final _$OutfitDaoMixin _db;
  OutfitDaoManager(this._db);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db.attachedDatabase, _db.outfits);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db.attachedDatabase, _db.clothingItems);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db.attachedDatabase, _db.outfitItems);
}
