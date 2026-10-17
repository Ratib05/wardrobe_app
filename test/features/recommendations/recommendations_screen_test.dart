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

Future<void> expandWhy(WidgetTester tester) async {
  await tester.tap(find.text('Why this outfit'));
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

  testApp('card shows rank, title, score and the ranked total', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    final card = find.byType(RecommendationCard);
    expect(card, findsOneWidget);
    expect(find.text('RANKED FROM 1 VALID COMBINATION'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    // Attribute-less items score a neutral 50.
    expect(find.text('50 / 100'), findsOneWidget);
    expect(find.text('Classic and simple'), findsOneWidget);
    expect(find.textContaining('Scores use fixed rules'), findsOneWidget);
  });

  testApp('Why this outfit lists seven factors with points', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    expect(find.text('Meets the basic outfit rules'), findsNothing);
    await expandWhy(tester);
    expect(find.text('Meets the basic outfit rules'), findsOneWidget);
    expect(find.text('Colour harmony'), findsOneWidget);
    // Default weights at a neutral 0.5 each: 25 * .5 = 13 (rounded), etc.
    expect(find.text('13/25'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testApp('Not for me hides the card and Undo brings it back', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths, items: wardrobe);
    await openRecommendations(tester);
    await tester.tap(find.byKey(const Key('not-for-me')));
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
    await tester.tap(find.text('Save outfit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilFound(tester, find.text('Saved'));
    final db = containerOf(tester).read(appDatabaseProvider);
    final outfits = (await tester.runAsync(() => db.select(db.outfits).get()))!;
    expect(outfits, hasLength(1));

    await expandWhy(tester);
    await tester.ensureVisible(find.byTooltip('Rate'));
    await tester.pumpAndSettle();
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

  testApp('Must include narrows suggestions only after Show suggestions', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        ...wardrobe,
        item(id: 't2', name: 'Shirt', category: ClothingCategory.top),
      ],
    );
    await openRecommendations(tester);
    expect(find.byType(RecommendationCard), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('Must include-null')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shirt').last);
    await tester.pumpAndSettle();
    // Not applied yet.
    expect(find.byType(RecommendationCard), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('show-suggestions')));
    await pumpUntil(
      tester,
      () => find.byType(RecommendationCard).evaluate().length == 1,
    );
    expect(find.text('Shirt'), findsWidgets);
    expect(find.text('Tee'), findsNothing);
  });
}
