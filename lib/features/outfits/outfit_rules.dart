import '../../core/clothing_item.dart';
import '../../core/outfit_templates.dart';
import '../../core/wardrobe_values.dart';

/// Non-blocking hints shown while building an outfit.
List<String> outfitWarnings(List<ClothingItem> items) {
  final warnings = <String>[];
  if (items.any((i) => i.isArchived)) warnings.add('Includes archived items');

  final present = items.map((i) => i.category).toSet();
  // Compare against the closest template (fewest missing; ties go to the first).
  Set<ClothingCategory>? fewestMissing;
  for (final t in outfitTemplates) {
    final missing = t.required.difference(present);
    if (fewestMissing == null || missing.length < fewestMissing.length) {
      fewestMissing = missing;
    }
  }
  if (fewestMissing != null && fewestMissing.isNotEmpty) {
    final labels =
        (fewestMissing.toList()..sort((a, b) => a.index.compareTo(b.index)))
            .map((c) => c.label)
            .join(', ');
    warnings.add('Not a complete outfit yet — add: $labels');
  }

  if (items.where((i) => i.category == ClothingCategory.footwear).length > 1) {
    warnings.add('More than one footwear item');
  }
  return warnings;
}

/// Returns an error message when an outfit can't be saved, else null.
String? validateOutfit(String name, List<String> itemIds) {
  if (name.trim().isEmpty) return 'Enter a name';
  if (itemIds.toSet().length != itemIds.length) {
    return 'An item can only be added once';
  }
  if (itemIds.length < 2) return 'Choose at least two items';
  return null;
}

/// True when [items] cover every required category of some outfit template.
bool isCompleteOutfit(List<ClothingItem> items) {
  final present = items.map((i) => i.category).toSet();
  return outfitTemplates.any((t) => present.containsAll(t.required));
}
