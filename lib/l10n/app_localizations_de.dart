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
  String get navCompare => 'Duelle';

  @override
  String get navAccount => 'Account';

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
  String get themeSectionTitle => 'Erscheinungsbild';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

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

  @override
  String get location => 'Standort';

  @override
  String get locationOptional => 'Standort (optional)';

  @override
  String get noLocation => 'Kein Standort festgelegt';

  @override
  String get locationAutoDetectedOnSave =>
      'Wird beim Speichern automatisch erfasst';

  @override
  String get editLocation => 'Standort bearbeiten';

  @override
  String get addLocation => 'Standort hinzufügen';

  @override
  String get deleteLocation => 'Standort löschen';

  @override
  String get useCurrentLocation => 'Aktuellen Standort verwenden';

  @override
  String get searchAddressOrCity => 'Adresse oder Ort suchen';

  @override
  String get searchAddressHint => 'z. B. Berlin, Marienplatz...';

  @override
  String get manualCoordinates => 'Koordinaten manuell eingeben';

  @override
  String get latitudeLabel => 'Breitengrad (Latitude)';

  @override
  String get longitudeLabel => 'Längengrad (Longitude)';

  @override
  String get apply => 'Übernehmen';

  @override
  String get searchingLocation => 'Standort wird gesucht...';

  @override
  String get locationNotFound => 'Kein Standort gefunden';

  @override
  String get locationPermissionDenied =>
      'Standortzugriff nicht möglich oder verweigert';

  @override
  String get invalidCoordinates => 'Ungültige Koordinaten';

  @override
  String get useLocation => 'Standort verwenden';

  @override
  String get locationDisabledSubtitle => 'Kein Standort für diese Partie';

  @override
  String get accountLoggedInStatus => 'Angemeldet';

  @override
  String get syncNever => 'Noch nicht synchronisiert';

  @override
  String get cloudActive => 'Supabase Cloud aktiv';

  @override
  String get yourFriendCode => 'Dein Freundes-Code';

  @override
  String get copyCodeTooltip => 'Code kopieren';

  @override
  String get friendCodeCopied => 'Freundes-Code in Zwischenablage kopiert!';

  @override
  String get myLocalProfileTitle => 'Mein lokales Spielerprofil';

  @override
  String get myLocalProfileDescription =>
      'Wähle aus, welcher lokale Spieler \"Du\" bist. Bei neuen Partien wirst du automatisch vorausgewählt.';

  @override
  String get noProfileSelected => 'Kein Profil ausgewählt';

  @override
  String get markedAsMe => 'Als \"ICH\" markiert';

  @override
  String get tapToSelect => 'Tippe zum Auswählen';

  @override
  String get change => 'Ändern';

  @override
  String get select => 'Auswählen';

  @override
  String get friendsSectionTitle => 'Freunde & Vernetzung';

  @override
  String get friendsSectionDescription =>
      'Verwalte deine Freunde. Wenn du eine Partie erstellst, kannst du Freunde direkt als Mitspieler auswählen.';

  @override
  String get addFriend => 'Freund hinzufügen';

  @override
  String get noFriendsYet => 'Noch keine Freunde hinzugefügt.';

  @override
  String get noFriendsPrompt =>
      'Tippe auf \"Freund hinzufügen\" und gib den Freundes-Code ein.';

  @override
  String linkedPlayer(Object name) {
    return 'Verknüpft: $name';
  }

  @override
  String get linkLocalPlayer => 'Lokalen Spieler verknüpfen';

  @override
  String get removeFriendTitle => 'Freundschaft entfernen?';

  @override
  String removeFriendPrompt(Object name) {
    return 'Möchtest du $name wirklich aus deiner Freundesliste entfernen?';
  }

  @override
  String get remove => 'Entfernen';

  @override
  String get syncSectionTitle => 'Sync & Cloud-Sicherung';

  @override
  String get syncSectionDescription =>
      'Partien, Spieler und Fotos werden automatisch in deiner Cloud gesichert.';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncing => 'Synchronisiere...';

  @override
  String lastSyncedAt(Object time) {
    return 'Zuletzt synchronisiert: $time';
  }

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutConfirm =>
      'Möchtest du dich wirklich abmelden? Deine lokalen Daten bleiben auf diesem Gerät gespeichert.';

  @override
  String get cloudAndFriendsTitle => 'Konto & Cloud-Sync';

  @override
  String get cloudAndFriendsDescription =>
      'Melde dich an, um deine Spielstatistiken online zu sichern, geräteübergreifend abzurufen und Partien mit Freunden zu teilen.';

  @override
  String get signInOrRegister => 'Jetzt Anmelden / Registrieren';

  @override
  String get cloudBenefitsTitle => 'Vorteile der Cloud:';

  @override
  String get cloudBenefit1 =>
      'Sicheres Cloud-Backup für alle Partien und Fotos';

  @override
  String get cloudBenefit2 => 'Synchronisation über mehrere Geräte';

  @override
  String get cloudBenefit3 =>
      'Freunde hinzufügen und Spielergebnisse verknüpfen';

  @override
  String get duelsTitle => 'Duell-Modus';

  @override
  String get duelsCardDescription =>
      'Vergleiche zwei Spieler direkt im Head-to-Head und sieh dir an, wer die meisten Siege hat.';

  @override
  String get comparePlayersAction => 'Spieler vergleichen';

  @override
  String get selectMyPlayerTitle => 'Wähle dein Spielerprofil';

  @override
  String get selectMyPlayerSubtitle =>
      'Dies verknüpft deinen Account mit deinen Statistiken.';

  @override
  String get noLocalPlayersYet => 'Noch keine lokalen Spieler vorhanden.';

  @override
  String get enterFriendCodePrompt =>
      'Gib den Freundes-Code ein (z. B. #NAME-1234):';

  @override
  String get friendCodeLabel => 'Freundes-Code';

  @override
  String get invalidOrOwnFriendCode => 'Ungültiger oder eigener Freundes-Code.';

  @override
  String get friendNotFound => 'Profil nicht gefunden.';

  @override
  String get friendAddedSuccess => 'Freund hinzugefügt!';

  @override
  String get linkPlayerDialogTitle => 'Spieler verknüpfen';

  @override
  String linkPlayerDialogSubtitle(Object name) {
    return 'Wähle einen bestehenden lokalen Spieler aus oder erstelle einen neuen für $name:';
  }

  @override
  String get createNewPlayer => 'Neuen Spieler erstellen';

  @override
  String get playerLinkedSuccess => 'Spieler verknüpft!';

  @override
  String get meLabel => 'ICH';

  @override
  String get setAsMe => 'Als \"ICH\" festlegen';

  @override
  String playerSetAsMeSuccess(Object player) {
    return '$player ist jetzt als \"ICH\" festgelegt.';
  }

  @override
  String get linkWithFriend => 'Mit Freund verknüpfen';

  @override
  String get friendLinked => 'Freund verknüpft';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get authWelcomeBack => 'Willkommen zurück!';

  @override
  String get authCreateAccount => 'Account erstellen';

  @override
  String get authSignInSubtitle =>
      'Melde dich an, um deine Daten zu synchronisieren.';

  @override
  String get authSignUpSubtitle =>
      'Erstelle einen kostenlosen Account für Cloud-Sync.';

  @override
  String get emailLabel => 'E-Mail-Adresse';

  @override
  String get emailRequired => 'Bitte gib eine E-Mail-Adresse ein';

  @override
  String get emailInvalid => 'Bitte gib eine gültige E-Mail-Adresse ein';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get passwordRequired => 'Bitte gib ein Passwort ein';

  @override
  String get passwordTooShort => 'Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get noAccountPrompt => 'Noch kein Account? Jetzt registrieren';

  @override
  String get haveAccountPrompt => 'Bereits registriert? Jetzt anmelden';

  @override
  String get signUpSuccessMessage =>
      'Account erfolgreich erstellt! Bitte überprüfe deine E-Mails, falls eine Bestätigung nötig ist.';

  @override
  String get signInSuccessMessage => 'Erfolgreich angemeldet!';

  @override
  String get notLinked => 'Nicht verknüpft';

  @override
  String get manageLinkTooltip => 'Verknüpfung verwalten';

  @override
  String get linkToLocalPlayerTooltip => 'Mit lokalem Spieler verknüpfen';

  @override
  String get cleanDuplicates => 'Doppelte Partien bereinigen';

  @override
  String duplicatesRemoved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doppelte Partien entfernt.',
      one: '1 doppelte Partie entfernt.',
    );
    return '$_temp0';
  }

  @override
  String get noDuplicatesFound => 'Keine Duplikate vorhanden.';

  @override
  String get signOutSuccess => 'Erfolgreich abgemeldet.';

  @override
  String linkFriendTitle(Object name) {
    return '\"$name\" verknüpfen';
  }

  @override
  String get linkFriendDescription =>
      'Wähle einen lokalen Spieler aus oder erstelle einen neuen, der mit diesem Freund synchronisiert wird.';

  @override
  String createNewPlayerFor(Object name) {
    return 'Neuen Spieler für \"$name\" anlegen';
  }

  @override
  String unlinkPlayerFrom(Object name) {
    return 'Verknüpfung mit \"$name\" aufheben';
  }

  @override
  String alreadyLinkedWith(Object code) {
    return 'Bereits verknüpft mit $code';
  }

  @override
  String get duelsSubtitle =>
      'Head-to-Head Statistiken zweier Spieler anzeigen';

  @override
  String get googleSignInSuccessMessage => 'Erfolgreich mit Google angemeldet!';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get orDivider => 'ODER';

  @override
  String get continueWithoutSignIn => 'Ohne Anmeldung fortfahren';

  @override
  String get friendRequestsTitle => 'Freundschaftsanfragen';

  @override
  String get incomingRequests => 'Eingehende Anfragen';

  @override
  String get outgoingRequests => 'Gesendete Anfragen';

  @override
  String get accept => 'Annehmen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get friendRequestAccepted => 'Freundschaftsanfrage angenommen!';

  @override
  String get friendRequestDeclined => 'Freundschaftsanfrage abgelehnt.';

  @override
  String get friendRequestSentSuccess => 'Freundschaftsanfrage gesendet!';

  @override
  String get friendRequestAlreadySent =>
      'Freundschaftsanfrage bereits gesendet.';

  @override
  String get alreadyFriends => 'Ihr seid bereits befreundet!';

  @override
  String get cancelRequest => 'Anfrage zurückziehen';

  @override
  String get requestPending => 'Ausstehend';

  @override
  String errorLoadingFriends(Object error) {
    return 'Fehler beim Laden der Freunde: $error';
  }

  @override
  String incomingRequestsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Anfragen',
      one: '1 offene Anfrage',
    );
    return '$_temp0';
  }

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get matchInvitationsTitle => 'Partie-Einladungen';

  @override
  String matchInvitationsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Einladungen',
      one: '1 neue Einladung',
    );
    return '$_temp0';
  }

  @override
  String invitedBy(Object name) {
    return 'Eingetragen von $name';
  }

  @override
  String get matchInvitationAccepted =>
      'Partie angenommen und zur Historie hinzugefügt!';

  @override
  String get matchInvitationDeclined => 'Partie-Einladung abgelehnt.';

  @override
  String declineMatchInvitationPrompt(Object game) {
    return 'Möchtest du diese Partie-Einladung für \"$game\" wirklich ablehnen?';
  }

  @override
  String yourPlacement(Object rank) {
    return 'Dein Platz: #$rank';
  }

  @override
  String yourScore(Object score) {
    return '$score Punkte';
  }

  @override
  String get acceptMatch => 'Annehmen';

  @override
  String get declineMatch => 'Ablehnen';

  @override
  String get noMatchInvitations => 'Keine offenen Einladungen';
}
