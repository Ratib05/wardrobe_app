import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import '../recommendations/engine/gap_analysis.dart';
import '../wardrobe/clothing_repository.dart';

/// Parses a budget such as "12.5" into cents (1250). Null for empty input;
/// throws [ValidationException] for anything that is not a plain amount.
int? parseBudgetCents(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(text);
  if (match == null) throw const ValidationException('Enter a valid amount');
  final cents = (match.group(2) ?? '').padRight(2, '0');
  return int.parse(match.group(1)!) * 100 + int.parse(cents);
}

/// Gap-suggestion keys already covered by wishlist entries (any status).
/// An entry with exactly one preferred colour matches that colour; otherwise
/// it has no colour part and so never hides a coloured suggestion.
Set<String> wishlistGapKeys(Iterable<WishlistItem> entries) => {
  for (final w in entries)
    gapKey(
      w.category,
      w.preferredColours.length == 1 ? w.preferredColours.first : null,
      w.formality,
    ),
};

class WishlistRepository {
  WishlistRepository(this._db, this._clothing);

  final AppDatabase _db;
  final ClothingRepository _clothing;

  Stream<List<WishlistItem>> watch(WishlistStatus status) =>
      _db.wishlistDao.watchByStatus(status);

  Stream<List<WishlistItem>> watchAll() => _db.wishlistDao.watchAll();

  Future<List<WishlistItem>> all() => _db.wishlistDao.all();

  Future<WishlistItem?> getById(String id) => _db.wishlistDao.getById(id);

  /// Creates (no [id]) or updates a wishlist entry; returns its id.
  Future<String> save({
    String? id,
    required String name,
    required ClothingCategory category,
    String? subcategory,
    Set<WardrobeColour> preferredColours = const {},
    Set<StyleTag> styleTags = const {},
    Formality? formality,
    int? targetPriceCents,
    WishlistPriority priority = WishlistPriority.medium,
    String? reason,
    String? notes,
    WishlistStatus status = WishlistStatus.planned,
  }) async {
    final error = validateItemName(name);
    if (error != null) throw ValidationException(error);
    if (targetPriceCents != null && targetPriceCents < 0) {
      throw const ValidationException('Enter a valid amount');
    }
    final now = DateTime.now();
    final existing = id == null ? null : await getById(id);
    final wishId = id ?? const Uuid().v4();
    await _db.wishlistDao.upsert(
      WishlistItemsCompanion(
        id: Value(wishId),
        name: Value(name.trim()),
        category: Value(category),
        subcategory: Value(subcategory),
        preferredColours: Value(preferredColours),
        styleTags: Value(styleTags),
        formality: Value(formality),
        targetPriceCents: Value(targetPriceCents),
        priority: Value(priority),
        reason: Value(reason),
        status: Value(status),
        purchasedItemId: Value(existing?.purchasedItemId),
        notes: Value(notes),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
    return wishId;
  }

  Future<void> setStatus(String id, WishlistStatus status) =>
      _db.wishlistDao.updateFields(
        id,
        WishlistItemsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> delete(String id) => _db.wishlistDao.deleteById(id);

  /// Adds [item] to the wardrobe and marks the entry purchased and linked to
  /// it, in one transaction. A failure (e.g. blank name) leaves the entry
  /// planned.
  // ponytail: a photo committed by the clothing save is not rolled back if the
  // later wishlist update fails; it would be an orphan file. Rare; sweep if seen.
  Future<void> markPurchased(
    String wishlistId,
    ClothingItem item, {
    File? stagedImage,
  }) => _db.transaction(() async {
    await _clothing.save(item, stagedImage: stagedImage);
    await _db.wishlistDao.updateFields(
      wishlistId,
      WishlistItemsCompanion(
        status: const Value(WishlistStatus.purchased),
        purchasedItemId: Value(item.id),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });
}
