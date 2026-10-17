import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/outfits/outfit_rules.dart';

import '../../helpers.dart';

void main() {
  final top = item(category: ClothingCategory.top);
  final bottom = item(category: ClothingCategory.bottom);
  final shoes = item(category: ClothingCategory.footwear);
  final dress = item(category: ClothingCategory.onePiece);

  test('incomplete outfit names the missing category', () {
    expect(outfitWarnings([top, bottom]), [
      'Not a complete outfit yet — add: Footwear',
    ]);
  });

  test('complete outfits have no warnings', () {
    expect(outfitWarnings([dress, shoes]), isEmpty);
    expect(outfitWarnings([top, bottom, shoes]), isEmpty);
  });

  test('more than one footwear item warns', () {
    final warnings = outfitWarnings([
      top,
      bottom,
      shoes,
      item(category: ClothingCategory.footwear),
    ]);
    expect(warnings, contains('More than one footwear item'));
  });

  test('archived items warn', () {
    final archived = item(category: ClothingCategory.top, isArchived: true);
    expect(
      outfitWarnings([archived, bottom, shoes]),
      contains('Includes archived items'),
    );
  });

  test('validateOutfit', () {
    expect(validateOutfit('', ['a', 'b']), 'Enter a name');
    expect(validateOutfit('x', ['a']), 'Choose at least two items');
    expect(validateOutfit('x', ['a', 'a']), 'An item can only be added once');
    expect(validateOutfit('x', ['a', 'b']), isNull);
  });
}
