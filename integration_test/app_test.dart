import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/outfits/outfit_providers.dart';
import 'package:wardrobe_app/features/outfits/widgets/outfit_card.dart';
import 'package:wardrobe_app/features/recommendations/widgets/recommendation_card.dart';
import 'package:wardrobe_app/features/wardrobe/wardrobe_providers.dart';
import 'package:wardrobe_app/features/wishlist/wishlist_providers.dart';
import 'package:wardrobe_app/services/storage_paths.dart';

import '../test/helpers.dart';

Widget appFor(StoragePaths paths, FakePickers pickers, Key key) =>
    ProviderScope(
      key: key,
      overrides: [
        storagePathsProvider.overrideWithValue(paths),
        platformPickersProvider.overrideWithValue(pickers),
      ],
      child: const WardrobeApp(),
    );

Future<void> openWardrobe(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Wardrobe')));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Workflow A: add clothing with photo, persists across restart', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync('wardrobe_it_');
    addTearDown(() {
      // Best effort: Windows may still hold the database file open.
      try {
        root.deleteSync(recursive: true);
      } on FileSystemException {
        // temp dir; the OS cleans it up
      }
    });
    final paths = StoragePaths(root);
    await paths.prepare();
    final pickers = FakePickers(writeTestJpeg(paths));

    await tester.pumpWidget(appFor(paths, pickers, UniqueKey()));
    await tester.pumpAndSettle();
    await openWardrobe(tester);
    await tester.tap(find.byKey(const Key('add-item')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('replace-photo')));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    await tester.enterText(find.byKey(const Key('name-field')), 'White tee');
    await tester.tap(find.byType(DropdownButtonFormField<ClothingCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Top').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-colour')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-colour-white')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-item')));
    await pumpUntilGone(tester, find.byKey(const Key('save-item')));
    await pumpUntilFound(tester, find.text('White tee'));

    // "Restart": tear the app down and start a fresh one on the same storage.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(appFor(paths, pickers, UniqueKey()));
    await tester.pumpAndSettle();
    await openWardrobe(tester);
    expect(find.text('White tee'), findsOneWidget);
    expect(paths.clothingImagesDir.listSync(), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Workflow B: create an outfit, reopen it', (tester) async {
    final root = Directory.systemTemp.createTempSync('wardrobe_it_');
    addTearDown(() {
      try {
        root.deleteSync(recursive: true);
      } on FileSystemException {
        // temp dir; the OS cleans it up
      }
    });
    final paths = StoragePaths(root);
    await paths.prepare();

    await tester.pumpWidget(appFor(paths, FakePickers(null), UniqueKey()));
    await tester.pumpAndSettle();
    final repo = ProviderScope.containerOf(
      tester.element(find.byType(WardrobeApp)),
    ).read(clothingRepositoryProvider);
    for (final i in [
      item(id: 't1', name: 'Tee', category: ClothingCategory.top),
      item(id: 'b1', name: 'Jeans', category: ClothingCategory.bottom),
      item(id: 's1', name: 'Boots', category: ClothingCategory.footwear),
    ]) {
      await repo.save(i);
    }
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-Outfits')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    for (final id in ['t1', 'b1', 's1']) {
      final tile = find.byKey(Key('pick-$id'));
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pump();
    }
    final casual = find.widgetWithText(FilterChip, 'Casual');
    await tester.ensureVisible(casual.first);
    await tester.pumpAndSettle();
    await tester.tap(casual.first);
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Outfit name'),
      'Weekend',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await pumpUntilFound(tester, find.byType(OutfitCard));

    await tester.tap(
      find.descendant(
        of: find.byType(OutfitCard),
        matching: find.text('Weekend'),
      ),
    );
    await pumpUntilFound(tester, find.text('Edit outfit'));
    await pumpUntilFound(tester, find.byKey(const Key('sel-t1')));
    expect(find.byKey(const Key('sel-b1')), findsOneWidget);
    expect(find.byKey(const Key('sel-s1')), findsOneWidget);
    final nameField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Outfit name'),
    );
    expect(nameField.controller!.text, 'Weekend');
    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Casual').first,
    );
    expect(chip.selected, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Workflow C: recommendations are valid and explained', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync('wardrobe_it_');
    addTearDown(() {
      try {
        root.deleteSync(recursive: true);
      } on FileSystemException {
        // temp dir; the OS cleans it up
      }
    });
    final paths = StoragePaths(root);
    await paths.prepare();

    await tester.pumpWidget(appFor(paths, FakePickers(null), UniqueKey()));
    await tester.pumpAndSettle();
    final repo = ProviderScope.containerOf(
      tester.element(find.byType(WardrobeApp)),
    ).read(clothingRepositoryProvider);
    ClothingItem make(
      String name,
      ClothingCategory c, {
      WardrobeColour? colour,
      bool archived = false,
      ItemCondition condition = ItemCondition.good,
    }) => item(
      id: name,
      name: name,
      category: c,
      primaryColour: colour,
      isArchived: archived,
      condition: condition,
      formality: Formality.casual,
    );
    for (final i in [
      make('Navy tee', ClothingCategory.top, colour: WardrobeColour.navy),
      make('Grey tee', ClothingCategory.top, colour: WardrobeColour.grey),
      make('Archived top', ClothingCategory.top, archived: true),
      make('Chinos', ClothingCategory.bottom, colour: WardrobeColour.beige),
      make(
        'Black trousers',
        ClothingCategory.bottom,
        colour: WardrobeColour.black,
      ),
      make(
        'Broken jeans',
        ClothingCategory.bottom,
        condition: ItemCondition.needsRepair,
      ),
      make('Sneakers', ClothingCategory.footwear),
      make('Loafers', ClothingCategory.footwear),
      make('Jacket', ClothingCategory.outerwear),
      make('Summer dress', ClothingCategory.onePiece),
    ]) {
      await repo.save(i);
    }
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-Suggestions')));
    await pumpUntilFound(tester, find.byType(RecommendationCard));

    expect(find.text('Archived top'), findsNothing);
    expect(find.text('Broken jeans'), findsNothing);
    final allowed = RegExp(
      r'^(Colours are compatible|All items suit .+|No item conflicts with .+|'
      r'Items share an occasion: .+|Formality levels are consistent|'
      r'Items share a style: .+|Suitable for .+|Items share a season: .+|'
      r'Matches your preferences|You rated this \d/5|'
      r'You liked this combination|Meets the basic outfit rules)$',
    );
    final reasons = find.byKey(const Key('reason')).evaluate();
    expect(reasons, isNotEmpty);
    for (final e in reasons) {
      expect((e.widget as Text).data, matches(allowed));
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Workflow D: back up, restore into a clean install', (
    tester,
  ) async {
    Directory freshRoot() {
      final root = Directory.systemTemp.createTempSync('wardrobe_it_');
      addTearDown(() {
        try {
          root.deleteSync(recursive: true);
        } on FileSystemException {
          // temp dir; the OS cleans it up
        }
      });
      return root;
    }

    ProviderContainer containerOf() =>
        ProviderScope.containerOf(tester.element(find.byType(WardrobeApp)));

    Future<void> openBackup() async {
      await tester.tap(find.byKey(const Key('nav-Backup')));
      await tester.pumpAndSettle();
    }

    final backupZip = '${freshRoot().path}${Platform.pathSeparator}backup.zip';

    // --- Install 1: create data and back it up.
    final paths1 = StoragePaths(freshRoot());
    await paths1.prepare();
    final pickers = FakePickers(writeTestJpeg(paths1), saveLocation: backupZip);
    await tester.pumpWidget(appFor(paths1, pickers, UniqueKey()));
    await tester.pumpAndSettle();
    var c = containerOf();
    final staged = await c.read(imageStorageProvider).stage(pickers.imagePath!);
    await c
        .read(clothingRepositoryProvider)
        .save(
          item(id: 'tee', name: 'Tee', category: ClothingCategory.top),
          stagedImage: staged,
        );
    await c
        .read(clothingRepositoryProvider)
        .save(
          item(id: 'jeans', name: 'Jeans', category: ClothingCategory.bottom),
        );
    await c
        .read(outfitRepositoryProvider)
        .save(name: 'Weekend', itemIds: ['tee', 'jeans']);
    await c
        .read(wishlistRepositoryProvider)
        .save(name: 'Boots', category: ClothingCategory.footwear);
    await tester.pumpAndSettle();

    await openBackup();
    await tester.tap(find.text('Back up wardrobe'));
    await pumpUntilFound(tester, find.text('Backup saved'));
    expect(File(backupZip).existsSync(), isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    // --- Install 2: clean, restore the backup.
    final paths2 = StoragePaths(freshRoot());
    await paths2.prepare();
    pickers.backupFile = backupZip;
    await tester.pumpWidget(appFor(paths2, pickers, UniqueKey()));
    await tester.pumpAndSettle();
    await openBackup();
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(tester, find.textContaining('Wardrobe restored'));

    c = containerOf();
    final items = await c.read(clothingRepositoryProvider).watchItems().first;
    expect(items.map((i) => i.name).toSet(), {'Tee', 'Jeans'});
    final tee = items.firstWhere((i) => i.name == 'Tee');
    expect(tee.imagePath, isNotNull);
    expect(paths2.imageFile(tee.imagePath!).existsSync(), isTrue);
    final outfits = await c.read(outfitRepositoryProvider).watchAll().first;
    expect(outfits.single.items.map((i) => i.name).toSet(), {'Tee', 'Jeans'});
    expect(await c.read(wishlistRepositoryProvider).all(), hasLength(1));

    // --- An invalid archive is rejected and nothing changes.
    final notABackup = File('${paths2.root.path}${Platform.pathSeparator}x.zip')
      ..writeAsStringSync('not a zip');
    pickers.backupFile = notABackup.path;
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(
      tester,
      find.text("This file isn't a wardrobe backup."),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();
    final after = await containerOf()
        .read(clothingRepositoryProvider)
        .watchItems()
        .first;
    expect(after, hasLength(2));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
