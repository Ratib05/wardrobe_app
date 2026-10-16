# UI/UX Specification

## 1. Design Goals

The application should make it easy to catalogue clothing, see available items, create outfits, and make practical wardrobe decisions.

Prioritise clear navigation, visual browsing, and minimal data entry.

## 2. Main Navigation

The main navigation should include:

- Dashboard
- Wardrobe
- Outfits
- Recommendations
- Wishlist
- Settings

## 3. Dashboard

Display:
- Total active clothing items.
- Recently added items.
- Favourite outfits.
- Suggested outfits.
- Shortcuts to add clothing and create outfits.
- Relevant wardrobe gap suggestions.

Avoid overwhelming the dashboard with statistics.

## 4. Wardrobe Screen

Provide:
- Grid and list views.
- Clothing photos.
- Search.
- Category and attribute filters.
- Sorting.
- An obvious add-item action.
- Access to archived items.

Each item should have a detail screen for editing attributes and managing its photo.

## 5. Add/Edit Clothing

Use a form with:
- Name and category.
- Photo selection.
- Colour and other visual attributes.
- Style and formality.
- Season and occasion.
- Optional brand, size, material, and notes.

Optional fields must not create unnecessary barriers to saving an item.

## 6. Outfit Builder

Allow the user to select items visually and combine them into an outfit.

The interface should show:
- Selected items.
- Item roles, where relevant.
- Validation warnings.
- Save and cancel actions.

Do not require every outfit to use the same rigid combination of clothing categories.

## 7. Recommendations

Each recommendation should show:
- The clothing items included.
- Overall score or ranking where useful.
- A short explanation.
- Actions to save, favourite, rate, or dismiss.

Do not display false precision. A score is a ranking aid, not an objective measure of fashion quality.

## 8. Wishlist and Wardrobe Gaps

Display potential purchases with:
- Name or description.
- Category.
- Reason for the suggestion.
- Expected wardrobe benefit.
- Optional budget and priority.

Allow suggestions to be dismissed or added to the wishlist.

## 9. Settings

Include:
- Backup Wardrobe.
- Restore Wardrobe.
- Storage or backup status where useful.
- App version.
- Data-management options.

Clearly explain that restoration may replace current wardrobe data.

## 10. Empty and Error States

Provide helpful messages when:
- The wardrobe is empty.
- Filters return no results.
- No valid outfit can be generated.
- A photo is missing.
- A backup is invalid.
- A restore operation fails.

## 11. Responsive Layout

Windows is the initial target. Layouts should also accommodate narrower screens so that Android support can be added without redesigning the entire application.