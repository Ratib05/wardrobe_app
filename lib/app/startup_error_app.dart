import 'package:flutter/material.dart';

/// Shown instead of the app when storage cannot be set up at launch.
/// Nothing is deleted or changed in this case.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Drobe',
    home: Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  "The wardrobe couldn't be opened",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your data has not been changed. Close the app and try '
                  'again. If this keeps happening, restore a backup once the '
                  'app starts.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
