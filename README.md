# Game Stats Tracker 🎲

Eine moderne und übersichtliche Flutter-App für Brettspieler, um Partien, Punkte und Platzierungen festzuhalten und Statistiken über Mitspieler zu generieren.

## 🚀 Features

* **Spiele-Bibliothek:** Übersicht über alle gespielten Brettspiele inklusive Gesamtzahl der gespielten Partien und anpassbaren Spiel-Covern.
* **Match-Historie & GPS-Standorte:** Chronologischer Verlauf jeder Partie inklusive Datum, Platzierungen, Punkten, Siegern und automatischem GPS-Standort (mit Direktlink zu Google Maps / Karten-App).
* **Spieler-Vergleich (Head-to-Head):** Vergleiche zwei beliebige Spieler direkt miteinander (Direkte Duelle, Siegquoten, durchschnittliche Platzierungen, gemeinsame Partien).
* **Erinnerungsfotos:** Füge optional jeder Partie Fotos als Erinnerung hinzu.
* **Spieler-Verwaltung:** Profile für Mitspieler mit runden Profilbildern und detaillierten Einzelstatistiken.
* **Charts:** Visuelle Darstellung des Punkteverlaufs in jedem Spiel über die Zeit.

## 📚 Entwickler- & KI-Dokumentation

* 🏗️ [Architektur & Datenfluss](docs/ARCHITECTURE.md)
* 🗄️ [Datenbankschema (Isar)](docs/DATABASE_SCHEMA.md)
* 🛠️ [Entwicklungs- & Test-Workflows](docs/DEVELOPMENT.md)
* 🤖 [KI-Regelwerk (AGENTS.md)](AGENTS.md)

## 🛠️ Technologie-Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart 3, Null-Safe)
* **Lokale Datenbank:** [Isar Database](https://isar.dev/) für rasend schnelles Speichern und Abfragen lokaler Daten.
* **State Management:** [Riverpod 2](https://riverpod.dev/) für sicheres und sauberes Zustandsmanagement.
* **Hardware & Plugins:** `geolocator`, `geocoding`, `url_launcher`, `image_picker`, `fl_chart`.

## 📦 Installation & Kompilierung

### Voraussetzungen
* Installiertes Flutter SDK
* Android Studio oder Visual Studio Code

### Projekt starten

1. **Pakete installieren:**
   ```bash
   flutter pub get
   ```

2. **Isar Code-Generator ausführen:**
   Da das Projekt Isar verwendet, müssen bei jeder Änderung der Datenbankmodelle (`MatchRecord`, `Player`, `Game`) die entsprechenden `.g.dart`-Dateien generiert werden:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   *(Unter Windows/Powershell eventuell `flutter.bat` verwenden)*

3. **App starten (Debug):**
   ```bash
   flutter run
   ```

4. **App als APK exportieren (Release für Android):**
   ```bash
   flutter build apk --release
   ```
   Die generierte APK findest du unter `build\app\outputs\flutter-apk\app-release.apk`.

## 📸 Screenshots & Workflow
*(Hier können Screenshots der App-Ansichten eingefügt werden)*
