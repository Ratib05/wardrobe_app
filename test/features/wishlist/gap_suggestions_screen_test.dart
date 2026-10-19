import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

import '../../helpers.dart';

Future<void> openGaps(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Gaps & wishlist')));
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
    expect(find.text('Black casual shoes'), findsOneWidget);
    expect(find.text('Needed'), findsWidgets);
    expect(find.text('PAIRS WITH'), findsWidgets);
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
    await tester.tap(find.text('Add to wishlist').first);
    await pumpUntilGone(
      tester,
      find.byKey(const Key('gap-footwear:black:casual')),
    );
    final db = containerOf(tester).read(appDatabaseProvider);
    final row = (await tester.runAsync(
      () => db.select(db.wishlistItems).getSingle(),
    ))!;
    expect(row.name, 'Black casual shoes');
    expect(row.status, WishlistStatus.planned);
    expect(row.reason, contains('This would make'));
    expect(row.preferredColours, {WardrobeColour.black});
  });

  testApp('Not for me stores a dismissed entry and hides the card', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: noFootwear);
    await openGaps(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Not for me').first);
    await pumpUntilGone(
      tester,
      find.byKey(const Key('gap-footwear:black:casual')),
    );
    final db = containerOf(tester).read(appDatabaseProvider);
    final row = (await tester.runAsync(
      () => db.select(db.wishlistItems).getSingle(),
    ))!;
    expect(row.status, WishlistStatus.dismissed);
  });
}
