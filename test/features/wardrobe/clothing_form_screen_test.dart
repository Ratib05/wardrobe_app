import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';

import '../../helpers.dart';

Future<void> openAddForm(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Wardrobe')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('add-item')));
  await tester.pumpAndSettle();
}

Future<void> enterName(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(const Key('name-field')), name);
}

Future<void> chooseCategory(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DropdownButtonFormField<ClothingCategory>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('save-item')));
  await tester.pump();
}

/// Saves and waits for the form to close (its Save button disappears).
Future<void> saveAndWait(WidgetTester tester) async {
  await tapSave(tester);
  await pumpUntilGone(tester, find.byKey(const Key('save-item')));
}

Future<void> addColour(WidgetTester tester, WardrobeColour colour) async {
  await tester.ensureVisible(find.byKey(const Key('add-colour')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('add-colour')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('pick-colour-${colour.name}')));
  await tester.pumpAndSettle();
}

Future<List<ClothingItem>> allItems(WidgetTester tester) async {
  final db = containerOf(tester).read(appDatabaseProvider);
  return (await tester.runAsync(() => db.select(db.clothingItems).get()))!;
}

Future<void> openItem(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(const Key('nav-Wardrobe')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name));
  await pumpUntilFound(tester, find.byKey(const Key('name-field')));
}

