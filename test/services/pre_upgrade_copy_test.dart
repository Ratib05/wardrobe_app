import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:wardrobe_app/services/pre_upgrade_copy.dart';

import '../helpers.dart';

void main() {
  test('copies an older database before an upgrade', () async {
    final paths = await tempPaths();
    sqlite.sqlite3.open(paths.databaseFile.path)
      ..execute('CREATE TABLE t (x INTEGER)')
      ..execute('PRAGMA user_version = 1')
      ..close();
    final copy = await copyDatabaseBeforeUpgrade(
      paths,
      2,
      now: DateTime(2026, 10, 18, 9, 5, 7),
    );
    expect(copy, isNotNull);
    expect(
      copy!.path,
      contains('wardrobe-before-schema-v2-20261018-090507.db'),
    );
    expect(copy.existsSync(), isTrue);
    expect(copy.lengthSync(), paths.databaseFile.lengthSync());
  });

  test('does nothing without a database or when already up to date', () async {
    final paths = await tempPaths();
    expect(await copyDatabaseBeforeUpgrade(paths, 2), isNull);
    sqlite.sqlite3.open(paths.databaseFile.path)
      ..execute('PRAGMA user_version = 2')
      ..close();
    expect(await copyDatabaseBeforeUpgrade(paths, 2), isNull);
    expect(paths.safetyCopiesDir.existsSync(), isFalse);
  });
}
