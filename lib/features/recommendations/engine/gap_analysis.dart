// Wardrobe gap analysis: which items you do not own would add the most
// outfits. Pure Dart (only lib/core and the sibling engine files).
//
// Candidate items are imaginary: a category in your outfit templates, a
// colour (neutrals plus your preferred colours, minus avoided ones) and a
// formality level you already own. Each is added to the wardrobe in turn and
// the outfits it would appear in are counted. A missing category alone never
// produces a suggestion.

import '../../../core/clothing_item.dart';
import '../../../core/outfit_templates.dart';
import '../../../core/wardrobe_values.dart';
import 'recommendation_engine.dart';
import 'scoring.dart';

enum GapKind { needed, useful }

String gapKey(
  ClothingCategory category,
  WardrobeColour? colour,
  Formality? formality,
) => '${category.name}:${colour?.name ?? '-'}:${formality?.name ?? '-'}';

class GapSuggestion {
  const GapSuggestion({
    required this.category,
    required this.colour,
    required this.formality,
    required this.kind,
    required this.newOutfits,
    required this.partnerCount,
    required this.title,
    required this.explanation,
    this.partners = const [],
  });

  final ClothingCategory category;
  final WardrobeColour colour;
  final Formality formality;
  final GapKind kind;

  /// Needed: every valid outfit it would make possible.
  /// Useful: only the good (Good or Strong match) outfits it would add.
  final int newOutfits;

  /// Distinct owned items it would pair with in those outfits.
  final int partnerCount;
  final String title;
  final String explanation;

  /// The owned items it would pair with, most often first.
  final List<ClothingItem> partners;

  String get key => gapKey(category, colour, formality);
}

class GapRequest {
  const GapRequest({
    required this.items,
    this.preferences = const RecommendationPreferences(),
    this.excludedKeys = const {},
    this.minNewOutfits = 3,
    this.limit = 10,
    this.perCategory = 2,
    this.occasion,
    this.formality,
  });

  final List<ClothingItem> items;
  final RecommendationPreferences preferences;

  /// Keys of suggestions to hide (already on the wishlist, or dismissed).
  final Set<String> excludedKeys;
  final int minNewOutfits;
  final int limit;
  final int perCategory;

  /// The event being planned for. Only owned items that suit it (or have no
  /// value recorded) count, and suggestions are made for it.
  final Occasion? occasion;
  final Formality? formality;
}

const _unlimited = 1 << 30;

/// Whether the wardrobe has the basics (a top, bottom or dress) that tell us
/// which outfit types you wear. Without them there is nothing to analyse.
bool canAnalyseGaps(List<ClothingItem> items) => items.any(
  (i) =>
      i.isAvailable &&
      (i.category == ClothingCategory.top ||
          i.category == ClothingCategory.bottom ||
          i.category == ClothingCategory.onePiece),
);