void main() {
  testApp('save without name or category shows errors', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    await tapSave(tester);
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Choose a category'), findsWidgets);
    expect(await allItems(tester), isEmpty);
  });

  testApp('name + category is enough to save', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    await enterName(tester, 'Navy chinos');
    await chooseCategory(tester, 'Bottom');
    await saveAndWait(tester);
    final items = await allItems(tester);
    expect(items, hasLength(1));
    expect(items.single.primaryColour, isNull);
    expect(items.single.seasons, isEmpty);
    expect(items.single.imagePath, isNull);
  });

  testApp('the first colour is the main one and can be changed', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    await enterName(tester, 'Overshirt');
    await chooseCategory(tester, 'Outerwear');
    await addColour(tester, WardrobeColour.olive);
    await addColour(tester, WardrobeColour.darkBrown);
    await tester.tap(find.byKey(const Key('colour-darkBrown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make main colour'));
    await tester.pumpAndSettle();
    await saveAndWait(tester);
    final saved = (await allItems(tester)).single;
    expect(saved.primaryColour, WardrobeColour.darkBrown);
    expect(saved.secondaryColours, {WardrobeColour.olive});
  });

  testApp('formality is picked from the segmented control', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    await enterName(tester, 'Tee');
    await chooseCategory(tester, 'Top');
    await tester.ensureVisible(find.byKey(const Key('segment-smartCasual')));
    await tester.tap(find.byKey(const Key('segment-smartCasual')));
    await tester.pump();
    await saveAndWait(tester);
    expect((await allItems(tester)).single.formality, Formality.smartCasual);
  });

  testApp('Hide from suggestions is saved', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    await enterName(tester, 'Stored away coat');
    await chooseCategory(tester, 'Outerwear');
    final hide = find.widgetWithText(
      CheckboxListTile,
      'Hide from suggestions (in repair, stored away)',
    );
    await tester.ensureVisible(hide);
    await tester.pumpAndSettle();
    await tester.tap(hide);
    await tester.pump();
    await saveAndWait(tester);
    expect((await allItems(tester)).single.hideFromSuggestions, isTrue);
  });

  testApp('chosen photo is stored under images/clothing', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      pickers: FakePickers(writeTestJpeg(paths)),
    );
    await openAddForm(tester);
    await tester.tap(find.byKey(const Key('replace-photo')));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    await enterName(tester, 'Tee');
    await chooseCategory(tester, 'Top');
    await saveAndWait(tester);
    final item = (await allItems(tester)).single;
    expect(item.imagePath, startsWith('images/clothing/'));
    expect(paths.imageFile(item.imagePath!).existsSync(), isTrue);
  });

  testApp('unsupported image shows a friendly message', (tester, paths) async {
    final txt = File('${paths.root.path}/notes.txt')
      ..writeAsStringSync('hello');
    await pumpApp(tester, paths: paths, pickers: FakePickers(txt.path));
    await openAddForm(tester);
    await tester.tap(find.byKey(const Key('replace-photo')));
    await pumpUntilFound(
      tester,
      find.text(
        "This image format isn't supported. Use a JPEG, PNG or WebP photo.",
      ),
    );
    expect(paths.tempDir.listSync(), isEmpty);
  });

  testApp('rotating replaces the stored photo with a turned copy', (
    tester,
    paths,
  ) async {
    File(
      '${paths.clothingImagesDir.path}/a.jpg',
    ).writeAsBytesSync(jpegBytes(width: 200, height: 100));
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(id: 'p', name: 'Photo tee', imagePath: 'images/clothing/a.jpg'),
      ],
    );
    await openItem(tester, 'Photo tee');
    expect(
      find.textContaining('Saved locally as images/clothing/a.jpg'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('rotate-photo')));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    await saveAndWait(tester);
    final saved = (await allItems(tester)).single;
    expect(saved.imagePath, isNot('images/clothing/a.jpg'));
    expect(paths.imageFile(saved.imagePath!).existsSync(), isTrue);
    expect(paths.imageFile('images/clothing/a.jpg').existsSync(), isFalse);
  });

  testApp('editing updates the item and keeps createdAt', (
    tester,
    paths,
  ) async {
    final created = DateTime.utc(2025, 5, 5);
    await pumpApp(
      tester,
      paths: paths,
      items: [item(id: 'e1', name: 'Old name', createdAt: created)],
    );
    await openItem(tester, 'Old name');
    expect(find.text('EDIT ITEM · ADDED 5 MAY 2025'), findsOneWidget);
    await enterName(tester, 'New name');
    await saveAndWait(tester);
    final saved = (await allItems(tester)).single;
    expect(saved.name, 'New name');
    expect(saved.createdAt.isAtSameMomentAs(created), isTrue);
  });

  testApp('shows saved outfits and valid combos for the item', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(id: 't', name: 'Tee', category: ClothingCategory.top),
        item(id: 'b', name: 'Jeans', category: ClothingCategory.bottom),
        item(id: 's', name: 'Boots', category: ClothingCategory.footwear),
      ],
      seed: (db) async {
        await db.outfitDao.saveOutfit(
          OutfitsCompanion(
            id: const Value('o1'),
            name: const Value('Casual'),
            createdAt: Value(DateTime.utc(2026)),
            updatedAt: Value(DateTime.utc(2026)),
          ),
          ['t', 'b'],
        );
      },
    );
    await openItem(tester, 'Tee');
    await pumpUntilFound(tester, find.text('saved outfits'));
    // One saved outfit; one valid top + bottom + shoes combination.
    await pumpUntilFound(tester, find.text('1'));
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('valid combos'), findsOneWidget);
  });

  testApp('delete dialog mentions outfits and deletes', (tester, paths) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [item(id: 'e1', name: 'Old name')],
      seed: (db) async {
        await db
            .into(db.outfits)
            .insert(
              OutfitsCompanion.insert(
                id: 'o1',
                name: 'O',
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026),
              ),
            );
        await db
            .into(db.outfitItems)
            .insert(
              OutfitItemsCompanion.insert(
                outfitId: 'o1',
                clothingItemId: 'e1',
                position: 0,
              ),
            );
      },
    );
    await openItem(tester, 'Old name');
    final delete = find.byKey(const Key('delete-item'));
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await pumpUntilFound(tester, find.textContaining('used in 1 outfit'));
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await pumpUntilFound(tester, find.text('Your wardrobe is empty'));
    expect(await allItems(tester), isEmpty);
  });

  testApp(
    'narrow layout stacks the form with Cancel and Save at the bottom',
    (tester, paths) async {
      await pumpApp(tester, paths: paths);
      await tester.tap(find.byTooltip('Add item'));
      await tester.pumpAndSettle();
      expect(find.text('New item'), findsOneWidget);
      expect(find.byKey(const Key('save-item')), findsOneWidget);
      expect(find.byKey(const Key('cancel-item')), findsOneWidget);
      await tester.tap(find.byKey(const Key('cancel-item')));
      await tester.pumpAndSettle();
      expect(find.text('Wardrobe'), findsWidgets);
    },
    size: const Size(420, 800),
  );

  testApp('on a phone, a photo is chosen, cropped, then stored', (
    tester,
    paths,
  ) async {
    final pickers = FakePickers(writeTestJpeg(paths, 'gallery.jpg'))
      ..phone = true
      ..croppedPath = writeTestJpeg(paths, 'cropped.jpg');
    await pumpApp(tester, paths: paths, pickers: pickers);
    await openAddForm(tester);
    await tester.tap(find.byKey(const Key('replace-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('choose-from-gallery')));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    expect(pickers.cropped, [pickers.imagePath]);
    await enterName(tester, 'Tee');
    await chooseCategory(tester, 'Top');
    await saveAndWait(tester);
    expect((await allItems(tester)).single.imagePath, isNotNull);
  });

  testApp('on a phone, Take photo uses the camera and backing out of the '
      'crop adds nothing', (tester, paths) async {
    final pickers = FakePickers(null)
      ..phone = true
      ..cameraPath = writeTestJpeg(paths, 'camera.jpg')
      ..croppedPath = null;
    await pumpApp(tester, paths: paths, pickers: pickers);
    await openAddForm(tester);
    await tester.tap(find.byKey(const Key('replace-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('take-photo')));
    await tester.pumpAndSettle();
    expect(pickers.cropped, [pickers.cameraPath]);
    expect(find.byKey(const Key('staged-photo')), findsNothing);
  });

  testApp('the Crop button re-crops the current photo', (tester, paths) async {
    File(
      '${paths.clothingImagesDir.path}/a.jpg',
    ).writeAsBytesSync(jpegBytes(width: 200, height: 100));
    final pickers = FakePickers(null)
      ..phone = true
      ..croppedPath = writeTestJpeg(paths, 'cropped.jpg');
    await pumpApp(
      tester,
      paths: paths,
      pickers: pickers,
      items: [
        item(id: 'p', name: 'Photo tee', imagePath: 'images/clothing/a.jpg'),
      ],
    );
    await openItem(tester, 'Photo tee');
    await tester.tap(find.byKey(const Key('crop-photo')));
    await pumpUntilFound(tester, find.byKey(const Key('staged-photo')));
    expect(pickers.cropped.single, endsWith('a.jpg'));
  });

  testApp('desktop has no Crop or Take photo', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openAddForm(tester);
    expect(find.byKey(const Key('crop-photo')), findsNothing);
  });
}
