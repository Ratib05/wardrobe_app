import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../services/backup_history.dart';
import '../../services/backup_service.dart';
import '../wardrobe/wardrobe_providers.dart';

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    ref.watch(storagePathsProvider),
    appVersion: ref.watch(appVersionProvider),
  ),
);

final backupControllerProvider = Provider<BackupController>(
  BackupController.new,
);

/// Orchestrates backup and restore for the Settings screen: picking files,
/// calling [BackupService], and swapping the live database during a restore.
class BackupController {
  BackupController(this._ref);

  final Ref _ref;

  BackupService get _service => _ref.read(backupServiceProvider);

  static String suggestedFileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'wardrobe-backup-${now.year}-${two(now.month)}-${two(now.day)}.zip';
  }

  /// Returns null when the user cancels the save dialog.
  Future<BackupResult?> backup() async {
    final pickers = _ref.read(platformPickersProvider);
    final paths = _ref.read(storagePathsProvider);
    final name = suggestedFileName(DateTime.now());
    final BackupResult result;
    final int size;
    if (pickers.exportsAsBytes) {
      // Android: build the zip in temporary/, then hand its bytes to the
      // system save dialog.
      // ponytail: the whole zip is held in memory; fine for a personal
      // wardrobe (photos are capped at 1600px). Stream it if backups ever
      // reach hundreds of MB.
      final temp = File(p.join(paths.tempDir.path, 'export-$name'));
      try {
        final made = await _service.createBackup(
          _ref.read(appDatabaseProvider),
          temp.path,
        );
        final bytes = await temp.readAsBytes();
        if (!await pickers.saveBackupBytes(name, bytes)) return null;
        // The real location is a content URI the app cannot reopen, so only
        // the file name is remembered.
        result = BackupResult(name, made.counts, made.missingImages);
        size = bytes.length;
      } finally {
        if (temp.existsSync()) temp.deleteSync();
      }
    } else {
      final path = await pickers.chooseBackupSaveLocation(name);
      if (path == null) return null;
      result = await _service.createBackup(
        _ref.read(appDatabaseProvider),
        path,
      );
      size = File(result.path).lengthSync();
    }
    BackupHistory(paths.backupHistoryFile).add(
      BackupRecord(
        path: result.path,
        sizeBytes: size,
        createdAt: DateTime.now(),
      ),
    );
    _ref.invalidate(backupHistoryProvider);
    return result;
  }

  /// Picks and validates a backup; returns null if the user cancels.
  Future<StagedRestore?> pickAndStage() async {
    final path = await _ref.read(platformPickersProvider).chooseBackupFile();
    if (path == null) return null;
    return _service.stageRestore(
      path,
      currentSchemaVersion: _ref.read(appDatabaseProvider).schemaVersion,
    );
  }

  /// Counts of what the wardrobe currently holds, or null if unreadable.
  Future<Map<String, int>?> currentCounts() async {
    try {
      return await _ref.read(appDatabaseProvider).tableCounts();
    } catch (_) {
      return null;
    }
  }

  static const _keptSafetyCopies = 3;

  /// Saves the current wardrobe to `safety-copies/` before it is replaced.
  /// Throws (and so stops the restore) if the copy cannot be written.
  Future<void> _makeSafetyCopy() async {
    final paths = _ref.read(storagePathsProvider);
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final target = p.join(paths.safetyCopiesDir.path, 'safety-copy-$stamp.zip');
    try {
      await paths.safetyCopiesDir.create(recursive: true);
      await _service.createBackup(_ref.read(appDatabaseProvider), target);
    } catch (e) {
      throw BackupException(
        BackupError.ioFailure,
        'The restore was cancelled because a safety copy of your current '
        'wardrobe could not be saved ($e). Nothing was changed.',
      );
    }
    final history = BackupHistory(paths.backupHistoryFile);
    history.add(
      BackupRecord(
        path: target,
        sizeBytes: File(target).lengthSync(),
        createdAt: now,
        kind: BackupKind.safetyCopy,
      ),
    );
    // Keep only the newest few safety copies.
    final old =
        paths.safetyCopiesDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.zip'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(_keptSafetyCopies)) {
      try {
        f.deleteSync();
        history.remove(f.path);
      } on FileSystemException {
        // leave it; it is only disk space
      }
    }
    _ref.invalidate(backupHistoryProvider);
  }

  /// Replaces the live wardrobe with [staged]. The live database is closed
  /// first and reopened afterwards (also when the restore fails, so the
  /// previous wardrobe keeps working). Returns the restored record counts.
  Future<Map<String, int>> confirmRestore(StagedRestore staged) async {
    // An unreadable wardrobe cannot be copied; restoring is still allowed,
    // as that is exactly when it is needed.
    if (await currentCounts() != null) {
      try {
        await _makeSafetyCopy();
      } on BackupException {
        await _service.discard(staged);
        rethrow;
      }
    }
    try {
      // Close the connection itself, not the whole database object: drift's
      // close() waits for every stream listener, and Riverpod pauses the
      // listeners of off-screen tabs, so it could wait forever.
      await _ref.read(appDatabaseProvider).executor.close();
    } catch (_) {
      // An unreadable live database is exactly when restoring is needed.
    }
    try {
      await _service.applyRestore(staged);
    } finally {
      _ref.invalidate(appDatabaseProvider);
      PaintingBinding.instance.imageCache.clear();
    }
    return _ref.read(appDatabaseProvider).tableCounts();
  }

  Future<void> cancelRestore(StagedRestore staged) => _service.discard(staged);
}

/// Sizes of the database file and the photo folder, in bytes.
final storageStatsProvider = FutureProvider<({int database, int photos})>((
  ref,
) async {
  ref.watch(wardrobeItemsProvider(false)); // refresh when the wardrobe changes
  final paths = ref.watch(storagePathsProvider);
  var photos = 0;
  if (paths.imagesDir.existsSync()) {
    for (final f in paths.imagesDir.listSync(recursive: true)) {
      if (f is File) photos += f.lengthSync();
    }
  }
  final db = paths.databaseFile;
  return (database: db.existsSync() ? db.lengthSync() : 0, photos: photos);
});
