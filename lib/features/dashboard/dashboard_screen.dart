import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/clothing_photo.dart';
import '../outfits/outfit_providers.dart';
import '../recommendations/recommendations_providers.dart';
import '../wardrobe/wardrobe_providers.dart';
import '../wishlist/gap_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(activeItemCountProvider);
    final items = ref.watch(wardrobeItemsProvider(false));
    final favourites = [
      for (final o in ref.watch(outfitsProvider).value ?? const [])
        if (o.outfit.isFavourite) o,
    ];
    final suggestions = [
      ...?ref
          .watch(recommendationsProvider((occasion: null, season: null)))
          .value
          ?.recommendations
          .take(3),
    ];
    final gaps = [
      ...?ref.watch(gapSuggestionsProvider).value?.suggestions.take(2),
    ];
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/wardrobe/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add clothing'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/outfits/new'),
                  icon: const Icon(Icons.style_outlined),
                  label: const Text('Create outfit'),
                ),
              ],
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Suggested outfits', style: theme.titleMedium),
            for (final rec in suggestions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(rec.items.map((i) => i.name).join(' + ')),
                subtitle: Text('${rec.label.label} · ${rec.reasons.first}'),
                onTap: () => context.go('/recommendations'),
              ),
          ],
          if (gaps.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Wardrobe gap ideas', style: theme.titleMedium),
            for (final g in gaps)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(g.title),
                subtitle: Text(g.explanation),
                onTap: () => context.go('/wishlist/gaps'),
              ),
          ],
          if (favourites.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Favourite outfits', style: theme.titleMedium),
            for (final o in favourites)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o.outfit.name),
                subtitle: Text(
                  '${o.items.length} ${o.items.length == 1 ? 'item' : 'items'}',
                ),
                onTap: () => context.push('/outfits/${o.outfit.id}'),
              ),
          ],
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
