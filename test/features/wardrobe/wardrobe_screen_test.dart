import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/wardrobe/wardrobe_providers.dart';

import '../../helpers.dart';

void main() {
  final wardrobe = [
    item(
      id: 't1',
      name: 'White oxford shirt',
      category: ClothingCategory.top,
      primaryColour: WardrobeColour.white,
      formality: Formality.smartCasual,
    ),
    item(
      id: 't2',
      name: 'Navy crewneck tee',
      category: ClothingCategory.top,
      primaryColour: WardrobeColour.navy,
      formality: Formality.casual,
    ),
    item(
      id: 'b1',
      name: 'Indigo jeans',
      category: ClothingCategory.bottom,
      primaryColour: WardrobeColour.navy,
    ),
    item(id: 's1', name: 'White sneakers', category: ClothingCategory.footwear),
  ];

  testApp('empty wardrobe shows empty state', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openAllItems(tester);
    expect(find.text('Your wardrobe is empty'), findsOneWidget);
    expect(find.text('Add your first item'), findsOneWidget);
    expect(find.text('0 ITEMS · 0 OUTFITS'), findsOneWidget);
  });

  testApp('header counts items and outfits', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    expect(find.text('Your wardrobe'), findsOneWidget);
    expect(find.text('4 ITEMS · 0 OUTFITS'), findsOneWidget);
    expect(find.text('TOPS · WHITE · SMART CASUAL'), findsOneWidget);
  });

  testApp('category chips show counts and filter one category', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    expect(
      find.descendant(
        of: find.widgetWithText(FilterChip, 'Tops'),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(FilterChip, 'Accessories'),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Tops'));
    await tester.pumpAndSettle();
    expect(find.text('White oxford shirt'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Indigo jeans'), findsOneWidget);
  });

  testApp('colour swatches filter by colour', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    await tester.tap(find.byKey(const Key('swatch-navy')));
    await tester.pumpAndSettle();
    expect(find.text('Navy crewneck tee'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsOneWidget);
    expect(find.text('White oxford shirt'), findsNothing);
  });

  testApp('search narrows the list by name or colour', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    await tester.enterText(find.byType(TextField), 'oxford');
    await tester.pumpAndSettle();
    expect(find.text('White oxford shirt'), findsOneWidget);
    expect(find.text('Navy crewneck tee'), findsNothing);
    await tester.enterText(find.byType(TextField), 'navy');
    await tester.pumpAndSettle();
    expect(find.text('Navy crewneck tee'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsOneWidget);
    expect(find.text('White oxford shirt'), findsNothing);
  });

  testApp('filters with no match show message and can be cleared', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No items match these filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('White oxford shirt'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsOneWidget);
  });

  testApp('missing photo file shows a placeholder, not an exception', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [item(name: 'Ghost', imagePath: 'images/clothing/gone.jpg')],
    );
    await openAllItems(tester);
    expect(find.text('Photo missing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testApp('items without a photo get a garment silhouette', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    expect(find.text('Photo missing'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testApp('archived items are only on the archived screen', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(name: 'Active', category: ClothingCategory.top),
        item(name: 'Old coat', isArchived: true),
      ],
    );
    await openAllItems(tester);
    expect(find.text('Old coat'), findsNothing);
    await tester.tap(find.byTooltip('Archived items'));
    await tester.pumpAndSettle();
    expect(find.text('Archived items'), findsWidgets);
    expect(find.text('Old coat'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
  });

  testApp('list toggle shows ListTiles', (tester, paths) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [item(name: 'Newest tee')],
    );
    await openAllItems(tester);
    expect(find.text('Newest tee'), findsOneWidget);
    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
  });

  testApp('the sort dropdown reorders the grid', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    final container = containerOf(tester);
    expect(
      container.read(filteredWardrobeProvider(false)).value!.first.id,
      's1', // newest first
    );
    await tester.tap(find.text('Recently added'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name').last);
    await tester.pumpAndSettle();
    expect(
      container.read(filteredWardrobeProvider(false)).value!.first.name,
      'Indigo jeans',
    );
  });

  testApp('needs details chip counts and filters unfinished items', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    await tester.tap(find.byKey(const Key('needs-details')));
    await tester.pumpAndSettle();
    expect(find.text('Needs details (2)'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsOneWidget);
    expect(find.text('White sneakers'), findsOneWidget);
    expect(find.text('White oxford shirt'), findsNothing);
  });

  testApp('import photos creates hidden items in the chosen category', (
    tester,
    paths,
  ) async {
    final pickers = FakePickers(null)
      ..imagePaths = [
        writeTestJpeg(paths, 'linen_shirt.jpg'),
        writeTestJpeg(paths, 'chinos.jpg'),
      ];
    await pumpApp(tester, paths: paths, pickers: pickers);
    await openAllItems(tester);
    await tester.tap(find.byKey(const Key('import-photos')));
    await tester.pumpAndSettle();
    expect(find.text('2 photos selected'), findsOneWidget);
    final importButton = find.widgetWithText(FilledButton, 'Import');
    expect(tester.widget<FilledButton>(importButton).onPressed, isNull);

    await tester.tap(find.byKey(const Key('import-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bottom').last);
    await tester.pumpAndSettle();
    await tester.tap(importButton);
    await pumpUntilFound(tester, find.text('Imported 2 items'));

    final container = containerOf(tester);
    final items = container.read(wardrobeItemsProvider(false)).value!;
    expect(items.map((i) => i.name).toSet(), {'Linen shirt', 'Chinos'});
    expect(items.every((i) => i.category == ClothingCategory.bottom), isTrue);
    expect(items.every((i) => i.hideFromSuggestions), isTrue);

    await tester.pumpAndSettle(); // let the snackbar finish sliding in
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(container.read(wardrobeFilterProvider).needsDetailsOnly, isTrue);
  });

  testApp('cancelling the picker or the dialog imports nothing', (
    tester,
    paths,
  ) async {
    final pickers = FakePickers(null);
    await pumpApp(tester, paths: paths, pickers: pickers);
    await openAllItems(tester);
    await tester.tap(find.byKey(const Key('import-photos')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    pickers.imagePaths = [writeTestJpeg(paths)];
    await tester.tap(find.byKey(const Key('import-photos')));
    await tester.pumpAndSettle();
    expect(find.text('1 photo selected'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Your wardrobe is empty'), findsOneWidget);
  });

  testApp(
    'narrow layout shows a filter button, search and an add button',
    (tester, paths) async {
      await pumpApp(tester, paths: paths, items: wardrobe);
      await openAllItems(tester);
      expect(find.byTooltip('Filters'), findsOneWidget);
      expect(find.byTooltip('Add item'), findsOneWidget);
      expect(find.byTooltip('Import photos'), findsOneWidget);
      expect(find.text('Search your wardrobe'), findsOneWidget);
      expect(find.byKey(const Key('add-item')), findsNothing);
      expect(find.text('White oxford shirt'), findsOneWidget);
    },
    size: const Size(420, 800),
  );

  testApp('opens on shelves with counts and no empty shelves', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await pumpUntilFound(tester, find.byKey(const Key('shelf-top')));
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('1 item'), findsNWidgets(2));
    expect(find.byKey(const Key('shelf-accessory')), findsNothing);
    expect(find.text('White oxford shirt'), findsNothing);
  });

  testApp('a shelf shows only its category and Shelves goes back', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await pumpUntilFound(tester, find.byKey(const Key('shelf-top')));
    await tester.tap(find.byKey(const Key('shelf-top')));
    await tester.pumpAndSettle();
    expect(find.text('White oxford shirt'), findsOneWidget);
    expect(find.text('Indigo jeans'), findsNothing);
    await tester.tap(find.byKey(const Key('back-to-shelves')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shelf-top')), findsOneWidget);
  });

  testApp('See all shows every item and the All pill stays on the grid', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openAllItems(tester);
    expect(find.text('Indigo jeans'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'Tops'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('Indigo jeans'), findsOneWidget);
    expect(find.byKey(const Key('shelf-top')), findsNothing);
  });

  testApp('searching jumps from the shelves to matching items', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await pumpUntilFound(tester, find.byKey(const Key('shelf-top')));
    await tester.enterText(find.byType(TextField), 'jeans');
    await tester.pumpAndSettle();
    expect(find.text('Indigo jeans'), findsOneWidget);
    expect(find.byKey(const Key('shelf-top')), findsNothing);
  });

  testApp('the back button returns from a shelf to the shelves', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await pumpUntilFound(tester, find.byKey(const Key('shelf-top')));
    await tester.tap(find.byKey(const Key('shelf-top')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shelf-top')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shelf-top')), findsOneWidget);
  });

  testApp('a phone shows the item count under the title', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await pumpUntilFound(tester, find.byKey(const Key('shelf-top')));
    expect(find.text('4 items'), findsOneWidget);
  }, size: const Size(360, 800));
}
