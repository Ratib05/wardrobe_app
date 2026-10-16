import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/storage_paths.dart';

/// Must be overridden in main() / tests with the resolved storage root.
final storagePathsProvider = Provider<StoragePaths>(
  (ref) => throw UnimplementedError('storagePathsProvider not overridden'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final paths = ref.watch(storagePathsProvider);
  final db = AppDatabase(driftDatabase(
    name: 'wardrobe',
    native: DriftNativeOptions(databasePath: () async => paths.databaseFile.path),
  ));
  ref.onDispose(db.close);
  return db;
});
