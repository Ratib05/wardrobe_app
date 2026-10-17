# Recommendation Engine Specification

## 1. Purpose

Generate useful outfit combinations and wardrobe gap suggestions using deterministic, explainable rules.

No AI, machine learning, or external service is required.

## 2. Inputs

The engine uses:
- Clothing items and their attributes.
- Saved outfits.
- User preferences.
- Recommendation feedback.
- Optional occasion, season, or formality filters.

Archived items must be excluded by default.

## 3. Outfit Generation

1. Select eligible clothing items.
2. Group items by compatible roles, such as tops, bottoms, footwear, and outerwear.
3. Generate candidate combinations.
4. Reject combinations that violate hard constraints.
5. Score the remaining combinations.
6. Rank results.
7. Return the highest-ranked combinations with explanations.

The engine must limit candidate generation to prevent excessive combinations as the wardrobe grows.

## 4. Hard Constraints

Examples include:
- A clothing item cannot appear twice in the same outfit.
- An archived item cannot be recommended.
- Required outfit roles must be present for the selected outfit template.
- Explicitly excluded preferences must be respected when applicable.

Not every outfit requires every possible category. Outfit templates should support different types of combinations.

## 5. Scoring

Use an initial configurable scoring model:

| Factor | Initial Weight |
|---|---:|
| Colour compatibility | 25% |
| Occasion suitability | 20% |
| Formality consistency | 15% |
| Style compatibility | 15% |
| Season suitability | 10% |
| Explicit user preferences | 10% |
| Previous recommendation feedback | 5% |

The weights total 100%. Treat them as starting values that can be tuned through testing.

If a factor is missing, do not automatically penalise an item as though it were incompatible. Apply a documented missing-data rule, such as neutral scoring or reduced confidence.

## 6. Explainability

Each recommendation should identify its strongest reasons, such as:
- Colours are compatible.
- Items suit the selected occasion.
- Formality levels are consistent.
- The combination matches preferred styles.
- The combination is suitable for the selected season.

Explanations must reflect the actual rules used to calculate the score.

## 7. Feedback

Users can save, like, rate, or dismiss recommendations.

Feedback may influence the ranking through explicit rules. For example, repeatedly dismissed combinations can receive a lower score.

Feedback must not train a machine-learning model.

## 8. Wardrobe Gap Analysis

Gap analysis should identify purchases that may unlock useful combinations.

For each potential item:
1. Identify outfit templates that are difficult to complete.
2. Estimate which combinations the item would enable.
3. Evaluate compatibility with existing clothing.
4. Estimate the number and variety of additional valid combinations.
5. Consider the user's stated preferences and budget.
6. Explain why the item could be useful.

A missing category alone is not sufficient evidence that a purchase is necessary.

## 9. Testing

Test:
- Colour compatibility rules.
- Formality and occasion constraints.
- Season handling.
- Missing or incomplete attributes.
- Exclusion of archived items.
- Deterministic scoring and ranking.
- Feedback adjustments.
- Wardrobe gap calculations.
- Edge cases with very small wardrobes.

Identical inputs and preferences should produce reproducible results.
## 10. Implemented Rules (version 1)

Code: `lib/features/recommendations/engine/` (pure Dart; no Flutter, database or service imports, enforced by a test). Where this section differs from the sections above, this section is authoritative.

### Outfit templates
- Top + bottom + footwear, with optional outerwear.
- Dress/jumpsuit + footwear, with optional outerwear.
- Accessories are never generated.

### Eligible items
Not archived, condition not "Needs repair" ("unavailable"), primary colour not in the user's avoided colours, and no avoided style tag.

### Candidate generation
- Each category is capped (15 items; outerwear 6). Favourites are kept first, then items matching the selected occasion, then the selected season, then by id.
- Every combination of a template's required categories is built, once without outerwear and once with each outerwear item.
- A combination is identified by its fingerprint: sorted item ids joined with `|`. Dismissed fingerprints are removed.
- Results are ranked by score (highest first), ties broken by fingerprint, and the top 20 are returned. Identical inputs always give identical output.

### Scoring (each factor 0 to 1; weighted sum)
| Factor (weight) | Rule |
|---|---|
| Colour (25%) | Mean over item pairs of primary colours: either colour neutral 1.0; same colour or same colour family 0.8; clashing pair 0.0; otherwise 0.5. Clashing pairs: red-pink, red-orange, orange-pink, red-green, orange-purple. |
| Occasion (20%) | Occasion selected: mean per item (tagged with it 1.0, tagged without it 0.0, untagged 0.5). None selected: 1.0 if all tagged items share an occasion, else 0.0. |
| Formality (15%) | 1 - (highest level - lowest level) / 4. |
| Style (15%) | Mean over pairs: share a style tag 1.0, else 0.0; a pair with an untagged item 0.5. |
| Season (10%) | Same rule as occasion. |
| Preferences (10%) | Share of items matching a preferred colour, style or formality. |
| Feedback (5%) | Latest rating r gives (r - 1) / 4; otherwise liked, saved, or already a saved outfit gives 1.0. |

