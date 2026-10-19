import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/count_chip.dart';
import '../../app/widgets/error_view.dart';
import '../../app/widgets/page_header.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../outfits/outfit_providers.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/wardrobe_shelves.dart';
import 'wardrobe_filter.dart';
import 'wardrobe_providers.dart';

/// Colours offered as quick filters (the full list is in "Filters").
const _swatchColours = [
  WardrobeColour.white,
  WardrobeColour.black,
  WardrobeColour.navy,
  WardrobeColour.grey,
  WardrobeColour.beige,
  WardrobeColour.olive,
  WardrobeColour.brown,
];

const _categoryTabs = [
  ClothingCategory.top,
  ClothingCategory.bottom,
  ClothingCategory.onePiece,
  ClothingCategory.outerwear,
  ClothingCategory.footwear,
  ClothingCategory.accessory,
];

String _plural(int n, String one, [String? many]) =>
    n == 1 ? one : (many ?? '${one}s');

/// Browse the wardrobe (or the archive when [archived]).
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key, this.archived = false});

  final bool archived;

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  bool _grid = true;

  /// "See all" was tapped: show the grid even with no filters set.
  bool _seeAll = false;
  late final TextEditingController _search;

  /// Set while a bulk photo import runs.
  ({int done, int total})? _progress;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(wardrobeFilterProvider).query,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  WardrobeFilterNotifier get _notifier =>
      ref.read(wardrobeFilterProvider.notifier);

  void _clearFilters() {
    _search.clear();
    _notifier.clear();
  }

  void _backToShelves() {
    _clearFilters();
    setState(() => _seeAll = false);
  }

  void _openFilters() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const FilterSheet(),
  );

  void _showNeedsDetails() => _notifier.set(
    ref.read(wardrobeFilterProvider).copyWith(needsDetailsOnly: true),
  );

  Future<void> _importPhotos() async {
    final paths = await ref.read(platformPickersProvider).pickImagePaths();
    if (paths.isEmpty || !mounted) return;
    final category = await showDialog<ClothingCategory>(
      context: context,
      builder: (_) => _ImportDialog(count: paths.length),
    );
    if (category == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _progress = (done: 0, total: paths.length));
    try {
      final result = await ref
          .read(clothingRepositoryProvider)
          .importPhotos(
            paths,
            category,
            onProgress: (done, total) {
              if (!mounted) return;
              setState(() => _progress = (done: done, total: total));
            },
          );
      final skipped = result.skipped;
      final skippedNote = skipped.isEmpty
          ? ''
          : ' · ${skipped.length} skipped (${skipped.join(', ')})';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${result.imported} '
            '${_plural(result.imported, 'item')}$skippedNote',
          ),
          action: result.imported == 0
              ? null
              : SnackBarAction(label: 'Show', onPressed: _showNeedsDetails),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import failed, nothing was added: $e')),
      );
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(wardrobeFilterProvider);
    final all = ref.watch(wardrobeItemsProvider(widget.archived));
    final shown = ref.watch(filteredWardrobeProvider(widget.archived));
    final outfitCount = ref.watch(outfitsProvider).value?.length ?? 0;
    final items = all.value ?? const <ClothingItem>[];
    // Shelves are the landing page; any search or filter shows the grid.
    final showShelves =
        !widget.archived && !filter.hasCriteria && !_seeAll && items.isNotEmpty;
    final phone = MediaQuery.sizeOf(context).width < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final pad = compact ? 16.0 : 32.0;
        final eyebrow = widget.archived
            ? '${items.length} archived ${_plural(items.length, 'item')}'
            : '${items.length} ${_plural(items.length, 'item')} · '
                  '$outfitCount ${_plural(outfitCount, 'outfit')}';
        final title = widget.archived ? 'Archived items' : 'Your wardrobe';

        final searchField = TextField(
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 20),
            hintText: compact
                ? 'Search your wardrobe'
                : 'Search name, colour, brand...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 24 : 10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 24 : 10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          onChanged: (q) => _notifier.set(filter.copyWith(query: q)),
        );

        final header = Padding(
          padding: EdgeInsets.fromLTRB(pad, compact ? 16 : 32, pad, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                PageHeader(
                  eyebrow: eyebrow,
                  subtitle: phone && !widget.archived
                      ? '${items.length} ${_plural(items.length, 'item')}'
                      : null,
                  title: widget.archived ? 'Archived' : 'Wardrobe',
                  compact: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.archived) ...[
                        IconButton.outlined(
                          key: const Key('import-photos'),
                          tooltip: 'Import photos',
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          onPressed: _progress == null ? _importPhotos : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton.outlined(
                        tooltip: 'Filters',
                        icon: Badge(
                          isLabelVisible: filter.hasCriteria,
                          child: const Icon(Icons.tune),
                        ),
                        onPressed: _openFilters,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                searchField,
              ] else
                PageHeader(
                  eyebrow: eyebrow,
                  title: title,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 300, child: searchField),
                      if (!widget.archived) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          key: const Key('import-photos'),
                          onPressed: _progress == null ? _importPhotos : null,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 20,
                          ),
                          label: const Text('Import photos'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          key: const Key('add-item'),
                          onPressed: () => context.push('/wardrobe/new'),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add item'),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (!showShelves)
                _CategoryChips(
                  items: items,
                  selected: filter.categories,
                  onShelves: widget.archived ? null : _backToShelves,
                  onSelect: (categories) {
                    if (categories.isEmpty) _seeAll = true;
                    _notifier.set(filter.copyWith(categories: categories));
                  },
                ),
              if (!compact) ...[
                const SizedBox(height: 14),
                _FilterRow(
                  filter: filter,
                  onChanged: _notifier.set,
                  needsDetailsCount: items.where((i) => i.needsDetails).length,
                  grid: _grid,
                  onToggleView: () => setState(() => _grid = !_grid),
                  onMoreFilters: _openFilters,
                  onArchived: widget.archived
                      ? null
                      : () => context.push('/wardrobe/archived'),
                ),
              ],
              if (_progress case final progress?) ...[
                const SizedBox(height: 12),
                Text('Importing ${progress.done} of ${progress.total}…'),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progress.done / progress.total),
              ],
              SizedBox(height: compact ? 12 : 20),
            ],
          ),
        );

        Widget empty(
          String message, {
          String? actionLabel,
          VoidCallback? onTap,
        }) => SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: Theme.of(context).textTheme.titleMedium),
                  if (actionLabel != null) ...[
                    const SizedBox(height: 12),
                    FilledButton(onPressed: onTap, child: Text(actionLabel)),
                  ],
                ],
              ),
            ),
          ),
        );

        final Widget body = shown.when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              SliverFillRemaining(hasScrollBody: false, child: ErrorView(e)),
          data: (list) {
            if (showShelves) {
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 88),
                sliver: SliverToBoxAdapter(
                  child: WardrobeShelves(
                    items: items,
                    onOpen: (c) =>
                        _notifier.set(filter.copyWith(categories: {c})),
                    onSeeAll: () => setState(() => _seeAll = true),
                  ),
                ),
              );
            }
            if (list.isEmpty) {
              if (items.isEmpty) {
                return widget.archived
                    ? empty('No archived items')
                    : empty(
                        'Your wardrobe is empty',
                        actionLabel: 'Add your first item',
                        onTap: () => context.push('/wardrobe/new'),
                      );
              }
              return empty(
                'No items match these filters',
                actionLabel: 'Clear filters',
                onTap: _clearFilters,
              );
            }
            if (!_grid && !compact) {
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
                sliver: SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => _ItemRow(list[i]),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, 0, pad, 88),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: compact ? 220 : 250,
                  mainAxisSpacing: compact ? 12 : 16,
                  crossAxisSpacing: compact ? 12 : 16,
                  childAspectRatio: compact ? 0.78 : 0.84,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => _ItemCard(list[i]),
              ),
            );
          },
        );

        return PopScope(
          canPop: widget.archived || showShelves,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _backToShelves();
          },
          child: Scaffold(
            floatingActionButton: compact && !widget.archived
                ? FloatingActionButton(
                    tooltip: 'Add item',
                    onPressed: () => context.push('/wardrobe/new'),
                    child: const Icon(Icons.add),
                  )
                : null,
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: header),
                body,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "All 12  Tops 4  Bottoms 3 ..." pills; one category at a time.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onShelves,
  });

  /// Null on the archive, which has no shelves.
  final VoidCallback? onShelves;
  final List<ClothingItem> items;
  final Set<ClothingCategory> selected;
  final ValueChanged<Set<ClothingCategory>> onSelect;

  Widget _chip(String label, int count, bool isSelected, VoidCallback onTap) =>
      CountChip(label: label, count: count, selected: isSelected, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    int count(ClothingCategory c) => items.where((i) => i.category == c).length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (onShelves != null) ...[
            ActionChip(
              key: const Key('back-to-shelves'),
              avatar: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Shelves'),
              onPressed: onShelves,
            ),
            const SizedBox(width: 8),
          ],
          _chip('All', items.length, selected.isEmpty, () => onSelect({})),
          for (final c in _categoryTabs) ...[
            const SizedBox(width: 8),
            _chip(
              c.labelPlural,
              count(c),
              selected.length == 1 && selected.contains(c),
              () => onSelect({c}),
            ),
          ],
        ],
      ),
    );
  }
}

