import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'storage_paths.dart';

const backupFormatVersion = 1;
const _formatName = 'wardrobe-backup';
const _maxExtractedBytes = 2 * 1024 * 1024 * 1024;

enum BackupError {
  notABackup,
  unsupportedVersion,
  newerSchema,
  corruptDatabase,
  ioFailure,
}

/// A backup or restore failure with a message that is safe to show the user.
class BackupException implements Exception {
  const BackupException(this.error, this.message);

  final BackupError error;
  final String message;

  @override
  String toString() => message;
}

class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.counts,
    required this.images,
  });

  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final Map<String, int> counts;

  /// Relative paths (`images/clothing/<id>.jpg`) of the photos in the archive.
  final List<String> images;

  Map<String, Object?> toJson() => {
    'format': _formatName,
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'counts': counts,
    'images': images,
  };

  /// Throws [FormatException] when keys are missing or of the wrong type.
  factory BackupManifest.fromJson(Map<String, Object?> json) {
    if (json['format'] != _formatName) {
      throw const FormatException('Not a wardrobe backup manifest');
    }
    T field<T>(String key) {
      final v = json[key];
      if (v is! T) throw FormatException('Manifest field "$key" is invalid');
      return v;
    }

    final counts = field<Map<String, Object?>>('counts');
    return BackupManifest(
      formatVersion: field<int>('formatVersion'),
      appVersion: field<String>('appVersion'),
      schemaVersion: field<int>('schemaVersion'),
      createdAt: DateTime.parse(field<String>('createdAt')),
      counts: {
        for (final e in counts.entries)
          e.key: e.value is int
              ? e.value as int
              : throw FormatException('Manifest count "${e.key}" is invalid'),
      },
      images: field<List<Object?>>('images').cast<String>(),
    );
  }
}

class BackupResult {
  const BackupResult(this.path, this.counts, this.missingImages);

  final String path;
  final Map<String, int> counts;

  /// Photos referenced by items but absent on disk (not in the backup).
  final List<String> missingImages;
}

/// A validated backup unpacked into a staging folder, ready to be applied.
class StagedRestore {
  const StagedRestore(this.dir, this.manifest, this.counts, this.missingImages);

  final Directory dir;
  final BackupManifest manifest;

  /// Record counts read from the backup's database.
  final Map<String, int> counts;
  final List<String> missingImages;
}

class BackupService {
  BackupService(this.paths, {required this.appVersion});

  final StoragePaths paths;
  final String appVersion;

  static const _uuid = Uuid();

  Directory get _temp => paths.tempDir;

