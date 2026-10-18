# Personal Wardrobe App

A private, local-first wardrobe management application built with Flutter and Dart. The app helps organise clothing, create outfits, receive outfit recommendations, and identify gaps in a personal wardrobe.

## Features

- **Wardrobe Management** — Catalogue clothing with photos, colours, categories, styles, seasons, occasions, and other attributes.
- **Wardrobe Browsing** — Search, filter, sort, and organise clothing items.
- **Outfit Builder** — Combine clothing items into outfits, save combinations, and mark favourites.
- **Outfit Recommendations** — Generate and rank outfit combinations using deterministic, rule-based logic.
- **Wardrobe Gap Analysis** — Identify potential purchases that could improve outfit combinations.
- **Wishlist** — Track clothing items to consider purchasing, including priorities and budgets.
- **Local Storage** — Keep wardrobe records and photos on the device.
- **Backup and Restore** — Export and restore wardrobe data, including associated images.
- **Offline Support** — Use core features without an internet connection.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application framework |
| Dart | Programming language |
| SQLite | Local database |
| Drift | Type-safe database access and migrations |
| Riverpod | State management |
| go_router | Navigation |
| path_provider | Local application storage paths |
| image_picker | Image selection |
| image_cropper | Image cropping (Android only; not supported on Windows, which has Rotate 90° instead) |
| file_picker | Saving backups through the Android system save dialog |
| image | Photo processing: rotate, resize, strip metadata |
| file_selector, archive | Backup export/import and ZIP handling |
| flutter_test | Unit and widget testing |
| integration_test | Integration testing |

## Architecture

The application follows a layered architecture to separate the user interface, business logic, data access, and file storage.

```text
Flutter UI
    |
    v
Presentation Layer
    |
    v
Domain Layer
    |-- Outfit Generation
    |-- Recommendation Scoring
    |-- Outfit Validation
    |-- Wardrobe Gap Analysis
    |
    v
Data Layer
    |-- Repositories
    |-- Drift DAOs
    |-- SQLite Database
    |
    +--------------------+
    |                    |
    v                    v
SQLite Database     Local Image Storage
    |
    v
Backup and Restore
```

### Storage

- Clothing records, outfits, preferences, and wishlist entries are stored in SQLite.
- Clothing photos are stored as local files rather than database BLOBs.
- Database records reference images using relative paths.
- Database schema changes are managed through Drift migrations.
- Backups include the database, images, and required metadata.

## Recommendation System

The app uses a deterministic recommendation engine rather than AI or machine learning.

The initial scoring model considers:

| Factor | Initial Weight |
|---|---:|
| Colour compatibility | 25% |
| Occasion suitability | 20% |
| Formality consistency | 15% |
| Style compatibility | 15% |
| Season suitability | 10% |
| User preferences | 10% |
| Previous feedback | 5% |

These weights are starting values and may be adjusted during development.

Recommendations should explain why an outfit was suggested. Wardrobe gap analysis evaluates whether a potential purchase could enable useful additional combinations rather than recommending purchases simply because a category is missing.

## Privacy and Design Principles

- Personal and non-commercial use.
- Local-first data storage.
- No mandatory accounts or internet connection.
- No cloud database or backend server.
- No external AI APIs or machine-learning dependencies.
- No automatic clothing recognition. (The edit form does suggest an item's main colour by sampling the pixels of its own photo against a fixed colour table; it does not identify what the item is. It also suggests formality, style and occasions from the words in the item's name, using a fixed keyword table.)
- Explainable outfit recommendations.
- Explicit user control over backups and restoration.

AI coding assistants may be used during development, but the running application does not depend on AI services.

## Getting Started

### Prerequisites

