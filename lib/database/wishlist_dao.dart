import 'package:drift/drift.dart';

import '../core/wardrobe_values.dart';
import 'app_database.dart';

part 'wishlist_dao.g.dart';

@DriftAccessor(tables: [WishlistItems])
class WishlistDao extends DatabaseAccessor<AppDatabase>
    with _$WishlistDaoMixin {
  WishlistDao(super.db);

  /// Newest first.
  Stream<List<WishlistItem>> watchByStatus(WishlistStatus status) =>
      (select(wishlistItems)
            ..where((t) => t.status.equalsValue(status))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .watch();

  Stream<List<WishlistItem>> watchAll() => select(wishlistItems).watch();

  Future<List<WishlistItem>> all() => select(wishlistItems).get();

  Future<WishlistItem?> getById(String id) =>
      (select(wishlistItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(WishlistItemsCompanion row) =>
      into(wishlistItems).insertOnConflictUpdate(row);

  Future<void> updateFields(String id, WishlistItemsCompanion changes) =>
      (update(wishlistItems)..where((t) => t.id.equals(id))).write(changes);

  Future<void> deleteById(String id) =>
      (delete(wishlistItems)..where((t) => t.id.equals(id))).go();
}
