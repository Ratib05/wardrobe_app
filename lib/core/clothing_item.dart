import 'wardrobe_values.dart';

/// The rounded average formality of [items]; null when none has a formality.
Formality? averageFormality(Iterable<ClothingItem> items) {
  final levels = [
    for (final i in items)
      if (i.formality != null) i.formality!.index,
  ];
  if (levels.isEmpty) return null;
  final mean = levels.reduce((a, b) => a + b) / levels.length;
  return Formality.values[mean.round()];
}

/// Returns an error message for an invalid name, or null when valid.
String? validateItemName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Enter a name';
  if (trimmed.length > 80) return 'Name must be 80 characters or fewer';
  return null;
}

/// A readable item name from a photo's file name, for bulk import:
/// `C:\Photos\blue_oxford-shirt.JPG` becomes "Blue oxford shirt".
String nameFromFileName(String path) {
  final file = path.split(RegExp(r'[\\/]')).last;
  final dot = file.lastIndexOf('.');
  final stem = dot > 0 ? file.substring(0, dot) : file;
  var name = stem.replaceAll(RegExp(r'[_.\-\s]+'), ' ').trim();
  if (name.isEmpty) return 'Imported item';
  if (name.length > 80) name = name.substring(0, 80).trim();
  return name[0].toUpperCase() + name.substring(1);
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

  /// Missing what suggestions rely on most (main colour or formality), as
  /// freshly imported photos are.
  bool get needsDetails => primaryColour == null || formality == null;
}
