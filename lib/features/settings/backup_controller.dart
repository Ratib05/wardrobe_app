import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../services/backup_service.dart';

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
    final path = await _ref
        .read(platformPickersProvider)
        .chooseBackupSaveLocation(suggestedFileName(DateTime.now()));
    if (path == null) return null;
    return _service.createBackup(_ref.read(appDatabaseProvider), path);
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

  /// Replaces the live wardrobe with [staged]. The live database is closed
  /// first and reopened afterwards (also when the restore fails, so the
  /// previous wardrobe keeps working). Returns the restored record counts.
  Future<Map<String, int>> confirmRestore(StagedRestore staged) async {
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
