# Personal Wardrobe App — Project Brief

## 1. Overview

The Personal Wardrobe App is a private, non-commercial application designed to help me catalogue clothing I own, create outfits, receive outfit recommendations, and identify gaps in my wardrobe.

The app will run locally on my devices. It will not require an account, cloud database, external backend, or internet connection for its core features.

## 2. Objectives

- Catalogue clothing using photos and manually entered details.
- Browse, search, sort, and filter wardrobe items.
- Create, save, edit, and rate outfits.
- Generate outfit recommendations using deterministic rules.
- Identify clothing gaps and useful potential purchases.
- Maintain a wishlist of clothing I do not own.
- Keep personal wardrobe data private and locally stored.
- Support reliable backup and restoration.

## 3. Target User

The initial and primary user is me. Multi-user functionality, social features, and commercial distribution are outside the initial scope.

## 4. Core Features

### Wardrobe Management
- Add, edit, archive, and delete clothing items.
- Attach photos to items.
- Record category, colours, style, formality, season, occasion, and other relevant attributes.
- Search and filter the wardrobe.

### Outfit Management
- Combine existing clothing items into outfits.
- Save and name outfits.
- Record occasions, ratings, and notes.
- Revisit and edit saved combinations.

### Outfit Recommendations
- Generate combinations from existing wardrobe items.
- Rank combinations using configurable rules.
- Explain why an outfit is recommended.
- Allow recommendations to be rated or dismissed.

### Wardrobe Gap Analysis
- Identify missing categories or items that could improve outfit combinations.
- Suggest potential purchases based on the current wardrobe.
- Add potential purchases to a wishlist.
- Avoid recommending purchases solely because a category is absent.

### Local Data Management
- Store structured data in SQLite.
- Store images in the app's local storage directory.
- Support exporting a complete backup and restoring it.
- Operate offline for core functionality.

## 5. Technology Stack

- **Language:** Dart
- **Framework:** Flutter
- **Database:** SQLite
- **Database library:** Drift
- **State management:** Riverpod
- **Navigation:** go_router
- **Image handling:** image_picker and image_cropper
- **Local file paths:** path_provider
- **Testing:** flutter_test and integration_test
- **Version control:** Git and a private GitHub repository

The initial development target is Windows desktop, with Android support planned using the same Flutter codebase.

## 6. Constraints

- No AI or machine-learning features inside the application.
- No external AI APIs.
- No cloud database or mandatory online services.
- No authentication system for the single-user MVP.
- No separate backend server or REST API.
- Recommendations must use explainable, deterministic rules.
- Clothing photos must not be stored as large binary objects inside SQLite.

## 7. Privacy and Reliability

All wardrobe data remains on the user's device unless the user explicitly exports or transfers a backup.

The application must provide a backup and restore workflow. The user should be informed when images are missing or data cannot be restored.

## 8. Success Criteria

The MVP is successful when I can:

1. Add clothing items with photos and attributes.
2. Browse and filter my wardrobe.
3. Create and save outfits.
4. Receive useful, explainable outfit recommendations.
5. Identify potential wardrobe gaps.
6. Maintain a wishlist.
7. Back up and restore the complete wardrobe.
8. Use the main features without an internet connection.