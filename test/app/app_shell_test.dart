import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/services/backup_history.dart';

import '../helpers.dart';

/// Navigation label -> AppBar title of the screen it opens.
const sections = {
  'Wardrobe': 'Wardrobe',
  'Outfits': 'Outfits',
  'Suggestions': 'Recommendations',
  'Gaps & wishlist': 'Wishlist',
  'Backup': 'Backup',
  'Settings': 'Settings',
};

void main() {
  testApp('wide layout shows the sidebar and opens every section', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    expect(find.byKey(const Key('sidebar')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    // The app opens on the wardrobe.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Wardrobe')),
      findsOneWidget,
    );
    for (final MapEntry(key: label, value: title) in sections.entries) {
      await tester.tap(find.byKey(Key('nav-$label')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(title)),
        findsOneWidget,
        reason: label,
      );
    }
  });

  testApp('narrow layout shows a five-item bottom bar', (tester, paths) async {
    await pumpApp(tester, paths: paths);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const Key('sidebar')), findsNothing);
    for (final label in ['Wardrobe', 'Outfits', 'Suggest', 'Gaps', 'Backup']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
  }, size: const Size(400, 800));

  testApp('sidebar footer says when the last backup was', (
    tester,
    paths,
  ) async {
    await pumpApp(tester, paths: paths);
    expect(find.text('STORED ON THIS DEVICE'), findsOneWidget);
    expect(find.text('No backup yet'), findsOneWidget);
  });

  testApp('sidebar footer shows the last backup age', (tester, paths) async {
    BackupHistory(paths.backupHistoryFile).add(
      BackupRecord(
        path: 'C:/x/backup.zip',
        sizeBytes: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );
    await pumpApp(tester, paths: paths);
    expect(find.text('Last backup 3 days ago'), findsOneWidget);
  });
}
