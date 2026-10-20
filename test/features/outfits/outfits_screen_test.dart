import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';

import '../../helpers.dart';

Future<void> _seed(
  AppDatabase db,
  String id,
  List<String> itemIds, {
  Occasion? occasion,
}) => db.outfitDao.saveOutfit(
  OutfitsCompanion(
    id: Value(id),
    name: Value('Outfit $id'),
    occasion: Value(occasion),
    createdAt: Value(DateTime.utc(2026)),
    updatedAt: Value(DateTime.utc(2026)),
  ),
  itemIds,
);

void main() {
  final wardrobe = [
    item(id: 'c1', category: ClothingCategory.top, formality: Formality.casual),
    item(
      id: 'c2',
      category: ClothingCategory.bottom,
      formality: Formality.casual,
    ),
    item(id: 'f1', category: ClothingCategory.top, formality: Formality.formal),
    item(
      id: 'f2',
      category: ClothingCategory.bottom,
      formality: Formality.formal,
    ),
    item(id: 'n1', category: ClothingCategory.top),
    item(id: 'n2', category: ClothingCategory.bottom),
  ];

  Future<void> seed(AppDatabase db) async {
    await _seed(db, 'casual', ['c1', 'c2'], occasion: Occasion.party);
    await _seed(db, 'formal', ['f1', 'f2'], occasion: Occasion.work);
    await _seed(db, 'unknown', ['n1', 'n2']);
  }

  Future<void> openOutfits(WidgetTester tester) async {
    await tester.tap(find.text('Outfits'));
    await tester.pumpAndSettle();
  }

  Finder chip(Object value) => find.byKey(Key('chip-$value'));

  int chipCount(Finder chip) => int.parse(
    ((find
                .descendant(of: chip, matching: find.byType(Text))
                .evaluate()
                .last
                .widget)
            as Text)
        .data!,
  );

  testApp('formality chips show counts and filter outfits', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe, seed: seed);
    await openOutfits(tester);
    expect(find.text('3 OUTFITS'), findsOneWidget);
    expect(chipCount(find.widgetWithText(FilterChip, 'All')), 3);
    expect(chipCount(chip(Formality.casual)), 1);
    expect(chipCount(chip(Formality.formal)), 1);
    expect(chipCount(chip(Formality.smart)), 0);

    await tester.tap(chip(Formality.casual));
    await tester.pumpAndSettle();
    expect(find.text('Outfit casual'), findsOneWidget);
    expect(find.text('Outfit formal'), findsNothing);

    await tester.tap(chip(Formality.smart));
    await tester.pumpAndSettle();
    expect(find.text('No outfits match these filters'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Outfit unknown'), findsOneWidget);
  });

  testApp('occasion chips show counts and filter outfits', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe, seed: seed);
    await openOutfits(tester);
    expect(chipCount(find.widgetWithText(FilterChip, 'Any occasion')), 3);
    expect(chipCount(chip(Occasion.work)), 1);
    expect(chipCount(chip(Occasion.sport)), 0);

    await tester.tap(chip(Occasion.work));
    await tester.pumpAndSettle();
    expect(find.text('Outfit formal'), findsOneWidget);
    expect(find.text('Outfit casual'), findsNothing);
    expect(find.text('Outfit unknown'), findsNothing);

    // Combines with the formality filter.
    await tester.tap(chip(Formality.casual));
    await tester.pumpAndSettle();
    expect(find.text('No outfits match these filters'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Any occasion'));
    await tester.pumpAndSettle();
    expect(find.text('Outfit casual'), findsOneWidget);
  });

  testApp('phone shows the outfit count under the title', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe, seed: seed);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Outfits'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 outfits'), findsOneWidget);
  }, size: const Size(360, 800));
}
