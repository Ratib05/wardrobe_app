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