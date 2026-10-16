# Local Storage Specification

## 1. Purpose

Define how the application stores, organises, backs up, and restores wardrobe data.

## 2. Storage Locations

Resolve storage directories through path_provider.

Use an application-support directory for persistent application data and an appropriate application documents or files directory for images.

Conceptually:

```text
Application Data/
├── data/
│   └── wardrobe.db
├── images/
│   ├── clothing/
│   └── outfits/
└── temporary/
```

This is a logical layout, not a hardcoded operating-system path.

## 3. Database Storage

- Store structured data in `wardrobe.db`.
- Access it through Drift.
- Use transactions for multi-step database operations.
- Use Drift migrations when the schema changes.
- Do not store clothing photos as BLOBs.

## 4. Image Storage

- Store images as local files.
- Generate unique, stable filenames.
- Store relative paths in database records.
- Validate file types and handle unsupported images.
- Resize large images when appropriate to limit storage use.
- Use temporary files during image updates, then replace the previous file after a successful operation.
- Handle missing files without crashing.

If an image is replaced or an item is permanently deleted, clean up the old file when it is safe to do so.

## 5. Backup Format

Export a single archive, such as a ZIP file, containing:

```text
wardrobe-backup.zip
├── manifest.json
├── database/
│   └── wardrobe.db
└── images/
    ├── clothing/
    └── outfits/
```

The manifest should record:
- Backup format version.
- Application version, where available.
- Database schema version.
- Backup creation timestamp.
- Required metadata for validation.

The backup must preserve the relative image paths referenced by the database.

## 6. Backup Behaviour

When the user selects **Backup Wardrobe**:

1. Prepare a consistent database snapshot.
2. Collect the associated image files.
3. Create the archive and manifest.
4. Validate that the archive contains the required files.
5. Allow the user to choose where to save it.
6. Report success or failure.

The app should warn users to store backups somewhere safe. A backup saved only on the same device may be lost if that device fails.

## 7. Restore Behaviour

When the user selects **Restore Wardrobe**:

1. Select the backup archive.
2. Validate the archive structure and manifest.
3. Check compatibility with the current app and schema.
4. Extract the backup into a temporary staging directory.
5. Validate the database and referenced image files where practical.
6. Ask for confirmation before replacing current data.
7. Restore the database and images as safely as possible.
8. Verify the restored data and report the result.

A failed validation must not replace the current wardrobe. If restoration fails partway through, preserve or recover the previous data where practical.

The app must warn the user if restoring will replace current records.

## 8. Deletion and Archiving

- Archiving hides an item from normal wardrobe browsing and recommendations without deleting it.
- Permanent deletion requires confirmation.
- Deleting an item must follow the database's defined relationship rules.
- Remove image files only when they are no longer needed by any retained record.

## 9. Offline Operation

Clothing management, outfit creation, recommendations, wishlist management, and backup preparation must not require an internet connection.

## 10. Security and Privacy

- Keep data in local application storage by default.
- Do not upload wardrobe photos or metadata automatically.
- Do not include credentials or unrelated personal files in backups.
- Treat exported backups as private data.
## 11. Implemented Layout and Photo Handling

- All data lives under `getApplicationSupportDirectory()` (see `lib/services/storage_paths.dart`):
  `data/wardrobe.db`, `images/clothing/<uuid>.jpg`, `temporary/`. `temporary/` is emptied at every startup. There is no `images/outfits/` folder because outfit photos are not a planned feature.
- Image paths are resolved through `StoragePaths.imageFile`, which rejects any path outside `images/`.
- Photo import (`lib/services/image_storage.dart`): files over 50 MB are rejected; the image is decoded, rotated upright from its EXIF orientation, shrunk to at most 1600 px on the longest side, stripped of all metadata (including GPS location) and saved as a JPEG (quality 85) in `temporary/`. Saving the item moves it into `images/clothing/` under a new UUID name; a new name per photo version avoids stale image caches.
- Unsupported images produce "This image format isn't supported. Use a JPEG, PNG or WebP photo."
- The old photo file is deleted only after the database write succeeds. If the write fails, the new photo is removed.
- `image_cropper` does not support Windows, so the Windows build has no cropping; grids show a centred crop.
