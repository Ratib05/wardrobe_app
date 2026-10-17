import 'wardrobe_values.dart';

/// Returns an error message for an invalid name, or null when valid.
String? validateItemName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Enter a name';
  if (trimmed.length > 80) return 'Name must be 80 characters or fewer';
  return null;
}

class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.primaryColour,
    this.secondaryColours = const {},
    this.pattern,
    this.material,
    this.fit,
    this.styleTags = const {},
    this.formality,
    this.seasons = const {},
    this.occasions = const {},
    this.brand,
    this.size,
    this.condition = ItemCondition.good,
    this.imagePath,
    this.isFavourite = false,
    this.isArchived = false,
    this.hideFromSuggestions = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final ClothingCategory category;
  final String? subcategory;
  final WardrobeColour? primaryColour;
  final Set<WardrobeColour> secondaryColours;
  final ClothingPattern? pattern;
  final String? material;
  final ClothingFit? fit;
  final Set<StyleTag> styleTags;
  final Formality? formality;
  final Set<Season> seasons;
  final Set<Occasion> occasions;
  final String? brand;
  final String? size;
  final ItemCondition condition;
  final String? imagePath;
  final bool isFavourite;
  final bool isArchived;

  /// The user chose to keep this item out of outfits and suggestions (for
  /// example it is in repair or stored away). It stays in the wardrobe.
  final bool hideFromSuggestions;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Usable in outfits and recommendations.
  bool get isAvailable =>
      !isArchived &&
      !hideFromSuggestions &&
      condition != ItemCondition.needsRepair;
}
