import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'storage_paths.dart';

/// Before the app opens a database that needs a schema upgrade, keeps a copy
/// of the file in `safety-copies/`. Returns the copy, or null when no upgrade
/// is needed (no database yet, or already at [targetSchemaVersion]).
Future<File?> copyDatabaseBeforeUpgrade(
  StoragePaths paths,
  int targetSchemaVersion, {
  DateTime? now,
}) async {
  final db = paths.databaseFile;
  if (!await db.exists()) return null;

  int version;
  final raw = sqlite.sqlite3.open(db.path, mode: sqlite.OpenMode.readOnly);
  try {
    version = raw.select('PRAGMA user_version').first.values.first as int;
  } finally {
    raw.close();
  }
  if (version == 0 || version >= targetSchemaVersion) return null;

  final t = (now ?? DateTime.now()).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}${two(t.second)}';
  await paths.safetyCopiesDir.create(recursive: true);
  return db.copy(
    p.join(
      paths.safetyCopiesDir.path,
      'wardrobe-before-schema-v$targetSchemaVersion-$stamp.db',
    ),
  );
}
