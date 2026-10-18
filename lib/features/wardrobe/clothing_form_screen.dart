import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/clothing_photo.dart';
import '../../app/widgets/enum_chips.dart';
import '../../app/widgets/garment_silhouette.dart';
import '../../app/widgets/page_header.dart';
import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/item_suggestions.dart';
import '../../core/wardrobe_values.dart';
import '../../services/image_storage.dart';
import '../../services/photo_colours.dart';
import '../wishlist/wishlist_providers.dart';
import 'item_stats_provider.dart';
import 'wardrobe_providers.dart';
import 'widgets/details_guide.dart';
import 'widgets/identify_colour_dialog.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Fields the form can fill in as a suggestion; the user's own change to a
/// field removes it from the suggested set, so it is never overwritten.
enum _Field { colours, formality, styles, occasions }

/// Add a new item, or edit the item with [itemId].
class ClothingFormScreen extends ConsumerStatefulWidget {
  const ClothingFormScreen({super.key, this.itemId, this.fromWishlistId});

  final String? itemId;

  /// When adding an item, prefill from this wishlist entry; saving then marks
  /// the entry purchased and links the new item.
  final String? fromWishlistId;

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

  /// Colours in order; the first is the item's main colour.
  List<WardrobeColour> _colours = [];
  ClothingPattern? _pattern;
  ClothingFit? _fit;
  Set<StyleTag> _styles = {};
  Formality? _formality;
  Set<Season> _seasons = {};
  Set<Occasion> _occasions = {};
  ItemCondition _condition = ItemCondition.good;
  bool _favourite = false;
  bool _hidden = false;

