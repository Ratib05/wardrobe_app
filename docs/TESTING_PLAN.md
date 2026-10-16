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