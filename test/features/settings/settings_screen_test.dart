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

Future<void> openSettingsPage(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Settings')));
  await tester.pumpAndSettle();
}

Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Future<void> openBackup(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Backup')));
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

  testApp('shows storage folder and photo status on the Backup page', (
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
    await openBackup(tester);
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Back up wardrobe'));
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    expect(find.textContaining('Your current 1 item'), findsOneWidget);
    expect(find.textContaining('(2 items'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(tester, find.textContaining('Wardrobe restored'));

    await tester.tap(find.byKey(const Key('nav-Wardrobe')));
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
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

  testApp('Settings shows the app version', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openSettingsPage(tester);
    expect(find.text('Version dev'), findsOneWidget);
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
    await openSettingsPage(tester);
    await tester.tap(find.text('Reset dismissed recommendations'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await pumpUntilFound(tester, find.text('Reset 1 dismissed recommendation'));
  });

  testApp(
    'the Backup page shows sizes, a suggested file name and Open folder',
    (tester, paths) async {
      final pickers = FakePickers(null);
      await pumpApp(tester, paths: paths, items: existing, pickers: pickers);
      await openBackup(tester);
      await pumpUntilFound(tester, find.byKey(const Key('db-size')));
      expect(
        tester.widget<Text>(find.byKey(const Key('suggested-file'))).data,
        matches(RegExp(r'^wardrobe-backup-\d{4}-\d{2}-\d{2}\.zip$')),
      );
      await tapScrolled(tester, find.byKey(const Key('open-folder')));
      await tester.pump();
      expect(pickers.openedFolders, [paths.root.path]);
    },
  );

  testApp('a finished backup appears under Recent backups', (
    tester,
    paths,
  ) async {
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
    await openBackup(tester);
    expect(find.text('No backups made yet.'), findsOneWidget);
    await tapScrolled(tester, find.text('Back up wardrobe'));
    await pumpUntilFound(tester, find.text('mine.zip'));
  });

  testApp('restoring first saves a safety copy and lists it', (
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
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(tester, find.textContaining('Wardrobe restored'));
    final copies = paths.safetyCopiesDir.listSync().whereType<File>().toList();
    expect(copies, hasLength(1));
    await pumpUntilFound(
      tester,
      find.textContaining('Safety copy · safety-copy-'),
    );
  });

  testApp('if the safety copy cannot be saved, nothing is replaced', (
    tester,
    paths,
  ) async {
    final zip = await makeBackupZip(tester);
    // A file where the folder should be makes the safety copy impossible.
    File(paths.safetyCopiesDir.path).writeAsStringSync('in the way');
    await pumpApp(
      tester,
      paths: paths,
      items: existing,
      pickers: FakePickers(null, backupFile: zip),
    );
    await openBackup(tester);
    await tapScrolled(tester, find.text('Restore wardrobe'));
    await pumpUntilFound(tester, find.text('Replace your wardrobe?'));
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await pumpUntilFound(
      tester,
      find.textContaining(
        'safety copy of your current wardrobe could not be saved',
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await tester.pumpAndSettle();
    expect(await itemCount(tester), 1);
    expect(
      paths.tempDir.listSync().where(
        (e) => p.basename(e.path).startsWith('restore-'),
      ),
      isEmpty,
    );
  });

  testApp('on a phone the backup is handed to the save dialog as bytes', (
    tester,
    paths,
  ) async {
    final pickers = FakePickers(null, saveLocation: 'unused')..phone = true;
    await pumpApp(tester, paths: paths, items: existing, pickers: pickers);
    await openBackup(tester);
    await tapScrolled(tester, find.text('Back up wardrobe'));
    await pumpUntilFound(tester, find.text('Backup saved'));
    expect(pickers.savedName, startsWith('wardrobe-backup-'));
    // A real zip, and no temporary export left behind.
    expect(String.fromCharCodes(pickers.savedBytes!.take(2)), 'PK');
    expect(
      paths.tempDir.listSync().where(
        (e) => p.basename(e.path).startsWith('export-'),
      ),
      isEmpty,
    );
    await pumpUntilFound(tester, find.textContaining('wardrobe-backup-'));
    expect(find.textContaining('File not found'), findsNothing);
  });

  testApp('cancelling the phone save dialog records nothing', (
    tester,
    paths,
  ) async {
    final pickers = FakePickers(null)..phone = true; // saveLocation null
    await pumpApp(tester, paths: paths, items: existing, pickers: pickers);
    await openBackup(tester);
    await tapScrolled(tester, find.text('Back up wardrobe'));
    await pumpUntilGone(tester, find.byType(LinearProgressIndicator));
    expect(find.text('Backup saved'), findsNothing);
    expect(find.text('No backups made yet.'), findsOneWidget);
  });
}