  final _suggested = <_Field>{};

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
    } else if (widget.fromWishlistId != null) {
      _prefillFromWishlist();
    }
  }

  Future<void> _prefillFromWishlist() async {
    final w = await ref
        .read(wishlistRepositoryProvider)
        .getById(widget.fromWishlistId!);
    if (!mounted || w == null) return;
    setState(() {
      _name.text = w.name;
      _subcategory.text = w.subcategory ?? '';
      _category = w.category;
      if (w.preferredColours.length == 1) {
        _colours = [w.preferredColours.first];
      }
      _styles = {...w.styleTags};
      _formality = w.formality;
    });
    _suggestDetails();
  }

  /// Fills formality, styles and occasions from the name and type. Only
  /// fields that are empty, or that were themselves suggested, are touched;
  /// anything the user set is left alone.
  void _suggestDetails() {
    final s = suggestDetails(
      _name.text,
      type: _text(_subcategory),
      category: _category,
    );
    setState(() {
      if (_formality == null || _suggested.contains(_Field.formality)) {
        _formality = s.formality;
        _markSuggested(_Field.formality, s.formality != null);
      }
      if (_styles.isEmpty || _suggested.contains(_Field.styles)) {
        _styles = {...s.styles};
        _markSuggested(_Field.styles, s.styles.isNotEmpty);
      }
      if (_occasions.isEmpty || _suggested.contains(_Field.occasions)) {
        // A formality the user picked decides the occasions; otherwise the
        // name's own rule does.
        final chosen =
            _formality != null && !_suggested.contains(_Field.formality);
        final occasions = chosen ? occasionsFor(_formality!) : s.occasions;
        _occasions = {...occasions};
        _markSuggested(_Field.occasions, occasions.isNotEmpty);
      }
    });
  }

  void _markSuggested(_Field field, bool on) =>
      on ? _suggested.add(field) : _suggested.remove(field);

  String? _suggestedHint(_Field field, String source) =>
      _suggested.contains(field) ? '· suggested from $source' : null;

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
      _colours = [
        ?item.primaryColour,
        ...(item.secondaryColours.toList()
          ..sort((a, b) => a.index.compareTo(b.index))),
      ];
      _pattern = item.pattern;
      _fit = item.fit;
      _styles = {...item.styleTags};
      _formality = item.formality;
      _seasons = {...item.seasons};
      _occasions = {...item.occasions};
      _condition = item.condition;
      _favourite = item.isFavourite;
      _hidden = item.hideFromSuggestions;
    });
    if (_colours.isEmpty) _suggestColour();
    _suggestDetails();
  }

  /// True while the colours are empty or were only suggested by the app.
  bool get _mayFillColours =>
      _colours.isEmpty || _suggested.contains(_Field.colours);

  /// Names the item's main colour from its photo, unless the user has set
  /// colours themselves.
  void _suggestColour() => _colourRead = _readColourSuggestion();

  /// The suggestion in progress. Save waits for it: on Windows a photo that
  /// is still being read cannot be moved into the wardrobe.
  Future<void> _colourRead = Future.value();

  Future<void> _readColourSuggestion() async {
    final file = _currentPhotoFile;
    if (!_mayFillColours || file == null) return;
    final pixels = await readPhotoPixels(file);
    // The user may have chosen a colour, or saved, while the photo was read.
    if (!mounted || _saving || !_mayFillColours) return;
    final colour = pixels?.mainColour();
    setState(() {
      if (colour == null) {
        if (_suggested.remove(_Field.colours)) _colours = [];
        return;
      }
      _colours = [colour];
      _suggested.add(_Field.colours);
    });
  }

  Future<void> _identifyColour() async {
    final file = _currentPhotoFile;
    if (file == null) return;
    final pixels = await readPhotoPixels(file);
    if (!mounted) return;
    if (pixels == null) {
      _snack('Could not read that photo.');
      return;
    }
    final picked = await showDialog<IdentifiedColour>(
      context: context,
      builder: (_) => IdentifyColourDialog(photo: file, pixels: pixels),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _suggested.remove(_Field.colours);
      _colours.remove(picked.colour);
      if (picked.asMain) {
        _colours.insert(0, picked.colour);
      } else {
        _colours.add(picked.colour);
      }
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
    final pickers = ref.read(platformPickersProvider);
    var camera = false;
    if (pickers.canTakePhoto) {
      final choice = await showModalBottomSheet<bool>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                key: const Key('take-photo'),
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                key: const Key('choose-from-gallery'),
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      );
      if (choice == null) return;
      camera = choice;
    }
    var path = camera
        ? await pickers.takePhotoPath()
        : await pickers.pickImagePath();
    if (path != null && pickers.canCrop) path = await pickers.cropImage(path);
    if (path == null) return;
    await _stagePath(path);
  }

  Future<void> _stagePath(String path) async {
    try {
      final staged = await _images.stage(path);
      await _replaceStaged(staged);
    } on UnsupportedImageException catch (e) {
      if (mounted) _snack(e.message);
    } catch (e) {
      if (mounted) _snack('Could not read that image: $e');
    }
  }

  File? get _currentPhotoFile {
    final existing = _existing;
    return _staged ??
        (existing?.imagePath != null && !_removePhoto
            ? _images.fileFor(existing!.imagePath)
            : null);
  }

  /// Crops the current photo again (Android).
  Future<void> _cropPhoto() async {
    final source = _currentPhotoFile;
    if (source == null || !source.existsSync()) return;
    final cropped = await ref
        .read(platformPickersProvider)
        .cropImage(source.path);
    if (cropped != null) await _stagePath(cropped);
  }

  Future<void> _replaceStaged(File staged) async {
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
    _suggestColour();
  }

  /// Turns the current photo 90 degrees clockwise (as a new staged file).
  Future<void> _rotatePhoto() async {
    final existing = _existing;
    final File? source =
        _staged ??
        (existing?.imagePath != null && !_removePhoto
            ? _images.fileFor(existing!.imagePath)
            : null);
    if (source == null || !source.existsSync()) return;
    try {
      await _replaceStaged(await _images.stageRotatedCopy(source));
    } catch (e) {
      if (mounted) _snack('Could not rotate that image: $e');
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

    setState(() => _saving = true);
    await _colourRead;
    final now = DateTime.now();
    final existing = _existing;
    final item = ClothingItem(
      id: existing?.id ?? const Uuid().v4(),
      name: _name.text,
      category: _category!,
      subcategory: _text(_subcategory),
      primaryColour: _colours.firstOrNull,
      secondaryColours: _colours.skip(1).toSet(),
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
      hideFromSuggestions: _hidden,
      notes: _text(_notes),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      final wishlistId = widget.fromWishlistId;
      if (wishlistId != null && !_editing) {
        await ref
            .read(wishlistRepositoryProvider)
            .markPurchased(wishlistId, item, stagedImage: _staged);
      } else {
        await ref
            .read(clothingRepositoryProvider)
            .save(item, stagedImage: _staged);
      }
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
        content: Text("Delete '${item.name}'? $usage This can't be undone."),
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

  // ----------------------------------------------------------------- pieces

  Widget _labeled(String label, Widget child, {String? hint}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          if (hint != null)
            Text(
              hint,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
        ],
      ),
      const SizedBox(height: 6),
      child,
    ],
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

  Widget _textField(
    TextEditingController c, {
    Key? fieldKey,
    String? hint,
    String? error,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) => TextField(
    key: fieldKey,
    controller: c,
    maxLines: maxLines,
    onChanged: onChanged,
    decoration: InputDecoration(hintText: hint, errorText: error),
  );

  Widget _categoryDropdown() => DropdownButtonFormField<ClothingCategory>(
    key: ValueKey(_category),
    initialValue: _category,
    isExpanded: true,
    hint: const Text('Choose a category'),
    decoration: InputDecoration(errorText: _categoryError),
    items: [
      for (final c in ClothingCategory.values)
        DropdownMenuItem(value: c, child: Text(c.label)),
    ],
    onChanged: (c) {
      setState(() {
        _category = c;
        _categoryError = null;
      });
      _suggestDetails();
    },
  );

  Widget _colourSection() => _labeled(
    'Colours',
    hint: _suggested.contains(_Field.colours)
        ? '· first is the main colour · suggested from photo'
        : '· first is the main colour',
    Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < _colours.length; i++)
          _ColourChip(
            colour: _colours[i],
            isMain: i == 0,
            onMakeMain: () => setState(() {
              _suggested.remove(_Field.colours);
              final c = _colours.removeAt(i);
              _colours.insert(0, c);
            }),
            onRemove: () => setState(() {
              _suggested.remove(_Field.colours);
              _colours.removeAt(i);
            }),
          ),
        _AddColour(
          available: [
            for (final c in WardrobeColour.values)
              if (!_colours.contains(c)) c,
          ],
          onAdd: (c) => setState(() {
            _suggested.remove(_Field.colours);
            _colours.add(c);
          }),
        ),
        ActionChip(
          key: const Key('identify-colour'),
          avatar: const Icon(Icons.colorize, size: 18),
          label: const Text('Identify from photo'),
          onPressed: _hasPhoto ? _identifyColour : null,
        ),
      ],
    ),
  );

  /// What the selected formality means, with a button for the full guide.
  Widget _formalityGuide() => Row(
    children: [
      Expanded(
        child: Text(
          _formality?.guide ?? 'Not sure? Tap the help button for a guide.',
          key: const Key('formality-guide'),
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ),
      IconButton(
        key: const Key('details-guide'),
        tooltip: 'What do these mean?',
        icon: const Icon(Icons.help_outline),
        onPressed: () => showDetailsGuide(context),
      ),
    ],
  );

  Widget _moreDetails() => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: const Text(
        'More details',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        _labeled(
          'Pattern',
          _single<ClothingPattern>(
            ClothingPattern.values,
            _pattern,
            (v) => _pattern = v,
          ),
        ),
        const SizedBox(height: 14),
        _labeled(
          'Fit',
          _single<ClothingFit>(ClothingFit.values, _fit, (v) => _fit = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _labeled('Material', _textField(_material))),
            const SizedBox(width: 16),
            Expanded(child: _labeled('Size', _textField(_size))),
          ],
        ),
        const SizedBox(height: 14),
        _labeled(
          'Condition',
          EnumChips<ItemCondition>(
            values: ItemCondition.values,
            label: (v) => v.label,
            selected: {_condition},
            single: true,
            onChanged: (s) =>
                setState(() => _condition = s.isEmpty ? _condition : s.first),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Favourite'),
          value: _favourite,
          onChanged: (v) => setState(() => _favourite = v),
        ),
      ],
    ),
  );

  Widget _formFields(bool compact) {
    Widget pair(Widget a, Widget b) => compact
        ? Column(children: [a, const SizedBox(height: 14), b])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          );
    const gap = SizedBox(height: 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pair(
          _labeled(
            'Name',
            _textField(
              _name,
              fieldKey: const Key('name-field'),
              error: _nameError,
              onChanged: (_) => _suggestDetails(),
            ),
          ),
          _labeled('Category', _categoryDropdown()),
        ),
        gap,
        pair(
          _labeled(
            'Type',
            _textField(_subcategory, onChanged: (_) => _suggestDetails()),
          ),
          _labeled(
            'Brand',
            hint: 'Optional',
            _textField(
              _brand,
              fieldKey: const Key('brand-field'),
              hint: 'e.g. Uniqlo',
            ),
          ),
        ),
        gap,
        _colourSection(),
        gap,
        _labeled(
          'Formality',
          hint: _suggestedHint(_Field.formality, 'name'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Segmented<Formality>(
                values: Formality.values,
                label: (f) => f.label,
                selected: _formality,
                onChanged: (f) {
                  setState(() {
                    _suggested.remove(_Field.formality);
                    _formality = f;
                  });
                  // Clearing it must not bring the name's suggestion back.
                  if (f != null) _suggestDetails();
                },
              ),
              _formalityGuide(),
            ],
          ),
        ),
        gap,
        _labeled(
          'Style',
          hint: _suggestedHint(_Field.styles, 'name'),
          _multi<StyleTag>(StyleTag.values, _styles, (v) {
            _styles = v;
            _suggested.remove(_Field.styles);
          }),
        ),
        gap,
        _labeled(
          'Seasons',
          _multi<Season>(Season.values, _seasons, (v) => _seasons = v),
        ),
        gap,
        _labeled(
          'Occasions',
          hint: _suggestedHint(_Field.occasions, 'formality'),
          _multi<Occasion>(Occasion.values, _occasions, (v) {
            _occasions = v;
            _suggested.remove(_Field.occasions);
          }),
        ),
        gap,
        _labeled('Notes', _textField(_notes, maxLines: 3)),
        const SizedBox(height: 8),
        _moreDetails(),
        const Divider(height: 24),
        _footerActions(compact),
      ],
    );
  }

  Widget _footerActions(bool compact) {
    final existing = _existing;
    final hide = CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: const Text('Hide from suggestions (in repair, stored away)'),
      value: _hidden,
      onChanged: (v) => setState(() => _hidden = v ?? false),
    );
    if (existing == null) return hide;
    final archive = OutlinedButton(
      key: const Key('archive-item'),
      onPressed: _toggleArchive,
      child: Text(existing.isArchived ? 'Unarchive' : 'Archive'),
    );
    final delete = OutlinedButton(
      key: const Key('delete-item'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: Color(0xFFE7C5C2)),
      ),
      onPressed: _delete,
      child: const Text('Delete item'),
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hide,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: archive),
              const SizedBox(width: 8),
              Expanded(child: delete),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: hide),
        archive,
        const SizedBox(width: 8),
        delete,
      ],
    );
  }

  Widget _photoPreview() {
    final existing = _existing;
    if (_staged != null) {
      return Image.file(
        _staged!,
        key: const Key('staged-photo'),
        fit: BoxFit.cover,
        cacheWidth: 600,
      );
    }
    if (existing != null && !_removePhoto) return ClothingPhoto(existing);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: _category == null
          ? const Center(child: Icon(Icons.add_a_photo_outlined))
          : GarmentSilhouette(
              category: _category!,
              colour: _colours.firstOrNull,
            ),
    );
  }

  bool get _hasPhoto =>
      _staged != null || (_existing?.imagePath != null && !_removePhoto);

  Widget _photoButtons() => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          key: const Key('replace-photo'),
          onPressed: _pickPhoto,
          child: Text(_hasPhoto ? 'Replace photo' : 'Choose photo'),
        ),
      ),
      const SizedBox(width: 8),
      if (ref.read(platformPickersProvider).canCrop) ...[
        IconButton.outlined(
          key: const Key('crop-photo'),
          tooltip: 'Crop',
          icon: const Icon(Icons.crop),
          onPressed: _hasPhoto ? _cropPhoto : null,
        ),
        const SizedBox(width: 8),
      ],
      IconButton.outlined(
        key: const Key('rotate-photo'),
        tooltip: 'Rotate 90°',
        icon: const Icon(Icons.rotate_right),
        onPressed: _hasPhoto ? _rotatePhoto : null,
      ),
    ],
  );

  String get _photoNote {
    const tail = 'resized to 1600px · location metadata removed';
    if (_staged != null) return 'Will be saved locally as a JPEG · $tail';
    final path = _existing?.imagePath;
    if (path != null && !_removePhoto) return 'Saved locally as $path · $tail';
    return 'Photos stay on this device.';
  }

  Widget _stats() {
    final id = _existing?.id;
    if (id == null) return const SizedBox.shrink();
    final stats = ref.watch(itemStatsProvider(id));
    Widget tile(String value, String label) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
    return Row(
      children: [
        tile('${stats.value?.savedOutfits ?? '–'}', 'saved outfits'),
        const SizedBox(width: 8),
        tile('${stats.value?.validCombos ?? '–'}', 'valid combos'),
      ],
    );
  }

  Widget _leftPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AspectRatio(
        aspectRatio: 0.9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _photoPreview(),
        ),
      ),
      const SizedBox(height: 10),
      _photoButtons(),
      if (_hasPhoto)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
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
        ),
      const SizedBox(height: 8),
      Text(_photoNote, style: monoCaption(context).copyWith(fontSize: 10)),
      const SizedBox(height: 14),
      _stats(),
    ],
  );

  // A Material (not a decorated Container) so the list tiles inside can
  // paint their ink on it.
  Widget _formCard(bool compact) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: EdgeInsets.all(compact ? 16 : 24),
      child: _formFields(compact),
    ),
  );

  String get _saveLabel => _editing ? 'Save changes' : 'Save item';

  Widget _saveButtons() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      OutlinedButton(
        key: const Key('cancel-item'),
        onPressed: _close,
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 8),
      FilledButton(
        key: const Key('save-item'),
        onPressed: _saving ? null : _save,
        child: Text(_saveLabel),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_notFound) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item not found')),
      );
    }
    final existing = _existing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                key: const Key('back'),
                icon: const Icon(Icons.arrow_back),
                onPressed: _close,
              ),
              title: Text(_editing ? 'Edit item' : 'New item'),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('cancel-item'),
                        onPressed: _close,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        key: const Key('save-item'),
                        onPressed: _saving ? null : _save,
                        child: Text(_saveLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1.1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _photoPreview(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _photoButtons(),
                  const SizedBox(height: 16),
                  _formCard(true),
                ],
              ),
            ),
          );
        }
        final added = existing == null
            ? null
            : '${existing.createdAt.toLocal().day} '
                  '${_months[existing.createdAt.toLocal().month - 1]} '
                  '${existing.createdAt.toLocal().year}';
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The header (with Save) stays put while the form scrolls.
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      key: const Key('back'),
                      onPressed: _close,
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: const Text('Back to wardrobe'),
                    ),
                    const SizedBox(height: 8),
                    PageHeader(
                      eyebrow: added == null
                          ? 'New item'
                          : 'Edit item · added $added',
                      title: existing?.name ?? 'New item',
                      trailing: _saveButtons(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: _leftPanel()),
                      const SizedBox(width: 24),
                      Expanded(child: _formCard(false)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Selected colour: swatch + name. Tap for "Make main colour" / "Remove".
class _ColourChip extends StatelessWidget {
  const _ColourChip({
    required this.colour,
    required this.isMain,
    required this.onMakeMain,
    required this.onRemove,
  });

  final WardrobeColour colour;
  final bool isMain;
  final VoidCallback onMakeMain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    key: Key('colour-${colour.name}'),
    tooltip: colour.label,
    onSelected: (v) => v == 'main' ? onMakeMain() : onRemove(),
    itemBuilder: (_) => [
      if (!isMain)
        const PopupMenuItem(value: 'main', child: Text('Make main colour')),
      const PopupMenuItem(value: 'remove', child: Text('Remove')),
    ],
    child: Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 14, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMain ? AppColors.text : AppColors.border,
          width: isMain ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Swatch(colour),
          const SizedBox(width: 8),
          Text(colour.label),
        ],
      ),
    ),
  );
}

