import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/outfits/widgets/outfit_card.dart';
import 'package:wardrobe_app/features/wardrobe/wardrobe_providers.dart';
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
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Wardrobe'),
    ),
  );
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
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose photo'));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'White tee');
    for (final label in ['Top', 'White']) {
      final chip = find.widgetWithText(FilterChip, label).first;
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
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

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Outfits'),
      ),
    );
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
}
