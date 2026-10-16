import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/error_view.dart';
import '../../core/clothing_item.dart';
import 'widgets/filter_sheet.dart';
import 'wardrobe_providers.dart';

/// Browse the wardrobe (or the archive when [archived]).
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key, this.archived = false});

  final bool archived;

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  bool _grid = true;
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(wardrobeFilterProvider).query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _search.clear();
    ref.read(wardrobeFilterProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(wardrobeFilterProvider);
    final all = ref.watch(wardrobeItemsProvider(widget.archived));
    final shown = ref.watch(filteredWardrobeProvider(widget.archived));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.archived ? 'Archived' : 'Wardrobe'),
        actions: [
          IconButton(
            tooltip: _grid ? 'List view' : 'Grid view',
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
          IconButton(
            tooltip: 'Filters',
            icon: Badge(
              isLabelVisible: filter.hasCriteria,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FilterSheet(),
            ),
          ),
          if (!widget.archived)
            IconButton(
              tooltip: 'Archived items',
              icon: const Icon(Icons.archive_outlined),
              onPressed: () => context.push('/wardrobe/archived'),
            ),
        ],
      ),
      floatingActionButton: widget.archived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/wardrobe/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search clothing',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (q) => ref
                  .read(wardrobeFilterProvider.notifier)
                  .set(filter.copyWith(query: q)),
            ),
          ),
          Expanded(
            child: shown.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(e),
              data: (items) {
                if (items.isNotEmpty) {
                  return _grid ? _Grid(items) : _ListBody(items);
                }
                if ((all.value ?? const []).isEmpty) {
                  return widget.archived
                      ? const _Empty('No archived items')
                      : _Empty(
                          'Your wardrobe is empty',
                          actionLabel: 'Add your first item',
                          onAction: () => context.push('/wardrobe/new'),
                        );
                }
                return _Empty(
                  'No items match these filters',
                  actionLabel: 'Clear filters',
                  onAction: _clearFilters,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message, {this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: Theme.of(context).textTheme.titleMedium),
        if (actionLabel != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class _Grid extends StatelessWidget {
  const _Grid(this.items);

  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 180,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
    ),
    itemCount: items.length,
    itemBuilder: (context, i) {
      final item = items[i];
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/wardrobe/item/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ClothingPhoto(item)),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (item.isFavourite)
                      const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ListBody extends StatelessWidget {
  const _ListBody(this.items);

  final List<ClothingItem> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) {
      final item = items[i];
      return ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ClothingPhoto(item, size: 48),
        ),
        title: Text(item.name),
        subtitle: Text(item.category.label),
        trailing: item.isFavourite
            ? const Icon(Icons.favorite, size: 16, color: Colors.redAccent)
            : null,
        onTap: () => context.push('/wardrobe/item/${item.id}'),
      );
    },
  );
}