/// Season / occasion / sort dropdowns, colour swatches and view buttons.
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.onChanged,
    required this.needsDetailsCount,
    required this.grid,
    required this.onToggleView,
    required this.onMoreFilters,
    required this.onArchived,
  });

  final WardrobeFilter filter;
  final ValueChanged<WardrobeFilter> onChanged;
  final int needsDetailsCount;
  final bool grid;
  final VoidCallback onToggleView;
  final VoidCallback onMoreFilters;
  final VoidCallback? onArchived;

  @override
  Widget build(BuildContext context) {
    final colours = filter.colours;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Dropdown<Season?>(
          label: 'Season',
          value: filter.seasons.length == 1 ? filter.seasons.first : null,
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            for (final s in Season.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (s) =>
              onChanged(filter.copyWith(seasons: s == null ? {} : {s})),
        ),
        _Dropdown<Occasion?>(
          label: 'Occasion',
          value: filter.occasions.length == 1 ? filter.occasions.first : null,
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            for (final o in Occasion.values)
              DropdownMenuItem(value: o, child: Text(o.label)),
          ],
          onChanged: (o) =>
              onChanged(filter.copyWith(occasions: o == null ? {} : {o})),
        ),
        _Dropdown<WardrobeSort>(
          label: 'Sort',
          value: filter.sort,
          items: [
            for (final s in WardrobeSort.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (s) =>
              onChanged(filter.copyWith(sort: s ?? WardrobeSort.recentlyAdded)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Colour', style: TextStyle(color: AppColors.muted)),
            for (final c in _swatchColours)
              FilterChip(
                key: Key('swatch-${c.name}'),
                avatar: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Color(c.argb),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                label: Text(c.label),
                selected: colours.contains(c),
                onSelected: (_) => onChanged(
                  filter.copyWith(
                    colours: colours.contains(c)
                        ? (Set.of(colours)..remove(c))
                        : {...colours, c},
                  ),
                ),
              ),
          ],
        ),
        FilterChip(
          key: const Key('needs-details'),
          label: Text('Needs details ($needsDetailsCount)'),
          selected: filter.needsDetailsOnly,
          onSelected: (v) => onChanged(filter.copyWith(needsDetailsOnly: v)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Filters',
              icon: Badge(
                isLabelVisible:
                    filter.styles.isNotEmpty ||
                    filter.formalities.isNotEmpty ||
                    filter.favouritesOnly,
                child: const Icon(Icons.tune),
              ),
              onPressed: onMoreFilters,
            ),
            IconButton(
              tooltip: grid ? 'List view' : 'Grid view',
              icon: Icon(grid ? Icons.view_list : Icons.grid_view),
              onPressed: onToggleView,
            ),
            if (onArchived != null)
              IconButton(
                tooltip: 'Archived items',
                icon: const Icon(Icons.archive_outlined),
                onPressed: onArchived,
              ),
          ],
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isDense: true,
            borderRadius: BorderRadius.circular(10),
            style: const TextStyle(color: AppColors.text, fontSize: 14),
          ),
        ),
      ),
    ],
  );
}

