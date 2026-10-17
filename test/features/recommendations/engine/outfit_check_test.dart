import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/outfits/outfit_rules.dart';
import 'package:wardrobe_app/features/recommendations/engine/outfit_check.dart';

import '../../../helpers.dart';

void main() {
  test('attribute-less items score a neutral 50 with no notes', () {
    final c = outfitCheck([item(id: 'a'), item(id: 'b'), item(id: 'c')]);
    expect(c.score, 50);
    expect(c.notes, isEmpty);
  });

  test('compatible items score high and explain why', () {
    final c = outfitCheck([
      item(
        id: 'a',
        primaryColour: WardrobeColour.navy,
        formality: Formality.smart,
      ),
      item(
        id: 'b',
        primaryColour: WardrobeColour.white,
        formality: Formality.smart,
      ),
    ]);
    expect(c.score, greaterThan(50));
    expect(
      c.notes.where((n) => n.good).map((n) => n.text),
      contains('Colours are compatible'),
    );
  });

  test('clashing colours and distant formality are reported as weaknesses', () {
    final c = outfitCheck([
      item(
        id: 'a',
        primaryColour: WardrobeColour.red,
        formality: Formality.relaxed,
      ),
      item(
        id: 'b',
        primaryColour: WardrobeColour.pink,
        formality: Formality.formal,
      ),
    ]);
    final weak = c.notes.where((n) => !n.good).map((n) => n.text);
    expect(
      weak,
      containsAll(['Colours may clash', 'Formality levels are far apart']),
    );
  });

  test('shoes are ordered by fit and labelled by formality', () {
    final others = [
      item(id: 't', category: ClothingCategory.top, formality: Formality.smart),
    ];
    shoe(String id, String name, Formality f) => item(
      id: id,
      name: name,
      category: ClothingCategory.footwear,
      formality: f,
    );
    final ranked = rankShoes([
      shoe('trainers', 'Trainers', Formality.casual),
      shoe('brogues', 'Brogues', Formality.smart),
      shoe('oxfords', 'Oxfords', Formality.formal),
    ], others);
    expect(ranked.first.shoe.id, 'brogues');
    expect(ranked.first.fit, anyOf(ShoeFit.strong, ShoeFit.good));
    expect(
      ranked.firstWhere((r) => r.shoe.id == 'trainers').fit,
      ShoeFit.casual,
    );
    expect(
      ranked.firstWhere((r) => r.shoe.id == 'oxfords').fit,
      ShoeFit.formal,
    );
  });

  test('with nothing else chosen shoes are listed by name, unlabelled', () {
    final ranked = rankShoes([
      item(id: 'b', name: 'Boots', category: ClothingCategory.footwear),
      item(id: 'a', name: 'Aces', category: ClothingCategory.footwear),
    ], const []);
    expect(ranked.map((r) => r.shoe.id), ['a', 'b']);
    expect(ranked.every((r) => r.fit == null), isTrue);
  });

  test('isCompleteOutfit follows the templates', () {
    final top = item(id: 't', category: ClothingCategory.top);
    final bottom = item(id: 'b', category: ClothingCategory.bottom);
    final shoes = item(id: 's', category: ClothingCategory.footwear);
    final dress = item(id: 'd', category: ClothingCategory.onePiece);
    expect(isCompleteOutfit([top, bottom]), isFalse);
    expect(isCompleteOutfit([top, bottom, shoes]), isTrue);
    expect(isCompleteOutfit([dress, shoes]), isTrue);
    expect(isCompleteOutfit([dress]), isFalse);
  });
}
