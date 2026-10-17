import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';

import '../../helpers.dart';

Future<void> openWishlist(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Gaps & wishlist')));
  await tester.pumpAndSettle();
}

Future<void> seedWish(
  AppDatabase db,
  String id,
  String name,
  ClothingCategory category,
) => db.wishlistDao.upsert(
  WishlistItemsCompanion.insert(
    id: id,
    name: name,
    category: category,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    purchasedItemId: const Value(null),
  ),
);

final anyTile = find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith('wish-'),
);

void main() {
  testApp('empty wishlist shows empty state', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openWishlist(tester);
    expect(find.text('Your wishlist is empty'), findsOneWidget);
  });

  testApp('adding an entry stores the budget in cents', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openWishlist(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final footwear = find.widgetWithText(FilterChip, 'Shoes');
    await tester.ensureVisible(footwear);
    await tester.pumpAndSettle();
    await tester.tap(footwear);
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Budget'), '12.5');
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Brown boots',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await pumpUntilFound(tester, anyTile);
    expect(
      find.descendant(
        of: anyTile,
        matching: find.textContaining('Brown boots'),
      ),
      findsOneWidget,
    );
    final db = containerOf(tester).read(appDatabaseProvider);
    final rows = (await tester.runAsync(
      () => db.select(db.wishlistItems).get(),
    ))!;
    expect(rows.single.targetPriceCents, 1250);
  });

  testApp('invalid budget shows an error', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openWishlist(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Budget'), 'abc');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pump();
    expect(find.text('Enter a valid amount'), findsOneWidget);
  });

  testApp('dismissing moves an entry to the Dismissed tab', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      seed: (db) => seedWish(db, 'w1', 'Scarf', ClothingCategory.accessory),
    );
    await openWishlist(tester);
    expect(find.text('Scarf'), findsOneWidget);
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dismiss'));
    await pumpUntilFound(tester, find.text('Your wishlist is empty'));
    await tester.tap(find.widgetWithText(Tab, 'Dismissed'));
    await tester.pumpAndSettle();
    expect(find.text('Scarf'), findsOneWidget);
  });

  testApp('Mark purchased prefills the form and links the new item', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      seed: (db) => seedWish(db, 'w1', 'Boots', ClothingCategory.footwear),
    );
    await openWishlist(tester);
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark purchased'));
    await pumpUntilFound(tester, find.text('Add item'));
    await pumpUntilFound(tester, find.widgetWithText(TextField, 'Boots'));
    await tester.pump(const Duration(milliseconds: 300));
    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Shoes').first,
    );
    expect(chip.selected, isTrue);
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await pumpUntilFound(tester, find.text('Your wishlist is empty'));
    final db = containerOf(tester).read(appDatabaseProvider);
    final entry = (await tester.runAsync(
      () => db.select(db.wishlistItems).getSingle(),
    ))!;
    final items = (await tester.runAsync(
      () => db.select(db.clothingItems).get(),
    ))!;
    expect(entry.status, WishlistStatus.purchased);
    expect(items.single.id, entry.purchasedItemId);
    expect(items.single.name, 'Boots');
  });
}
