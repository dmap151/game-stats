# AGENTS.md - Antigravity & AI Developer Guide for Game Stats

This document provides essential instructions, architectural guidelines, and conventions for AI coding agents (Antigravity, Cursor, Copilot, Gemini) working on the **Game Stats** project.

---

## 1. Project Overview & Tech Stack

- **Framework**: Flutter 3.x / Dart 3.x (Null Safe)
- **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) 2.x
- **Database**: [isar](https://pub.dev/packages/isar) 3.1.0+1 (NoSQL embedded fast local database)
- **Styling**: Material 3 Design Tokens (Theme-based, dynamic dark/light)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Hardware & Plugins**: `geolocator` (GPS tagging), `geocoding` (Reverse address lookup), `image_picker` (Photos/Avatars), `url_launcher` (Map links), `shared_preferences` (Persistent local UI states).

---

## 2. Directory Structure

```
lib/
├── data/
│   ├── models/            # Isar database models (*.dart & generated *.g.dart)
│   │   ├── game.dart
│   │   ├── player.dart
│   │   └── match_record.dart
│   └── database_service.dart  # Direct Isar CRUD operations & Stream emitters
├── providers/             # Riverpod StreamProviders, StateProviders, Computed stats
│   ├── providers.dart
│   └── head_to_head_provider.dart
├── services/              # External APIs, Hardware, Location, BGG
│   ├── location_service.dart
│   └── bgg_service.dart
├── theme/                 # AppTheme with Material 3 ColorScheme tokens
│   └── app_theme.dart
├── utils/                 # Pure helper functions & algorithms
│   └── game_image_helper.dart
└── ui/
    ├── screens/           # Main route screens
    └── widgets/           # Reusable atomic UI components
```

---

## 3. Strict Coding Conventions & Rules

### A. State Management (Riverpod)
- Always use `ConsumerWidget` or `ConsumerStatefulWidget` for UI components needing state.
- Do **NOT** invoke `DatabaseService` methods inside `build()` without Riverpod.
- Read database mutations via `ref.read(databaseProvider)`.
- Watch reactive collections via `ref.watch(matchRecordsProvider)`, `ref.watch(playersProvider)`, `ref.watch(gamesProvider)`.

### B. UI Styling & Visual Design
- **Round Avatars**: All avatars and game thumbnails must be circular (`CircleAvatar` + `ClipOval(child: Image.file(...))`).
- **No Hero Animations**: Do not wrap avatar or photo transitions in `Hero` widgets.
- **Image Performance**: Always set `cacheWidth: 100-200` and `gaplessPlayback: true` on `Image.file(...)` to prevent scroll jank and memory spikes.
- **Material 3 Tokens**:
  - Never use hardcoded colors for containers. Use `theme.colorScheme.surfaceContainerHighest`, `primaryContainer`, etc.
  - Never use deprecated `.withOpacity(...)` on Color; use `.withValues(alpha: 0.x)`.
  - Never use deprecated `surfaceVariant`, `background`, or `onBackground`. Use `surfaceContainerHighest` and `surface`.

### C. Database & Schema Changes (Isar)
- Whenever a model in `lib/data/models/` is modified (new field, changed index):
  1. Run `flutter pub run build_runner build --delete-conflicting-outputs` (or use `flutter.bat`).
  2. In the generated `*.g.dart` file, ensure `experimental_member_use, experimental_member_use_from_same_package` is present in `// ignore_for_file:` if analyzer warnings appear.
  3. Ensure `DatabaseService` provides corresponding CRUD methods and streams.

### D. GPS & Hardware Integrations
- GPS coordinates are captured silently in the background on match submission without blocking or delaying the user experience.
- Use `LocationService.getAddress(lat, lng)` to resolve human-readable city names (cached in memory).
- Use `LocationBadge` widget for rendering location chips that open Google Maps / Maps app on tap.

---

## 4. Verification & Validation Commands

Always verify your changes before finishing a task:
- **Code Analysis**: `flutter analyze` (Must pass with 0 errors and 0 warnings).
- **Unit Tests**: `flutter test` (All tests must pass).
- **Code Generation**: `flutter pub run build_runner build --delete-conflicting-outputs`.
- **Debug Build**: `flutter build apk --debug`.
