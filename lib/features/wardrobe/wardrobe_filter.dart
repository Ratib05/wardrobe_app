import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';

enum WardrobeSort {
  recentlyAdded('Recently added'),
  name('Name'),
  category('Category');

  const WardrobeSort(this.label);
  final String label;
}

/// Search, filter and sort criteria for the wardrobe list.
/// Within a facet any selected value matches; across facets all must match.
/// An item with no value for an active facet does not match.
class WardrobeFilter {
  const WardrobeFilter({
    this.query = '',
    this.categories = const {},
    this.colours = const {},
    this.styles = const {},
    this.seasons = const {},
    this.occasions = const {},
    this.formalities = const {},
    this.favouritesOnly = false,
    this.needsDetailsOnly = false,
    this.sort = WardrobeSort.recentlyAdded,
  });

  final String query;
  final Set<ClothingCategory> categories;
  final Set<WardrobeColour> colours;
  final Set<StyleTag> styles;
  final Set<Season> seasons;
  final Set<Occasion> occasions;
  final Set<Formality> formalities;
  final bool favouritesOnly;

  /// Only items missing a main colour or formality (see
  /// [ClothingItem.needsDetails]).
  final bool needsDetailsOnly;
  final WardrobeSort sort;

  /// True when anything other than the sort order is set.
  bool get hasCriteria =>
      query.trim().isNotEmpty ||
      categories.isNotEmpty ||
      colours.isNotEmpty ||
      styles.isNotEmpty ||
      seasons.isNotEmpty ||
      occasions.isNotEmpty ||
      formalities.isNotEmpty ||
      favouritesOnly ||
      needsDetailsOnly;

  WardrobeFilter copyWith({
    String? query,
    Set<ClothingCategory>? categories,
    Set<WardrobeColour>? colours,
    Set<StyleTag>? styles,
    Set<Season>? seasons,
    Set<Occasion>? occasions,
    Set<Formality>? formalities,
    bool? favouritesOnly,
    bool? needsDetailsOnly,
    WardrobeSort? sort,
  }) => WardrobeFilter(
    query: query ?? this.query,
    categories: categories ?? this.categories,
    colours: colours ?? this.colours,
    styles: styles ?? this.styles,
    seasons: seasons ?? this.seasons,
    occasions: occasions ?? this.occasions,
    formalities: formalities ?? this.formalities,
    favouritesOnly: favouritesOnly ?? this.favouritesOnly,
    needsDetailsOnly: needsDetailsOnly ?? this.needsDetailsOnly,
    sort: sort ?? this.sort,
  );

  /// The search box matches the name, brand and colour names.
  static bool _matchesQuery(ClothingItem i, String q) {
    bool has(String? text) => text != null && text.toLowerCase().contains(q);
    return has(i.name) ||
        has(i.brand) ||
        has(i.primaryColour?.label) ||
        i.secondaryColours.any((c) => has(c.label));
  }

  bool _matches(ClothingItem i) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty && !_matchesQuery(i, q)) return false;
    if (favouritesOnly && !i.isFavourite) return false;
    if (needsDetailsOnly && !i.needsDetails) return false;
    if (categories.isNotEmpty && !categories.contains(i.category)) return false;
    if (colours.isNotEmpty &&
        !colours.any(
          (c) => c == i.primaryColour || i.secondaryColours.contains(c),
        )) {
      return false;
    }
    if (styles.isNotEmpty && !styles.any(i.styleTags.contains)) return false;
    if (seasons.isNotEmpty && !seasons.any(i.seasons.contains)) return false;
    if (occasions.isNotEmpty && !occasions.any(i.occasions.contains)) {
      return false;
    }
    if (formalities.isNotEmpty && !formalities.contains(i.formality)) {
      return false;
    }
    return true;
  }

  int _compare(ClothingItem a, ClothingItem b) {
    final primary = switch (sort) {
      WardrobeSort.recentlyAdded => b.createdAt.compareTo(a.createdAt),
      WardrobeSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      WardrobeSort.category =>
        a.category.index != b.category.index
            ? a.category.index.compareTo(b.category.index)
            : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    return primary != 0 ? primary : a.id.compareTo(b.id);
  }

  List<ClothingItem> apply(List<ClothingItem> items) =>
      items.where(_matches).toList()..sort(_compare);
}
