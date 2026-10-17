# UI/UX Specification

## 1. Design Goals

The application should make it easy to catalogue clothing, see available items, create outfits, and make practical wardrobe decisions.

Prioritise clear navigation, visual browsing, and minimal data entry.

## 2. Main Navigation

The main navigation has five destinations: Wardrobe, Outfits, Suggestions, Gaps & wishlist and Backup. A small Settings link sits below them in the sidebar. The sidebar footer reads "Stored on this device" with the age of the last backup.


## 3. Dashboard

There is no dashboard. The app opens on the Wardrobe. (Superseded by the design mockups; the remaining sections are being updated screen by screen to match them.)

## 4. Wardrobe Screen

Implemented to match the design mockups.

- Header: a small monospace line "12 ITEMS · 18 OUTFITS", the title "Your wardrobe", a search box (name, colour and brand) and an "Add item" button.
- Category pills with counts: All, Tops, Bottoms, Dresses, Outerwear, Shoes, Accessories. One category at a time.
- Filter row: Season, Occasion and Sort dropdowns, quick colour swatches (white, black, navy, grey, beige, olive, brown), and buttons for more filters (style, formality, favourites, full colour list), grid/list view, and archived items.
- Item cards: photo (or a garment silhouette tinted with the item's colour when there is no photo), name, and a caption such as "TOPS · SMART CASUAL". Favourite and "hidden from suggestions" markers appear on the photo. A missing photo file shows a "Photo missing" placeholder.
- Narrow screens (under 640 px wide): the title row has a filters button, the search box is a pill, pills scroll sideways, the grid has two columns and the add button is a floating "+".
- There are no "worn" counts: wear tracking is not part of the app.

## 5. Add/Edit Clothing

Implemented to match the design mockups. The header (back link, title, Cancel and Save) stays fixed while the form scrolls.

- Left panel: the photo (or silhouette), "Replace photo" and a rotate button (90 degrees clockwise), a note about where the photo is stored (local, resized to 1600 px, location metadata removed), and two numbers: saved outfits containing the item and valid outfit combinations it can be part of.
- Form: Name and Category (dropdown), Type and Brand (optional), Colours (ordered; the first is the main colour, chips can be made main or removed, "+ Add colour" opens a swatch picker), Formality (five segments), Style, Seasons and Occasions chips, Notes.
- "More details" holds pattern, fit, material, size, condition and favourite, so every attribute from the requirements stays available while the main form matches the design.
- "Hide from suggestions (in repair, stored away)" keeps an item out of outfits and recommendations. Archive and Delete item sit beside it (delete asks for confirmation, offers "Archive instead" and says how many outfits are affected).
- Only name and category are required.
- Narrow screens: a single column with Cancel and Save in a bar at the bottom.

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