import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
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
}
