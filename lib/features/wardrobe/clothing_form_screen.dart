import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/enum_chips.dart';
import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import '../../services/image_storage.dart';
import 'wardrobe_providers.dart';

/// Add a new item, or edit the item with [itemId].
class ClothingFormScreen extends ConsumerStatefulWidget {
  const ClothingFormScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<ClothingFormScreen> createState() => _ClothingFormScreenState();
}

class _ClothingFormScreenState extends ConsumerState<ClothingFormScreen> {
  final _name = TextEditingController();
  final _subcategory = TextEditingController();
  final _brand = TextEditingController();
  final _size = TextEditingController();
  final _material = TextEditingController();
  final _notes = TextEditingController();

  late final ImageStorage _images;
  ClothingItem? _existing;
  bool _loading = false;
  bool _notFound = false;
  bool _saving = false;

  ClothingCategory? _category;
  WardrobeColour? _primary;
  Set<WardrobeColour> _secondary = {};
  ClothingPattern? _pattern;
  ClothingFit? _fit;
  Set<StyleTag> _styles = {};
  Formality? _formality;
  Set<Season> _seasons = {};
  Set<Occasion> _occasions = {};
  ItemCondition _condition = ItemCondition.good;
  bool _favourite = false;

  File? _staged;
  bool _removePhoto = false;
  String? _nameError;
  String? _categoryError;

