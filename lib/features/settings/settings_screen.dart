import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/widgets/page_header.dart';
import '../recommendations/recommendations_providers.dart';
import 'score_weights_card.dart';

/// Small settings page reached from the sidebar: recommendation preferences,
/// resetting dismissed suggestions, and the app version.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _resetDismissed(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Bring back every recommendation you dismissed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final n = await ref.read(recommendationRepositoryProvider).resetDismissed();
    ref.invalidate(recommendationsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Reset $n dismissed recommendation${n == 1 ? '' : 's'}',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(eyebrow: 'Recommendations', title: 'Settings'),
              const SizedBox(height: 24),
              const ScoreWeightsCard(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tune),
                title: const Text('Recommendation preferences'),
                subtitle: const Text(
                  'Colours and styles you like or want to avoid',
                ),
                onTap: () => context.push('/settings/preferences'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.undo),
                title: const Text('Reset dismissed recommendations'),
                onTap: () => _resetDismissed(context, ref),
              ),
              const SizedBox(height: 24),
              Text('Version ${ref.watch(appVersionProvider)}'),
            ],
          ),
        ),
      ),
    ),
  );
}
