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

- Header: a small monospace line "12 ITEMS · 18 OUTFITS", the title "Your wardrobe", a search box (name, colour and brand), an "Import photos" button and an "Add item" button.
- Shelves (landing page, all screen sizes): the Wardrobe tab opens on one shelf per category that has items (empty categories are hidden). Each shelf shows a stack of the newest photos, the category name and "N items". Tapping a shelf opens the grid for that category; "SEE ALL" opens the grid with every item. Setting a search or filter also goes straight to the grid. The archive has no shelves. On phones the total ("24 items") shows under the title; on desktop the header line shows items and outfits.
- Category pills with counts, shown with the grid: a "Shelves" pill (back to the shelves; the phone back button does the same), All, Tops, Bottoms, Dresses, Outerwear, Shoes, Accessories. One category at a time.
- Filter row: Season, Occasion and Sort dropdowns, quick colour chips, each a swatch with its name (White, Black, Navy, Grey, Beige, Olive, Brown), and buttons for more filters (style, formality, favourites, full colour list), grid/list view, and archived items. A "Needs details (N)" chip shows only items with no main colour or no formality.
- Import photos: pick several images (Windows file dialog, Android photo picker), choose one category in a dialog ("N photos selected", Import disabled until a category is chosen), then each photo becomes an item named after its file (`blue_oxford-shirt.jpg` becomes "Blue oxford shirt", up to 80 characters, "Imported item" if nothing is left). Imported items are hidden from suggestions; the user fills in details and unticks "Hide from suggestions" on each. A progress line ("Importing 3 of 12...") shows while it runs, then a message such as "Imported 11 items · 1 skipped (photo.heic)" with a "Show" action that turns on Needs details. Unreadable photos are skipped; the rest are saved in one transaction, so a failed save adds nothing. There is no cropping during import.
- Item cards: photo (or a garment silhouette tinted with the item's colour when there is no photo), name, and a caption such as "TOPS · NAVY · SMART CASUAL" (category, main colour name, formality). Favourite and "hidden from suggestions" markers appear on the photo. A missing photo file shows a "Photo missing" placeholder.
- Narrow screens (under 640 px wide): the title row has import photos and filters buttons (Needs details is a switch in the filters sheet), the search box is a pill, pills scroll sideways, the grid has two columns and the add button is a floating "+".
- There are no "worn" counts: wear tracking is not part of the app.

## 5. Add/Edit Clothing

Implemented to match the design mockups. The header (back link, title, Cancel and Save) stays fixed while the form scrolls.

- Left panel: the photo (or silhouette), "Replace photo" and a rotate button (90 degrees clockwise), a note about where the photo is stored (local, resized to 1600 px, location metadata removed), and two numbers: saved outfits containing the item and valid outfit combinations it can be part of.
- Form: Name and Category (dropdown), Type and Brand (optional), Colours (ordered; the first is the main colour, chips can be made main or removed, "+ Add colour" opens a swatch picker, "Identify from photo" opens the colour finder described below), Formality (five segments), Style, Seasons and Occasions chips, Notes.
- **Colour suggestion:** when a photo is chosen, cropped or rotated, or an item with a photo and no colours is opened (such as an imported one), the form fills the main colour with the closest of the app's colours to the middle of the photo and shows "suggested from photo" beside the Colours label. The suggestion is only made if one colour clearly leads (at least 30% of the middle of the photo), and it never replaces colours the user has chosen. Changing any colour removes the "suggested" label. Saving waits for any suggestion in progress. This is plain pixel sampling against a fixed colour table (CIELAB distance, `lib/core/colour_match.dart`), not recognition of what the item is.- **Identify from photo:** a dialog showing the photo. Tapping a spot shows the nearest colour name in large type with its swatch, and "Could also be: …" when the runner-up is nearly as close. "Use as main colour" puts it first; "Add colour" adds it as another colour. The button is disabled when the item has no photo. It exists because colour names are easier to trust than swatches for users with colour-vision deficiency.
- **Identify from photo:** a dialog showing the photo. Tapping a spot shows the nearest colour name in large type with its swatch, and "Could also be: …" when the runner-up is nearly as close. "Use as main colour" puts it first; "Add colour" adds it as another colour. The button is disabled when the item has no photo. It exists because a colour name is easier to trust than a swatch for someone with colour-vision deficiency.
- **Detail suggestions:** typing the name or type, choosing the category, or opening an item fills Formality, Style and Occasions from a fixed keyword table (`lib/core/item_suggestions.dart`). The first matching rule wins and specific phrases come before generic ones ("dress shoes" before "dress", "polo neck" before "polo", "graphic tee" before "tee"); hyphens are ignored so "tie-dye" never matches "tie"; some rules apply to one category only (an oxford is smart casual as a top, smart as shoes; a cap is streetwear only as an accessory). If nothing matches, nothing is suggested. Rule groups: lounge and pyjamas, activewear, outdoor and weatherproof, formal wear and suits, dress shoes, smart tailoring (blazers, heels), overcoats, knitwear, relaxed (hoodies, joggers, sandals), streetwear, trainers, casual basics (T-shirts, jeans, shorts), smart casual (oxford and button-down shirts, polos, chinos, loafers). Occasions follow formality (Relaxed: Casual, Lounge; Casual: Casual; Smart casual: Casual, Work; Smart: Work, Party; Formal: Work, Formal) unless a rule lists its own. Suggested fields are labelled "suggested from name" (occasions: "suggested from formality"). Only empty fields, or fields that were themselves suggested, are ever filled; a value the user picks or edits is never replaced, and picking a formality fills empty occasions to match. Clearing Formality does not bring the suggestion back. Saving the form confirms the suggestions.- **Formality guide:** a line under the Formality control describes the selected level (for example Smart casual: "A step up from casual: collared shirts, polos, chinos, knitwear, loafers or clean trainers. No tie."). A help button opens "What do these mean?", listing every formality level and style with one plain sentence each.
- "More details" holds pattern, fit, material, size, condition and favourite, so every attribute from the requirements stays available while the main form matches the design.
- "Hide from suggestions (in repair, stored away)" keeps an item out of outfits and recommendations. Archive and Delete item sit beside it (delete asks for confirmation, offers "Archive instead" and says how many outfits are affected).
- Only name and category are required.
- Narrow screens: a single column with Cancel and Save in a bar at the bottom.

## 5a. Outfits List

- Header: "N OUTFITS" (on phones, "N outfits" under the title), the title, and a Favourites toggle.
- Formality pills with counts: All, Relaxed, Casual, Smart casual, Smart, Formal. One at a time, combined with Favourites. An outfit's formality is the rounded average of its items' formality (not stored); outfits whose items have no formality appear only under All.

## 6. Outfit Builder

Implemented. Slots, a picker and a live check, on one screen.

- **Slots:** Outer layer (optional), Top, Bottom, Shoes and Accessory (optional). The "Dress / jumpsuit" switch swaps Top and Bottom for a single Dress slot and clears the items it replaces. Tapping a slot makes it the active one; picking an item fills it and moves on to the next empty required slot. Tapping a chosen item again, or the slot's close button, removes it.
- **Picker:** the available items of the active slot's category. For Shoes the heading is "Choose shoes ordered by fit". Shoes are ranked by the same scoring rules as the recommendations and labelled Strong fit, Good fit, Slightly formal or Slightly casual (formality relative to the other chosen items). With nothing else chosen the shoes are listed by name without labels.
- **Outfit check:** "NN / 100", computed with the recommendation engine's factors and weights (feedback is neutral because the outfit is new). Notes are only what is true: strengths are the factor reasons that scored 0.75 or more, weaknesses are factors below 0.5 ("Red and green may clash" naming the first clashing pair, "Formality levels are far apart", and so on). Missing data is never penalised. Below it, the structural warnings (incomplete outfit, archived items, more than one pair of shoes).
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

## 8. Gaps & Wishlist

Implemented as one page ("Gaps & wishlist" in the sidebar), not separate screens.

- **Ideas:** cards for purchases that would add outfits. Each shows the title (for example "Black casual shoes"), a pill ("Needed" when no complete outfit is possible yet, "Over N outfits" for outerwear, otherwise "+N new outfits"), the explanation (which names the category you are shortest of, for example "You have only 1 pair of shoes for 36 tops and 6 bottoms"), and "Example outfits": up to three complete outfits it would create, best first, as rows of photos. The item to buy is a dashed outline in its colour. "Add to wishlist" stores a planned entry; "Not for me" stores a dismissed one, which hides the idea. Ideas that add fewer than 6 outfits are listed last and get an outlined button instead of a filled one.
- **Plan for:** above the ideas, Occasion and Formality pills (Any plus each value, with a count of your available items), one of each at a time. Picking them re-runs the ideas for that event (for example Work + Smart); with nothing to buy it says "Your wardrobe already covers these outfits." The choice is not saved.
- **Wishlist:** Planned, Purchased and Dismissed filters, then a table: Item (with category), Priority pill, Budget (A$), Unlocks ("+N outfits" the item would make possible, planned entries only) and Note (the reason, else the notes). The row menu keeps Edit, Mark purchased (opens the add-item form prefilled), Mark purchased without adding, Dismiss, Move back to planned and Delete.
- "Add manually" opens the wishlist form. Empty states: "Add some clothing first", "No suggestions right now — your wardrobe covers your outfit types.", "Your wishlist is empty".
- Budget does not affect ranking; hypothetical items have no price.

## 9. Settings

Implemented as a small page reached from the sidebar. Backup and restore have their own page, "Backup & restore": storage tiles (database size, photos size and count, data folder with Open folder), an export card with the suggested file name and approximate size, a restore card that explains the automatic safety copy, and a list of recent backups and safety copies.

- **Score weights:** one slider per scoring factor. Values are relative; the shares shown next to the sliders are rescaled to add up to 100. "Save weights" stores them, "Reset to defaults" restores 25/20/15/15/10/10/5. They apply to Suggestions, the Outfit check in the builder, and the shoe ranking.
- Recommendation preferences (liked and avoided colours and styles, and an "Avoid one-colour outfits" switch that hides suggestions whose top and bottom are the same or a similar colour).
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
### Phone layouts (width under 640 px)

- **Navigation:** a bottom bar (Wardrobe, Outfits, Suggest, Gaps, Backup). Settings is reached from the icon in the Backup page header.
- **Wardrobe:** opens on shelves (see section 4), with the item total under the title; pill search, import photos and filters buttons, a two-column grid and a floating "+" button.
- **Add/Edit item:** one column, with Cancel and Save in a bottom bar. Choosing a photo offers Take photo or Choose from gallery, then the crop screen. A Crop button re-crops the current photo; Rotate 90° is also available.
- **Outfit builder:** one column (slots, picker, outfit check, details).
- **Suggestions:** the filters sit in a collapsed "Filters" panel, and suggestions are shown one per page with a "1 / N" counter and previous/next arrows (swipe also works).
- **Gaps & wishlist:** an Ideas / Wishlist switch instead of both sections.
- **Backup:** tiles and cards stack in one column. Exporting hands the zip to the system save dialog.
