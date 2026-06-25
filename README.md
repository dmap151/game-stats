# Game Stats Tracker 🎲

Eine moderne und übersichtliche Flutter-App für Brettspieler, um Partien, Punkte und Platzierungen festzuhalten und Statistiken über Mitspieler zu generieren.

## 🚀 Features

* **Spiele-Bibliothek:** Übersicht über alle gespielten Brettspiele inklusive Gesamtzahl der gespielten Partien.
* **Match-Historie:** Chronologischer Verlauf jeder gespielten Partie mit Datum, Platzierungen, Punkten und Siegern.
* **Erinnerungsfotos:** Füge optional jeder Partie ein Bild als Erinnerung (direkt per Kamera oder aus der Galerie) hinzu. Das Bild wird in der Historie beim Aufklappen der Partie angezeigt.
* **Spieler-Verwaltung:** Lege Profile für deine Mitspieler an – inklusive persönlicher Profilbilder!
* **Detaillierte Statistiken:** 
  * Globale Win-Rate für jeden Spieler.
  * Anzahl der insgesamt gespielten Partien.
  * Eigener Reiter für Spieler-Rankings (Welcher Spieler gewinnt am häufigsten bei welchem Spiel?).
* **Charts:** Visuelle Darstellung des Punkteverlaufs (Höchstpunktzahlen) in jedem Spiel über die Zeit.
* **Volle Kontrolle:** Partien und Spieler-Profile lassen sich jederzeit nachträglich bearbeiten (Name, Foto) oder löschen. Historische Daten werden beim Umbenennen von Spielern intelligent aktualisiert.

## 🛠️ Technologie-Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Lokale Datenbank:** [Isar Database](https://isar.dev/) für rasend schnelles Speichern und Abfragen lokaler Daten.
* **State Management:** [Riverpod](https://riverpod.dev/) für sicheres und sauberes Zustandsmanagement.
* **Diagramme:** `fl_chart` für die Visualisierung der Punkteverläufe.
* **Design:** Clean, modern, "Card-based" mit leichten Glassmorphism-Akzenten. Optimiert auf Lesbarkeit.

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
