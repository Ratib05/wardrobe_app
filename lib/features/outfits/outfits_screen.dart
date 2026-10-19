import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/count_chip.dart';
import '../../app/widgets/error_view.dart';
import '../../app/widgets/page_header.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import 'outfit_providers.dart';
import 'outfit_repository.dart' show OutfitWithItems;
import 'widgets/outfit_card.dart';

class OutfitsScreen extends ConsumerStatefulWidget {
  const OutfitsScreen({super.key});

  @override
  ConsumerState<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends ConsumerState<OutfitsScreen> {
  bool _favouritesOnly = false;
  Formality? _formality;

  @override
  Widget build(BuildContext context) {
    final outfits = ref.watch(outfitsProvider);
    final all = outfits.value ?? const <OutfitWithItems>[];
    final count = all.length;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/outfits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Create outfit'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: '$count ${count == 1 ? 'outfit' : 'outfits'}',
              subtitle: narrow
                  ? '$count ${count == 1 ? 'outfit' : 'outfits'}'
                  : null,
              title: 'Outfits',
              compact: MediaQuery.sizeOf(context).width < 640,
              trailing: FilterChip(
                label: const Text('Favourites'),
                selected: _favouritesOnly,
                onSelected: (v) => setState(() => _favouritesOnly = v),
              ),
            ),
            const SizedBox(height: 16),
            _formalityChips(all),
            const SizedBox(height: 8),
            Expanded(child: _list(outfits)),
          ],
        ),
      ),
    );
  }

  /// "All 7  Relaxed 1  Casual 3 ..." pills; one formality at a time.
  Widget _formalityChips(List<OutfitWithItems> all) {
    int count(Formality f) =>
        all.where((o) => averageFormality(o.items) == f).length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CountChip(
            label: 'All',
            count: all.length,
            selected: _formality == null,
            onTap: () => setState(() => _formality = null),
          ),
          for (final f in Formality.values) ...[
            const SizedBox(width: 8),
            CountChip(
              label: f.label,
              count: count(f),
              selected: _formality == f,
              onTap: () => setState(() => _formality = f),
            ),
          ],
        ],
      ),
    );
  }

  Widget _list(AsyncValue<List<OutfitWithItems>> outfits) => outfits.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => ErrorView(e),
    data: (all) {
      final shown = [
        for (final o in all)
          if ((!_favouritesOnly || o.outfit.isFavourite) &&
              (_formality == null || averageFormality(o.items) == _formality))
            o,
      ];
      if (shown.isEmpty) {
        return Center(
          child: Text(
            all.isEmpty ? 'No outfits yet' : 'No outfits match these filters',
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
  );
}
