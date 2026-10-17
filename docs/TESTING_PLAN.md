# Testing Plan — Personal Wardrobe App

## 1. Objectives

Verify that wardrobe management, outfit creation, recommendations, local storage, and backup/restore work reliably.

## 2. Unit Tests

Test domain logic independently of the UI and database.

Include:
- Clothing attribute validation.
- Outfit composition rules.
- Colour compatibility.
- Occasion and formality rules.
- Season suitability.
- Recommendation scoring.
- Ranking and tie handling.
- Feedback adjustments.
- Wardrobe gap calculations.
- Missing attribute handling.

The recommendation engine should produce reproducible results for identical inputs.

## 3. Database and Repository Tests

Using a test SQLite database, verify:
- Creating, reading, updating, and deleting clothing records.
- Creating and editing outfits.
- Preventing duplicate outfit-item links.
- Foreign-key behaviour.
- Wishlist updates.
- Preference persistence.
- Feedback persistence.
- Archive behaviour.
- Database migration correctness.

## 4. Image Storage Tests

Verify:
- Images can be added and displayed.
- Replacing an image updates the stored reference.
- Missing images produce a placeholder.
- Deleting an item handles associated images correctly.
- Relative paths remain valid after backup restoration.

## 5. Widget Tests

Test:
- Main navigation.
- Wardrobe browsing and filters.
- Clothing forms.
- Outfit builder.
- Recommendation explanations and actions.
- Wishlist operations.
- Backup and restore screens.
- Empty states and error messages.

## 6. Integration Tests

Test complete workflows:

### Workflow A: Add Clothing
1. Open the wardrobe.
2. Add a clothing item.
3. Select an image.
4. Enter attributes.
5. Save the item.
6. Verify that it appears in the wardrobe.

### Workflow B: Create an Outfit
1. Select existing clothing items.
2. Create an outfit.
3. Save it.
4. Reopen it.
5. Verify its items and details.

### Workflow C: Get Recommendations
1. Add a representative wardrobe.
2. Generate recommendations.
3. Verify that invalid combinations are excluded.
4. Verify that explanations match the scoring rules.

### Workflow D: Backup and Restore
1. Create clothing records, outfits, and wishlist entries.
2. Include associated images.
3. Export a backup.
4. Restore into a clean test environment.
5. Verify records, relationships, and images.

Also test invalid archives, unsupported versions, and failed restores.

## 7. Regression Tests

After changing database schemas, recommendation rules, or storage behaviour, rerun relevant tests to ensure existing features continue to work.

## 8. Acceptance Criteria

The MVP must:
- Pass core unit and repository tests.
- Support the primary wardrobe and outfit workflows.
- Generate valid, explainable recommendations.
- Handle missing images gracefully.
- Successfully back up and restore data.
- Reject invalid backups without replacing existing data.
## 9. Running the Tests

```bash
flutter analyze
flutter test                                          # unit, repository and widget tests
flutter test integration_test/app_test.dart -d windows   # end-to-end workflows A to D
```

### What exists
- **Unit tests:** value lists and models, scoring rules, the recommendation engine (determinism, caps, exclusions, explanations), gap analysis, filtering, outfit rules, budget parsing.
- **Repository and database tests:** CRUD for clothing, outfits, wishlist, preferences and feedback; foreign keys, cascades and CHECK constraints; photo replacement and orphan cleanup; image processing (rotation, resizing, metadata removal).
- **Backup and restore tests:** archive contents, manifest, missing photos, tampered paths, invalid and hostile archives, newer versions, damaged databases, and rollback after a failed swap. Live data is checked to be byte-identical after every rejected restore.
- **Widget tests:** navigation (wide and narrow), wardrobe browsing and filters, clothing form, outfit builder, recommendations, wishlist, gap suggestions, preferences and Settings including the restore flow.
- **Integration tests:** Workflow A (add clothing with a photo, restart), B (create and reopen an outfit), C (recommendations exclude unavailable items and give valid explanations), D (back up, restore into a clean install, reject an invalid archive).
- **Guards:** `test/drift/schema_test.dart` fails if the tables no longer match the committed schema snapshot (change `schemaVersion` and add a migration instead); `test/privacy_test.dart` fails on any networking, cloud or analytics usage; `test/performance_test.dart` times filtering, recommendations and gap analysis on a seeded 500-item wardrobe.

### Notes for test authors
- Widget tests run inside Flutter's fake clock; real file and database work needs the helpers in `test/helpers.dart` (`testApp`, `pumpApp`, `pumpUntilFound`, `pumpUntilGone`).
- Seed data through `pumpApp(items: ..., seed: ...)` before the app starts; writing several rows while stream listeners are active stalls under fake time.