List<GapSuggestion> analyseGaps(GapRequest request) {
  final eligible = [
    for (final i in request.items)
      if (isEligible(i, request.preferences)) i,
  ];
  // Outfit types come from the whole wardrobe; everything else only from the
  // items that suit the event being planned.
  final categories = {for (final i in eligible) i.category};
  final owned = [
    for (final i in eligible)
      if ((request.formality == null ||
              i.formality == null ||
              i.formality == request.formality) &&
          (request.occasion == null ||
              i.occasions.isEmpty ||
              i.occasions.contains(request.occasion)))
        i,
  ];

  // Outfit types you actually wear.
  final active = <OutfitTemplate>[
    if (categories.contains(ClothingCategory.top) ||
        categories.contains(ClothingCategory.bottom))
      outfitTemplates[0],
    if (categories.contains(ClothingCategory.onePiece)) outfitTemplates[1],
  ];
  if (active.isEmpty) return const [];

  final candidateCategories = <ClothingCategory>{
    for (final t in active) ...t.required,
    for (final t in active) ...t.optional,
  };
  final excluded = request.preferences.excludedColours;
  final preferredCandidates = {...request.preferences.preferredColours}
    ..removeAll(excluded);
  // Neutrals all score identically (a neutral goes with anything), so for
  // each category and formality only one of them is tried.
  final plainNeutrals = [
    for (final c in WardrobeColour.values)
      if (c.isNeutral &&
          !preferredCandidates.contains(c) &&
          !excluded.contains(c))
        c,
  ];
  final ownedFormalities = {
    for (final i in owned)
      if (i.formality != null) i.formality!,
  };
  final formalities = request.formality != null
      ? {request.formality!}
      : ownedFormalities.isEmpty
      ? {Formality.casual}
      : ownedFormalities;

  final baseline = recommend(
    RecommendationRequest(
      items: owned,
      preferences: request.preferences,
      occasion: request.occasion,
      limit: _unlimited,
    ),
  );
  final canMakeOutfits = baseline.isNotEmpty;

  final found = <GapSuggestion>[];
  for (final category in ClothingCategory.values) {
    if (!candidateCategories.contains(category)) continue;
    int ownedIn(WardrobeColour c) => owned
        .where((i) => i.category == category && i.primaryColour == c)
        .length;
    // The neutral you own fewest of in this category first (ties: list order).
    final neutralsByOwned = [...plainNeutrals]
      ..sort((a, b) {
        final c = ownedIn(a).compareTo(ownedIn(b));
        return c != 0 ? c : a.index.compareTo(b.index);
      });
    for (final formality in Formality.values) {
      if (!formalities.contains(formality)) continue;
      bool hidden(WardrobeColour c) =>
          request.excludedKeys.contains(gapKey(category, c, formality));
      final colours = [
        ...WardrobeColour.values.where(
          (c) => preferredCandidates.contains(c) && !hidden(c),
        ),
        ?neutralsByOwned.where((c) => !hidden(c)).firstOrNull,
      ];
      for (final colour in colours) {
        final suggestion = _evaluate(
          request,
          owned,
          category,
          colour,
          formality,
          canMakeOutfits,
          ownedIn(colour),
        );
        if (suggestion != null) found.add(suggestion);
      }
    }
  }

  // Nothing can be completed by one item: suggest the basics of the main
  // outfit type that are missing.
  // ponytail: only the first outfit type you wear; add dress outfits when
  // someone needs both.
  if (!canMakeOutfits && found.isEmpty) {
    final formality =
        request.formality ?? averageFormality(owned) ?? Formality.casual;
    for (final category in ClothingCategory.values) {
      if (!active.first.required.contains(category) ||
          owned.any((i) => i.category == category)) {
        continue;
      }
      final colour = plainNeutrals
          .where(
            (c) =>
                !request.excludedKeys.contains(gapKey(category, c, formality)),
          )
          .firstOrNull;
      if (colour == null) continue;
      found.add(_starter(category, colour, formality, request.occasion));
    }
  }

  final preferred = request.preferences.preferredColours;
  found.sort((a, b) {
    var c = a.kind.index.compareTo(b.kind.index); // needed first
    if (c != 0) return c;
    c = b.newOutfits.compareTo(a.newOutfits);
    if (c != 0) return c;
    c = b.partnerCount.compareTo(a.partnerCount);
    if (c != 0) return c;
    final aPref = preferred.contains(a.colour) ? 0 : 1;
    final bPref = preferred.contains(b.colour) ? 0 : 1;
    c = aPref.compareTo(bPref);
    return c != 0 ? c : a.key.compareTo(b.key);
  });

  final perCategory = <ClothingCategory, int>{};
  final result = <GapSuggestion>[];
  for (final s in found) {
    final n = perCategory[s.category] ?? 0;
    if (n >= request.perCategory) continue;
    perCategory[s.category] = n + 1;
    result.add(s);
    if (result.length >= request.limit) break;
  }
  return result;
}

GapSuggestion _starter(
  ClothingCategory category,
  WardrobeColour colour,
  Formality formality,
  Occasion? occasion,
) => GapSuggestion(
  category: category,
  colour: colour,
  formality: formality,
  kind: GapKind.needed,
  newOutfits: 0,
  partnerCount: 0,
  title:
      '${colour.label} ${formality.label.toLowerCase()} '
      '${category.label.toLowerCase()}',
  explanation:
      'You have no ${formality.label.toLowerCase()} '
      '${category.labelPlural.toLowerCase()}'
      '${occasion == null ? '' : ' for ${occasion.label.toLowerCase()}'} yet.',
);

