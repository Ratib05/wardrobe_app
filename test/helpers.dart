import 'dart:io';

import 'package:image/image.dart' as img;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/recommendations/engine/gap_analysis.dart';
import 'package:wardrobe_app/features/recommendations/engine/recommendation_engine.dart';
import 'package:wardrobe_app/features/recommendations/recommendations_providers.dart';
import 'package:wardrobe_app/features/wishlist/gap_providers.dart';
import 'package:wardrobe_app/services/platform_pickers.dart';
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
  bool hideFromSuggestions = false,
  DateTime? createdAt,
}) {
  final n = ++_counter;
  final created =
      createdAt ?? DateTime.utc(2026, 1, 1).add(Duration(minutes: n));
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
    hideFromSuggestions: hideFromSuggestions,
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
    }
  });
}

/// Pumps the whole app against a real on-disk database in [paths].
Future<void> pumpApp(
  WidgetTester tester, {
  required StoragePaths paths,
  List<ClothingItem> items = const [],
  Future<void> Function(AppDatabase db)? seed,
  PlatformPickers? pickers,
  List<Override> overrides = const [],
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // Seed through a temporary connection before the app (and any stream
  // listener) exists; sequential writes with live listeners stall under
  // fake-async.
  if (items.isNotEmpty || seed != null) {
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase(paths.databaseFile));
      for (final i in items) {
        await db.clothingDao.upsert(i);
      }
      if (seed != null) await seed(db);
      await db.close();
    });
  }
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        storagePathsProvider.overrideWithValue(paths),
        // A factory (not a value) so a restore can close and reopen it. The
        // same-isolate connection keeps widget tests in fake-async.
        appDatabaseProvider.overrideWith((ref) {
          final db = AppDatabase(NativeDatabase(paths.databaseFile));
          ref.onDispose(db.close);
          return db;
        }),
        // Direct call: isolates don't complete inside fake-async.
        gapRunnerProvider.overrideWithValue((r) async => analyseGaps(r)),
        recommendRunnerProvider.overrideWithValue(
          (r) async => recommendWithTotal(r),
        ),
        if (pickers != null) platformPickersProvider.overrideWithValue(pickers),
        ...overrides,
      ],
      child: const WardrobeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// A small valid JPEG.
Uint8List jpegBytes({int width = 64, int height = 32}) =>
    Uint8List.fromList(img.encodeJpg(img.Image(width: width, height: height)));

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(WardrobeApp)));

/// Returns fixed paths instead of opening file dialogs.
class FakePickers extends PlatformPickers {
  FakePickers(this.imagePath, {this.saveLocation, this.backupFile});
  String? imagePath;
  String? saveLocation;
  String? backupFile;

  @override
  Future<String?> pickImagePath() async => imagePath;

  /// Returned by the multi-photo picker (bulk import).
  List<String> imagePaths = const [];

  @override
  Future<List<String>> pickImagePaths() async => imagePaths;

  @override
  Future<String?> chooseBackupSaveLocation(String suggestedName) async =>
      saveLocation;

  @override
  Future<String?> chooseBackupFile() async => backupFile;

  final openedFolders = <String>[];

  /// Phone-style behaviour, off by default (the tests run as desktop).
  bool phone = false;
  String? cameraPath;
  String? croppedPath;
  final cropped = <String>[];
  Uint8List? savedBytes;
  String? savedName;

  @override
  bool get canTakePhoto => phone;

  @override
  Future<String?> takePhotoPath() async => cameraPath;

  @override
  bool get canCrop => phone;

  @override
  Future<String?> cropImage(String path) async {
    cropped.add(path);
    return croppedPath;
  }

  @override
  bool get exportsAsBytes => phone;

  @override
  Future<bool> saveBackupBytes(String name, Uint8List bytes) async {
    if (saveLocation == null) return false;
    savedName = name;
    savedBytes = bytes;
    return true;
  }

  @override
  bool get canOpenFolder => true;

  @override
  Future<void> openFolder(String path) async => openedFolders.add(path);
}

/// Pumps (letting real IO/DB futures complete) until [finder] matches.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 250; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $finder');
}

/// Pumps until [done] returns true.
Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 250; i++) {
    if (done()) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for condition');
}

/// Pumps until [finder] no longer matches.
Future<void> pumpUntilGone(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 250; i++) {
    if (finder.evaluate().isEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $finder to disappear');
}

/// Writes a plain single-colour JPEG (0xRRGGBB) into [paths].root.
String writeSolidJpeg(
  StoragePaths paths,
  int rgb, [
  String name = 'solid.jpg',
]) {
  final image = img.Image(width: 64, height: 64)
    ..clear(img.ColorRgb8((rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255));
  final f = File('${paths.root.path}/$name')
    ..writeAsBytesSync(img.encodeJpg(image));
  return f.path;
}

/// Writes a small JPEG into [paths].root and returns its path.
String writeTestJpeg(StoragePaths paths, [String name = 'photo.jpg']) {
  final f = File('${paths.root.path}/$name')..writeAsBytesSync(jpegBytes());
  return f.path;
}

/// The Wardrobe tab opens on shelves; waits briefly for them, then taps
/// "See all" to reach the item grid. Does nothing when there are no shelves
/// (empty wardrobe, or the grid is already showing).
Future<void> openAllItems(WidgetTester tester) async {
  final seeAll = find.byKey(const Key('see-all'));
  for (var i = 0; i < 20 && seeAll.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  if (seeAll.evaluate().isEmpty) return;
  await tester.ensureVisible(seeAll);
  await tester.pumpAndSettle();
  await tester.tap(seeAll);
  await tester.pumpAndSettle();
}
