import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/services/storage_paths.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

int _counter = 0;

/// Deterministic clothing item for tests.
ClothingItem item({
  String? id,
  String name = 'Item',
  ClothingCategory category = ClothingCategory.top,
  WardrobeColour? primaryColour,
  Set<WardrobeColour> secondaryColours = const {},
  Set<StyleTag> styleTags = const {},
  Formality? formality,
  Set<Season> seasons = const {},
  Set<Occasion> occasions = const {},
  ItemCondition condition = ItemCondition.good,
  String? imagePath,
  bool isFavourite = false,
  bool isArchived = false,
  DateTime? createdAt,
}) {
  final n = ++_counter;
  final created = createdAt ?? DateTime.utc(2026, 1, 1).add(Duration(minutes: n));
  return ClothingItem(
    id: id ?? 'item-$n',
    name: name,
    category: category,
    primaryColour: primaryColour,
    secondaryColours: secondaryColours,
    styleTags: styleTags,
    formality: formality,
    seasons: seasons,
    occasions: occasions,
    condition: condition,
    imagePath: imagePath,
    isFavourite: isFavourite,
    isArchived: isArchived,
    createdAt: created,
    updatedAt: created,
  );
}

/// Fresh temp storage root, prepared and deleted after the test.
Future<StoragePaths> tempPaths() async {
  final root = Directory.systemTemp.createTempSync('wardrobe_test_');
  addTearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });
  final paths = StoragePaths(root);
  // Synchronous so it also works inside testWidgets' fake-async zone.
  paths.dataDir.createSync(recursive: true);
  paths.clothingImagesDir.createSync(recursive: true);
  paths.tempDir.createSync(recursive: true);
  return paths;
}

AppDatabase? _openDb;

/// testWidgets wrapper for app-level tests: unmounts the app and closes the
/// database before the test ends so drift's stream timers don't leak.
void testApp(
  String description,
  Future<void> Function(WidgetTester tester, StoragePaths paths) body, {
  Size size = const Size(1200, 800),
}) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final paths = await tempPaths();
    try {
      await body(tester, paths);
    } finally {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.runAsync(() async => _openDb?.close());
      _openDb = null;
    }
  });
}

/// Pumps the whole app against a real on-disk database in [paths].
Future<void> pumpApp(WidgetTester tester, {required StoragePaths paths}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // Same-isolate database keeps widget tests in fake-async.
  final db = _openDb = AppDatabase(NativeDatabase(paths.databaseFile));
  await tester.pumpWidget(ProviderScope(
    retry: (_, _) => null,
    overrides: [
      storagePathsProvider.overrideWithValue(paths),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const WardrobeApp(),
  ));
  await tester.pumpAndSettle();
}
