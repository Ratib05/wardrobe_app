import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/image_storage.dart';
import '../services/platform_pickers.dart';
import '../services/storage_paths.dart';

/// Must be overridden in main() / tests with the resolved storage root.
final storagePathsProvider = Provider<StoragePaths>(
  (ref) => throw UnimplementedError('storagePathsProvider not overridden'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final paths = ref.watch(storagePathsProvider);
  final db = AppDatabase(
    driftDatabase(
      name: 'wardrobe',
      native: DriftNativeOptions(
        databasePath: () async => paths.databaseFile.path,
      ),
    ),
  );
  ref.onDispose(db.close);
  return db;
});

final imageStorageProvider = Provider<ImageStorage>(
  (ref) => ImageStorage(ref.watch(storagePathsProvider)),
);

final platformPickersProvider = Provider<PlatformPickers>(
  (ref) => const PlatformPickers(),
);
