import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/page_header.dart';
import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../recommendations/engine/outfit_check.dart';
import '../recommendations/engine/scoring.dart';
import '../recommendations/recommendations_providers.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'outfit_providers.dart';
import 'outfit_rules.dart';

enum _Slot {
  outer('Outer layer', ClothingCategory.outerwear, optional: true),
  top('Top', ClothingCategory.top),
  bottom('Bottom', ClothingCategory.bottom),
  dress('Dress / jumpsuit', ClothingCategory.onePiece),
  shoes('Shoes', ClothingCategory.footwear),
  accessory('Accessory', ClothingCategory.accessory, optional: true);

  const _Slot(this.label, this.category, {this.optional = false});
  final String label;
  final ClothingCategory category;
  final bool optional;
}

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
  // Not editable in the builder, but kept so editing never loses them.
  final _notes = TextEditingController();
  Season? _season;
  int? _rating;

  final List<String> _selected = [];
  // Items of the outfit being edited, so archived ones can still be shown.
  List<ClothingItem> _loadedItems = const [];
  Occasion? _occasion;
  bool _favourite = false;
  bool _dress = false;
  _Slot _active = _Slot.top;
  bool _loading = false;
  bool _notFound = false;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.outfitId != null;

  List<_Slot> get _slots => [
    _Slot.outer,
    if (_dress) _Slot.dress else ...[_Slot.top, _Slot.bottom],
    _Slot.shoes,
    _Slot.accessory,
  ];

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
      _dress = o.items.any((i) => i.category == ClothingCategory.onePiece);
      _active = _dress ? _Slot.dress : _Slot.top;
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

  Map<String, ClothingItem> _lookup(List<ClothingItem> active) => {
    for (final i in _loadedItems) i.id: i,
    for (final i in active) i.id: i,
  };

  ClothingItem? _inSlot(_Slot slot, Map<String, ClothingItem> byId) {
    for (final id in _selected) {
      final item = byId[id];
      if (item != null && item.category == slot.category) return item;
    }
    return null;
  }

  void _removeCategory(ClothingCategory c, Map<String, ClothingItem> byId) =>
      _selected.removeWhere((id) => byId[id]?.category == c);

  void _pick(ClothingItem item, Map<String, ClothingItem> byId) {
    setState(() {
      _error = null;
      final wasSelected = _selected.contains(item.id);
      _removeCategory(item.category, byId);
      if (wasSelected) return;
      _selected.add(item.id);
      // Move on to the next empty slot.
      for (final s in _slots) {
        if (_inSlot(s, byId) == null && !s.optional) {
          _active = s;
          return;
        }
      }
    });
  }

  void _setDress(bool on, Map<String, ClothingItem> byId) => setState(() {
    _dress = on;
    final drop = on
        ? [ClothingCategory.top, ClothingCategory.bottom]
        : [ClothingCategory.onePiece];
    for (final c in drop) {
      _removeCategory(c, byId);
    }
    _active = on ? _Slot.dress : _Slot.top;
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

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(wardrobeItemsProvider(false)).value ?? const [];
    final prefs =
        ref.watch(preferencesProvider).value ??
        const RecommendationPreferences();
    final weights = ref.watch(scoreWeightsProvider).value;
    final byId = _lookup(active);
    final selectedItems = [
      for (final id in _selected)
        if (byId[id] != null) byId[id]!,
    ];
    final complete = isCompleteOutfit(selectedItems);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1000;

    final slots = _slotsCard(byId);
    final picker = _pickerCard(active, byId, selectedItems, prefs, weights);
    final check = _checkCard(selectedItems, prefs, weights);
    final details = _detailsCard(complete);

    final header = PageHeader(
      eyebrow: _editing ? 'Edit outfit' : 'New outfit',
      title: _editing ? 'Edit outfit' : 'Build an outfit',
      compact: !wide,
      trailing: _editing
          ? IconButton.outlined(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            )
          : null,
    );

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_notFound) {
      body = const Center(child: Text('Outfit not found'));
    } else if (wide) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 400, child: _scroll([slots, check, details])),
          const SizedBox(width: 24),
          Expanded(child: _scroll([picker])),
        ],
      );
    } else {
      body = _scroll([slots, picker, check, details]);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 40 : 16,
            wide ? 32 : 16,
            wide ? 40 : 16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('back'),
                  onPressed: _close,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to outfits'),
                ),
              ),
              header,
              const SizedBox(height: 16),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }

  // Not a lazy ListView: the sections are few and all must stay built.
  Widget _scroll(List<Widget> children) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  Widget _card(String? title, Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title.toUpperCase(), style: monoCaption(context)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    ),
  );

  Widget _slotsCard(Map<String, ClothingItem> byId) => _card(
    'Your outfit',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('dress-switch'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Dress / jumpsuit'),
          subtitle: const Text('Replaces top and bottom'),
          value: _dress,
          onChanged: (v) => _setDress(v, byId),
        ),
        for (final slot in _slots) _slotRow(slot, byId),
      ],
    ),
  );

  Widget _slotRow(_Slot slot, Map<String, ClothingItem> byId) {
    final item = _inSlot(slot, byId);
    final isActive = _active == slot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive ? AppColors.primarySoft : const Color(0xFFF7F6F1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('slot-${slot.name}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _active = slot),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item == null
                        ? const ColoredBox(
                            color: AppColors.placeholder,
                            child: Icon(Icons.add, color: AppColors.muted),
                          )
                        : ClothingPhoto(item),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.optional ? '${slot.label} (optional)' : slot.label,
                        style: monoCaption(context),
                      ),
                      Text(
                        item?.name ?? 'Choose',
                        key: item == null ? null : Key('sel-${item.id}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item == null ? AppColors.muted : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item != null)
                  IconButton(
                    key: Key('clear-${slot.name}'),
                    tooltip: 'Remove ${slot.label.toLowerCase()}',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _selected.remove(item.id)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerCard(
    List<ClothingItem> active,
    Map<String, ClothingItem> byId,
    List<ClothingItem> selectedItems,
    RecommendationPreferences prefs,
    Map<ScoreFactor, double>? weights,
  ) {
    final slot = _active;
    final pool = [
      for (final i in active)
        if (i.isAvailable && i.category == slot.category) i,
      // The outfit's own item stays visible even if it was archived since.
      for (final i in selectedItems)
        if (i.category == slot.category && !(i.isAvailable)) i,
    ];
    final isShoes = slot == _Slot.shoes;
    final ranked = isShoes
        ? rankShoes(
            pool,
            [
              for (final i in selectedItems)
                if (i.category != ClothingCategory.footwear) i,
            ],
            occasion: _occasion,
            preferences: prefs,
            weights: weights,
          )
        : [
            for (final i
                in (pool..sort(
                  (a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                )))
              (shoe: i, fit: null as ShoeFit?, score: 0),
          ];
    return _card(
      isShoes ? 'Choose shoes ordered by fit' : 'Choose ${slot.label}',
      ranked.isEmpty
          ? Text('You have no ${slot.category.labelPlural.toLowerCase()} yet.')
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final r in ranked)
                  _PickTile(
                    key: Key('pick-${r.shoe.id}'),
                    item: r.shoe,
                    selected: _selected.contains(r.shoe.id),
                    fit: r.fit,
                    onTap: () => _pick(r.shoe, byId),
                  ),
              ],
            ),
    );
  }

  Widget _checkCard(
    List<ClothingItem> items,
    RecommendationPreferences prefs,
    Map<ScoreFactor, double>? weights,
  ) {
    final warnings = items.isEmpty ? const <String>[] : outfitWarnings(items);
    final check = items.length < 2
        ? null
        : outfitCheck(
            items,
            occasion: _occasion,
            preferences: prefs,
            weights: weights,
          );
    return _card(
      'Outfit check',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (check == null)
            const Text(
              'Choose at least two items to see how well they go together.',
              style: TextStyle(color: AppColors.muted),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${check.score}',
                  key: const Key('outfit-score'),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  ' / 100',
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final n in check.notes)
              _note(
                n.good ? Icons.check_circle_outline : Icons.error_outline,
                n.good ? AppColors.good : AppColors.warn,
                n.text,
              ),
          ],
          for (final w in warnings)
            _note(Icons.info_outline, AppColors.warn, w),
        ],
      ),
    );
  }

  Widget _note(IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _detailsCard(bool complete) => _card(
    null,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('outfit-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Outfit name'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Occasion?>(
          key: ValueKey(_occasion),
          initialValue: _occasion,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Occasion'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any')),
            for (final o in Occasion.values)
              DropdownMenuItem(value: o, child: Text(o.label)),
          ],
          onChanged: (o) => setState(() => _occasion = o),
        ),
        CheckboxListTile(
          key: const Key('favourite'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Favourite'),
          value: _favourite,
          onChanged: (v) => setState(() => _favourite = v ?? false),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        if (!complete)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Add a top, bottom and shoes (or a dress and shoes) to save.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        FilledButton(
          key: const Key('save-outfit'),
          onPressed: _saving || !complete ? null : _save,
          child: Text(_editing ? 'Save changes' : 'Save outfit'),
        ),
      ],
    ),
  );
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    this.fit,
  });

  final ClothingItem item;
  final bool selected;
  final VoidCallback onTap;
  final ShoeFit? fit;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 112,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ClothingPhoto(item, size: 100),
          ),
          const SizedBox(height: 4),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (fit != null)
            Text(
              fit!.label,
              style: TextStyle(
                fontSize: 11,
                color: fit == ShoeFit.strong || fit == ShoeFit.good
                    ? AppColors.good
                    : AppColors.warn,
              ),
            ),
        ],
      ),
    ),
  );
}
