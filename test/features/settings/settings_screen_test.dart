import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/features/settings/backup_controller.dart';
import 'package:wardrobe_app/services/backup_service.dart';

import '../../helpers.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Settings'),
    ),
  );
  await tester.pumpAndSettle();
}

/// Builds a backup of a two-item wardrobe and returns the zip path.
Future<String> makeBackupZip(WidgetTester tester) async {
  final source = await tempPaths();
  return (await tester.runAsync(() async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.clothingDao.upsert(item(id: 'r1', name: 'Restored tee'));
    await db.clothingDao.upsert(
      item(id: 'r2', name: 'Restored jeans', category: ClothingCategory.bottom),
    );
    final dest = p.join(
      Directory.systemTemp.createTempSync('wardrobe_zip_').path,
      'backup.zip',
    );
    await BackupService(source, appVersion: '1').createBackup(db, dest);
    await db.close();
    return dest;
  }))!;
}

Future<int> itemCount(WidgetTester tester) async {
  final db = containerOf(tester).read(appDatabaseProvider);
  return (await tester.runAsync(
    () => db.select(db.clothingItems).get(),
  ))!.length;
}

/// Fails the swap step to exercise the rollback path through the UI.
class FailingApplyService extends BackupService {
  FailingApplyService(super.paths, {required super.appVersion});

  @override
  Future<void> applyRestore(StagedRestore staged) async {
    Directory(p.join(staged.dir.path, 'database')).deleteSync(recursive: true);
    return super.applyRestore(staged);
  }
}

void main() {
  final existing = [item(id: 'old', name: 'Old thing')];

  testApp('shows version, storage folder and photo status', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(id: 'g', name: 'Ghost', imagePath: 'images/clothing/gone.jpg'),
      ],
    );
    await openSettings(tester);
    expect(find.text('Version dev'), findsOneWidget);
    expect(find.text(paths.root.path), findsOneWidget);
    await pumpUntilFound(tester, find.text('1 photo, 1 missing'));
  });

  testApp('backup saves a zip to the chosen location', (tester, paths) async {
    final dest = p.join(
      Directory.systemTemp.createTempSync('wardrobe_dest_').path,
      'mine.zip',
    );
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, saveLocation: dest),
    );
    await openSettings(tester);
    await tester.tap(find.text('Back up wardrobe'));
    await pumpUntilFound(tester, find.text('Backup saved'));
    expect(File(dest).existsSync(), isTrue);
  });

  testApp('restoring a non-backup file explains and changes nothing', (
    tester,
    paths,
  ) async {
    final txt = File(p.join(paths.root.path, 'notes.zip'))
      ..writeAsStringSync('hello');
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, backupFile: txt.path),
    );
    await openSettings(tester);
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(
      tester,
      find.text("This file isn't a wardrobe backup."),
    );
    expect(await itemCount(tester), 1);
  });

  testApp('restoring a valid backup replaces the wardrobe', (
    tester,
    paths,
  ) async {
    final zip = await makeBackupZip(tester);
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, backupFile: zip),
    );
    await openSettings(tester);
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    expect(find.textContaining('Your current 1 item'), findsOneWidget);
    expect(find.textContaining('(2 items'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(tester, find.textContaining('Wardrobe restored'));

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Wardrobe'),
      ),
    );
    await pumpUntilFound(tester, find.text('Restored tee'));
    expect(find.text('Restored jeans'), findsOneWidget);
    expect(find.text('Old thing'), findsNothing);
  });

  testApp('cancelling a restore leaves everything unchanged', (
    tester,
    paths,
  ) async {
    final zip = await makeBackupZip(tester);
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, backupFile: zip),
    );
    await openSettings(tester);
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    // The progress bar stays up until the staging folder has been removed.
    await pumpUntilGone(tester, find.byType(LinearProgressIndicator));
    expect(await itemCount(tester), 1);
    expect(
      paths.tempDir.listSync().where(
        (e) => p.basename(e.path).startsWith('restore-'),
      ),
      isEmpty,
    );
  });

  testApp('a failed swap keeps the existing wardrobe', (tester, paths) async {
    final zip = await makeBackupZip(tester);
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, backupFile: zip),
      overrides: [
        backupServiceProvider.overrideWith(
          (ref) => FailingApplyService(paths, appVersion: 'test'),
        ),
      ],
    );
    await openSettings(tester);
    await tester.tap(find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(
      tester,
      find.text('Restore failed. Your existing wardrobe was kept.'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();
    expect(await itemCount(tester), 1);
    final dbRow = (await tester.runAsync(() async {
      final db = containerOf(tester).read(appDatabaseProvider);
      return db.select(db.clothingItems).getSingle();
    }))!;
    expect(dbRow.name, 'Old thing');
  });

  testApp('reset dismissed recommendations clears dismissals', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      seed: (db) => db.recommendationDao.insertFeedback(
        RecommendationFeedbackCompanion.insert(
          id: 'f1',
          outfitFingerprint: 'a|b|c',
          feedbackType: FeedbackType.dismissed,
          createdAt: DateTime.utc(2026),
          reason: const Value(null),
        ),
      ),
    );
    await openSettings(tester);
    await tester.tap(find.text('Reset dismissed recommendations'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await pumpUntilFound(tester, find.text('Reset 1 dismissed recommendation'));
  });
}
