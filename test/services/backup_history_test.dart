import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/services/backup_history.dart';

import '../helpers.dart';

BackupRecord record(DateTime at, {BackupKind kind = BackupKind.backup}) =>
    BackupRecord(
      path: 'C:/b/${at.toIso8601String()}.zip',
      sizeBytes: 100,
      createdAt: at,
      kind: kind,
    );

void main() {
  test('records persist newest first', () async {
    final paths = await tempPaths();
    final history = BackupHistory(paths.backupHistoryFile);
    expect(history.load(), isEmpty);
    history.add(record(DateTime.utc(2026, 1, 1)));
    history.add(record(DateTime.utc(2026, 3, 1)));
    history.add(record(DateTime.utc(2026, 2, 1)));
    final loaded = BackupHistory(paths.backupHistoryFile).load();
    expect(loaded.map((r) => r.createdAt.month), [3, 2, 1]);
  });

  test('keeps only the 20 newest', () async {
    final history = BackupHistory((await tempPaths()).backupHistoryFile);
    for (var i = 0; i < 25; i++) {
      history.add(record(DateTime.utc(2026, 1, 1).add(Duration(days: i))));
    }
    expect(history.load(), hasLength(20));
  });

  test('a damaged file reads as empty', () async {
    final paths = await tempPaths();
    paths.backupHistoryFile.writeAsStringSync('{not json');
    expect(BackupHistory(paths.backupHistoryFile).load(), isEmpty);
    paths.backupHistoryFile.writeAsStringSync('[1, {"path": 3}]');
    expect(BackupHistory(paths.backupHistoryFile).load(), isEmpty);
  });

  test('lastBackupLabel', () {
    final now = DateTime(2026, 10, 17, 15);
    String label(DateTime d, [BackupKind k = BackupKind.backup]) =>
        lastBackupLabel([record(d, kind: k)], now);
    expect(lastBackupLabel([], now), 'No backup yet');
    expect(label(DateTime(2026, 10, 17, 9)), 'Last backup today');
    expect(label(DateTime(2026, 10, 16, 23)), 'Last backup yesterday');
    expect(label(DateTime(2026, 10, 14, 9)), 'Last backup 3 days ago');
    expect(label(DateTime(2026, 9, 2)), 'Last backup 2 Sep 2026');
    expect(
      label(DateTime(2026, 10, 17), BackupKind.safetyCopy),
      'No backup yet',
    );
  });
}