  bool get _editing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _images = ref.read(imageStorageProvider);
    if (_editing) {
      _loading = true;
      _load();
    }
  }

  @override
  void dispose() {
    // Leaving without saving discards a staged photo.
    final staged = _staged;
    if (staged != null) _images.discard(staged);
    for (final c in [_name, _subcategory, _brand, _size, _material, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final item = await ref
        .read(clothingRepositoryProvider)
        .getById(widget.itemId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (item == null) {
        _notFound = true;
        return;
      }
      _existing = item;
      _name.text = item.name;
      _subcategory.text = item.subcategory ?? '';
      _brand.text = item.brand ?? '';
      _size.text = item.size ?? '';
      _material.text = item.material ?? '';
      _notes.text = item.notes ?? '';
      _category = item.category;
      _primary = item.primaryColour;
      _secondary = {...item.secondaryColours};
      _pattern = item.pattern;
      _fit = item.fit;
      _styles = {...item.styleTags};
      _formality = item.formality;
      _seasons = {...item.seasons};
      _occasions = {...item.occasions};
      _condition = item.condition;
      _favourite = item.isFavourite;
    });
  }

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  void _snack(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/wardrobe');
    }
  }

  Future<void> _pickPhoto() async {
    final path = await ref.read(platformPickersProvider).pickImagePath();
    if (path == null) return;
    try {
      final staged = await _images.stage(path);
      final old = _staged;
      if (!mounted) {
        await _images.discard(staged);
        return;
      }
      setState(() {
        _staged = staged;
        _removePhoto = false;
      });
      if (old != null) await _images.discard(old);
    } on UnsupportedImageException catch (e) {
      if (mounted) _snack(e.message);
    } catch (e) {
      if (mounted) _snack('Could not read that image: $e');
    }
  }

  Future<void> _save() async {
    final nameError = validateItemName(_name.text);
    final categoryError = _category == null ? 'Choose a category' : null;
    setState(() {
      _nameError = nameError;
      _categoryError = categoryError;
    });
    if (nameError != null || categoryError != null) return;

    final now = DateTime.now();
    final existing = _existing;
    final item = ClothingItem(
      id: existing?.id ?? const Uuid().v4(),
      name: _name.text,
      category: _category!,
      subcategory: _text(_subcategory),
      primaryColour: _primary,
      secondaryColours: _secondary,
      pattern: _pattern,
      material: _text(_material),
      fit: _fit,
      styleTags: _styles,
      formality: _formality,
      seasons: _seasons,
      occasions: _occasions,
      brand: _text(_brand),
      size: _text(_size),
      condition: _condition,
      imagePath: _removePhoto ? null : existing?.imagePath,
      isFavourite: _favourite,
      isArchived: existing?.isArchived ?? false,
      notes: _text(_notes),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    setState(() => _saving = true);
    try {
      await ref.read(clothingRepositoryProvider).save(item, stagedImage: _staged);
      _staged = null; // committed
      if (mounted) _close();
    } on ValidationException catch (e) {
      if (mounted) _snack(e.message);
    } catch (e) {
      if (mounted) _snack('Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleArchive() async {
    final item = _existing!;
    await ref
        .read(clothingRepositoryProvider)
        .setArchived(item.id, !item.isArchived);
    if (mounted) _close();
  }

  Future<void> _delete() async {
    final item = _existing!;
    final repo = ref.read(clothingRepositoryProvider);
    final n = await repo.outfitCount(item.id);
    if (!mounted) return;
    final usage = n == 0
        ? ''
        : "It's used in $n ${n == 1 ? 'outfit' : 'outfits'} and will be "
              'removed from ${n == 1 ? 'it' : 'them'}. ';
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Delete '${item.name}'? $usage"
            "This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancel'),
          ),
          if (!item.isArchived)
            TextButton(
              onPressed: () => Navigator.pop(context, 'archive'),
              child: const Text('Archive instead'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'archive') {
      await _toggleArchive();
    } else if (choice == 'delete') {
      await repo.delete(item.id);
      if (mounted) _close();
    }
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

  Widget _single<T extends Enum>(
    List<T> values,
    T? value,
    ValueChanged<T?> onChanged,
  ) => EnumChips<T>(
    values: values,
    label: (v) => (v as dynamic).label as String,
    selected: value == null ? <T>{} : {value},
    single: true,
    onChanged: (s) => setState(() => onChanged(s.isEmpty ? null : s.first)),
  );

  Widget _multi<T extends Enum>(
    List<T> values,
    Set<T> value,
    ValueChanged<Set<T>> onChanged,
  ) => EnumChips<T>(
    values: values,
    label: (v) => (v as dynamic).label as String,
    selected: value,
    onChanged: (s) => setState(() => onChanged(s)),
  );

  Widget _textField(String label, TextEditingController c, {int? maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget _photo() {
    final existing = _existing;
    final hasPhoto =
        _staged != null ||
        (existing?.imagePath != null && !_removePhoto);
    Widget preview;
    if (_staged != null) {
      preview = Image.file(
        _staged!,
        key: const Key('staged-photo'),
        fit: BoxFit.cover,
        cacheWidth: 400,
      );
    } else if (existing != null && !_removePhoto) {
      preview = ClothingPhoto(existing);
    } else {
      preview = ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.add_a_photo_outlined),
      );
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 120, height: 120, child: preview),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(hasPhoto ? 'Replace photo' : 'Choose photo'),
            ),
            if (hasPhoto)
              TextButton(
                onPressed: () async {
                  final old = _staged;
                  setState(() {
                    _staged = null;
                    _removePhoto = true;
                  });
                  if (old != null) await _images.discard(old);
                },
                child: const Text('Remove photo'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = _existing;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit item' : 'Add item'),
        actions: [
          if (existing != null) ...[
            IconButton(
              tooltip: existing.isArchived ? 'Unarchive' : 'Archive',
              icon: Icon(
                existing.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              onPressed: _toggleArchive,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          ],
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notFound
          ? const Center(child: Text('Item not found'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section('Photo', _photo()),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _nameError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      'Category',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _single<ClothingCategory>(
                            ClothingCategory.values,
                            _category,
                            (v) => _category = v,
                          ),
                          if (_categoryError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _categoryError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _textField('Subcategory', _subcategory),
                    _section(
                      'Primary colour',
                      _single<WardrobeColour>(
                        WardrobeColour.values,
                        _primary,
                        (v) => _primary = v,
                      ),
                    ),
                    _section(
                      'Secondary colours',
                      _multi<WardrobeColour>(
                        WardrobeColour.values,
                        _secondary,
                        (v) => _secondary = v,
                      ),
                    ),
                    _section(
                      'Pattern',
                      _single<ClothingPattern>(
                        ClothingPattern.values,
                        _pattern,
                        (v) => _pattern = v,
                      ),
                    ),
                    _section(
                      'Style',
                      _multi<StyleTag>(
                        StyleTag.values,
                        _styles,
                        (v) => _styles = v,
                      ),
                    ),
                    _section(
                      'Formality',
                      _single<Formality>(
                        Formality.values,
                        _formality,
                        (v) => _formality = v,
                      ),
                    ),
                    _section(
                      'Seasons',
                      _multi<Season>(
                        Season.values,
                        _seasons,
                        (v) => _seasons = v,
                      ),
                    ),
                    _section(
                      'Occasions',
                      _multi<Occasion>(
                        Occasion.values,
                        _occasions,
                        (v) => _occasions = v,
                      ),
                    ),
                    _textField('Brand', _brand),
                    _textField('Size', _size),
                    _textField('Material', _material),
                    _section(
                      'Fit',
                      _single<ClothingFit>(
                        ClothingFit.values,
                        _fit,
                        (v) => _fit = v,
                      ),
                    ),
                    _section(
                      'Condition',
                      EnumChips<ItemCondition>(
                        values: ItemCondition.values,
                        label: (v) => v.label,
                        selected: {_condition},
                        single: true,
                        onChanged: (s) => setState(
                          () => _condition = s.isEmpty ? _condition : s.first,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Favourite'),
                      value: _favourite,
                      onChanged: (v) => setState(() => _favourite = v),
                    ),
                    _textField('Notes', _notes, maxLines: 3),
                  ],
                ),
              ),
            ),
    );
  }
}
