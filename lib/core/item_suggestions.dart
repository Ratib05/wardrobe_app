// Suggests formality, style and occasions from an item's name and type, using
// a fixed keyword table. Pure Dart. It reads the words the user typed; it does
// not look at the photo and does not recognise anything.

import 'wardrobe_values.dart';

class DetailSuggestion {
  const DetailSuggestion({
    this.formality,
    this.styles = const {},
    this.occasions = const {},
  });

  final Formality? formality;
  final Set<StyleTag> styles;
  final Set<Occasion> occasions;

  bool get isEmpty => formality == null && styles.isEmpty && occasions.isEmpty;
}

/// The occasions that usually go with a formality level.
Set<Occasion> occasionsFor(Formality formality) => switch (formality) {
  Formality.relaxed => {Occasion.casual, Occasion.lounge},
  Formality.casual => {Occasion.casual},
  Formality.smartCasual => {Occasion.casual, Occasion.work},
  Formality.smart => {Occasion.work, Occasion.party},
  Formality.formal => {Occasion.work, Occasion.formal},
};

class _Rule {
  const _Rule(
    this.words,
    this.formality,
    this.styles, {
    this.occasions,
    this.category,
  });

  /// Singular, lower case; plurals ("s", "es") match automatically.
  final List<String> words;
  final Formality formality;
  final Set<StyleTag> styles;

  /// Defaults to [occasionsFor] the formality.
  final Set<Occasion>? occasions;

  /// When set, the rule applies only to items of this category.
  final ClothingCategory? category;
}

const _classic = {StyleTag.classic};
const _classicSmart = {StyleTag.classic, StyleTag.smart};
const _classicMinimal = {StyleTag.classic, StyleTag.minimal};

/// The first matching rule wins, so specific phrases come before generic ones
/// ("dress shoe" before "dress", "polo neck" before "polo", "graphic tee"
/// before "tee"). Hyphens are dropped before matching, so "t-shirt" is
/// "tshirt" and "tie-dye" can never match "tie".
// ponytail: linear scan of a hand-written table; fine for a few dozen rules.
// If it grows past a screenful, move it to a data file.
const _rules = <_Rule>[
  _Rule(
    [
      'pyjama',
      'pajama',
      'loungewear',
      'slipper',
      'robe',
      'dressing gown',
      'nightie',
      'onesie',
    ],
    Formality.relaxed,
    {StyleTag.relaxed},
    occasions: {Occasion.lounge},
  ),
  _Rule(
    [
      'gym',
      'running',
      'legging',
      'activewear',
      'tracksuit',
      'track suit',
      'sports bra',
      'workout',
    ],
    Formality.relaxed,
    {StyleTag.sporty},
    occasions: {Occasion.sport},
  ),
  _Rule(
    [
      'parka',
      'puffer',
      'raincoat',
      'fleece',
      'hiking',
      'windbreaker',
      'waterproof',
    ],
    Formality.casual,
    {StyleTag.sporty},
    occasions: {Occasion.casual, Occasion.outdoor},
  ),
  _Rule(
    ['tuxedo', 'bow tie', 'bowtie', 'gown', 'evening dress'],
    Formality.formal,
    _classic,
    occasions: {Occasion.formal, Occasion.party},
  ),
  _Rule(
    ['tie', 'cufflink'],
    Formality.formal,
    _classicSmart,
    category: ClothingCategory.accessory,
  ),
  _Rule(
    ['suit', 'waistcoat', 'dinner jacket'],
    Formality.formal,
    _classicSmart,
  ),
  _Rule(
    ['dress shoe', 'brogue', 'derby', 'derbies', 'oxford shoe'],
    Formality.smart,
    _classicSmart,
    occasions: {Occasion.work, Occasion.party, Occasion.formal},
  ),
  _Rule(
    ['oxford'],
    Formality.smart,
    _classicSmart,
    occasions: {Occasion.work, Occasion.party, Occasion.formal},
    category: ClothingCategory.footwear,
  ),
  _Rule(
    [
      'blazer',
      'sport coat',
      'sports coat',
      'tailored trouser',
      'dress pant',
      'dress trouser',
      'slacks',
      'pencil skirt',
      'heel',
      'stiletto',
      'dress shirt',
    ],
    Formality.smart,
    _classicSmart,
  ),
  _Rule(
    ['overcoat', 'trench', 'peacoat', 'pea coat'],
    Formality.smart,
    _classic,
    occasions: {Occasion.casual, Occasion.work, Occasion.formal},
  ),
  _Rule(
    [
      'jumper',
      'sweater',
      'cardigan',
      'knit',
      'knitwear',
      'turtleneck',
      'polo neck',
      'poloneck',
      'roll neck',
      'rollneck',
      'pullover',
    ],
    Formality.smartCasual,
    _classicMinimal,
  ),
  _Rule(
    [
      'hoodie',
      'sweatshirt',
      'jogger',
      'sweatpant',
      'trackie',
      'track pant',
      'slider',
      'slide',
      'sandal',
      'thong',
      'flip flop',
      'flipflop',
      'croc',
    ],
    Formality.relaxed,
    {StyleTag.relaxed, StyleTag.sporty},
  ),
  _Rule(
    ['graphic tee', 'cargo', 'bomber', 'bucket hat'],
    Formality.casual,
    {StyleTag.streetwear},
  ),
  _Rule(
    ['cap', 'beanie', 'snapback'],
    Formality.casual,
    {StyleTag.streetwear},
    category: ClothingCategory.accessory,
  ),
  _Rule(
    ['trainer', 'sneaker', 'runner', 'kicks'],
    Formality.casual,
    {StyleTag.sporty, StyleTag.streetwear},
  ),
  _Rule(
    [
      'tshirt',
      't shirt',
      'tee',
      'jean',
      'shorts',
      'denim',
      'leather jacket',
      'tank top',
      'singlet',
    ],
    Formality.casual,
    _classicMinimal,
  ),
  _Rule(
    ['oxford'],
    Formality.smartCasual,
    _classic,
    category: ClothingCategory.top,
  ),
  _Rule(
    [
      'button down',
      'buttondown',
      'button up',
      'polo',
      'chino',
      'blouse',
      'loafer',
      'chelsea boot',
      'shirt',
    ],
    Formality.smartCasual,
    _classic,
  ),
];

String _normalise(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r"['’\-]"), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

bool _hasPhrase(String text, String phrase) =>
    RegExp('(^| )${RegExp.escape(phrase)}(s|es)?( |\$)').hasMatch(text);

/// Suggestions for an item called [name] (with an optional [type] such as
/// "Chinos"). Nothing is suggested when no rule matches.
DetailSuggestion suggestDetails(
  String name, {
  String? type,
  ClothingCategory? category,
}) {
  final text = _normalise('$name ${type ?? ''}');
  if (text.isEmpty) return const DetailSuggestion();
  for (final rule in _rules) {
    if (rule.category != null && rule.category != category) continue;
    if (rule.words.any((word) => _hasPhrase(text, word))) {
      return DetailSuggestion(
        formality: rule.formality,
        styles: rule.styles,
        occasions: rule.occasions ?? occasionsFor(rule.formality),
      );
    }
  }
  return const DetailSuggestion();
}
