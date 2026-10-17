import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/enum_chips.dart';
import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'outfit_providers.dart';
import 'outfit_rules.dart';

/// Create a new outfit, or edit the one with [outfitId].
class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key, this.outfitId});

  final String? outfitId;

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  final _name = TextEditingController();
  final _notes = TextEditingController();
  final List<String> _selected = [];
  // Items of the outfit being edited, so archived ones can still be shown.
  List<ClothingItem> _loadedItems = const [];
  Occasion? _occasion;
  Season? _season;
  int? _rating;
  bool _favourite = false;
  bool _loading = false;
  bool _notFound = false;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.outfitId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _loading = true;
      _load();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final o = await ref
        .read(outfitRepositoryProvider)
        .getById(widget.outfitId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (o == null) {
        _notFound = true;
        return;
      }
      _loadedItems = o.items;
      _selected.addAll(o.items.map((i) => i.id));
      _name.text = o.outfit.name;
      _notes.text = o.outfit.notes ?? '';
      _occasion = o.outfit.occasion;
      _season = o.outfit.season;
      _rating = o.outfit.rating;
      _favourite = o.outfit.isFavourite;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/outfits');
    }
  }

  void _toggle(String id) => setState(() {
    _error = null;
    if (!_selected.remove(id)) _selected.add(id);
  });

  Future<void> _save() async {
    final notes = _notes.text.trim();
    final error = validateOutfit(_name.text, _selected);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await ref
          .read(outfitRepositoryProvider)
          .save(
            id: widget.outfitId,
            name: _name.text,
            itemIds: List.of(_selected),
            occasion: _occasion,
            season: _season,
            rating: _rating,
            isFavourite: _favourite,
            notes: notes.isEmpty ? null : notes,
          );
      if (mounted) _close();
    } on ValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Delete '${_name.text.trim()}'? This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(outfitRepositoryProvider).delete(widget.outfitId!);
    if (mounted) _close();
  }

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(wardrobeItemsProvider(false)).value ?? const [];
    final byId = {
      for (final i in _loadedItems) i.id: i,
      for (final i in active) i.id: i,
    };
    final selectedItems = [
      for (final id in _selected)
        if (byId[id] != null) byId[id]!,
    ];
    final warnings = selectedItems.isEmpty
        ? const <String>[]
        : outfitWarnings(selectedItems);
    final pickable = active.where((i) => i.isAvailable).toList()
      ..sort((a, b) {
        final c = a.category.index.compareTo(b.category.index);
        return c != 0
            ? c
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit outfit' : 'New outfit'),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notFound
          ? const Center(child: Text('Outfit not found'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Outfit name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        'Selected items',
                        selectedItems.isEmpty
                            ? const Text('Tap items below to add them')
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final item in selectedItems)
                                    InkWell(
                                      key: Key('sel-${item.id}'),
                                      onTap: () => _toggle(item.id),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: ClothingPhoto(
                                              item,
                                              size: 72,
                                            ),
                                          ),
                                          Text(
                                            item.category.label,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      for (final w in warnings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(child: Text(w)),
                            ],
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _section(
                        'Occasion',
                        EnumChips<Occasion>(
                          values: Occasion.values,
                          label: (v) => v.label,
                          selected: _occasion == null ? {} : {_occasion!},
                          single: true,
                          onChanged: (s) => setState(
                            () => _occasion = s.isEmpty ? null : s.first,
                          ),
                        ),
                      ),
                      _section(
                        'Season',
                        EnumChips<Season>(
                          values: Season.values,
                          label: (v) => v.label,
                          selected: _season == null ? {} : {_season!},
                          single: true,
                          onChanged: (s) => setState(
                            () => _season = s.isEmpty ? null : s.first,
                          ),
                        ),
                      ),
                      _section(
                        'Rating',
                        Row(
                          children: [
                            for (var n = 1; n <= 5; n++)
                              IconButton(
                                key: Key('star-$n'),
                                tooltip: '$n star${n == 1 ? '' : 's'}',
                                icon: Icon(
                                  _rating != null && n <= _rating!
                                      ? Icons.star
                                      : Icons.star_border,
                                ),
                                onPressed: () => setState(
                                  () => _rating = _rating == n ? null : n,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Favourite'),
                        value: _favourite,
                        onChanged: (v) => setState(() => _favourite = v),
                      ),
                      TextField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your clothing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (pickable.isEmpty)
                        const Text('Add some clothing to your wardrobe first.')
                      else
                        for (final category in ClothingCategory.values)
                          if (pickable.any((i) => i.category == category))
                            _section(
                              category.label,
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final item in pickable.where(
                                    (i) => i.category == category,
                                  ))
                                    _PickTile(
                                      key: Key('pick-${item.id}'),
                                      item: item,
                                      selected: _selected.contains(item.id),
                                      onTap: () => _toggle(item.id),
                                    ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ClothingItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ClothingPhoto(item, size: 72),
            ),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
