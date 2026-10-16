// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_dao.dart';

// ignore_for_file: type=lint
mixin _$ClothingDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClothingItemsTable get clothingItems => attachedDatabase.clothingItems;
  ClothingDaoManager get managers => ClothingDaoManager(this);
}

class ClothingDaoManager {
  final _$ClothingDaoMixin _db;
  ClothingDaoManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db.attachedDatabase, _db.clothingItems);
}