class _AddColour extends StatelessWidget {
  const _AddColour({required this.available, required this.onAdd});

  final List<WardrobeColour> available;
  final ValueChanged<WardrobeColour> onAdd;

  Future<void> _choose(BuildContext context) async {
    final colour = await showDialog<WardrobeColour>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a colour'),
        content: SizedBox(
          width: 420,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in available)
                ActionChip(
                  key: Key('pick-colour-${c.name}'),
                  avatar: _Swatch(c),
                  label: Text(c.label),
                  onPressed: () => Navigator.pop(context, c),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (colour != null) onAdd(colour);
  }

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('add-colour'),
    borderRadius: BorderRadius.circular(24),
    onTap: available.isEmpty ? null : () => _choose(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.muted.withValues(alpha: 0.5)),
      ),
      child: const Text(
        '+ Add colour',
        style: TextStyle(color: AppColors.muted),
      ),
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.colour);

  final WardrobeColour colour;

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: Color(colour.argb),
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.border),
    ),
  );
}

/// A row of connected options; the selected one is dark. Tapping the
/// selected option clears it.
class _Segmented<T extends Enum> extends StatelessWidget {
  const _Segmented({
    required this.values,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final String Function(T) label;
  final T? selected;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1EA),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: InkWell(
                key: Key('segment-${v.name}'),
                onTap: () => onChanged(selected == v ? null : v),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: selected == v ? AppColors.text : Colors.transparent,
                  child: Text(
                    label(v),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected == v ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
