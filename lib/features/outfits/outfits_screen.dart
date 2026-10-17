import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/error_view.dart';
import 'outfit_providers.dart';
import 'widgets/outfit_card.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> {
  bool _favouritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final outfits = ref.watch(outfitsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfits'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('Favourites'),
              selected: _favouritesOnly,
              onSelected: (v) => setState(() => _favouritesOnly = v),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/outfits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Create outfit'),
      ),
      body: outfits.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(e),
        data: (all) {
          final shown = _favouritesOnly
              ? all.where((o) => o.outfit.isFavourite).toList()
              : all;
          if (shown.isEmpty) {
            return Center(
              child: Text(
                all.isEmpty ? 'No outfits yet' : 'No favourite outfits yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final o = shown[i];
              return OutfitCard(
                outfit: o,
                onTap: () => context.push('/outfits/${o.outfit.id}'),
                onToggleFavourite: () => ref
                    .read(outfitRepositoryProvider)
                    .setFavourite(o.outfit.id, !o.outfit.isFavourite),
              );
            },
          );
        },
      ),
    );
  }
}
