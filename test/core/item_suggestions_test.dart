import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/item_suggestions.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

void main() {
  DetailSuggestion s(String name, {String? type, ClothingCategory? category}) =>
      suggestDetails(name, type: type, category: category);

  test('one representative item per rule group', () {
    expect(s('Black tuxedo').formality, Formality.formal);
    expect(s('Navy suit jacket').formality, Formality.formal);
    expect(
      s('Silk tie', category: ClothingCategory.accessory).formality,
      Formality.formal,
    );
    expect(s('Navy blazer').formality, Formality.smart);
    expect(s('Black heels').formality, Formality.smart);
    expect(s('Camel overcoat').formality, Formality.smart);
    expect(s('White oxford shirt').formality, Formality.smartCasual);
    expect(s('Beige chinos').formality, Formality.smartCasual);
    expect(s('Brown loafers').formality, Formality.smartCasual);
    expect(s('Grey jumper').formality, Formality.smartCasual);
    expect(s('Blue jeans').formality, Formality.casual);
    expect(s('Plain T-shirt').formality, Formality.casual);
    expect(s('White trainers').formality, Formality.casual);
    expect(s('Black hoodie').formality, Formality.relaxed);
    expect(s('Grey joggers').formality, Formality.relaxed);
    expect(s('Gym leggings').formality, Formality.relaxed);
    expect(s('Striped pyjamas').formality, Formality.relaxed);
    expect(s('Green parka').formality, Formality.casual);
  });

  test('styles and occasions come with the formality', () {
    final blazer = s('Navy blazer');
    expect(blazer.styles, {StyleTag.classic, StyleTag.smart});
    expect(blazer.occasions, {Occasion.work, Occasion.party});
    final trainers = s('White trainers');
    expect(trainers.styles, {StyleTag.sporty, StyleTag.streetwear});
    expect(trainers.occasions, {Occasion.casual});
    expect(s('Gym leggings').occasions, {Occasion.sport});
    expect(s('Green parka').occasions, {Occasion.casual, Occasion.outdoor});
    expect(s('Striped pyjamas').occasions, {Occasion.lounge});
  });

  test('hyphens and plurals match; look-alike words do not', () {
    expect(s('Tie-dye T-shirt').formality, Formality.casual);
    expect(s('Button-down shirts').formality, Formality.smartCasual);
    expect(s('Short sleeve shirt').formality, Formality.smartCasual);
    expect(s('Tracksuit').formality, Formality.relaxed);
    expect(s('Dressing gown').formality, Formality.relaxed);
    expect(s('Cap sleeve top').formality, isNull);
  });

  test('specific phrases beat generic ones', () {
    expect(s('Black polo neck').styles, {StyleTag.classic, StyleTag.minimal});
    expect(s('Navy polo').styles, {StyleTag.classic});
    expect(s('Dress shoes').formality, Formality.smart);
    expect(s('Dress shirt').formality, Formality.smart);
    expect(s('Graphic tee').styles, {StyleTag.streetwear});
    expect(s('Running trainers').formality, Formality.relaxed);
  });

  test('category-specific rules', () {
    expect(
      s('Brown oxfords', category: ClothingCategory.footwear).formality,
      Formality.smart,
    );
    expect(
      s('Blue oxford', category: ClothingCategory.top).formality,
      Formality.smartCasual,
    );
    expect(s('Blue oxford').formality, isNull);
    expect(s('Black cap', category: ClothingCategory.accessory).styles, {
      StyleTag.streetwear,
    });
    expect(s('Black cap', category: ClothingCategory.top).formality, isNull);
  });

  test('the type text is used too', () {
    expect(s('Favourite', type: 'Chinos').formality, Formality.smartCasual);
  });

  test('unknown or empty names suggest nothing', () {
    expect(s('Mystery item').isEmpty, isTrue);
    expect(s('').isEmpty, isTrue);
    expect(s('   ').isEmpty, isTrue);
  });

  test('occasionsFor covers every formality', () {
    for (final f in Formality.values) {
      expect(occasionsFor(f), isNotEmpty, reason: f.label);
    }
  });

  test('every formality and style has a guide', () {
    for (final f in Formality.values) {
      expect(f.guide, isNotEmpty);
    }
    for (final t in StyleTag.values) {
      expect(t.guide, isNotEmpty);
    }
  });
}
