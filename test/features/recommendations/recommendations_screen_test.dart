import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/features/recommendations/widgets/recommendation_card.dart';

import '../../helpers.dart';

Future<void> openRecommendations(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-Suggestions')));
  await tester.pumpAndSettle();
}

void main() {
  final wardrobe = [
    item(id: 't', name: 'Tee', category: ClothingCategory.top),
    item(id: 'b', name: 'Jeans', category: ClothingCategory.bottom),
    item(id: 's', name: 'Boots', category: ClothingCategory.footwear),
  ];

  testApp('empty wardrobe explains what to do', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openRecommendations(tester);
    expect(
      find.text('Add some clothing to get recommendations.'),
      findsOneWidget,
    );
  });

  testApp('missing footwear is named', (tester, paths) async {
    await pumpApp(tester, paths: paths, items: wardrobe.take(2).toList());
    await openRecommendations(tester);
    expect(find.text('To get recommendations, add: Shoes.'), findsOneWidget);
  });

  testApp('card shows a label and reasons, never a number', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    final card = find.byType(RecommendationCard);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.textContaining('match')),
      findsOneWidget,
    );
    expect(find.text('Meets the basic outfit rules'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(find.textContaining(RegExp(r'\d\.\d')), findsNothing);
  });

  testApp('dismiss hides the card and Undo brings it back', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    await tester.tap(find.byTooltip('Dismiss'));
    await pumpUntilGone(tester, find.byType(RecommendationCard));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Recommendation dismissed'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await pumpUntilFound(tester, find.byType(RecommendationCard));
  });

  testApp('save creates an outfit; rating records feedback', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilFound(tester, find.text('Saved'));
    final db = containerOf(tester).read(appDatabaseProvider);
    final outfits = (await tester.runAsync(() => db.select(db.outfits).get()))!;
    expect(outfits, hasLength(1));

    await tester.tap(find.byTooltip('Rate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4 stars'));
    await pumpUntilFound(tester, find.text('Rated 4/5'));
    final rows = (await tester.runAsync(
      () => db.select(db.recommendationFeedback).get(),
    ))!;
    final rated = rows.where((r) => r.feedbackType == FeedbackType.rated);
    expect(rated.single.rating, 4);
  });
}
