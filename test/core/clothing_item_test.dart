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

  test('nameFromFileName', () {
    expect(
      nameFromFileName(r'C:\Photos\blue_oxford-shirt.JPG'),
      'Blue oxford shirt',
    );
    expect(
      nameFromFileName('/storage/IMG_20261018_101530.jpg'),
      'IMG 20261018 101530',
    );
    expect(nameFromFileName('1000012345.jpg'), '1000012345');
    expect(nameFromFileName('no extension'), 'No extension');
    expect(nameFromFileName('my.linen.shirt.png'), 'My linen shirt');
    expect(nameFromFileName('__-.jpg'), 'Imported item');
    expect(nameFromFileName('.jpg'), 'Jpg');
    final long = nameFromFileName('${'a' * 100}.jpg');
    expect(long.length, 80);
    expect(validateItemName(long), isNull);
  });

  test('needsDetails is true without a main colour or formality', () {
    expect(item().needsDetails, isTrue);
    expect(item(primaryColour: WardrobeColour.navy).needsDetails, isTrue);
    expect(item(formality: Formality.casual).needsDetails, isTrue);
    expect(
      item(
        primaryColour: WardrobeColour.navy,
        formality: Formality.casual,
      ).needsDetails,
      isFalse,
    );
  });

  test('isAvailable', () {
    expect(item(isArchived: true).isAvailable, isFalse);
    expect(item(condition: ItemCondition.needsRepair).isAvailable, isFalse);
    expect(item(hideFromSuggestions: true).isAvailable, isFalse);
    expect(item().isAvailable, isTrue);
  });

  test('neutral colours', () {
    expect(WardrobeColour.values.where((c) => c.isNeutral).toSet(), {
      WardrobeColour.black,
      WardrobeColour.white,
      WardrobeColour.cream,
      WardrobeColour.lightGrey,
      WardrobeColour.grey,
      WardrobeColour.navy,
      WardrobeColour.charcoal,
      WardrobeColour.beige,
      WardrobeColour.stone,
      WardrobeColour.tan,
      WardrobeColour.khaki,
      WardrobeColour.brown,
      WardrobeColour.darkBrown,
      WardrobeColour.denim,
      WardrobeColour.lightDenim,
    });
  });

  test('formality levels run from relaxed to formal', () {
    expect(Formality.values.map((f) => f.label), [
      'Relaxed',
      'Casual',
      'Smart casual',
      'Smart',
      'Formal',
    ]);
  });

  test('averageFormality rounds the mean and ignores unset items', () {
    expect(averageFormality([item(), item()]), isNull);
    expect(
      averageFormality([
        item(formality: Formality.casual),
        item(formality: Formality.smart),
        item(),
      ]),
      Formality.smartCasual,
    );
  });
}
