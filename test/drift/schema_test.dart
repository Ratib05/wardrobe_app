import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_app/database/app_database.dart';

import 'generated/schema.dart';

/// Fails when the tables in code no longer match the committed snapshot of
/// schema v1 (drift_schemas/). After a deliberate change: bump
/// schemaVersion, run `dart run drift_dev make-migrations`, add the
/// migration step, then regenerate this helper.
void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('current schema matches the committed v1 snapshot', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, db.schemaVersion);
  });
}
