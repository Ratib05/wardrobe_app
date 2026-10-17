import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/startup_error_app.dart';
import 'database/app_database.dart';
import 'services/pre_upgrade_copy.dart';
import 'services/storage_paths.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final StoragePaths paths;
  final String version;
  try {
    paths = await StoragePaths.resolveDefault();
    await paths.prepare();
    // Keep a copy of an older database before it is upgraded.
    await copyDatabaseBeforeUpgrade(paths, currentSchemaVersion);
    final info = await PackageInfo.fromPlatform();
    version = '${info.version}+${info.buildNumber}';
  } catch (e, stack) {
    debugPrint('Startup failed: $e\n$stack');
    runApp(StartupErrorApp(error: e));
    return;
  }
  runApp(
    ProviderScope(
      // Fail fast: surface database/file errors instead of silently retrying.
      retry: (_, _) => null,
      overrides: [
        storagePathsProvider.overrideWithValue(paths),
        appVersionProvider.overrideWithValue(version),
      ],
      child: const WardrobeApp(),
    ),
  );
}
