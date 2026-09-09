import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Board Game Stats'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navRecord.
  ///
  /// In de, this message translates to:
  /// **'Eintragen'**
  String get navRecord;

  /// No description provided for @navPlayers.
  ///
  /// In de, this message translates to:
  /// **'Spieler'**
  String get navPlayers;

  /// No description provided for @navLibrary.
  ///
  /// In de, this message translates to:
  /// **'Bibliothek'**
  String get navLibrary;

  /// No description provided for @navCompare.
  ///
  /// In de, this message translates to:
  /// **'Duelle'**
  String get navCompare;

  /// No description provided for @navAccount.
  ///
  /// In de, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @globalStatistics.
  ///
  /// In de, this message translates to:
  /// **'Globale Statistiken'**
  String get globalStatistics;

  /// No description provided for @matchesPlayed.
  ///
  /// In de, this message translates to:
  /// **'Partien gespielt'**
  String get matchesPlayed;

  /// No description provided for @noMatchesRecorded.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Partien erfasst'**
  String get noMatchesRecorded;

  /// No description provided for @totalRecorded.
  ///
  /// In de, this message translates to:
  /// **'Insgesamt erfasst'**
  String get totalRecorded;

  /// No description provided for @mostPlayedGame.
  ///
  /// In de, this message translates to:
  /// **'Häufigstes Spiel'**
  String get mostPlayedGame;

  /// No description provided for @noMatchesYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Partien'**
  String get noMatchesYet;

  /// No description provided for @matchesPlayedCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Partie gespielt} other{{count} Partien gespielt}}'**
  String matchesPlayedCount(num count);

  /// No description provided for @matchCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Partie} other{{count} Partien}}'**
  String matchCount(num count);

  /// No description provided for @winCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Sieg} other{{count} Siege}}'**
  String winCount(num count);

  /// No description provided for @recentlyPlayed.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gespielt'**
  String get recentlyPlayed;

  /// No description provided for @noMatchesRecordedPrompt.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Partien eingetragen.'**
  String get noMatchesRecordedPrompt;

  /// No description provided for @viewFullHistory.
  ///
  /// In de, this message translates to:
  /// **'Gesamte Historie ansehen'**
  String get viewFullHistory;

  /// No description provided for @errorLoadingMatches.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Partien'**
  String get errorLoadingMatches;

  /// No description provided for @manageDataTooltip.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get manageDataTooltip;

  /// No description provided for @fullHistory.
  ///
  /// In de, this message translates to:
  /// **'Gesamte Historie'**
  String get fullHistory;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Historie'**
  String get errorLoadingHistory;

  /// No description provided for @newMatchTitle.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis eintragen'**
  String get newMatchTitle;

  /// No description provided for @editMatchTitle.
  ///
  /// In de, this message translates to:
  /// **'Partie bearbeiten'**
  String get editMatchTitle;

  /// No description provided for @pleaseAddPlayersFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte lege zuerst Spieler im \"Spieler\"-Tab an.'**
  String get pleaseAddPlayersFirst;

  /// No description provided for @gameNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Spielname'**
  String get gameNameLabel;

  /// No description provided for @gameNameValidator.
  ///
  /// In de, this message translates to:
  /// **'Bitte Spielnamen eingeben'**
  String get gameNameValidator;

  /// No description provided for @matchDate.
  ///
  /// In de, this message translates to:
  /// **'Datum der Partie'**
  String get matchDate;

  /// No description provided for @memoryPhoto.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungsfoto (optional)'**
  String get memoryPhoto;

  /// No description provided for @addImage.
  ///
  /// In de, this message translates to:
  /// **'Bild hinzufügen'**
  String get addImage;

  /// No description provided for @takePhoto.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie wählen'**
  String get chooseFromGallery;

  /// No description provided for @coPlayers.
  ///
  /// In de, this message translates to:
  /// **'Mitspieler'**
  String get coPlayers;

  /// No description provided for @addAnotherPlayer.
  ///
  /// In de, this message translates to:
  /// **'Weiteren Spieler hinzufügen'**
  String get addAnotherPlayer;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get saveChanges;

  /// No description provided for @errorEnterPlayerName.
  ///
  /// In de, this message translates to:
  /// **'Bitte für jeden Eintrag einen Spielernamen eingeben.'**
  String get errorEnterPlayerName;

  /// No description provided for @matchSavedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis gespeichert!'**
  String get matchSavedSuccess;

  /// No description provided for @matchUpdatedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Änderungen gespeichert!'**
  String get matchUpdatedSuccess;

  /// No description provided for @errorLoadingPlayers.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Spieler'**
  String get errorLoadingPlayers;

  /// No description provided for @playerNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Spielername'**
  String get playerNameLabel;

  /// No description provided for @playerNameValidator.
  ///
  /// In de, this message translates to:
  /// **'Bitte Name wählen'**
  String get playerNameValidator;

  /// No description provided for @rankLabel.
  ///
  /// In de, this message translates to:
  /// **'Platzierung'**
  String get rankLabel;

  /// No description provided for @rankValue.
  ///
  /// In de, this message translates to:
  /// **'{rank}. Platz'**
  String rankValue(Object rank);

  /// No description provided for @pointsOptional.
  ///
  /// In de, this message translates to:
  /// **'Punkte (optional)'**
  String get pointsOptional;

  /// No description provided for @playersTitle.
  ///
  /// In de, this message translates to:
  /// **'Spieler'**
  String get playersTitle;

  /// No description provided for @sortPlayersBy.
  ///
  /// In de, this message translates to:
  /// **'Spieler sortieren nach'**
  String get sortPlayersBy;

  /// No description provided for @addPlayerTooltip.
  ///
  /// In de, this message translates to:
  /// **'Neuer Spieler'**
  String get addPlayerTooltip;

  /// No description provided for @noPlayersFound.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Spieler angelegt.'**
  String get noPlayersFound;

  /// No description provided for @comparePlayersTooltip.
  ///
  /// In de, this message translates to:
  /// **'Spieler vergleichen'**
  String get comparePlayersTooltip;

  /// No description provided for @newPlayerDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Neuen Spieler anlegen'**
  String get newPlayerDialogTitle;

  /// No description provided for @playerNameHint.
  ///
  /// In de, this message translates to:
  /// **'Name des Spielers'**
  String get playerNameHint;

  /// No description provided for @playerCreatedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Spieler erfolgreich erstellt!'**
  String get playerCreatedSuccess;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @playerStatsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'{matches, plural, =1{1 Partie} other{{matches} Partien}} • {wins, plural, =1{1 Sieg} other{{wins} Siege}} ({winRate}%)'**
  String playerStatsSubtitle(num matches, Object winRate, num wins);

  /// No description provided for @libraryTitle.
  ///
  /// In de, this message translates to:
  /// **'Spiele-Bibliothek'**
  String get libraryTitle;

  /// No description provided for @sortGamesBy.
  ///
  /// In de, this message translates to:
  /// **'Spiele sortieren nach'**
  String get sortGamesBy;

  /// No description provided for @sortTooltip.
  ///
  /// In de, this message translates to:
  /// **'Sortieren'**
  String get sortTooltip;

  /// No description provided for @noGamesInLibrary.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Spiele in der Bibliothek.'**
  String get noGamesInLibrary;

  /// No description provided for @gameSubtitle.
  ///
  /// In de, this message translates to:
  /// **'{matches, plural, =1{1 Partie} other{{matches} Partien}} gespielt'**
  String gameSubtitle(num matches);

  /// No description provided for @lastPlayedPrefix.
  ///
  /// In de, this message translates to:
  /// **' • Zuletzt {date}'**
  String lastPlayedPrefix(Object date);

  /// No description provided for @errorLoadingLibrary.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Bibliothek'**
  String get errorLoadingLibrary;

  /// No description provided for @editProfileTooltip.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get editProfileTooltip;

  /// No description provided for @deletePlayerTooltip.
  ///
  /// In de, this message translates to:
  /// **'Spieler löschen'**
  String get deletePlayerTooltip;

  /// No description provided for @deletePlayerDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Spieler löschen?'**
  String get deletePlayerDialogTitle;

  /// No description provided for @deletePlayerDialogContent.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Spieler wirklich löschen? Historische Partien bleiben erhalten, aber der Spieler wird aus der Auswahlliste entfernt.'**
  String get deletePlayerDialogContent;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Profil erfolgreich aktualisiert!'**
  String get profileUpdatedSuccess;

  /// No description provided for @playerDeletedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Spieler gelöscht'**
  String get playerDeletedSuccess;

  /// No description provided for @matchesCount.
  ///
  /// In de, this message translates to:
  /// **'Partien'**
  String get matchesCount;

  /// No description provided for @winsCount.
  ///
  /// In de, this message translates to:
  /// **'Siege'**
  String get winsCount;

  /// No description provided for @winRateLabel.
  ///
  /// In de, this message translates to:
  /// **'Siegquote'**
  String get winRateLabel;

  /// No description provided for @playedGamesTitle.
  ///
  /// In de, this message translates to:
  /// **'Gespielte Spiele'**
  String get playedGamesTitle;

  /// No description provided for @noGamesPlayedYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Spiele gespielt.'**
  String get noGamesPlayedYet;

  /// No description provided for @editGameImageTooltip.
  ///
  /// In de, this message translates to:
  /// **'Titelbild bearbeiten'**
  String get editGameImageTooltip;

  /// No description provided for @deleteMatchDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Partie löschen?'**
  String get deleteMatchDialogTitle;

  /// No description provided for @deleteMatchDialogContent.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diese Partie wirklich unwiderruflich löschen?'**
  String get deleteMatchDialogContent;

  /// No description provided for @matchDeletedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Partie gelöscht'**
  String get matchDeletedSuccess;

  /// No description provided for @enterMatchTooltip.
  ///
  /// In de, this message translates to:
  /// **'Partie eintragen'**
  String get enterMatchTooltip;

  /// No description provided for @totalMatches.
  ///
  /// In de, this message translates to:
  /// **'Partien'**
  String get totalMatches;

  /// No description provided for @highScoreLabel.
  ///
  /// In de, this message translates to:
  /// **'Highscore'**
  String get highScoreLabel;

  /// No description provided for @avgPointsLabel.
  ///
  /// In de, this message translates to:
  /// **'Ø Punkte'**
  String get avgPointsLabel;

  /// No description provided for @playerRankings.
  ///
  /// In de, this message translates to:
  /// **'Spieler-Rangliste'**
  String get playerRankings;

  /// No description provided for @scoreDistribution.
  ///
  /// In de, this message translates to:
  /// **'Punkteverlauf'**
  String get scoreDistribution;

  /// No description provided for @matchHistory.
  ///
  /// In de, this message translates to:
  /// **'Partien-Historie'**
  String get matchHistory;

  /// No description provided for @bggLink.
  ///
  /// In de, this message translates to:
  /// **'Auf BoardGameGeek ansehen'**
  String get bggLink;

  /// No description provided for @searchOnBgg.
  ///
  /// In de, this message translates to:
  /// **'Auf BoardGameGeek suchen'**
  String get searchOnBgg;

  /// No description provided for @editGameTitle.
  ///
  /// In de, this message translates to:
  /// **'Spiel bearbeiten'**
  String get editGameTitle;

  /// No description provided for @removeCustomImage.
  ///
  /// In de, this message translates to:
  /// **'Eigenes Bild entfernen'**
  String get removeCustomImage;

  /// No description provided for @imageSource.
  ///
  /// In de, this message translates to:
  /// **'Bildquelle'**
  String get imageSource;

  /// No description provided for @comparePlayersTitle.
  ///
  /// In de, this message translates to:
  /// **'Spieler Vergleich'**
  String get comparePlayersTitle;

  /// No description provided for @noPlayersAvailable.
  ///
  /// In de, this message translates to:
  /// **'Keine Spieler verfügbar.'**
  String get noPlayersAvailable;

  /// No description provided for @selectPlayer1.
  ///
  /// In de, this message translates to:
  /// **'Spieler 1 wählen'**
  String get selectPlayer1;

  /// No description provided for @selectPlayer2.
  ///
  /// In de, this message translates to:
  /// **'Spieler 2 wählen'**
  String get selectPlayer2;

  /// No description provided for @headToHeadTitle.
  ///
  /// In de, this message translates to:
  /// **'Direkter Vergleich (Head-to-Head)'**
  String get headToHeadTitle;

  /// No description provided for @sharedMatches.
  ///
  /// In de, this message translates to:
  /// **'Gemeinsame Partien'**
  String get sharedMatches;

  /// No description provided for @mutualMatchesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Partie} other{{count} Partien}} gegeneinander gespielt'**
  String mutualMatchesSubtitle(num count);

  /// No description provided for @leaderLabel.
  ///
  /// In de, this message translates to:
  /// **'Führender'**
  String get leaderLabel;

  /// No description provided for @tiedLabel.
  ///
  /// In de, this message translates to:
  /// **'Unentschieden'**
  String get tiedLabel;

  /// No description provided for @noSharedMatches.
  ///
  /// In de, this message translates to:
  /// **'Noch keine gemeinsamen Partien aufgezeichnet.'**
  String get noSharedMatches;

  /// No description provided for @selectBothPlayersPrompt.
  ///
  /// In de, this message translates to:
  /// **'Wähle zwei Spieler aus, um deren Statistiken und direkte Duelle zu vergleichen.'**
  String get selectBothPlayersPrompt;

  /// No description provided for @manageDataTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen & Daten'**
  String get manageDataTitle;

  /// No description provided for @manageDataDescription.
  ///
  /// In de, this message translates to:
  /// **'Sichere deine Spieldaten, Spieler und Fotos als Datei oder importiere ein bestehendes Backup von einem anderen Gerät.'**
  String get manageDataDescription;

  /// No description provided for @exportDatabase.
  ///
  /// In de, this message translates to:
  /// **'Datenbank exportieren'**
  String get exportDatabase;

  /// No description provided for @exportDatabaseSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstellt ein ZIP-Archiv inklusive Fotos zum Teilen oder Speichern.'**
  String get exportDatabaseSubtitle;

  /// No description provided for @importDatabase.
  ///
  /// In de, this message translates to:
  /// **'Datenbank importieren'**
  String get importDatabase;

  /// No description provided for @importDatabaseSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Importiert Spiele, Spieler und Partien aus einem Backup (.zip oder .json).'**
  String get importDatabaseSubtitle;

  /// No description provided for @exportSuccess.
  ///
  /// In de, this message translates to:
  /// **'Backup erfolgreich erstellt!'**
  String get exportSuccess;

  /// No description provided for @exportError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Exportieren: {error}'**
  String exportError(Object error);

  /// No description provided for @importSuccessOverwrite.
  ///
  /// In de, this message translates to:
  /// **'Datenbank erfolgreich wiederhergestellt!'**
  String get importSuccessOverwrite;

  /// No description provided for @importSuccessMerge.
  ///
  /// In de, this message translates to:
  /// **'Daten erfolgreich zusammengeführt!'**
  String get importSuccessMerge;

  /// No description provided for @importError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Importieren: {error}'**
  String importError(Object error);

  /// No description provided for @importDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Backup importieren'**
  String get importDialogTitle;

  /// No description provided for @importDialogContent.
  ///
  /// In de, this message translates to:
  /// **'Folgende Daten wurden in der Backup-Datei gefunden:'**
  String get importDialogContent;

  /// No description provided for @importModeQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du die Daten importieren?'**
  String get importModeQuestion;

  /// No description provided for @merge.
  ///
  /// In de, this message translates to:
  /// **'Zusammenführen'**
  String get merge;

  /// No description provided for @overwrite.
  ///
  /// In de, this message translates to:
  /// **'Überschreiben'**
  String get overwrite;

  /// No description provided for @gamesCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Spiele'**
  String get gamesCountLabel;

  /// No description provided for @playersCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Spieler'**
  String get playersCountLabel;

  /// No description provided for @matchesCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Partien'**
  String get matchesCountLabel;

  /// No description provided for @photosCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Bilder/Fotos'**
  String get photosCountLabel;

  /// No description provided for @createdAtLabel.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am'**
  String get createdAtLabel;

  /// No description provided for @unknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get unknown;

  /// No description provided for @preparingBackup.
  ///
  /// In de, this message translates to:
  /// **'Backup wird vorbereitet & verpackt...'**
  String get preparingBackup;

  /// No description provided for @importingBackup.
  ///
  /// In de, this message translates to:
  /// **'Backup wird importiert...'**
  String get importingBackup;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @languageSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache / Language'**
  String get languageSectionTitle;

  /// No description provided for @languageSystem.
  ///
  /// In de, this message translates to:
  /// **'Systemstandard'**
  String get languageSystem;

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @themeSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get themeSectionTitle;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @sortNameAsc.
  ///
  /// In de, this message translates to:
  /// **'Name (A–Z)'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In de, this message translates to:
  /// **'Name (Z–A)'**
  String get sortNameDesc;

  /// No description provided for @sortMatchesDesc.
  ///
  /// In de, this message translates to:
  /// **'Meiste Partien'**
  String get sortMatchesDesc;

  /// No description provided for @sortMatchesAsc.
  ///
  /// In de, this message translates to:
  /// **'Wenigste Partien'**
  String get sortMatchesAsc;

  /// No description provided for @sortWinsDesc.
  ///
  /// In de, this message translates to:
  /// **'Meiste Siege'**
  String get sortWinsDesc;

  /// No description provided for @sortWinRateDesc.
  ///
  /// In de, this message translates to:
  /// **'Beste Siegquote'**
  String get sortWinRateDesc;

  /// No description provided for @sortRecentlyPlayed.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gespielt'**
  String get sortRecentlyPlayed;

  /// No description provided for @sortNewest.
  ///
  /// In de, this message translates to:
  /// **'Neueste zuerst'**
  String get sortNewest;

  /// No description provided for @confirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// No description provided for @date.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get date;

  /// No description provided for @players.
  ///
  /// In de, this message translates to:
  /// **'Spieler'**
  String get players;

  /// No description provided for @games.
  ///
  /// In de, this message translates to:
  /// **'Spiele'**
  String get games;

  /// No description provided for @rank.
  ///
  /// In de, this message translates to:
  /// **'Platz'**
  String get rank;

  /// No description provided for @winner.
  ///
  /// In de, this message translates to:
  /// **'Gewinner'**
  String get winner;

  /// No description provided for @score.
  ///
  /// In de, this message translates to:
  /// **'Punkte'**
  String get score;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @selectPlayer.
  ///
  /// In de, this message translates to:
  /// **'Spieler auswählen'**
  String get selectPlayer;

  /// No description provided for @playerWon.
  ///
  /// In de, this message translates to:
  /// **'{player} hat gewonnen'**
  String playerWon(Object player);

  /// No description provided for @pointsCount.
  ///
  /// In de, this message translates to:
  /// **'{points, plural, =1{1 Punkt} other{{points} Punkte}}'**
  String pointsCount(num points);

  /// No description provided for @unknownGame.
  ///
  /// In de, this message translates to:
  /// **'Unbekanntes Spiel'**
  String get unknownGame;

  /// No description provided for @playerCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Spieler} other{{count} Spieler}}'**
  String playerCount(num count);

  /// No description provided for @notEnoughChartData.
  ///
  /// In de, this message translates to:
  /// **'Nicht genug Daten für ein Diagramm (min. 2 Partien mit Punkten nötig)'**
  String get notEnoughChartData;

  /// No description provided for @location.
  ///
  /// In de, this message translates to:
  /// **'Standort'**
  String get location;

  /// No description provided for @locationOptional.
  ///
  /// In de, this message translates to:
  /// **'Standort (optional)'**
  String get locationOptional;

  /// No description provided for @noLocation.
  ///
  /// In de, this message translates to:
  /// **'Kein Standort festgelegt'**
  String get noLocation;

  /// No description provided for @locationAutoDetectedOnSave.
  ///
  /// In de, this message translates to:
  /// **'Wird beim Speichern automatisch erfasst'**
  String get locationAutoDetectedOnSave;

  /// No description provided for @editLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort bearbeiten'**
  String get editLocation;

  /// No description provided for @addLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort hinzufügen'**
  String get addLocation;

  /// No description provided for @deleteLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort löschen'**
  String get deleteLocation;

  /// No description provided for @useCurrentLocation.
  ///
  /// In de, this message translates to:
  /// **'Aktuellen Standort verwenden'**
  String get useCurrentLocation;

  /// No description provided for @searchAddressOrCity.
  ///
  /// In de, this message translates to:
  /// **'Adresse oder Ort suchen'**
  String get searchAddressOrCity;

  /// No description provided for @searchAddressHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Berlin, Marienplatz...'**
  String get searchAddressHint;

  /// No description provided for @manualCoordinates.
  ///
  /// In de, this message translates to:
  /// **'Koordinaten manuell eingeben'**
  String get manualCoordinates;

  /// No description provided for @latitudeLabel.
  ///
  /// In de, this message translates to:
  /// **'Breitengrad (Latitude)'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In de, this message translates to:
  /// **'Längengrad (Longitude)'**
  String get longitudeLabel;

  /// No description provided for @apply.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get apply;

  /// No description provided for @searchingLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort wird gesucht...'**
  String get searchingLocation;

  /// No description provided for @locationNotFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Standort gefunden'**
  String get locationNotFound;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In de, this message translates to:
  /// **'Standortzugriff nicht möglich oder verweigert'**
  String get locationPermissionDenied;

  /// No description provided for @invalidCoordinates.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Koordinaten'**
  String get invalidCoordinates;

  /// No description provided for @useLocation.
  ///
  /// In de, this message translates to:
  /// **'Standort verwenden'**
  String get useLocation;

  /// No description provided for @locationDisabledSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kein Standort für diese Partie'**
  String get locationDisabledSubtitle;

  /// No description provided for @accountLoggedInStatus.
  ///
  /// In de, this message translates to:
  /// **'Angemeldet'**
  String get accountLoggedInStatus;

  /// No description provided for @syncNever.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht synchronisiert'**
  String get syncNever;

  /// No description provided for @cloudActive.
  ///
  /// In de, this message translates to:
  /// **'Supabase Cloud aktiv'**
  String get cloudActive;

  /// No description provided for @yourFriendCode.
  ///
  /// In de, this message translates to:
  /// **'Dein Freundes-Code'**
  String get yourFriendCode;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get copyCodeTooltip;

  /// No description provided for @friendCodeCopied.
  ///
  /// In de, this message translates to:
  /// **'Freundes-Code in Zwischenablage kopiert!'**
  String get friendCodeCopied;

  /// No description provided for @myLocalProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Mein lokales Spielerprofil'**
  String get myLocalProfileTitle;

  /// No description provided for @myLocalProfileDescription.
  ///
  /// In de, this message translates to:
  /// **'Wähle aus, welcher lokale Spieler \"Du\" bist. Bei neuen Partien wirst du automatisch vorausgewählt.'**
  String get myLocalProfileDescription;

  /// No description provided for @noProfileSelected.
  ///
  /// In de, this message translates to:
  /// **'Kein Profil ausgewählt'**
  String get noProfileSelected;

  /// No description provided for @markedAsMe.
  ///
  /// In de, this message translates to:
  /// **'Als \"ICH\" markiert'**
  String get markedAsMe;

  /// No description provided for @tapToSelect.
  ///
  /// In de, this message translates to:
  /// **'Tippe zum Auswählen'**
  String get tapToSelect;

  /// No description provided for @change.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get change;

  /// No description provided for @select.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get select;

  /// No description provided for @friendsSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Freunde & Vernetzung'**
  String get friendsSectionTitle;

  /// No description provided for @friendsSectionDescription.
  ///
  /// In de, this message translates to:
  /// **'Verwalte deine Freunde. Wenn du eine Partie erstellst, kannst du Freunde direkt als Mitspieler auswählen.'**
  String get friendsSectionDescription;

  /// No description provided for @addFriend.
  ///
  /// In de, this message translates to:
  /// **'Freund hinzufügen'**
  String get addFriend;

  /// No description provided for @noFriendsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Freunde hinzugefügt.'**
  String get noFriendsYet;

  /// No description provided for @noFriendsPrompt.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf \"Freund hinzufügen\" und gib den Freundes-Code ein.'**
  String get noFriendsPrompt;

  /// No description provided for @linkedPlayer.
  ///
  /// In de, this message translates to:
  /// **'Verknüpft: {name}'**
  String linkedPlayer(Object name);

  /// No description provided for @linkLocalPlayer.
  ///
  /// In de, this message translates to:
  /// **'Lokalen Spieler verknüpfen'**
  String get linkLocalPlayer;

  /// No description provided for @removeFriendTitle.
  ///
  /// In de, this message translates to:
  /// **'Freundschaft entfernen?'**
  String get removeFriendTitle;

  /// No description provided for @removeFriendPrompt.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du {name} wirklich aus deiner Freundesliste entfernen?'**
  String removeFriendPrompt(Object name);

  /// No description provided for @remove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// No description provided for @syncSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Sync & Cloud-Sicherung'**
  String get syncSectionTitle;

  /// No description provided for @syncSectionDescription.
  ///
  /// In de, this message translates to:
  /// **'Partien, Spieler und Fotos werden automatisch in deiner Cloud gesichert.'**
  String get syncSectionDescription;

  /// No description provided for @syncNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt synchronisieren'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In de, this message translates to:
  /// **'Synchronisiere...'**
  String get syncing;

  /// No description provided for @lastSyncedAt.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt synchronisiert: {time}'**
  String lastSyncedAt(Object time);

  /// No description provided for @signOut.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du dich wirklich abmelden? Deine lokalen Daten bleiben auf diesem Gerät gespeichert.'**
  String get signOutConfirm;

  /// No description provided for @cloudAndFriendsTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto & Cloud-Sync'**
  String get cloudAndFriendsTitle;

  /// No description provided for @cloudAndFriendsDescription.
  ///
  /// In de, this message translates to:
  /// **'Melde dich an, um deine Spielstatistiken online zu sichern, geräteübergreifend abzurufen und Partien mit Freunden zu teilen.'**
  String get cloudAndFriendsDescription;

  /// No description provided for @signInOrRegister.
  ///
  /// In de, this message translates to:
  /// **'Jetzt Anmelden / Registrieren'**
  String get signInOrRegister;

  /// No description provided for @cloudBenefitsTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorteile der Cloud:'**
  String get cloudBenefitsTitle;

  /// No description provided for @cloudBenefit1.
  ///
  /// In de, this message translates to:
  /// **'Sicheres Cloud-Backup für alle Partien und Fotos'**
  String get cloudBenefit1;

  /// No description provided for @cloudBenefit2.
  ///
  /// In de, this message translates to:
  /// **'Synchronisation über mehrere Geräte'**
  String get cloudBenefit2;

  /// No description provided for @cloudBenefit3.
  ///
  /// In de, this message translates to:
  /// **'Freunde hinzufügen und Spielergebnisse verknüpfen'**
  String get cloudBenefit3;

  /// No description provided for @duelsTitle.
  ///
  /// In de, this message translates to:
  /// **'Duell-Modus'**
  String get duelsTitle;

  /// No description provided for @duelsCardDescription.
  ///
  /// In de, this message translates to:
  /// **'Vergleiche zwei Spieler direkt im Head-to-Head und sieh dir an, wer die meisten Siege hat.'**
  String get duelsCardDescription;

  /// No description provided for @comparePlayersAction.
  ///
  /// In de, this message translates to:
  /// **'Spieler vergleichen'**
  String get comparePlayersAction;

  /// No description provided for @selectMyPlayerTitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle dein Spielerprofil'**
  String get selectMyPlayerTitle;

  /// No description provided for @selectMyPlayerSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Dies verknüpft deinen Account mit deinen Statistiken.'**
  String get selectMyPlayerSubtitle;

  /// No description provided for @noLocalPlayersYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine lokalen Spieler vorhanden.'**
  String get noLocalPlayersYet;

  /// No description provided for @enterFriendCodePrompt.
  ///
  /// In de, this message translates to:
  /// **'Gib den Freundes-Code ein (z. B. #NAME-1234):'**
  String get enterFriendCodePrompt;

  /// No description provided for @friendCodeLabel.
  ///
  /// In de, this message translates to:
  /// **'Freundes-Code'**
  String get friendCodeLabel;

  /// No description provided for @invalidOrOwnFriendCode.
  ///
  /// In de, this message translates to:
  /// **'Ungültiger oder eigener Freundes-Code.'**
  String get invalidOrOwnFriendCode;

  /// No description provided for @friendNotFound.
  ///
  /// In de, this message translates to:
  /// **'Profil nicht gefunden.'**
  String get friendNotFound;

  /// No description provided for @friendAddedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Freund hinzugefügt!'**
  String get friendAddedSuccess;

  /// No description provided for @linkPlayerDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Spieler verknüpfen'**
  String get linkPlayerDialogTitle;

  /// No description provided for @linkPlayerDialogSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle einen bestehenden lokalen Spieler aus oder erstelle einen neuen für {name}:'**
  String linkPlayerDialogSubtitle(Object name);

  /// No description provided for @createNewPlayer.
  ///
  /// In de, this message translates to:
  /// **'Neuen Spieler erstellen'**
  String get createNewPlayer;

  /// No description provided for @playerLinkedSuccess.
  ///
  /// In de, this message translates to:
  /// **'Spieler verknüpft!'**
  String get playerLinkedSuccess;

  /// No description provided for @meLabel.
  ///
  /// In de, this message translates to:
  /// **'ICH'**
  String get meLabel;

  /// No description provided for @setAsMe.
  ///
  /// In de, this message translates to:
  /// **'Als \"ICH\" festlegen'**
  String get setAsMe;

  /// No description provided for @playerSetAsMeSuccess.
  ///
  /// In de, this message translates to:
  /// **'{player} ist jetzt als \"ICH\" festgelegt.'**
  String playerSetAsMeSuccess(Object player);

  /// No description provided for @linkWithFriend.
  ///
  /// In de, this message translates to:
  /// **'Mit Freund verknüpfen'**
  String get linkWithFriend;

  /// No description provided for @friendLinked.
  ///
  /// In de, this message translates to:
  /// **'Freund verknüpft'**
  String get friendLinked;

  /// No description provided for @signIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get signUp;

  /// No description provided for @authWelcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück!'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In de, this message translates to:
  /// **'Account erstellen'**
  String get authCreateAccount;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melde dich an, um deine Daten zu synchronisieren.'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstelle einen kostenlosen Account für Cloud-Sync.'**
  String get authSignUpSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine E-Mail-Adresse ein'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail-Adresse ein'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib ein Passwort ein'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Passwort muss mindestens 6 Zeichen lang sein'**
  String get passwordTooShort;

  /// No description provided for @forgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get forgotPassword;

  /// No description provided for @noAccountPrompt.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Account? Jetzt registrieren'**
  String get noAccountPrompt;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bereits registriert? Jetzt anmelden'**
  String get haveAccountPrompt;

  /// No description provided for @signUpSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Account erfolgreich erstellt! Bitte überprüfe deine E-Mails, falls eine Bestätigung nötig ist.'**
  String get signUpSuccessMessage;

  /// No description provided for @signInSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich angemeldet!'**
  String get signInSuccessMessage;

  /// No description provided for @notLinked.
  ///
  /// In de, this message translates to:
  /// **'Nicht verknüpft'**
  String get notLinked;

  /// No description provided for @manageLinkTooltip.
  ///
  /// In de, this message translates to:
  /// **'Verknüpfung verwalten'**
  String get manageLinkTooltip;

  /// No description provided for @linkToLocalPlayerTooltip.
  ///
  /// In de, this message translates to:
  /// **'Mit lokalem Spieler verknüpfen'**
  String get linkToLocalPlayerTooltip;

  /// No description provided for @cleanDuplicates.
  ///
  /// In de, this message translates to:
  /// **'Doppelte Partien bereinigen'**
  String get cleanDuplicates;

  /// No description provided for @duplicatesRemoved.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 doppelte Partie entfernt.} other{{count} doppelte Partien entfernt.}}'**
  String duplicatesRemoved(num count);

  /// No description provided for @noDuplicatesFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Duplikate vorhanden.'**
  String get noDuplicatesFound;

  /// No description provided for @signOutSuccess.
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich abgemeldet.'**
  String get signOutSuccess;

  /// No description provided for @linkFriendTitle.
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" verknüpfen'**
  String linkFriendTitle(Object name);

  /// No description provided for @linkFriendDescription.
  ///
  /// In de, this message translates to:
  /// **'Wähle einen lokalen Spieler aus oder erstelle einen neuen, der mit diesem Freund synchronisiert wird.'**
  String get linkFriendDescription;

  /// No description provided for @createNewPlayerFor.
  ///
  /// In de, this message translates to:
  /// **'Neuen Spieler für \"{name}\" anlegen'**
  String createNewPlayerFor(Object name);

  /// No description provided for @unlinkPlayerFrom.
  ///
  /// In de, this message translates to:
  /// **'Verknüpfung mit \"{name}\" aufheben'**
  String unlinkPlayerFrom(Object name);

  /// No description provided for @alreadyLinkedWith.
  ///
  /// In de, this message translates to:
  /// **'Bereits verknüpft mit {code}'**
  String alreadyLinkedWith(Object code);

  /// No description provided for @duelsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Head-to-Head Statistiken zweier Spieler anzeigen'**
  String get duelsSubtitle;

  /// No description provided for @googleSignInSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich mit Google angemeldet!'**
  String get googleSignInSuccessMessage;

  /// No description provided for @continueWithGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google fortfahren'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In de, this message translates to:
  /// **'ODER'**
  String get orDivider;

  /// No description provided for @continueWithoutSignIn.
  ///
  /// In de, this message translates to:
  /// **'Ohne Anmeldung fortfahren'**
  String get continueWithoutSignIn;

  /// No description provided for @friendRequestsTitle.
  ///
  /// In de, this message translates to:
  /// **'Freundschaftsanfragen'**
  String get friendRequestsTitle;

  /// No description provided for @incomingRequests.
  ///
  /// In de, this message translates to:
  /// **'Eingehende Anfragen'**
  String get incomingRequests;

  /// No description provided for @outgoingRequests.
  ///
  /// In de, this message translates to:
  /// **'Gesendete Anfragen'**
  String get outgoingRequests;

  /// No description provided for @accept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get decline;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In de, this message translates to:
  /// **'Freundschaftsanfrage angenommen!'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestDeclined.
  ///
  /// In de, this message translates to:
  /// **'Freundschaftsanfrage abgelehnt.'**
  String get friendRequestDeclined;

  /// No description provided for @friendRequestSentSuccess.
  ///
  /// In de, this message translates to:
  /// **'Freundschaftsanfrage gesendet!'**
  String get friendRequestSentSuccess;

  /// No description provided for @friendRequestAlreadySent.
  ///
  /// In de, this message translates to:
  /// **'Freundschaftsanfrage bereits gesendet.'**
  String get friendRequestAlreadySent;

  /// No description provided for @alreadyFriends.
  ///
  /// In de, this message translates to:
  /// **'Ihr seid bereits befreundet!'**
  String get alreadyFriends;

  /// No description provided for @cancelRequest.
  ///
  /// In de, this message translates to:
  /// **'Anfrage zurückziehen'**
  String get cancelRequest;

  /// No description provided for @requestPending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get requestPending;

  /// No description provided for @errorLoadingFriends.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Freunde: {error}'**
  String errorLoadingFriends(Object error);

  /// No description provided for @incomingRequestsCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 offene Anfrage} other{{count} offene Anfragen}}'**
  String incomingRequestsCount(num count);

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get refresh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
