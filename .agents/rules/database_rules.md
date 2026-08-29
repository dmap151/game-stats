# Isar Database & Data Model Rules

## 1. Schema Management
- Models are located in `lib/data/models/`:
  - `Game`: Represents board games (`id`, `name`, `imagePath`).
  - `Player`: Represents players (`id`, `name`, `imagePath`).
  - `MatchRecord`: Represents played matches (`id`, `game`, `date`, `numberOfPlayers`, `imagePath`, `imagePaths`, `playerScores`, `latitude`, `longitude`).
  - `PlayerScore` (`@embedded`): Holds `playerId`, `playerName`, `placement`, `score`.

## 2. Code Generation Trigger
Whenever models in `lib/data/models/` change:
1. Run:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
2. Verify `analysis_options.yaml` has `exclude: ["**/*.g.dart"]` and `experimental_member_use: ignore`.

## 3. DatabaseService Integration
- All direct database operations are encapsulated in `DatabaseService` (`lib/data/database_service.dart`).
- UI layers access `DatabaseService` via `ref.read(databaseProvider)`.
- UI observes live collections via streams provided by `DatabaseService` (`listenToMatches()`, `listenToPlayers()`, `listenToGames()`).
