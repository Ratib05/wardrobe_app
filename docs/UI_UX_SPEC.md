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

Implemented. Slots, a picker and a live check, on one screen.

- **Slots:** Outer layer (optional), Top, Bottom, Shoes and Accessory (optional). The "Dress / jumpsuit" switch swaps Top and Bottom for a single Dress slot and clears the items it replaces. Tapping a slot makes it the active one; picking an item fills it and moves on to the next empty required slot. Tapping a chosen item again, or the slot's close button, removes it.
- **Picker:** the available items of the active slot's category. For Shoes the heading is "Choose shoes ordered by fit". Shoes are ranked by the same scoring rules as the recommendations and labelled Strong fit, Good fit, Slightly formal or Slightly casual (formality relative to the other chosen items). With nothing else chosen the shoes are listed by name without labels.
- **Outfit check:** "NN / 100", computed with the recommendation engine's factors and weights (feedback is neutral because the outfit is new). Notes are only what is true: strengths are the factor reasons that scored 0.75 or more, weaknesses are factors below 0.5 ("Colours may clash", "Formality levels are far apart", and so on). Missing data is never penalised. Below it, the structural warnings (incomplete outfit, archived items, more than one pair of shoes).
- **Details:** name, occasion dropdown (also used by the check), Favourite, Save. Save is enabled only when the outfit is complete for a template (top + bottom + shoes, or dress + shoes; outerwear and accessories optional). Season, rating and notes are not shown in the builder but are kept when an existing outfit is edited.
- **Layout:** two columns at 1000 px and wider (slots, check and details on the left; picker on the right); one column below that.

## 7. Recommendations (Suggestions)

Implemented.

- **Header:** "Suggested outfits", with "Ranked from N valid combinations" (the engine's total before the top 20 are cut).
- **Filters:** Occasion, Season, Formality and Must include (an item that every suggestion must contain), plus a "Show suggestions" button. Changes are applied only when the button is pressed. The formality filter keeps items of that formality and items with no formality recorded.
- **Card:** rank (#1), a generated title such as "Crisp and neutral" (from average formality and the colours), thumbnails with category captions, the score as "90 / 100" with the match label, and "Not for me" and "Save outfit" buttons. There is no wear tracking.
- **Why this outfit** (expandable): seven factor bars with points out of each factor's maximum (for example 23/25, 13/20), the plain-language reasons, and Favourite and Rate.
- **Footer:** "Scores use fixed rules and weights — no data leaves this device. Adjust weights in Settings › Recommendations."
- A score is a ranking aid, not an objective measure of fashion quality.

## 8. Wishlist and Wardrobe Gaps

Display potential purchases with:
- Name or description.
- Category.
- Reason for the suggestion.
- Expected wardrobe benefit.
- Optional budget and priority.

Allow suggestions to be dismissed or added to the wishlist.

## 9. Settings

Implemented as a small page reached from the sidebar. Backup and restore have their own page.

- **Score weights:** one slider per scoring factor. Values are relative; the shares shown next to the sliders are rescaled to add up to 100. "Save weights" stores them, "Reset to defaults" restores 25/20/15/15/10/10/5. They apply to Suggestions, the Outfit check in the builder, and the shoe ranking.
- Recommendation preferences (liked and avoided colours and styles).
- Reset dismissed recommendations.
- App version.

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