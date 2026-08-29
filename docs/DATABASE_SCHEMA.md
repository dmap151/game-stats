# Database Schema Documentation (Isar NoSQL)

## Overview
The application uses [Isar](https://isar.dev) for high-performance, embedded, local NoSQL persistence on mobile devices.

---

## Collections

### 1. `Game` (`lib/data/models/game.dart`)
Represents board games stored in the library.

| Property | Type | Description |
|---|---|---|
| `id` | `Id` (int) | Auto-increment primary key |
| `name` | `String` | Unique indexed game title (`@Index(unique: true)`) |
| `imagePath` | `String?` | Custom uploaded image path (overrides match photos) |

---

### 2. `Player` (`lib/data/models/player.dart`)
Represents registered players.

| Property | Type | Description |
|---|---|---|
| `id` | `Id` (int) | Auto-increment primary key |
| `name` | `String` | Unique indexed player name (`@Index(unique: true)`) |
| `imagePath` | `String?` | Profile avatar image path |

---

### 3. `MatchRecord` (`lib/data/models/match_record.dart`)
Represents a completed match session.

| Property | Type | Description |
|---|---|---|
| `id` | `Id` (int) | Auto-increment primary key |
| `game` | `IsarLink<Game>` | Link to the played Game entity |
| `date` | `DateTime` | Timestamp of the played match |
| `numberOfPlayers` | `int` | Number of participants |
| `imagePath` | `String?` | Primary match photo |
| `imagePaths` | `List<String>` | Additional match photos |
| `playerScores` | `List<PlayerScore>` | List of participant scores and placements |
| `latitude` | `double?` | GPS latitude captured at match creation |
| `longitude` | `double?` | GPS longitude captured at match creation |

---

### 4. `PlayerScore` (`@embedded` in `lib/data/models/match_record.dart`)
Embedded object representing an individual player's performance in a match.

| Property | Type | Description |
|---|---|---|
| `playerId` | `int?` | Foreign ID of the `Player` (or null if manual entry) |
| `playerName` | `String?` | Name of the player |
| `placement` | `int` | Final rank in the match (1 = Winner) |
| `score` | `int?` | Optional numerical score points |
