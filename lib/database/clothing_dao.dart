import 'package:drift/drift.dart';

import 'app_database.dart';

part 'clothing_dao.g.dart';

@DriftAccessor(tables: [ClothingItems])
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
}
