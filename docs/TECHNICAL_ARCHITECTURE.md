# Technical Architecture — Personal Wardrobe App

## 1. Overview

The application uses Flutter for its interface and Dart for its application logic. Drift provides structured access to a local SQLite database.

There is no separate backend. The application accesses local data through repositories and services.

## 2. Architecture

```text
Flutter UI
    |
    v
Presentation Layer
    |-- Screens
    |-- Widgets
    |-- Riverpod providers
    |
    v
Domain Layer
    |-- Business rules
    |-- Outfit generation
    |-- Outfit validation
    |-- Recommendation scoring
    |-- Wardrobe gap analysis
    |
    v
Data Layer
    |-- Repositories
    |-- Drift DAOs
    |-- SQLite database
    |
    +---------------------+
    |                     |
    v                     v
SQLite Database       Local Image Storage
    |
    v
Backup and Restore Services
```

## 3. Technology Choices

- Flutter and Dart: desktop and future Android application.
- Drift and SQLite: local structured storage and schema migrations.
- Riverpod: state management and dependency injection.
- go_router: navigation.
- image_picker: selecting or capturing images where supported.
- image_cropper: cropping images. It does not support Windows, so it is not used in the Windows MVP and is only an optional addition for Android.
- drift_flutter: opens the Drift database on each platform.
- image: decoding, rotating, resizing and re-encoding photos (pure Dart, offline).
- file_selector and archive: choosing backup locations and creating or extracting backup ZIP files.
- package_info_plus: reading the app version for backup manifests.
- path_provider: locating application storage directories.
- uuid: portable identifiers where required.
- flutter_test: unit and widget testing.
- integration_test: end-to-end application testing.

Package versions should be selected and checked for compatibility during implementation.

## 4. Application Layers

### Presentation
Contains screens, reusable widgets, and state-management providers.

The presentation layer must not execute SQL directly or implement recommendation scoring.

### Domain
Contains business rules and application use cases, including:
- Create and update clothing items.
- Build and validate outfits.
- Generate recommendations.
- Calculate recommendation scores.
- Analyse wardrobe gaps.
- Manage preferences and feedback.

The recommendation engine should accept ordinary domain objects and return ranked results. It should not require a database connection to be tested.

### Data
Contains Drift tables, DAOs, repositories, and data mapping.

Repositories provide a consistent interface between application logic and the database.

### Services
Contains file and application-level operations, including:
- Image storage and deletion.
- Backup creation.
- Backup validation and restoration.
- Import/export support where required.

## 5. Database and Images

The database is stored in the platform's application-support directory using path_provider.

Images are stored separately in the application's local files directory. Database records store relative image paths rather than absolute device-specific paths.

Exact storage paths must be resolved at runtime rather than hardcoded.

## 6. Recommendation Engine

The recommendation engine uses deterministic rules.

Its responsibilities include:
1. Selecting eligible wardrobe items.
2. Generating candidate combinations.
3. Rejecting invalid combinations.
4. Scoring valid combinations.
5. Ranking results.
6. Producing explanations for recommendations.

The engine must be independent of the UI and avoid direct database access.

## 7. Error Handling

The app must handle:
- Database read or write failures.
- Invalid or incomplete clothing attributes.
- Missing image files.
- Unsupported backup versions.
- Corrupted backup archives.
- Failed restoration.
- Database migration errors.

Errors should be logged locally where useful and displayed in understandable language. Do not introduce a remote logging service for the MVP.

## 8. Testing Strategy

- Unit tests for domain logic and recommendation scoring.
- Repository tests using a test database.
- Widget tests for key screens and interactions.
- Integration tests for clothing entry, outfit creation, recommendations, and backup/restore.
- Migration tests for database schema changes.

## 9. Architectural Constraints

Do not introduce:
- Supabase or Firebase.
- PostgreSQL servers.
- A Node.js backend.
- REST APIs.
- Docker-based infrastructure.
- Cloud storage or mandatory online accounts.
- AI APIs or machine-learning dependencies.

These constraints may be reconsidered only if the project requirements explicitly change.