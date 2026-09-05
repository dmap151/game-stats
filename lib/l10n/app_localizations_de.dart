// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Board Game Stats';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRecord => 'Eintragen';

  @override
  String get navPlayers => 'Spieler';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get globalStatistics => 'Globale Statistiken';

  @override
  String get matchesPlayed => 'Partien gespielt';

  @override
  String get noMatchesRecorded => 'Noch keine Partien erfasst';

  @override
  String get totalRecorded => 'Insgesamt erfasst';

  @override
  String get mostPlayedGame => 'Häufigstes Spiel';

  @override
  String get noMatchesYet => 'Noch keine Partien';

  @override
  String matchesPlayedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Partien gespielt',
      one: '1 Partie gespielt',
    );
    return '$_temp0';
  }

  @override
  String matchCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Partien',
      one: '1 Partie',
    );
    return '$_temp0';
  }

  @override
  String winCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Siege',
      one: '1 Sieg',
    );
    return '$_temp0';
  }

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String get noMatchesRecordedPrompt => 'Noch keine Partien eingetragen.';

  @override
  String get viewFullHistory => 'Gesamte Historie ansehen';

  @override
  String get errorLoadingMatches => 'Fehler beim Laden der Partien';

  @override
  String get manageDataTooltip => 'Einstellungen';

  @override
  String get fullHistory => 'Gesamte Historie';

  @override
  String get errorLoadingHistory => 'Fehler beim Laden der Historie';

  @override
  String get newMatchTitle => 'Ergebnis eintragen';

  @override
  String get editMatchTitle => 'Partie bearbeiten';

  @override
  String get pleaseAddPlayersFirst =>
      'Bitte lege zuerst Spieler im \"Spieler\"-Tab an.';

  @override
  String get gameNameLabel => 'Spielname';

  @override
  String get gameNameValidator => 'Bitte Spielnamen eingeben';

  @override
  String get matchDate => 'Datum der Partie';

  @override
  String get memoryPhoto => 'Erinnerungsfoto (optional)';

  @override
  String get addImage => 'Bild hinzufügen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get coPlayers => 'Mitspieler';

  @override
  String get addAnotherPlayer => 'Weiteren Spieler hinzufügen';

  @override
  String get save => 'Speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get errorEnterPlayerName =>
      'Bitte für jeden Eintrag einen Spielernamen eingeben.';

  @override
  String get matchSavedSuccess => 'Ergebnis gespeichert!';

  @override
  String get matchUpdatedSuccess => 'Änderungen gespeichert!';

  @override
  String get errorLoadingPlayers => 'Fehler beim Laden der Spieler';

  @override
  String get playerNameLabel => 'Spielername';

  @override
  String get playerNameValidator => 'Bitte Name wählen';

  @override
  String get rankLabel => 'Platzierung';

  @override
  String rankValue(Object rank) {
    return '$rank. Platz';
  }

  @override
  String get pointsOptional => 'Punkte (optional)';

  @override
  String get playersTitle => 'Spieler';

  @override
  String get sortPlayersBy => 'Spieler sortieren nach';

  @override
  String get addPlayerTooltip => 'Neuer Spieler';

  @override
  String get noPlayersFound => 'Noch keine Spieler angelegt.';

  @override
  String get comparePlayersTooltip => 'Spieler vergleichen';

  @override
  String get newPlayerDialogTitle => 'Neuen Spieler anlegen';

  @override
  String get playerNameHint => 'Name des Spielers';

  @override
  String get playerCreatedSuccess => 'Spieler erfolgreich erstellt!';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String playerStatsSubtitle(num matches, Object winRate, num wins) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches Partien',
      one: '1 Partie',
    );
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins Siege',
      one: '1 Sieg',
    );
    return '$_temp0 • $_temp1 ($winRate%)';
  }

  @override
  String get libraryTitle => 'Spiele-Bibliothek';

  @override
  String get sortGamesBy => 'Spiele sortieren nach';

  @override
  String get sortTooltip => 'Sortieren';

  @override
  String get noGamesInLibrary => 'Noch keine Spiele in der Bibliothek.';

  @override
  String gameSubtitle(num matches) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches Partien',
      one: '1 Partie',
    );
    return '$_temp0 gespielt';
  }

  @override
  String lastPlayedPrefix(Object date) {
    return ' • Zuletzt $date';
  }

  @override
  String get errorLoadingLibrary => 'Fehler beim Laden der Bibliothek';

  @override
  String get editProfileTooltip => 'Profil bearbeiten';

  @override
  String get deletePlayerTooltip => 'Spieler löschen';

  @override
  String get deletePlayerDialogTitle => 'Spieler löschen?';

  @override
  String get deletePlayerDialogContent =>
      'Möchtest du diesen Spieler wirklich löschen? Historische Partien bleiben erhalten, aber der Spieler wird aus der Auswahlliste entfernt.';

  @override
  String get profileUpdatedSuccess => 'Profil erfolgreich aktualisiert!';

  @override
  String get playerDeletedSuccess => 'Spieler gelöscht';

  @override
  String get matchesCount => 'Partien';

  @override
  String get winsCount => 'Siege';

  @override
  String get winRateLabel => 'Siegquote';

  @override
  String get playedGamesTitle => 'Gespielte Spiele';

  @override
  String get noGamesPlayedYet => 'Noch keine Spiele gespielt.';

  @override
  String get editGameImageTooltip => 'Titelbild bearbeiten';

  @override
  String get deleteMatchDialogTitle => 'Partie löschen?';

  @override
  String get deleteMatchDialogContent =>
      'Möchtest du diese Partie wirklich unwiderruflich löschen?';

  @override
  String get matchDeletedSuccess => 'Partie gelöscht';

  @override
  String get enterMatchTooltip => 'Partie eintragen';

  @override
  String get totalMatches => 'Partien';

  @override
  String get highScoreLabel => 'Highscore';

  @override
  String get avgPointsLabel => 'Ø Punkte';

  @override
  String get playerRankings => 'Spieler-Rangliste';

  @override
  String get scoreDistribution => 'Punkteverlauf';

  @override
  String get matchHistory => 'Partien-Historie';

  @override
  String get bggLink => 'Auf BoardGameGeek ansehen';

  @override
  String get searchOnBgg => 'Auf BoardGameGeek suchen';

  @override
  String get editGameTitle => 'Spiel bearbeiten';

  @override
  String get removeCustomImage => 'Eigenes Bild entfernen';

  @override
  String get imageSource => 'Bildquelle';

  @override
  String get comparePlayersTitle => 'Spieler Vergleich';

  @override
  String get noPlayersAvailable => 'Keine Spieler verfügbar.';

  @override
  String get selectPlayer1 => 'Spieler 1 wählen';

  @override
  String get selectPlayer2 => 'Spieler 2 wählen';

  @override
  String get headToHeadTitle => 'Direkter Vergleich (Head-to-Head)';

  @override
  String get sharedMatches => 'Gemeinsame Partien';

  @override
  String mutualMatchesSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Partien',
      one: '1 Partie',
    );
    return '$_temp0 gegeneinander gespielt';
  }

  @override
  String get leaderLabel => 'Führender';

  @override
  String get tiedLabel => 'Unentschieden';

  @override
  String get noSharedMatches => 'Noch keine gemeinsamen Partien aufgezeichnet.';

  @override
  String get selectBothPlayersPrompt =>
      'Wähle zwei Spieler aus, um deren Statistiken und direkte Duelle zu vergleichen.';

  @override
  String get manageDataTitle => 'Einstellungen & Daten';

  @override
  String get manageDataDescription =>
      'Sichere deine Spieldaten, Spieler und Fotos als Datei oder importiere ein bestehendes Backup von einem anderen Gerät.';

  @override
  String get exportDatabase => 'Datenbank exportieren';

  @override
  String get exportDatabaseSubtitle =>
      'Erstellt ein ZIP-Archiv inklusive Fotos zum Teilen oder Speichern.';

  @override
  String get importDatabase => 'Datenbank importieren';

  @override
  String get importDatabaseSubtitle =>
      'Importiert Spiele, Spieler und Partien aus einem Backup (.zip oder .json).';

  @override
  String get exportSuccess => 'Backup erfolgreich erstellt!';

  @override
  String exportError(Object error) {
    return 'Fehler beim Exportieren: $error';
  }

  @override
  String get importSuccessOverwrite =>
      'Datenbank erfolgreich wiederhergestellt!';

  @override
  String get importSuccessMerge => 'Daten erfolgreich zusammengeführt!';

  @override
  String importError(Object error) {
    return 'Fehler beim Importieren: $error';
  }

  @override
  String get importDialogTitle => 'Backup importieren';

  @override
  String get importDialogContent =>
      'Folgende Daten wurden in der Backup-Datei gefunden:';

  @override
  String get importModeQuestion => 'Wie möchtest du die Daten importieren?';

  @override
  String get merge => 'Zusammenführen';

  @override
  String get overwrite => 'Überschreiben';

  @override
  String get gamesCountLabel => 'Spiele';

  @override
  String get playersCountLabel => 'Spieler';

  @override
  String get matchesCountLabel => 'Partien';

  @override
  String get photosCountLabel => 'Bilder/Fotos';

  @override
  String get createdAtLabel => 'Erstellt am';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get preparingBackup => 'Backup wird vorbereitet & verpackt...';

  @override
  String get importingBackup => 'Backup wird importiert...';

  @override
  String get close => 'Schließen';

  @override
  String get languageSectionTitle => 'Sprache / Language';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get sortNameAsc => 'Name (A–Z)';

  @override
  String get sortNameDesc => 'Name (Z–A)';

  @override
  String get sortMatchesDesc => 'Meiste Partien';

  @override
  String get sortMatchesAsc => 'Wenigste Partien';

  @override
  String get sortWinsDesc => 'Meiste Siege';

  @override
  String get sortWinRateDesc => 'Beste Siegquote';

  @override
  String get sortRecentlyPlayed => 'Zuletzt gespielt';

  @override
  String get sortNewest => 'Neueste zuerst';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get date => 'Datum';

  @override
  String get players => 'Spieler';

  @override
  String get games => 'Spiele';

  @override
  String get rank => 'Platz';

  @override
  String get winner => 'Gewinner';

  @override
  String get score => 'Punkte';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get selectPlayer => 'Spieler auswählen';

  @override
  String playerWon(Object player) {
    return '$player hat gewonnen';
  }

  @override
  String pointsCount(num points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points Punkte',
      one: '1 Punkt',
    );
    return '$_temp0';
  }

  @override
  String get unknownGame => 'Unbekanntes Spiel';

  @override
  String playerCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler',
      one: '1 Spieler',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughChartData =>
      'Nicht genug Daten für ein Diagramm (min. 2 Partien mit Punkten nötig)';
}
