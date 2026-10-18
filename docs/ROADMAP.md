# Development Roadmap

## Status

| Phase | Status |
|---|---|
| 1. Project setup | Done |
| 2. Wardrobe management | Done |
| 3. Outfit management | Done |
| 4. Recommendation engine | Done |
| 5. Wardrobe gap analysis and wishlist | Done |
| 6. Backup and restore | Done |
| 7. Polish and testing | Done in code; the Windows build is being used with a real wardrobe before Phase 8 |
| 8. Android support | Built and tested in code; needs a run on a real device or emulator |

## Phase 1: Project Setup

- Create the Flutter project.
- Configure Git and the private repository.
- Set up Riverpod and go_router.
- Add Drift and configure SQLite.
- Establish the initial folder structure.
- Create basic navigation and application layout.

**Completion criteria:** The app launches and can access a local database.

## Phase 2: Wardrobe Management

- Create the clothing database table.
- Implement repositories and data access.
- Add image storage.
- Build add, edit, archive, and delete workflows.
- Implement wardrobe browsing, search, and filters.

**Completion criteria:** Clothing records and photos persist between app sessions.

## Phase 3: Outfit Management

- Create outfit and outfit-item tables.
- Build the outfit builder.
- Implement save, edit, delete, rating, and favourite features.

**Completion criteria:** Users can create and retrieve outfits from saved clothing.

## Phase 4: Recommendation Engine

- Define outfit templates.
- Implement combination generation.
- Add hard validation rules.
- Implement scoring and ranking.
- Add recommendation explanations.
- Add unit tests for core rules.

**Completion criteria:** Recommendations are deterministic, valid, and explainable.

## Phase 5: Wardrobe Gap Analysis and Wishlist

- Analyse incomplete or constrained outfit combinations.
- Estimate the benefits of potential purchases.
- Build wardrobe gap screens.
- Implement wishlist management.
- Add purchased-item linking.

**Completion criteria:** The app can explain useful potential purchases and track them.

## Phase 6: Backup and Restore

- Implement database snapshotting.
- Create backup archives and manifests.
- Validate archives.
- Implement staged restoration.
- Handle missing images and incompatible versions.
- Test recovery and failure scenarios.

**Completion criteria:** The user can restore a complete wardrobe from a valid backup.

## Phase 7: Polish and Testing

- Improve empty and error states.
- Test common workflows.
- Check performance with a larger wardrobe.
- Test database migrations.
- Review privacy and local-storage behaviour.
- Update README and documentation.

**Completion criteria:** The Windows MVP is stable and documented.

## Phase 8: Android Support

- Test Flutter layouts on Android.
- Adapt photo selection and file handling.
- Validate Android storage behaviour.
- Test backup and restore on mobile.
- Fix platform-specific issues.

**Implemented:** the `android/` platform; cropping after picking or taking a photo (and a Crop button on an existing photo) with `image_cropper`; Take photo / Choose from gallery; backup export through the system save dialog (`file_picker`, whole zip in memory); no `INTERNET` permission and no Android cloud backup or device transfer of app data; phone layouts (bottom bar, filter button, floating add button, one-at-a-time suggestions, Ideas/Wishlist tabs, Settings reached from the Backup page). Widget tests cover the phone behaviour with a fake picker.

**Still to verify by hand:** the camera, crop screen and save dialog on a real device, and a backup made on the phone restoring on Windows (and back).

**Completion criteria:** Core features work on Android using the same codebase.

## Development Priorities

Build a reliable wardrobe manager before investing heavily in recommendation features.

The recommended order is:

1. Local database and clothing records.
2. Image handling.
3. Outfit creation.
4. Basic deterministic recommendations.
5. Wishlist and wardrobe gap analysis.
6. Backup and restore.
7. UI polish and Android support.