**Missing data:** a factor that cannot be judged (fewer than two items with a value, untagged items, no preferences, no feedback) scores a neutral 0.5, so incomplete items are never treated as incompatible.

### Explanations and labels
- A factor supplies a reason only when it scores at least 0.75, and the wording matches the rule that produced it: "Colours are compatible", "All items suit {occasion}" (every item tagged) or "No item conflicts with {occasion}" (some items untagged), "Items share an occasion: {x}", "Formality levels are consistent", "Items share a style: {x}", "Suitable for {season}" / "No item conflicts with {season}" / "Items share a season: {x}", "Matches your preferences", "You rated this {r}/5", "You liked this combination".
- The top three reasons by weighted contribution are shown; if none qualify the card says "Meets the basic outfit rules".
- Labels: 0.75 and above "Strong match", 0.55 and above "Good match", otherwise "Possible match". The score is also shown out of 100 (rounded), with per-factor points (weight × factor value, out of the factor's weight) in the expandable "Why this outfit" section.

### Feedback
- Save creates an outfit and records "saved"; Favourite creates a favourite outfit and records "liked"; Rate records a rating from 1 to 5.
- Dismiss hides that combination permanently. It can be undone immediately, and Settings will offer "Reset dismissed recommendations".

### Differences from the original specification
- "Unavailable" is implemented as condition = "Needs repair".
- Dismissed recommendations are hidden permanently instead of being ranked lower.

## 11. Implemented Gap Analysis (version 1)

Code: `lib/features/recommendations/engine/gap_analysis.dart` (pure Dart).

### Which outfit types are analysed
Only types you actually wear: top + bottom + footwear if you own an available top or bottom, and dress/jumpsuit + footwear if you own an available dress or jumpsuit. If you own none of those, the screen says "Add some clothing first". A missing category alone never produces a suggestion.

### Candidate items
Imaginary items for each category of the active templates (including outerwear, never accessories), in every colour of: neutral colours plus your preferred colours, minus your avoided colours; and in each formality level you already own (casual if none are recorded). Each candidate is added to the wardrobe and the outfits it would appear in are generated with the normal recommendation engine.

### Needed vs. useful
- **Needed:** you cannot complete any outfit today and this item would make at least one possible. All valid outfits it enables are counted, whatever their score, so this works even when attributes are not filled in.
- **Useful:** you can already make outfits and this item would add at least three good outfits (Good or Strong match). Only those good outfits are counted.

### Ordering and limits
Needed first, then by the number of new outfits, then the number of distinct items it would pair with, then your preferred colours, then a fixed key order. At most two suggestions per category and ten overall. Identical inputs give identical results.

### Wishlist interaction
- "Add to wishlist" saves a planned wishlist entry with the explanation as its reason.
- "Not for me" saves the same entry with status "dismissed" (deleting it from the Dismissed tab brings the suggestion back).
- A suggestion is hidden when a wishlist entry of any status has the same category, colour and formality (an entry with one preferred colour matches that colour).

### Differences from the original specification
- Budget does not affect ranking, because imaginary items have no price.
- Dismissed gap suggestions are stored as wishlist entries rather than in a separate table.

### Weights, titles and the outfit check

- **Custom weights:** stored as `user_preferences` rows of type `scoreWeight` (value = factor name, `weight` = relative strength). They are normalised to sum to 1 when read; no rows means the defaults. All-zero or negative weights are rejected.
- **Titles:** a deterministic name from the outfit's average formality (Laid-back, Easy, Crisp, Sharp, Dressy, or Classic when unknown) and its colours (neutral, tonal, colourful, or simple when unknown), for example "Crisp and neutral".
- **Formality filter:** keeps items of the chosen formality and items with none recorded. **Must include** uses the engine's `mustInclude` hook.
- **Valid combinations:** `recommendWithTotal` also returns the number of valid, non-dismissed combinations before the top 20 are cut.
- **Outfit check (builder):** `outfitCheck` scores a hand-built outfit with the same factors and weights (feedback is neutral). Notes are factor reasons (0.75 or more) and weaknesses (below 0.5). `rankShoes` orders shoes by that score and labels them Strong fit, Good fit, Slightly formal or Slightly casual from formality relative to the other chosen items.
