import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

import '../../helpers.dart';

Future<void> openGaps(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Gaps & wishlist')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Wardrobe gaps'));
  await tester.pumpAndSettle();
}

void main() {
  final noFootwear = [
    for (var i = 0; i < 3; i++)
      item(id: 't$i', name: 'Top $i', category: ClothingCategory.top),
    for (var i = 0; i < 2; i++)
      item(id: 'b$i', name: 'Bottom $i', category: ClothingCategory.bottom),
  ];

  testApp('empty wardrobe asks for clothing first', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openGaps(tester);
    expect(find.text('Add some clothing first'), findsOneWidget);
  });

  testApp('shows a needed suggestion with an explanation', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: noFootwear);
    await openGaps(tester);
    expect(find.text('Beige casual shoes'), findsOneWidget);
    expect(find.text('Needed'), findsWidgets);
    expect(
      find.textContaining('This would make 6 outfits possible'),
      findsWidgets,
    );
  });

  testApp('Add to wishlist stores a planned entry and hides the card', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: noFootwear);
    await openGaps(tester);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Add to wishlist').first,
    );
    await pumpUntilGone(tester, find.text('Beige casual shoes'));
    final db = containerOf(tester).read(appDatabaseProvider);
    final row = (await tester.runAsync(
      () => db.select(db.wishlistItems).getSingle(),
    ))!;
    expect(row.name, 'Beige casual shoes');
    expect(row.status, WishlistStatus.planned);
    expect(row.reason, contains('This would make'));
    expect(row.preferredColours, {WardrobeColour.beige});
  });

  testApp('Not for me stores a dismissed entry and hides the card', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: noFootwear);
    await openGaps(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Not for me').first);
    await pumpUntilGone(tester, find.text('Beige casual shoes'));
    final db = containerOf(tester).read(appDatabaseProvider);
    final row = (await tester.runAsync(
      () => db.select(db.wishlistItems).getSingle(),
    ))!;
    expect(row.status, WishlistStatus.dismissed);
  });
}
