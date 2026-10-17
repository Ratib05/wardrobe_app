import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/widgets/clothing_photo.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/outfits/widgets/outfit_card.dart';

import '../../helpers.dart';

Future<void> openOutfits(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Outfits')));
  await tester.pumpAndSettle();
}

Future<void> openBuilder(WidgetTester tester) async {
  await openOutfits(tester);
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> pick(WidgetTester tester, String id) async {
  final tile = find.byKey(Key('pick-$id'));
  await tester.ensureVisible(tile);
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pump();
}

Future<void> seedOutfit(
  AppDatabase db,
  String id,
  String name,
  List<String> itemIds, {
  bool favourite = false,
}) => db.outfitDao.saveOutfit(
  OutfitsCompanion(
    id: Value(id),
    name: Value(name),
    isFavourite: Value(favourite),
    createdAt: Value(DateTime.utc(2026)),
    updatedAt: Value(DateTime.utc(2026)),
  ),
  itemIds,
);

void main() {
  final wardrobe = [
    item(id: 't1', name: 'Tee', category: ClothingCategory.top),
    item(id: 'b1', name: 'Jeans', category: ClothingCategory.bottom),
    item(id: 's1', name: 'Boots', category: ClothingCategory.footwear),
  ];

  testApp('warns until the outfit is complete', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await pick(tester, 't1');
    await pick(tester, 'b1');
    expect(find.text('Not a complete outfit yet — add: Shoes'), findsOneWidget);
    await pick(tester, 's1');
    expect(find.textContaining('Not a complete outfit'), findsNothing);
  });

  testApp('tapping a selected item deselects it', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await pick(tester, 't1');
    expect(find.byKey(const Key('sel-t1')), findsOneWidget);
    await pick(tester, 't1');
    expect(find.byKey(const Key('sel-t1')), findsNothing);
  });

  testApp('saving needs two items', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Outfit name'), 'X');
    await pick(tester, 't1');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pump();
    expect(find.text('Choose at least two items'), findsOneWidget);
  });

  testApp('saved outfit appears in the list with its photos', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    for (final id in ['t1', 'b1', 's1']) {
      await pick(tester, id);
    }
    await tester.enterText(
      find.widgetWithText(TextField, 'Outfit name'),
      'Office',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await pumpUntilFound(tester, find.byType(OutfitCard));
    expect(
      find.descendant(
        of: find.byType(OutfitCard),
        matching: find.text('Office'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(OutfitCard),
        matching: find.byType(ClothingPhoto),
      ),
      findsNWidgets(3),
    );
  });

  testApp('editing an outfit with an archived item shows a warning', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(
          id: 'old',
          name: 'Old top',
          category: ClothingCategory.top,
          isArchived: true,
        ),
        wardrobe[1],
      ],
      seed: (db) => seedOutfit(db, 'o1', 'Retro', ['old', 'b1']),
    );
    await openOutfits(tester);
    await tester.tap(find.text('Retro'));
    await pumpUntilFound(tester, find.text('Includes archived items'));
  });

  testApp('the Favourites chip shows only favourite outfits', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: wardrobe,
      seed: (db) async {
        await seedOutfit(db, 'o1', 'Date night', ['t1', 'b1'], favourite: true);
        await seedOutfit(db, 'o2', 'Gym', ['b1', 's1']);
      },
    );
    await openOutfits(tester);
    expect(find.text('Date night'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'Favourites'));
    await tester.pumpAndSettle();
    expect(find.text('Date night'), findsOneWidget);
    expect(find.text('Gym'), findsNothing);
  });
}
