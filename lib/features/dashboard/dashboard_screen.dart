import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../wardrobe/wardrobe_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(activeItemCountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: count.when(
          data: (n) => Text(
            '$n ${n == 1 ? 'item' : 'items'} in your wardrobe',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Something went wrong: $e'),
        ),
      ),
    );
  }
}
