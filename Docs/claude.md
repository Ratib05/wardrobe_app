# AGENTS.md

## Project Overview

This repository contains a private, non-commercial wardrobe management application built with Flutter and Dart.

The application allows the user to catalogue clothing, create outfits, receive deterministic outfit recommendations, identify wardrobe gaps, manage a wishlist, and back up or restore local data.

## Required Technology Stack

Use:
- Flutter and Dart.
- SQLite through Drift.
- Riverpod for state management.
- go_router for navigation.
- path_provider for local application directories.
- image_picker and image_cropper for image handling where appropriate.
- flutter_test and integration_test for testing.

Check package compatibility before adding dependencies.

## Architectural Rules

- Keep UI, business logic, data access, and storage services separate.
- Use repositories for data access.
- Use Drift DAOs for database operations.
- Do not access SQL directly from widgets.
- Keep the recommendation engine independent of UI code and database access.
- Use Drift migrations for schema changes.
- Store images as files, not database BLOBs.
- Store relative image paths in the database.
- Use transactions for operations that change multiple related records.

## Explicit Restrictions

Do not introduce:
- Supabase.
- Firebase.
- PostgreSQL servers.
- Node.js backends.
- REST APIs.
- Docker infrastructure.
- Cloud synchronisation.
- External AI APIs.
- Machine-learning models.
- Automatic image recognition.

Do not add unnecessary dependencies or infrastructure. The core application must work offline.

AI coding tools may be used during development, but the running application must not depend on AI services.

## Coding Standards

- Prefer clear, readable Dart code.
- Use descriptive names.
- Keep functions focused.
- Avoid unnecessary abstractions.
- Follow existing project conventions.
- Handle errors explicitly.
- Avoid silently discarding user data.
- Do not hardcode platform-specific storage paths.
- Do not commit private wardrobe photos, database files, or personal backups to Git.

## Testing Requirements

- Add unit tests for new business rules.
- Test recommendation logic independently.
- Add repository tests for database changes.
- Add widget tests for significant UI changes.
- Test backup and restore behaviour when modifying storage code.
- Run relevant tests before declaring work complete.

## Documentation

When changing architecture, data structures, recommendation rules, or storage behaviour, update the relevant documents in `docs/`.

Do not claim a feature is implemented unless the code and tests support that claim.

## Implementation Workflow

Before making a substantial change:
1. Review the relevant documentation.
2. Identify the affected components.
3. Implement the smallest coherent change.
4. Add or update tests.
5. Update documentation if required.
6. Summarise the changes and any remaining limitations.