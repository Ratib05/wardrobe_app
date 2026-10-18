# Product Requirements Document — Personal Wardrobe App

## 1. Purpose

This document defines the requirements for a private, local-first wardrobe management application.

## 2. Product Principles

- **Local-first:** Core functionality works without internet access.
- **Private:** No accounts, cloud synchronisation, or external data collection in the MVP.
- **Explainable:** Recommendations use explicit rules rather than AI or machine learning.
- **Practical:** Prioritise fast wardrobe entry, browsing, and outfit creation.
- **Reliable:** Provide backup and restore functionality.

## 3. Functional Requirements

### FR-01: Clothing Management
Users must be able to create, view, edit, archive, and delete clothing records.

Each item should support:
- Name
- Category and subcategory
- Primary and secondary colours
- Pattern
- Material
- Fit
- Style tags
- Formality
- Suitable seasons
- Suitable occasions
- Brand and size, where applicable
- Condition
- Photo
- Favourite status
- Notes
- Creation and modification dates

Optional attributes must not prevent an item from being saved.

### FR-02: Wardrobe Browsing
Users must be able to:
- View clothing items in a grid or list.
- Search by name.
- Filter by category, colour, style, season, occasion, and formality.
- Sort by name, recently added, or other supported attributes.
- View archived items separately.

### FR-03: Outfit Creation
Users must be able to:
- Select clothing items and combine them into an outfit.
- Save, name, edit, and delete outfits.
- Add notes, occasions, and ratings.
- Mark outfits as favourites.
- View all items belonging to an outfit.

The app should prevent the same clothing item from being added twice to one outfit.

### FR-04: Outfit Recommendations
The app must generate outfit suggestions using clothing items currently available in the wardrobe.

Recommendations must:
- Follow defined outfit composition rules.
- Consider occasion, formality, colour compatibility, style, and season.
- Exclude archived or unavailable items.
- Rank valid combinations.
- Explain the main reasons for each recommendation.
- Allow the user to save, rate, dismiss, or favourite recommendations.

Recommendations must not depend on AI, machine learning, or external services.

### FR-05: Wardrobe Gap Analysis
The app must identify opportunities to improve the range of outfits that can be created.

It should:
- Identify underrepresented clothing categories.
- Detect constraints that prevent common outfit combinations.
- Estimate whether a potential purchase would enable additional combinations.
- Explain why an item may be useful.
- Allow suggested purchases to be added to the wishlist.

Gap analysis must distinguish between a potentially useful purchase and a required purchase. It must not assume that every missing category needs to be filled.

### FR-06: Wishlist
Users must be able to:
- Add items they do not own.
- Record category, colour, style, formality, budget, priority, and notes.
- Mark items as purchased or remove them.
- Link a purchased item to a new wardrobe entry where practical.

### FR-07: Preferences and Feedback
Users should be able to record relevant preferences, such as preferred colours, styles, and formality.

Recommendation feedback may influence future ranking through explicit scoring rules. The application must not train a machine-learning model.

### FR-08: Local Storage
The app must:
- Store structured data in SQLite through Drift.
- Store images as local files.
- Reference images using portable relative paths.
- Work without network access for core features.
- Handle missing images gracefully.

### FR-09: Backup and Restore
Users must be able to export a backup containing the database, images, and required metadata.

Users must be able to restore a valid backup.

The app must validate a backup before replacing existing data and warn users that restoring may replace their current wardrobe.

## 4. Non-Functional Requirements

### Performance
- Common browsing and filtering operations should feel responsive.
- Images should load efficiently.
- Recommendation generation should run locally.

### Reliability
- Database changes must use supported migrations.
- Failed restores must not unnecessarily destroy existing data.
- Missing images must not crash the application.

### Usability
- Clothing entry should require minimal effort.
- Optional attributes should remain optional.
- Recommendation explanations should use understandable language.

### Maintainability
- UI, business logic, data access, and storage services must remain separate.
- Recommendation logic must be independently testable.

### Privacy
- No telemetry or analytics service is required.
- No external AI services or mandatory cloud storage.
- Exporting a backup must be an explicit user action.

## 5. Out of Scope

The MVP will not include:
- AI-based clothing recognition. (Plain pixel-colour sampling to suggest an item's main colour is not recognition and is included.)
- AI-generated outfits.
- Social sharing or public profiles.
- Multiple user accounts.
- Cloud synchronisation.
- Online shopping integrations.
- Automatic web scraping.
- A separate backend or REST API.

## 6. MVP Acceptance Criteria

The MVP is ready when the user can manage a wardrobe, save outfits, receive rule-based recommendations, maintain a wishlist, identify potential wardrobe gaps, and successfully back up and restore all local data.