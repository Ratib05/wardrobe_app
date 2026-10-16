import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/clothing_photo.dart';
import '../wardrobe/wardrobe_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(activeItemCountProvider);
    final items = ref.watch(wardrobeItemsProvider(false));
    final theme = Theme.of(context).textTheme;
    final recent = [...?items.value]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          count.when(
            data: (n) => Text(
              '$n ${n == 1 ? 'item' : 'items'} in your wardrobe',
              style: theme.titleLarge,
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Something went wrong: $e'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.push('/wardrobe/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add clothing'),
            ),
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Recently added', style: theme.titleMedium),
            for (final item in recent.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ClothingPhoto(item, size: 40),
                ),
                title: Text(item.name),
                onTap: () => context.push('/wardrobe/item/${item.id}'),
              ),
          ],
        ],
      ),
    );
  }
}