Install the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) — included with Flutter
- [Git](https://git-scm.com/downloads)
- An IDE such as [Visual Studio Code](https://code.visualstudio.com/)

For Windows desktop development, install the required Visual Studio C++ desktop development tools. See the [Flutter Windows setup guide](https://docs.flutter.dev/platform-integration/windows/setup).

### Installation

Clone the repository:

```bash
git clone <repository-url>
cd wardrobe_app
```

Install dependencies:

```bash
flutter pub get
```

Check the development environment:

```bash
flutter doctor
```

### Run the Application

For Windows desktop:

```bash
flutter run -d windows
```

For Android, once Android support is configured and a device or emulator is available:

```bash
flutter run -d android
```

Windows and Android are both configured. The Android build compiles (`flutter build apk`); camera, cropping and the backup save dialog still need a check on a real device or emulator (see `docs/ROADMAP.md`).

## Development Workflow

The project is planned to be developed in the following order:

1. Project setup and local database.
2. Clothing catalogue and image storage.
3. Wardrobe browsing, search, and filtering.
4. Outfit creation and management.
5. Rule-based outfit recommendations.
6. Wardrobe gap analysis and wishlist.
7. Backup and restore.
8. Testing, polish, and Android support.

Refer to `docs/ROADMAP.md` for the detailed development plan.

## Testing

Run all unit and widget tests:

```bash
flutter test
```

Run integration tests (these launch the real app, so a device is required):

```bash
flutter test integration_test/app_test.dart -d windows
```

After changing database tables, regenerate Drift code with `dart run build_runner build`. Schema changes also need a version bump and a migration; see `docs/DATABASE_DESIGN.md`.

## Project Structure

```text
wardrobe_app/
├── docs/                    project documentation
├── lib/
│   ├── app/                 app widget, router, navigation shell, providers, shared widgets
│   ├── core/                value lists, domain models, outfit templates (no Flutter/Drift)
│   ├── database/            Drift tables, DAOs, generated code
│   ├── features/            wardrobe, outfits, recommendations (+ engine/), wishlist, settings (backup, preferences)
│   └── services/            storage paths, image processing, backup and restore, platform pickers
├── test/                    unit, repository and widget tests (mirrors lib/)
├── integration_test/        end-to-end workflows A to D
├── drift_schemas/           committed snapshot of each released database schema
├── windows/                 Windows runner
├── build.yaml               Drift code generation settings
├── pubspec.yaml
├── README.md
└── .gitignore
```

The `android/` folder holds the Android platform. Its manifest has no INTERNET permission and disables Android's automatic cloud backup and device transfer, so the wardrobe only leaves the device through the in-app backup.

## Documentation

Project requirements, architecture, and implementation plans are maintained in the `docs/` directory.

| Document | Description |
|---|---|
| `PROJECT_BRIEF.md` | Project purpose, goals, and scope |
| `PRD.md` | Product and functional requirements |
| `TECHNICAL_ARCHITECTURE.md` | Application architecture and technology choices |
| `DATABASE_DESIGN.md` | Database tables and relationships |
| `LOCAL_STORAGE_SPEC.md` | Local files, images, backups, and restoration |
| `RECOMMENDATION_ENGINE.md` | Outfit generation and scoring rules |
| `UI_UX_SPEC.md` | Screen and interaction requirements |
| `USER_STORIES.md` | User needs and expected functionality |
| `TESTING_PLAN.md` | Testing strategy and acceptance criteria |
| `ROADMAP.md` | Planned development phases |

Instructions and architectural constraints for AI coding assistants are kept in a local, untracked `claude.md` at the repository root (excluded via `.gitignore`).

## Current Status

**Status:** Windows MVP implemented and tested; Android support implemented and built, awaiting a device test.

Wardrobe management, outfits, rule-based recommendations, wardrobe gap analysis, the wishlist, and backup and restore are implemented, with unit, widget and integration tests. The Android target was added after the Windows MVP. Features should be considered implemented only when the corresponding functionality and tests are in place.

## Future Plans

- Complete the Windows desktop MVP.
- Refine recommendation rules and scoring.
- Improve wardrobe gap analysis.
- Test backup and restoration thoroughly.
- Add and validate Android support.
- Improve usability based on personal use.

## License

This project is intended for personal, non-commercial use. A formal open-source licence has not yet been selected.