/// Asks which category a batch of imported photos belongs to.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.count});

  final int count;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  ClothingCategory? _category;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${widget.count} ${_plural(widget.count, 'photo')} selected'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Each photo becomes an item named after its file. They stay hidden '
          'from suggestions until you add their details.',
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ClothingCategory>(
          key: const Key('import-category'),
          initialValue: _category,
          hint: const Text('Choose a category'),
          items: [
            for (final c in ClothingCategory.values)
              DropdownMenuItem(value: c, child: Text(c.label)),
          ],
          onChanged: (c) => setState(() => _category = c),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _category == null
            ? null
            : () => Navigator.pop(context, _category),
        child: const Text('Import'),
      ),
    ],
  );
}

String _caption(ClothingItem i) => [
  i.category.labelPlural,
  if (i.primaryColour != null) i.primaryColour!.label,
  if (i.formality != null) i.formality!.label,
].join(' · ').toUpperCase();

class _ItemCard extends StatelessWidget {
  const _ItemCard(this.item);

  final ClothingItem item;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/wardrobe/item/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ClothingPhoto(item),
                  ),
                  if (item.isFavourite)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.favorite,
                        size: 18,
                        color: AppColors.danger,
                      ),
                    ),
                  if (item.hideFromSuggestions)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Tooltip(
                        message: 'Hidden from suggestions',
                        child: Icon(
                          Icons.visibility_off_outlined,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _caption(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: monoCaption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow(this.item);

  final ClothingItem item;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ClothingPhoto(item, size: 48),
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(_caption(item), style: monoCaption(context)),
      trailing: item.isFavourite
          ? const Icon(Icons.favorite, size: 16, color: AppColors.danger)
          : null,
      onTap: () => context.push('/wardrobe/item/${item.id}'),
    ),
  );
}
