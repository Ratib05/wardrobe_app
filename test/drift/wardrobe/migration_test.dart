// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 to v2 renames formality values and keeps all data', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    const ts = "'2026-01-01T00:00:00.000Z'";
    await oldDb.customStatement(
      'INSERT INTO clothing_items (id, name, category, formality, created_at, updated_at) '
      "VALUES ('a', 'Hoodie', 'top', 'loungewear', $ts, $ts), "
      "('b', 'Suit', 'top', 'business', $ts, $ts), "
      "('c', 'Tee', 'top', 'casual', $ts, $ts), "
      "('d', 'Plain', 'top', NULL, $ts, $ts)",
    );
    await oldDb.customStatement(
      'INSERT INTO wishlist_items (id, name, category, formality, created_at, updated_at) '
      "VALUES ('w', 'Blazer', 'outerwear', 'business', $ts, $ts)",
    );
    await oldDb.customStatement(
      'INSERT INTO user_preferences (preference_type, preference_value, created_at) '
      "VALUES ('preferredFormality', 'business', $ts), "
      "('preferredFormality', 'loungewear', $ts), "
      "('preferredColour', 'navy', $ts)",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);

    final items = {
      for (final i in await db.select(db.clothingItems).get()) i.id: i,
    };
    expect(items['a']!.formality, Formality.relaxed);
    expect(items['b']!.formality, Formality.smart);
    expect(items['c']!.formality, Formality.casual);
    expect(items['d']!.formality, isNull);
    expect(items.values.every((i) => !i.hideFromSuggestions), isTrue);
    expect(
      (await db.select(db.wishlistItems).getSingle()).formality,
      Formality.smart,
    );
    final prefs = {
      for (final p in await db.select(db.userPreferences).get())
        p.preferenceValue: p,
    };
    expect(prefs.keys.toSet(), {'smart', 'relaxed', 'navy'});
    expect(prefs['smart']!.weight, isNull);
    await db.close();
  });
}
