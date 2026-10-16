import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

import '../../helpers.dart';

Future<void> openWardrobe(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Wardrobe'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testApp('empty wardrobe shows empty state', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    await openWardrobe(tester);
    expect(find.text('Your wardrobe is empty'), findsOneWidget);
    expect(find.text('Add your first item'), findsOneWidget);
  });

  testApp('search narrows the list', (tester, paths) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(name: 'Blue shirt'),
        item(name: 'Jeans'),
      ],
    );
    await openWardrobe(tester);
    expect(find.text('Jeans'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'shirt');
    await tester.pumpAndSettle();
    expect(find.text('Blue shirt'), findsOneWidget);
    expect(find.text('Jeans'), findsNothing);
  });

  testApp('filters with no match show message and can be cleared', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(name: 'Blue shirt'),
        item(name: 'Jeans'),
      ],
    );
    await openWardrobe(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No items match these filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Blue shirt'), findsOneWidget);
    expect(find.text('Jeans'), findsOneWidget);
  });

  testApp('missing photo file shows a placeholder, not an exception', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [item(name: 'Ghost', imagePath: 'images/clothing/gone.jpg')],
    );
    await openWardrobe(tester);
    expect(find.text('Photo missing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testApp('archived items are only on the archived screen', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [
        item(name: 'Active', category: ClothingCategory.top),
        item(name: 'Old coat', isArchived: true),
      ],
    );
    await openWardrobe(tester);
    expect(find.text('Old coat'), findsNothing);
    await tester.tap(find.byTooltip('Archived items'));
    await tester.pumpAndSettle();
    expect(find.text('Old coat'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
  });

  testApp('list toggle shows ListTiles; dashboard lists recent items', (
    tester,
    paths,
  ) async {
    await pumpApp(
      tester,
      paths: paths,
      items: [item(name: 'Newest tee')],
    );
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Newest tee'), findsOneWidget);
    await openWardrobe(tester);
    await tester.tap(find.byTooltip('List view'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
  });
}
