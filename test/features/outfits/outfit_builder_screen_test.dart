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

  Future<void> chooseSlot(WidgetTester tester, String slot) async {
    await tester.tap(find.byKey(Key('slot-$slot')));
    await tester.pump();
  }

  testApp('warns until the outfit is complete', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await pick(tester, 't1');
    await chooseSlot(tester, 'bottom');
    await pick(tester, 'b1');
    expect(find.text('Not a complete outfit yet — add: Shoes'), findsOneWidget);
    expect(find.byKey(const Key('outfit-score')), findsOneWidget);
    await chooseSlot(tester, 'shoes');
    await pick(tester, 's1');
    expect(find.textContaining('Not a complete outfit'), findsNothing);
  });

  testApp('Save stays disabled until the outfit is complete', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await tester.enterText(find.byKey(const Key('outfit-name')), 'X');
    await pick(tester, 't1');
    final save = find.byKey(const Key('save-outfit'));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await chooseSlot(tester, 'bottom');
    await pick(tester, 'b1');
    await chooseSlot(tester, 'shoes');
    await pick(tester, 's1');
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
  });

  testApp('tapping a selected item deselects it', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await pick(tester, 't1');
    expect(find.byKey(const Key('sel-t1')), findsOneWidget);
    await chooseSlot(tester, 'top');
    await pick(tester, 't1');
    expect(find.byKey(const Key('sel-t1')), findsNothing);
  });

  testApp('the dress switch swaps top and bottom for a dress', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        ...wardrobe,
        item(id: 'd1', name: 'Sundress', category: ClothingCategory.onePiece),
      ],
    );
    await openBuilder(tester);
    await pick(tester, 't1');
    expect(find.byKey(const Key('slot-top')), findsOneWidget);
    await tester.tap(find.byKey(const Key('dress-switch')));
    await tester.pump();
    expect(find.byKey(const Key('slot-top')), findsNothing);
    expect(find.byKey(const Key('slot-dress')), findsOneWidget);
    expect(find.byKey(const Key('sel-t1')), findsNothing);
    await pick(tester, 'd1');
    await chooseSlot(tester, 'shoes');
    await pick(tester, 's1');
    expect(find.textContaining('Not a complete outfit'), findsNothing);
  });

  testApp('shoes are offered with a fit label', (tester, paths) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(
          id: 't1',
          name: 'Shirt',
          category: ClothingCategory.top,
          formality: Formality.smart,
        ),
        item(
          id: 's1',
          name: 'Trainers',
          category: ClothingCategory.footwear,
          formality: Formality.casual,
        ),
      ],
    );
    await openBuilder(tester);
    await pick(tester, 't1');
    await chooseSlot(tester, 'shoes');
    expect(find.text('CHOOSE SHOES ORDERED BY FIT'), findsOneWidget);
    expect(find.text('Slightly casual'), findsOneWidget);
  });

  testApp('saved outfit appears in the list with its photos', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openBuilder(tester);
    await pick(tester, 't1');
    await chooseSlot(tester, 'bottom');
    await pick(tester, 'b1');
    await chooseSlot(tester, 'shoes');
    await pick(tester, 's1');
    await tester.enterText(find.byKey(const Key('outfit-name')), 'Office');
    final save = find.byKey(const Key('save-outfit'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
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
