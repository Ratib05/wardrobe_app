// Fixed value lists for clothing attributes. The database stores each
// value's enum `name`; `label` is what the UI shows.

enum ClothingCategory {
  top('Top', 'Tops'),
  bottom('Bottom', 'Bottoms'),
  onePiece('Dress / jumpsuit', 'Dresses'),
  outerwear('Outerwear', 'Outerwear'),
  footwear('Shoes', 'Shoes'),
  accessory('Accessory', 'Accessories');

  const ClothingCategory(this.label, this.labelPlural);
  final String label;
  final String labelPlural;
}

enum ColourFamily {
  neutral,
  red,
  pink,
  orange,
  yellow,
  green,
  blue,
  purple,
  multi,
}

enum WardrobeColour {
  black('Black', ColourFamily.neutral, 0xFF111111),
  white('White', ColourFamily.neutral, 0xFFFFFFFF),
  cream('Cream', ColourFamily.neutral, 0xFFF3EBD8),
  lightGrey('Light grey', ColourFamily.neutral, 0xFFD0D0D0),
  grey('Grey', ColourFamily.neutral, 0xFF9E9E9E),
  navy('Navy', ColourFamily.neutral, 0xFF1A237E),
  charcoal('Charcoal', ColourFamily.neutral, 0xFF3B3B3B),
  beige('Beige', ColourFamily.neutral, 0xFFD7C4A3),
  stone('Stone', ColourFamily.neutral, 0xFFCBBFA8),
  tan('Tan', ColourFamily.neutral, 0xFFC19A6B),
  khaki('Khaki', ColourFamily.neutral, 0xFFA89A6A),
  brown('Brown', ColourFamily.neutral, 0xFF6D4C41),
  darkBrown('Dark brown', ColourFamily.neutral, 0xFF3E2C20),
  denim('Denim', ColourFamily.neutral, 0xFF3F5E8C),
  red('Red', ColourFamily.red, 0xFFD32F2F),
  burgundy('Burgundy', ColourFamily.red, 0xFF800020),
  maroon('Maroon', ColourFamily.red, 0xFF5E1914),
  pink('Pink', ColourFamily.pink, 0xFFF48FB1),
  coral('Coral', ColourFamily.orange, 0xFFFF7F50),
  orange('Orange', ColourFamily.orange, 0xFFFB8C00),
  rust('Rust', ColourFamily.orange, 0xFFB7522F),
  yellow('Yellow', ColourFamily.yellow, 0xFFFDD835),
  mustard('Mustard', ColourFamily.yellow, 0xFFD4A017),
  green('Green', ColourFamily.green, 0xFF388E3C),
  forestGreen('Forest green', ColourFamily.green, 0xFF1F4D2B),
  sage('Sage', ColourFamily.green, 0xFF9CAF88),
  olive('Olive', ColourFamily.green, 0xFF708238),
  teal('Teal', ColourFamily.blue, 0xFF00897B),
  blue('Blue', ColourFamily.blue, 0xFF1976D2),
  lightBlue('Light blue', ColourFamily.blue, 0xFF81D4FA),
  purple('Purple', ColourFamily.purple, 0xFF7B1FA2),
  lavender('Lavender', ColourFamily.purple, 0xFFB39DDB),
  multicolour('Multicolour', ColourFamily.multi, 0xFF9C27B0);

  const WardrobeColour(this.label, this.family, this.argb);
  final String label;
  final ColourFamily family;
  final int argb;
  bool get isNeutral => family == ColourFamily.neutral;
}

/// Ordered from least to most formal.
enum Formality {
  relaxed(
    'Relaxed',
    'Comfort first: hoodies, joggers, sliders, pyjamas. Fine at home, '
        'not for the office.',
  ),
  casual('Casual', 'Everyday basics: T-shirts, jeans, shorts, trainers.'),
  smartCasual(
    'Smart casual',
    'A step up from casual: collared shirts, polos, chinos, knitwear, '
        'loafers or clean trainers. No tie.',
  ),
  smart(
    'Smart',
    'Office-ready: blazers, tailored trousers, dress shirts, dress shoes.',
  ),
  formal(
    'Formal',
    'Weddings and black-tie: suits with ties, tuxedos, gowns, polished shoes.',
  );

  const Formality(this.label, this.guide);
  final String label;

  /// One plain sentence on what belongs at this level.
  final String guide;
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
  classic(
    'Classic',
    'Timeless shapes that never date: oxford shirts, chinos, trench coats, '
        'plain knits.',
  ),
  minimal(
    'Minimal',
    'Plain colours and clean lines, with no logos or busy patterns.',
  ),
  smart(
    'Smart',
    'Sharp and tailored: blazers, fitted trousers, polished shoes.',
  ),
  relaxed('Relaxed', 'Loose and comfortable: soft fabrics, easy fits.'),
  sporty(
    'Sporty',
    'Athletic looks: trainers, joggers, tracksuits, technical fabrics.',
  ),
  streetwear(
    'Streetwear',
    'Urban casual: graphic tees, hoodies, cargos, caps, chunky trainers.',
  ),
  vintage('Vintage', 'Retro or older-era looks: classic denim, retro prints.'),
  bold('Bold', 'Stand-out colours, loud prints or unusual shapes.');

  const StyleTag(this.label, this.guide);
  final String label;

  /// One plain sentence on what this style looks like.
  final String guide;
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

  /// Stored value is a ScoreFactor name; the strength is in `weight`.
  scoreWeight,
}
