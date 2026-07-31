# Game Stats Tracker - Architecture

## Overview
This Flutter application uses **Riverpod** for state management and **Isar** for a fast, local NoSQL database.

## Directory Structure
- `lib/data/`: Contains the `DatabaseService` and Isar `models/`.
- `lib/providers/`: Contains Riverpod providers that bridge the database and the UI.
- `lib/theme/`: App-wide theme and design tokens.
- `lib/ui/`: Contains all visual elements.
  - `lib/ui/screens/`: High-level page routes.
  - `lib/ui/widgets/`: Reusable, smaller UI components extracted from screens.

## Data Flow
1. **Database Layer (`lib/data/`)**: The `DatabaseService` handles all direct CRUD operations with Isar.
2. **Provider Layer (`lib/providers/`)**: Providers observe streams from `DatabaseService` or call its methods. They expose state to the UI.
3. **UI Layer (`lib/ui/`)**: `ConsumerWidget`s watch providers. When a user interacts (e.g., saves a match), the UI calls a method on a provider or directly on `DatabaseService` via `ref.read(databaseProvider)`.

## Key Concepts
- **Isar Code Generation**: Models (`.dart`) generate `.g.dart` files containing Isar collections and schemas.
- **Reactive UI**: The UI reacts to changes in Isar automatically via Riverpod `StreamProvider`s.