  Future<void> _deleteDir(Directory dir) async {
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } on FileSystemException {
      // Best effort: leftover staging is cleared at the next startup.
    }
  }

  // ---------------------------------------------------------------- backup

  /// Writes a complete backup (database snapshot, photos, manifest) to
  /// [destinationPath]. Throws [BackupException] on failure; temporary files
  /// are always removed and no partial file is left at the destination.
  Future<BackupResult> createBackup(
    AppDatabase db,
    String destinationPath,
  ) async {
    final id = _uuid.v4();
    final staging = Directory(p.join(_temp.path, 'backup-$id'));
    final tempZip = File(p.join(_temp.path, 'backup-$id.zip'));
    final partial = File('$destinationPath.partial');
    try {
      final dbDir = Directory(p.join(staging.path, 'database'));
      await dbDir.create(recursive: true);
      await db.customStatement('VACUUM INTO ?', [
        p.join(dbDir.path, 'wardrobe.db'),
      ]);

      final images = <String>{};
      final missing = <String>{};
      for (final rel in await db.clothingDao.allImagePaths()) {
        final File source;
        try {
          source = paths.imageFile(rel);
        } on ArgumentError {
          missing.add(rel);
          continue;
        }
        if (!await source.exists()) {
          missing.add(rel);
          continue;
        }
        final target = File(p.joinAll([staging.path, ...p.posix.split(rel)]));
        await target.parent.create(recursive: true);
        await source.copy(target.path);
        images.add(rel);
      }

      final counts = await db.tableCounts();
      final manifest = BackupManifest(
        formatVersion: backupFormatVersion,
        appVersion: appVersion,
        schemaVersion: db.schemaVersion,
        createdAt: DateTime.now().toUtc(),
        counts: counts,
        images: images.toList()..sort(),
      );
      await File(p.join(staging.path, 'manifest.json')).writeAsString(
        const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      );

      await ZipFileEncoder().zipDirectory(staging, filename: tempZip.path);
      await _verifyArchive(tempZip, manifest);

      await tempZip.copy(partial.path);
      await partial.rename(destinationPath);
      return BackupResult(destinationPath, counts, missing.toList()..sort());
    } on BackupException {
      rethrow;
    } catch (e) {
      throw BackupException(BackupError.ioFailure, 'Backup failed: $e');
    } finally {
      await _deleteDir(staging);
      for (final f in [tempZip, partial]) {
        try {
          if (await f.exists()) await f.delete();
        } on FileSystemException {
          // best effort
        }
      }
    }
  }

  Future<void> _verifyArchive(File zip, BackupManifest manifest) async {
    final input = InputFileStream(zip.path);
    try {
      final names = ZipDecoder().decodeStream(input).files.map((f) => f.name);
      final present = names.toSet();
      final required = [
        'manifest.json',
        'database/wardrobe.db',
        ...manifest.images,
      ];
      final absent = required.where((n) => !present.contains(n));
      if (absent.isNotEmpty) {
        throw BackupException(
          BackupError.ioFailure,
          'Backup failed: the archive is missing ${absent.first}',
        );
      }
    } finally {
      await input.close();
    }
  }

  // --------------------------------------------------------------- restore

  /// Unpacks and fully validates [zipPath] without touching live data.
  /// Throws [BackupException] (and removes the staging folder) on failure.
  Future<StagedRestore> stageRestore(
    String zipPath, {
    required int currentSchemaVersion,
  }) async {
    final staging = Directory(p.join(_temp.path, 'restore-${_uuid.v4()}'));
    try {
      await staging.create(recursive: true);
      await _extract(zipPath, staging);
      final manifest = await _readManifest(staging);
      if (manifest.formatVersion != backupFormatVersion) {
        throw const BackupException(
          BackupError.unsupportedVersion,
          "This backup uses a format this app can't read.",
        );
      }
      if (manifest.schemaVersion > currentSchemaVersion) {
        throw const BackupException(
          BackupError.newerSchema,
          'This backup was made by a newer version of the app. '
          'Update the app first.',
        );
      }
      final dbFile = File(p.join(staging.path, 'database', 'wardrobe.db'));
      _checkDatabaseFile(dbFile, manifest.schemaVersion);
      final (counts, imagePaths) = await _readStagedDatabase(dbFile);

      final missing = <String>[
        for (final rel in imagePaths)
          if (!_stagedImageExists(staging, rel)) rel,
      ]..sort();
      return StagedRestore(staging, manifest, counts, missing);
    } on BackupException {
      await _deleteDir(staging);
      rethrow;
    } catch (e) {
      await _deleteDir(staging);
      throw BackupException(BackupError.ioFailure, 'Restore failed: $e');
    }
  }

  Future<void> _extract(String zipPath, Directory staging) async {
    final InputFileStream input;
    try {
      input = InputFileStream(zipPath);
    } catch (_) {
      throw const BackupException(
        BackupError.notABackup,
        "This file isn't a wardrobe backup.",
      );
    }
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeStream(input);
      } catch (_) {
        throw const BackupException(
          BackupError.notABackup,
          "This file isn't a wardrobe backup.",
        );
      }
      // Entries that would land outside staging (e.g. "../x") are skipped.
      await extractArchiveToDisk(
        archive,
        staging.path,
        maxSize: _maxExtractedBytes,
      );
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(
        BackupError.notABackup,
        "This file isn't a wardrobe backup.",
      );
    } finally {
      await input.close();
    }
  }

  Future<BackupManifest> _readManifest(Directory staging) async {
    try {
      final text = await File(
        p.join(staging.path, 'manifest.json'),
      ).readAsString();
      return BackupManifest.fromJson(
        (jsonDecode(text) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      throw const BackupException(
        BackupError.notABackup,
        "This file isn't a wardrobe backup.",
      );
    }
  }

  static const _corrupt = BackupException(
    BackupError.corruptDatabase,
    "The backup's database is damaged and can't be restored.",
  );

  /// Cheap structural checks with plain sqlite3 (read-only, no migration).
  void _checkDatabaseFile(File dbFile, int manifestSchemaVersion) {
    if (!dbFile.existsSync()) throw _corrupt;
    sqlite.Database? raw;
    try {
      raw = sqlite.sqlite3.open(dbFile.path, mode: sqlite.OpenMode.readOnly);
      final integrity = raw.select('PRAGMA integrity_check').first.values.first;
      final version = raw.select('PRAGMA user_version').first.values.first;
      final fkProblems = raw.select('PRAGMA foreign_key_check');
      if (integrity != 'ok' ||
          version != manifestSchemaVersion ||
          fkProblems.isNotEmpty) {
        throw _corrupt;
      }
    } on BackupException {
      rethrow;
    } catch (_) {
      throw _corrupt;
    } finally {
      raw?.close();
    }
  }

  /// Opens the staged copy with the app's own schema (running migrations for
  /// older backups) and reads record counts and referenced photo paths.
  Future<(Map<String, int>, List<String>)> _readStagedDatabase(
    File dbFile,
  ) async {
    // The staged copy is a different file from the live database, so drift's
    // "multiple databases" warning does not apply.
    final previousWarning = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final AppDatabase db;
    try {
      db = AppDatabase(NativeDatabase(dbFile));
    } finally {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarning;
    }
    try {
      return (await db.tableCounts(), await db.clothingDao.allImagePaths());
    } catch (_) {
      throw _corrupt;
    } finally {
      await db.close();
    }
  }

  bool _stagedImageExists(Directory staging, String rel) {
    final imagesRoot = p.join(staging.path, 'images');
    final resolved = p.normalize(p.join(staging.path, rel));
    return p.isWithin(imagesRoot, resolved) && File(resolved).existsSync();
  }

  /// Replaces the live database and photos with the staged ones. The caller
  /// must close the live database first. On failure the previous wardrobe is
  /// put back and a [BackupException] is thrown.
  Future<void> applyRestore(StagedRestore staged) async {
    final rollback = Directory(p.join(_temp.path, 'pre-restore-${_uuid.v4()}'));
    final movedData = Directory(p.join(rollback.path, 'data'));
    final movedImages = Directory(p.join(rollback.path, 'images'));
    var movedDataAway = false;
    var movedImagesAway = false;
    try {
      await rollback.create(recursive: true);
      if (await paths.dataDir.exists()) {
        await paths.dataDir.rename(movedData.path);
      }
      movedDataAway = true;
      if (await paths.imagesDir.exists()) {
        await paths.imagesDir.rename(movedImages.path);
      }
      movedImagesAway = true;

      await Directory(
        p.join(staged.dir.path, 'database'),
      ).rename(paths.dataDir.path);
      final stagedImages = Directory(p.join(staged.dir.path, 'images'));
      if (await stagedImages.exists()) {
        await stagedImages.rename(paths.imagesDir.path);
      }
      await paths.clothingImagesDir.create(recursive: true);
      if (!await paths.databaseFile.exists()) {
        throw const FileSystemException('Restored database is missing');
      }
    } catch (_) {
      await _rollBack(
        movedData: movedDataAway ? movedData : null,
        movedImages: movedImagesAway ? movedImages : null,
      );
      await _deleteDir(rollback);
      await _deleteDir(staged.dir);
      throw const BackupException(
        BackupError.ioFailure,
        'Restore failed. Your existing wardrobe was kept.',
      );
    }
    await _deleteDir(rollback);
    await _deleteDir(staged.dir);
  }

  Future<void> _rollBack({Directory? movedData, Directory? movedImages}) async {
    await _deleteDir(paths.dataDir);
    await _deleteDir(paths.imagesDir);
    if (movedData != null && await movedData.exists()) {
      await movedData.rename(paths.dataDir.path);
    }
    if (movedImages != null && await movedImages.exists()) {
      await movedImages.rename(paths.imagesDir.path);
    }
  }

  /// Discards a staged restore the user chose not to apply.
  Future<void> discard(StagedRestore staged) => _deleteDir(staged.dir);
}
