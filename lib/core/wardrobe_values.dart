// Fixed value lists for clothing attributes. The database stores each
// value's enum `name`; `label` is what the UI shows.

enum ClothingCategory {
  top('Top'),
  bottom('Bottom'),
  onePiece('Dress / jumpsuit'),
  outerwear('Outerwear'),
  footwear('Footwear'),
  accessory('Accessory');

  const ClothingCategory(this.label);
  final String label;
}

enum ColourFamily { neutral, red, pink, orange, yellow, green, blue, purple, multi }

enum WardrobeColour {
  black('Black', ColourFamily.neutral, 0xFF111111),
  white('White', ColourFamily.neutral, 0xFFFFFFFF),
  grey('Grey', ColourFamily.neutral, 0xFF9E9E9E),
  navy('Navy', ColourFamily.neutral, 0xFF1A237E),
  beige('Beige', ColourFamily.neutral, 0xFFD7C4A3),
  brown('Brown', ColourFamily.neutral, 0xFF6D4C41),
  denim('Denim', ColourFamily.neutral, 0xFF3F5E8C),
  red('Red', ColourFamily.red, 0xFFD32F2F),
  burgundy('Burgundy', ColourFamily.red, 0xFF800020),
  pink('Pink', ColourFamily.pink, 0xFFF48FB1),
  orange('Orange', ColourFamily.orange, 0xFFFB8C00),
  yellow('Yellow', ColourFamily.yellow, 0xFFFDD835),
  green('Green', ColourFamily.green, 0xFF388E3C),
  olive('Olive', ColourFamily.green, 0xFF708238),
  blue('Blue', ColourFamily.blue, 0xFF1976D2),
  lightBlue('Light blue', ColourFamily.blue, 0xFF81D4FA),
  purple('Purple', ColourFamily.purple, 0xFF7B1FA2),
  multicolour('Multicolour', ColourFamily.multi, 0xFF9C27B0);

  const WardrobeColour(this.label, this.family, this.argb);
  final String label;
  final ColourFamily family;
  final int argb;
  bool get isNeutral => family == ColourFamily.neutral;
}

/// Ordered from least to most formal.
enum Formality {
  loungewear('Loungewear'),
  casual('Casual'),
  smartCasual('Smart casual'),
  business('Business'),
  formal('Formal');

  const Formality(this.label);
  final String label;
}

enum Season {
  spring('Spring'),
  summer('Summer'),
  autumn('Autumn'),
  winter('Winter');

  const Season(this.label);
  final String label;
}

enum Occasion {
  casual('Casual'),
  work('Work'),
  formal('Formal'),
  party('Party'),
  sport('Sport'),
  outdoor('Outdoor'),
  lounge('Lounge');

  const Occasion(this.label);
  final String label;
}

enum StyleTag {
  classic('Classic'),
  minimal('Minimal'),
  smart('Smart'),
  relaxed('Relaxed'),
  sporty('Sporty'),
  streetwear('Streetwear'),
  vintage('Vintage'),
  bold('Bold');

  const StyleTag(this.label);
  final String label;
}

enum ClothingPattern {
  solid('Solid'),
  striped('Striped'),
  checked('Checked'),
  floral('Floral'),
  printed('Printed'),
  other('Other');

  const ClothingPattern(this.label);
  final String label;
}

enum ClothingFit {
  slim('Slim'),
  regular('Regular'),
  relaxed('Relaxed'),
  oversized('Oversized');

  const ClothingFit(this.label);
  final String label;
}

enum ItemCondition {
  brandNew('New'),
  good('Good'),
  worn('Worn'),
  needsRepair('Needs repair');

  const ItemCondition(this.label);
  final String label;
}

enum WishlistPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const WishlistPriority(this.label);
  final String label;
}

enum WishlistStatus {
  planned('Planned'),
  purchased('Purchased'),
  dismissed('Dismissed');

  const WishlistStatus(this.label);
  final String label;
}

enum FeedbackType { saved, liked, rated, dismissed }

enum PreferenceType {
  preferredColour,
  preferredStyle,
  preferredFormality,
  excludedColour,
  excludedStyle,
}