GapSuggestion? _evaluate(
  GapRequest request,
  List<ClothingItem> owned,
  ClothingCategory category,
  WardrobeColour colour,
  Formality formality,
  bool canMakeOutfits,
  int ownedOfColour,
) {
  final key = gapKey(category, colour, formality);
  final title =
      '${colour.label} ${formality.label.toLowerCase()} '
      '${category.label.toLowerCase()}';
  final imaginary = ClothingItem(
    id: 'gap:$key',
    name: title,
    category: category,
    primaryColour: colour,
    formality: formality,
    occasions: {?request.occasion},
    createdAt: DateTime.utc(2000),
    updatedAt: DateTime.utc(2000),
  );
  final forEvent = request.occasion == null
      ? ''
      : ' for ${request.occasion!.label.toLowerCase()}';
  final outfits = recommend(
    RecommendationRequest(
      items: owned,
      preferences: request.preferences,
      occasion: request.occasion,
      limit: _unlimited,
      mustInclude: imaginary,
    ),
  );

  List<ClothingItem> partners(Iterable<Recommendation> recs) {
    final counts = <String, int>{};
    final byId = <String, ClothingItem>{};
    for (final r in recs) {
      for (final i in r.items) {
        if (i.id == imaginary.id) continue;
        counts[i.id] = (counts[i.id] ?? 0) + 1;
        byId[i.id] = i;
      }
    }
    final ids = counts.keys.toList()
      ..sort((a, b) {
        final c = counts[b]!.compareTo(counts[a]!);
        return c != 0 ? c : a.compareTo(b);
      });
    return [for (final id in ids) byId[id]!];
  }

  if (!canMakeOutfits) {
    if (outfits.isEmpty) return null;
    final neededPartners = partners(outfits);
    return GapSuggestion(
      category: category,
      colour: colour,
      formality: formality,
      kind: GapKind.needed,
      newOutfits: outfits.length,
      partnerCount: neededPartners.length,
      partners: neededPartners,
      title: title,
      explanation:
          "You can't put together a complete outfit yet. This would make "
          '${outfits.length} ${outfits.length == 1 ? 'outfit' : 'outfits'} '
          'possible$forEvent.',
    );
  }

  final good = outfits
      .where((r) => r.label != MatchLabel.possible)
      .toList(growable: false);
  if (good.length < request.minNewOutfits) return null;
  final goodPartners = partners(good);
  final partnerCount = goodPartners.length;
  return GapSuggestion(
    category: category,
    colour: colour,
    formality: formality,
    kind: GapKind.useful,
    newOutfits: good.length,
    partnerCount: partnerCount,
    partners: goodPartners,
    title: title,
    explanation:
        'Would pair with $partnerCount of your items, adding '
        '${good.length} good outfits$forEvent.'
        '${ownedOfColour == 0 ? ' You have no ${colour.label.toLowerCase()} '
                  '${category.labelPlural.toLowerCase()} yet.' : ''}',
  );
}

/// How many valid outfits an item you do not own yet would make possible
/// (every score counts). [colour] and [formality] may be unknown.
int outfitsUnlockedBy({
  required List<ClothingItem> items,
  required ClothingCategory category,
  WardrobeColour? colour,
  Formality? formality,
  RecommendationPreferences preferences = const RecommendationPreferences(),
}) {
  final imaginary = ClothingItem(
    id: 'gap:${gapKey(category, colour, formality)}',
    name: 'Wishlist item',
    category: category,
    primaryColour: colour,
    formality: formality,
    createdAt: DateTime.utc(2000),
    updatedAt: DateTime.utc(2000),
  );
  return recommendWithTotal(
    RecommendationRequest(
      items: items,
      preferences: preferences,
      limit: 0,
      mustInclude: imaginary,
    ),
  ).total;
}
