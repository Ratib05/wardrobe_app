import 'wardrobe_values.dart';

/// A valid way to put an outfit together. Shared by the outfit builder,
/// the recommendation engine and gap analysis.
class OutfitTemplate {
  const OutfitTemplate(this.label, this.required, this.optional);

  final String label;
  final Set<ClothingCategory> required;
  final Set<ClothingCategory> optional;
}

const outfitTemplates = <OutfitTemplate>[
  OutfitTemplate(
    'Top, bottom and footwear',
    {ClothingCategory.top, ClothingCategory.bottom, ClothingCategory.footwear},
    {ClothingCategory.outerwear},
  ),
  OutfitTemplate(
    'Dress or jumpsuit and footwear',
    {ClothingCategory.onePiece, ClothingCategory.footwear},
    {ClothingCategory.outerwear},
  ),
];
