import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/app/providers.dart';
import 'package:wardrobe_app/core/wardrobe_values.dart';

import '../../helpers.dart';

void main() {
  testApp('avoiding a colour stores an excluded preference', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    await tester.tap(find.byKey(const Key('nav-Settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recommendation preferences'));
    await tester.pumpAndSettle();
    expect(
      find.text('Avoided colours and styles are never recommended.'),
      findsOneWidget,
    );

    final navy = find.descendant(
      of: find.byKey(const Key('avoid-colours')),
      matching: find.widgetWithText(FilterChip, 'Navy'),
    );
    await tester.ensureVisible(navy);
    await tester.pumpAndSettle();
    await tester.tap(navy);
    await pumpUntilFound(
      tester,
      find.descendant(
        of: find.byKey(const Key('avoid-colours')),
        matching: find.byWidgetPredicate(
          (w) =>
              w is FilterChip && w.selected && (w.label as Text).data == 'Navy',
        ),
      ),
    );
    final db = containerOf(tester).read(appDatabaseProvider);
    final rows = (await tester.runAsync(
      () => db.select(db.userPreferences).get(),
    ))!;
    expect(rows.single.preferenceType, PreferenceType.excludedColour);
    expect(rows.single.preferenceValue, 'navy');
  });
}
