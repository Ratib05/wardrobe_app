import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/features/recommendations/engine/scoring.dart';
import 'package:wardrobe_app/features/recommendations/recommendations_providers.dart';

import '../../helpers.dart';

void main() {
  testApp('weights default to the fixed shares, save and reset', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    await tester.tap(find.byKey(const Key('nav-Settings')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('share-colour'))).data,
      '25',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('share-feedback'))).data,
      '5',
    );

    // Drag colour to zero: the other shares are rescaled to add up to 100.
    await tester.drag(
      find.byKey(const Key('weight-colour')),
      const Offset(-2000, 0),
    );
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('share-colour'))).data,
      '0',
    );
    await tester.tap(find.byKey(const Key('save-weights')));
    final container = containerOf(tester);
    await pumpUntil(
      tester,
      () => container.read(scoreWeightsProvider).value != null,
    );
    final stored = container.read(scoreWeightsProvider).value;
    expect(stored![ScoreFactor.colour], 0);
    expect(stored.values.fold(0.0, (a, b) => a + b), closeTo(1, 1e-9));

    await tester.tap(find.byKey(const Key('reset-weights')));
    await pumpUntil(
      tester,
      () => container.read(scoreWeightsProvider).value == null,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('share-colour'))).data,
      '25',
    );
  });
}
