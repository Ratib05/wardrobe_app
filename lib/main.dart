import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'services/storage_paths.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final paths = await StoragePaths.resolveDefault();
  await paths.prepare();
  final info = await PackageInfo.fromPlatform();
  runApp(
    ProviderScope(
      // Fail fast: surface database/file errors instead of silently retrying.
      retry: (_, _) => null,
      overrides: [
        storagePathsProvider.overrideWithValue(paths),
        appVersionProvider.overrideWithValue(
          '${info.version}+${info.buildNumber}',
        ),
      ],
      child: const WardrobeApp(),
    ),
  );
}
