import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/app.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/database/app_database.dart';

import '../helpers.dart';

const sections = [
  'Dashboard',
  'Wardrobe',
  'Outfits',
  'Recommendations',
  'Wishlist',
  'Settings',
];

void main() {
  testApp('wide layout uses NavigationRail and opens every section', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    for (final s in sections) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text(s),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(s)),
        findsOneWidget,
        reason: s,
      );
    }
  });

  testApp('narrow layout uses NavigationBar', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  }, size: const Size(400, 800));

  testApp('dashboard shows live item count', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    expect(find.text('0 items in your wardrobe'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WardrobeApp)),
    );
    await tester.runAsync(
      () => container
          .read(appDatabaseProvider)
          .into(container.read(appDatabaseProvider).clothingItems)
          .insert(item(id: 'a').toInsertable()),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 item in your wardrobe'), findsOneWidget);
  });
}
