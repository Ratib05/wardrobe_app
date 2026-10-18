import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/wardrobe/wardrobe_filter.dart';

import '../../helpers.dart';

void main() {
  List<String> names(WardrobeFilter f, List<ClothingItem> items) =>
      f.apply(items).map((i) => i.name).toList();

  test('query is trimmed and case-insensitive', () {
    final items = [item(name: 'Blue shirt'), item(name: 'Jeans')];
    expect(names(const WardrobeFilter(query: ' SHI '), items), ['Blue shirt']);
  });

  test('search also matches brand and colour names', () {
    final items = [
      item(name: 'Overshirt', primaryColour: WardrobeColour.olive),
      item(name: 'Tee', secondaryColours: {WardrobeColour.rust}),
      item(name: 'Jeans'),
    ];
    // item() has no brand argument; brand matching is covered by the form test.
    expect(names(const WardrobeFilter(query: 'olive'), items), ['Overshirt']);
    expect(names(const WardrobeFilter(query: 'RUST'), items), ['Tee']);
  });

  test('any within a facet, all across facets', () {
    final items = [
      item(name: 'A', category: ClothingCategory.top, seasons: {Season.winter}),
      item(
        name: 'B',
        category: ClothingCategory.bottom,
        seasons: {Season.summer},
      ),
      item(
        name: 'C',
        category: ClothingCategory.footwear,
        seasons: {Season.winter},
      ),
    ];
    const cats = {ClothingCategory.top, ClothingCategory.bottom};
    expect(
      names(
        const WardrobeFilter(categories: cats, sort: WardrobeSort.name),
        items,
      ),
      ['A', 'B'],
    );
    expect(
      names(
        const WardrobeFilter(
          categories: cats,
          seasons: {Season.winter},
          sort: WardrobeSort.name,
        ),
        items,
      ),
      ['A'],
    );
  });

  test('colour facet checks secondary colours too', () {
    final items = [
      item(
        name: 'A',
        primaryColour: WardrobeColour.red,
        secondaryColours: {WardrobeColour.navy},
      ),
      item(name: 'B', primaryColour: WardrobeColour.red),
    ];
    expect(names(const WardrobeFilter(colours: {WardrobeColour.navy}), items), [
      'A',
    ]);
  });

  test('item without a value never matches an active facet', () {
    final items = [
      item(name: 'A', seasons: {Season.summer}),
      item(name: 'B'),
    ];
    expect(names(const WardrobeFilter(seasons: {Season.summer}), items), ['A']);
  });

  test('sorting with id tie-break', () {
    final items = [
      item(id: 'z', name: 'apple'),
      item(id: 'y', name: 'Apple'),
      item(id: 'x', name: 'banana'),
    ];
    final byName = const WardrobeFilter(sort: WardrobeSort.name).apply(items);
    expect(byName.map((i) => i.id), ['y', 'z', 'x']);
    final recent = const WardrobeFilter().apply(items);
    expect(recent.first.id, 'x'); // created last
  });

  test('hasCriteria ignores sort', () {
    expect(const WardrobeFilter().hasCriteria, isFalse);
    expect(const WardrobeFilter(sort: WardrobeSort.name).hasCriteria, isFalse);
    expect(const WardrobeFilter(favouritesOnly: true).hasCriteria, isTrue);
    expect(const WardrobeFilter(needsDetailsOnly: true).hasCriteria, isTrue);
  });

  test('needsDetailsOnly keeps items missing a colour or formality', () {
    final items = [
      item(
        name: 'Done',
        primaryColour: WardrobeColour.navy,
        formality: Formality.casual,
      ),
      item(name: 'No formality', primaryColour: WardrobeColour.navy),
      item(name: 'Bare'),
    ];
    expect(
      names(
        const WardrobeFilter(needsDetailsOnly: true, sort: WardrobeSort.name),
        items,
      ),
      ['Bare', 'No formality'],
    );
  });
}
