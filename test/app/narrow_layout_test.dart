import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/widgets/recommendation_card.dart';

import '../helpers.dart';

/// Phone-sized screens (360 x 800) must lay out without overflow.
void main() {
  const phone = Size(360, 800);
  final wardrobe = [
    item(id: 't1', name: 'Tee', category: ClothingCategory.top),
    item(id: 't2', name: 'Shirt', category: ClothingCategory.top),
    item(id: 'b', name: 'Jeans', category: ClothingCategory.bottom),
    item(id: 's', name: 'Boots', category: ClothingCategory.footwear),
  ];

  testApp('every main screen fits a phone', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    for (final nav in [
      'Wardrobe',
      'Outfits',
      'Suggestions',
      'Gaps & wishlist',
      'Backup',
    ]) {
      // Narrow layout: the bottom bar uses short labels.
      final label = switch (nav) {
        'Suggestions' => 'Suggest',
        'Gaps & wishlist' => 'Gaps',
        _ => nav,
      };
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: nav);
    }
  }, size: phone);

  testApp('suggestions are a swipeable pager on a phone', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Suggest'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('suggestion-pager')), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.byType(RecommendationCard), findsOneWidget);
    await tester.tap(find.byTooltip('Next suggestion'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    // Filters are tucked into an expander.
    expect(find.text('Show suggestions'), findsNothing);
    await tester.tap(find.byKey(const Key('filters-tile')));
    await tester.pumpAndSettle();
    expect(find.text('Show suggestions'), findsOneWidget);
  }, size: phone);

  testApp('gaps and wishlist are tabs on a phone', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Gaps'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('status-planned')), findsNothing);
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('status-planned')), findsOneWidget);
    expect(find.text('Your wishlist is empty'), findsOneWidget);
  }, size: phone);

  testApp('builder, item form and settings fit a phone', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    // Outfit builder with a few slots filled.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Outfits'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    for (final id in ['t1', 'b', 's']) {
      final tile = find.byKey(Key('pick-$id'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull, reason: 'builder');
    await tester.tap(find.byKey(const Key('back')));
    await tester.pumpAndSettle();
    // Edit item.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Wardrobe'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tee'));
    await pumpUntilFound(tester, find.byKey(const Key('name-field')));
    expect(tester.takeException(), isNull, reason: 'item form');
  }, size: phone);

  testApp('Settings is reachable from Backup on a phone', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Backup'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.text('SCORE WEIGHTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, size: phone);
}
