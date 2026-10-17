import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/widgets/enum_chips.dart';
import '../../core/app_exceptions.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import 'wishlist_providers.dart';
import 'wishlist_repository.dart';

/// Add a wishlist entry, or edit the one with [wishlistId].
class WishlistFormScreen extends ConsumerStatefulWidget {
  const WishlistFormScreen({super.key, this.wishlistId});

  final String? wishlistId;

  @override
  ConsumerState<WishlistFormScreen> createState() => _WishlistFormScreenState();
}

class _WishlistFormScreenState extends ConsumerState<WishlistFormScreen> {
  final _name = TextEditingController();
  final _subcategory = TextEditingController();
  final _budget = TextEditingController();
  final _reason = TextEditingController();
  final _notes = TextEditingController();

  ClothingCategory? _category;
  Set<WardrobeColour> _colours = {};
  Set<StyleTag> _styles = {};
  Formality? _formality;
  WishlistPriority _priority = WishlistPriority.medium;
  WishlistStatus _status = WishlistStatus.planned;

  bool _loading = false;
  bool _notFound = false;
  bool _saving = false;
  String? _nameError;
  String? _categoryError;
  String? _budgetError;

  bool get _editing => widget.wishlistId != null;

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
    for (final c in [_name, _subcategory, _budget, _reason, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final w = await ref
        .read(wishlistRepositoryProvider)
        .getById(widget.wishlistId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (w == null) {
        _notFound = true;
        return;
      }
      _name.text = w.name;
      _subcategory.text = w.subcategory ?? '';
      final cents = w.targetPriceCents;
      _budget.text = cents == null
          ? ''
          : (cents % 100 == 0
                ? '${cents ~/ 100}'
                : '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}');
      _reason.text = w.reason ?? '';
      _notes.text = w.notes ?? '';
      _category = w.category;
      _colours = {...w.preferredColours};
      _styles = {...w.styleTags};
      _formality = w.formality;
      _priority = w.priority;
      _status = w.status;
    });
  }

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/wishlist');
    }
  }

  Future<void> _save() async {
    int? cents;
    String? budgetError;
    try {
      cents = parseBudgetCents(_budget.text);
    } on ValidationException catch (e) {
      budgetError = e.message;
    }
    final nameError = validateItemName(_name.text);
    final categoryError = _category == null ? 'Choose a category' : null;
    setState(() {
      _nameError = nameError;
      _categoryError = categoryError;
      _budgetError = budgetError;
    });
    if (nameError != null || categoryError != null || budgetError != null) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(wishlistRepositoryProvider)
          .save(
            id: widget.wishlistId,
            name: _name.text,
            category: _category!,
            subcategory: _text(_subcategory),
            preferredColours: _colours,
            styleTags: _styles,
            formality: _formality,
            targetPriceCents: cents,
            priority: _priority,
            reason: _text(_reason),
            notes: _text(_notes),
            status: _status,
          );
      if (mounted) _close();
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section(String title, Widget child, {String? error}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController c, {
    String? error,
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit wishlist item' : 'New wishlist item'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notFound
          ? const Center(child: Text('Wishlist item not found'))
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field('Name', _name, error: _nameError),
                      _section(
                        'Category',
                        EnumChips<ClothingCategory>(
                          values: ClothingCategory.values,
                          label: (v) => v.label,
                          selected: _category == null ? {} : {_category!},
                          single: true,
                          onChanged: (s) => setState(
                            () => _category = s.isEmpty ? null : s.first,
                          ),
                        ),
                        error: _categoryError,
                      ),
                      _field('Subcategory', _subcategory),
                      _section(
                        'Preferred colours',
                        EnumChips<WardrobeColour>(
                          values: WardrobeColour.values,
                          label: (v) => v.label,
                          selected: _colours,
                          onChanged: (s) => setState(() => _colours = s),
                        ),
                      ),
                      _section(
                        'Style',
                        EnumChips<StyleTag>(
                          values: StyleTag.values,
                          label: (v) => v.label,
                          selected: _styles,
                          onChanged: (s) => setState(() => _styles = s),
                        ),
                      ),
                      _section(
                        'Formality',
                        EnumChips<Formality>(
                          values: Formality.values,
                          label: (v) => v.label,
                          selected: _formality == null ? {} : {_formality!},
                          single: true,
                          onChanged: (s) => setState(
                            () => _formality = s.isEmpty ? null : s.first,
                          ),
                        ),
                      ),
                      _field('Budget', _budget, error: _budgetError),
                      _section(
                        'Priority',
                        EnumChips<WishlistPriority>(
                          values: WishlistPriority.values,
                          label: (v) => v.label,
                          selected: {_priority},
                          single: true,
                          onChanged: (s) => setState(
                            () => _priority = s.isEmpty ? _priority : s.first,
                          ),
                        ),
                      ),
                      _field('Why it would be useful', _reason, maxLines: 2),
                      _field('Notes', _notes, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
