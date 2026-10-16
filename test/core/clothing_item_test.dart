import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/clothing_item.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

import '../helpers.dart';

void main() {
  test('validateItemName', () {
    expect(validateItemName('  '), 'Enter a name');
    expect(validateItemName('Shirt'), isNull);
    expect(validateItemName('a' * 81), 'Name must be 80 characters or fewer');
  });

  test('isAvailable', () {
    expect(item(isArchived: true).isAvailable, isFalse);
    expect(item(condition: ItemCondition.needsRepair).isAvailable, isFalse);
    expect(item().isAvailable, isTrue);
  });

  test('neutral colours', () {
    expect(WardrobeColour.values.where((c) => c.isNeutral).toSet(), {
      WardrobeColour.black,
      WardrobeColour.white,
      WardrobeColour.grey,
      WardrobeColour.navy,
      WardrobeColour.beige,
      WardrobeColour.brown,
      WardrobeColour.denim,
    });
  });
}
