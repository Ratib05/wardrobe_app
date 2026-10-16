# Database Design — Personal Wardrobe App

## 1. Overview

The application uses SQLite through Drift. It is a single-user application, so a users table and authentication system are unnecessary for the MVP.

Use UUID identifiers for records that may need to be exported or transferred between installations.

Store images as files, not as database BLOBs.

## 2. Tables

### clothing_items

Stores individual wardrobe items.

| Field | Purpose |
|---|---|
| id | Primary key, UUID |
| name | Item name |
| category | Main category |
| subcategory | Optional subcategory |
| primary_colour | Main colour |
| secondary_colours | Optional additional colours |
| pattern | Optional pattern |
| material | Optional material |
| fit | Optional fit |
| style_tags | Style labels |
| formality | Formality level |
| seasons | Suitable seasons |
| occasions | Suitable occasions |
| brand | Optional brand |
| size | Optional size |
| condition | Item condition |
| image_path | Relative path to image |
| is_favourite | Favourite flag |
| is_archived | Archive flag |
| notes | Optional notes |
| created_at | Creation timestamp |
| updated_at | Last modification timestamp |

Use structured columns for frequently filtered attributes. Use JSON or a dedicated related table for multi-valued attributes, following Drift's supported mapping approach. Choose one consistent strategy during implementation.

### outfits

Stores saved outfit combinations.

| Field | Purpose |
|---|---|
| id | Primary key, UUID |
| name | Outfit name |
| occasion | Optional intended occasion |
| season | Optional season |
| rating | Optional user rating |
| is_favourite | Favourite flag |
| notes | Optional notes |
| created_at | Creation timestamp |
| updated_at | Last modification timestamp |

### outfit_items

Links clothing items to outfits.

| Field | Purpose |
|---|---|
| outfit_id | Foreign key to outfits |
| clothing_item_id | Foreign key to clothing_items |
| role | Optional role in the outfit |
| position | Optional display order |

Use a composite primary key on `outfit_id` and `clothing_item_id` to prevent duplicate items in one outfit.

### wishlist_items

Stores potential purchases.

| Field | Purpose |
|---|---|
| id | Primary key, UUID |
| name | Item name or description |
| category | Desired category |
| subcategory | Optional subcategory |
| preferred_colours | Optional colour preferences |
| style_tags | Optional style tags |
| formality | Optional formality level |
| target_price | Optional desired price |
| priority | Purchase priority |
| reason | Why the item may be useful |
| status | Planned, purchased, or dismissed |
| purchased_item_id | Optional link to clothing_items |
| notes | Optional notes |
| created_at | Creation timestamp |
| updated_at | Last modification timestamp |

### user_preferences

Stores explicit user preferences.

| Field | Purpose |
|---|---|
| id | Primary key |
| preference_type | Preference category |
| preference_value | Selected value |
| weight | Optional preference strength |
| created_at | Creation timestamp |
| updated_at | Last modification timestamp |

Examples include preferred styles, colours, formality levels, and excluded preferences.

### recommendation_feedback

Stores feedback on recommendations.

| Field | Purpose |
|---|---|
| id | Primary key, UUID |
| outfit_fingerprint | Identifier for the recommended combination |
| rating | Optional rating |
| feedback_type | Saved, liked, dismissed, or other supported feedback |
| reason | Optional explanation |
| created_at | Feedback timestamp |

An outfit fingerprint should be generated consistently from the sorted identifiers of the clothing items in a combination. Feedback is optional and must not require machine learning.

## 3. Relationships

```text
outfits
   |
   | one-to-many
   v
outfit_items
   ^
   | many-to-one
   |
clothing_items

wishlist_items
   |
   | optional purchased_item_id
   v
clothing_items
```

A clothing item may appear in multiple outfits. An outfit may contain multiple clothing items.

## 4. Data Integrity

- Enable SQLite foreign-key enforcement.
- Prevent duplicate outfit-item relationships.
- Validate required fields before saving.
- Use database transactions for multi-step changes.
- Define deletion behaviour explicitly.
- Avoid leaving outfit records with references to deleted clothing items.
- Prefer archiving items when the user may want to retain historical outfit records.

## 5. Image References

The `image_path` field stores a relative path within the app's image storage directory, for example:

`images/clothing/<item-id>.jpg`

The app must not assume that the image exists. If it is missing, display a placeholder and provide a recovery option.

## 6. Migrations

Use Drift migrations for database schema changes.

- Increment the schema version when the database structure changes.
- Provide migration logic for existing data.
- Test migrations against representative earlier database versions.
- Do not manually edit the live database schema.

## 7. Derived Information

Do not store information that can be reliably calculated from existing records unless there is a clear performance or historical-recording reason.

For example, wardrobe gaps should initially be calculated from the current wardrobe rather than stored in a separate table.

## 8. Implementation Notes

Final column types, indexes, constraints, and Drift table definitions should be confirmed during implementation.

Use indexes for frequently searched or joined fields when testing shows they are beneficial.