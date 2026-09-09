// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Board Game Stats';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRecord => 'Record';

  @override
  String get navPlayers => 'Players';

  @override
  String get navLibrary => 'Library';

  @override
  String get navCompare => 'Duels';

  @override
  String get navAccount => 'Account';

  @override
  String get globalStatistics => 'Global Statistics';

  @override
  String get matchesPlayed => 'Matches Played';

  @override
  String get noMatchesRecorded => 'No matches recorded yet';

  @override
  String get totalRecorded => 'Total recorded';

  @override
  String get mostPlayedGame => 'Most Played Game';

  @override
  String get noMatchesYet => 'No matches yet';

  @override
  String matchesPlayedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches played',
      one: '1 match played',
    );
    return '$_temp0';
  }

  @override
  String matchCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String winCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wins',
      one: '1 win',
    );
    return '$_temp0';
  }

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get noMatchesRecordedPrompt => 'No matches recorded yet.';

  @override
  String get viewFullHistory => 'View full history';

  @override
  String get errorLoadingMatches => 'Error loading matches';

  @override
  String get manageDataTooltip => 'Settings';

  @override
  String get fullHistory => 'Full History';

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get newMatchTitle => 'Record Match';

  @override
  String get editMatchTitle => 'Edit Match';

  @override
  String get pleaseAddPlayersFirst =>
      'Please add players in the \"Players\" tab first.';

  @override
  String get gameNameLabel => 'Game name';

  @override
  String get gameNameValidator => 'Please enter a game name';

  @override
  String get matchDate => 'Match date';

  @override
  String get memoryPhoto => 'Photo (optional)';

  @override
  String get addImage => 'Add image';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get coPlayers => 'Players';

  @override
  String get addAnotherPlayer => 'Add another player';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get errorEnterPlayerName =>
      'Please enter a player name for each entry.';

  @override
  String get matchSavedSuccess => 'Match saved!';

  @override
  String get matchUpdatedSuccess => 'Changes saved!';

  @override
  String get errorLoadingPlayers => 'Error loading players';

  @override
  String get playerNameLabel => 'Player name';

  @override
  String get playerNameValidator => 'Please select a name';

  @override
  String get rankLabel => 'Rank';

  @override
  String rankValue(Object rank) {
    return 'Place $rank';
  }

  @override
  String get pointsOptional => 'Score (optional)';

  @override
  String get playersTitle => 'Players';

  @override
  String get sortPlayersBy => 'Sort players by';

  @override
  String get addPlayerTooltip => 'New player';

  @override
  String get noPlayersFound => 'No players added yet.';

  @override
  String get comparePlayersTooltip => 'Compare players';

  @override
  String get newPlayerDialogTitle => 'Add new player';

  @override
  String get playerNameHint => 'Player name';

  @override
  String get playerCreatedSuccess => 'Player created successfully!';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String playerStatsSubtitle(num matches, Object winRate, num wins) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches matches',
      one: '1 match',
    );
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins wins',
      one: '1 win',
    );
    return '$_temp0 • $_temp1 ($winRate%)';
  }

  @override
  String get libraryTitle => 'Game Library';

  @override
  String get sortGamesBy => 'Sort games by';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get noGamesInLibrary => 'No games in library yet.';

  @override
  String gameSubtitle(num matches) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches matches',
      one: '1 match',
    );
    return '$_temp0 played';
  }

  @override
  String lastPlayedPrefix(Object date) {
    return ' • Last played $date';
  }

  @override
  String get errorLoadingLibrary => 'Error loading library';

  @override
  String get editProfileTooltip => 'Edit profile';

  @override
  String get deletePlayerTooltip => 'Delete player';

  @override
  String get deletePlayerDialogTitle => 'Delete player?';

  @override
  String get deletePlayerDialogContent =>
      'Are you sure you want to delete this player? Historic matches will be preserved, but the player will be removed from selection.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully!';

  @override
  String get playerDeletedSuccess => 'Player deleted';

  @override
  String get matchesCount => 'Matches';

  @override
  String get winsCount => 'Wins';

  @override
  String get winRateLabel => 'Win Rate';

  @override
  String get playedGamesTitle => 'Played Games';

  @override
  String get noGamesPlayedYet => 'No games played yet.';

  @override
  String get editGameImageTooltip => 'Edit cover image';

  @override
  String get deleteMatchDialogTitle => 'Delete match?';

  @override
  String get deleteMatchDialogContent =>
      'Are you sure you want to permanently delete this match?';

  @override
  String get matchDeletedSuccess => 'Match deleted';

  @override
  String get enterMatchTooltip => 'Record match';

  @override
  String get totalMatches => 'Matches';

  @override
  String get highScoreLabel => 'Highscore';

  @override
  String get avgPointsLabel => 'Avg Score';

  @override
  String get playerRankings => 'Player Rankings';

  @override
  String get scoreDistribution => 'Score History';

  @override
  String get matchHistory => 'Match History';

  @override
  String get bggLink => 'View on BoardGameGeek';

  @override
  String get searchOnBgg => 'Search on BoardGameGeek';

  @override
  String get editGameTitle => 'Edit Game';

  @override
  String get removeCustomImage => 'Remove custom image';

  @override
  String get imageSource => 'Image source';

  @override
  String get comparePlayersTitle => 'Compare Players';

  @override
  String get noPlayersAvailable => 'No players available.';

  @override
  String get selectPlayer1 => 'Select Player 1';

  @override
  String get selectPlayer2 => 'Select Player 2';

  @override
  String get headToHeadTitle => 'Head-to-Head Comparison';

  @override
  String get sharedMatches => 'Shared Matches';

  @override
  String mutualMatchesSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0 played against each other';
  }

  @override
  String get leaderLabel => 'Leader';

  @override
  String get tiedLabel => 'Tied';

  @override
  String get noSharedMatches => 'No shared matches recorded yet.';

  @override
  String get selectBothPlayersPrompt =>
      'Select two players to compare their statistics and head-to-head records.';

  @override
  String get manageDataTitle => 'Settings & Data';

  @override
  String get manageDataDescription =>
      'Backup your game data, players and photos to a file or import an existing backup from another device.';

  @override
  String get exportDatabase => 'Export database';

  @override
  String get exportDatabaseSubtitle =>
      'Creates a ZIP archive including photos to share or save.';

  @override
  String get importDatabase => 'Import database';

  @override
  String get importDatabaseSubtitle =>
      'Imports games, players and matches from a backup (.zip or .json).';

  @override
  String get exportSuccess => 'Backup created successfully!';

  @override
  String exportError(Object error) {
    return 'Error exporting: $error';
  }

  @override
  String get importSuccessOverwrite => 'Database restored successfully!';

  @override
  String get importSuccessMerge => 'Data merged successfully!';

  @override
  String importError(Object error) {
    return 'Error importing: $error';
  }

  @override
  String get importDialogTitle => 'Import backup';

  @override
  String get importDialogContent =>
      'The following data was found in the backup file:';

  @override
  String get importModeQuestion => 'How would you like to import the data?';

  @override
  String get merge => 'Merge';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get gamesCountLabel => 'Games';

  @override
  String get playersCountLabel => 'Players';

  @override
  String get matchesCountLabel => 'Matches';

  @override
  String get photosCountLabel => 'Photos';

  @override
  String get createdAtLabel => 'Created at';

  @override
  String get unknown => 'Unknown';

  @override
  String get preparingBackup => 'Preparing & packaging backup...';

  @override
  String get importingBackup => 'Importing backup...';

  @override
  String get close => 'Close';

  @override
  String get languageSectionTitle => 'Language / Sprache';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sortNameAsc => 'Name (A–Z)';

  @override
  String get sortNameDesc => 'Name (Z–A)';

  @override
  String get sortMatchesDesc => 'Most Matches';

  @override
  String get sortMatchesAsc => 'Fewest Matches';

  @override
  String get sortWinsDesc => 'Most Wins';

  @override
  String get sortWinRateDesc => 'Best Win Rate';

  @override
  String get sortRecentlyPlayed => 'Recently Played';

  @override
  String get sortNewest => 'Newest First';

  @override
  String get confirm => 'Confirm';

  @override
  String get date => 'Date';

  @override
  String get players => 'Players';

  @override
  String get games => 'Games';

  @override
  String get rank => 'Rank';

  @override
  String get winner => 'Winner';

  @override
  String get score => 'Score';

  @override
  String get edit => 'Edit';

  @override
  String get selectPlayer => 'Select player';

  @override
  String playerWon(Object player) {
    return '$player has won';
  }

  @override
  String pointsCount(num points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get unknownGame => 'Unknown game';

  @override
  String playerCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Players',
      one: '1 Player',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughChartData =>
      'Not enough data for a chart (at least 2 matches with scores needed)';

  @override
  String get location => 'Location';

  @override
  String get locationOptional => 'Location (optional)';

  @override
  String get noLocation => 'No location set';

  @override
  String get locationAutoDetectedOnSave =>
      'Will be detected automatically on save';

  @override
  String get editLocation => 'Edit location';

  @override
  String get addLocation => 'Add location';

  @override
  String get deleteLocation => 'Delete location';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get searchAddressOrCity => 'Search address or place';

  @override
  String get searchAddressHint => 'e.g. London, Times Square...';

  @override
  String get manualCoordinates => 'Enter coordinates manually';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get apply => 'Apply';

  @override
  String get searchingLocation => 'Searching location...';

  @override
  String get locationNotFound => 'No location found';

  @override
  String get locationPermissionDenied =>
      'Location access unavailable or denied';

  @override
  String get invalidCoordinates => 'Invalid coordinates';

  @override
  String get useLocation => 'Use location';

  @override
  String get locationDisabledSubtitle => 'No location for this match';

  @override
  String get accountLoggedInStatus => 'Signed In';

  @override
  String get syncNever => 'Not yet synchronized';

  @override
  String get cloudActive => 'Supabase Cloud active';

  @override
  String get yourFriendCode => 'Your Friend Code';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get friendCodeCopied => 'Friend code copied to clipboard!';

  @override
  String get myLocalProfileTitle => 'My Local Player Profile';

  @override
  String get myLocalProfileDescription =>
      'Select which local player is \"You\". You will be automatically pre-selected in new matches.';

  @override
  String get noProfileSelected => 'No profile selected';

  @override
  String get markedAsMe => 'Marked as \"ME\"';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get change => 'Change';

  @override
  String get select => 'Select';

  @override
  String get friendsSectionTitle => 'Friends & Connections';

  @override
  String get friendsSectionDescription =>
      'Manage your friends. When creating a match, you can select friends directly as co-players.';

  @override
  String get addFriend => 'Add friend';

  @override
  String get noFriendsYet => 'No friends added yet.';

  @override
  String get noFriendsPrompt =>
      'Tap \"Add friend\" and enter their friend code.';

  @override
  String linkedPlayer(Object name) {
    return 'Linked: $name';
  }

  @override
  String get linkLocalPlayer => 'Link local player';

  @override
  String get removeFriendTitle => 'Remove friend?';

  @override
  String removeFriendPrompt(Object name) {
    return 'Are you sure you want to remove $name from your friends list?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get syncSectionTitle => 'Sync & Cloud Backup';

  @override
  String get syncSectionDescription =>
      'Matches, players, and photos are automatically saved to your cloud.';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing...';

  @override
  String lastSyncedAt(Object time) {
    return 'Last synced: $time';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm =>
      'Are you sure you want to sign out? Your local data will remain saved on this device.';

  @override
  String get cloudAndFriendsTitle => 'Cloud & Friends';

  @override
  String get cloudAndFriendsDescription =>
      'Sign in to back up your game statistics online, access them across devices, and share matches with friends.';

  @override
  String get signInOrRegister => 'Sign In / Register now';

  @override
  String get cloudBenefitsTitle => 'Benefits of the Cloud:';

  @override
  String get cloudBenefit1 => 'Secure cloud backup for all matches and photos';

  @override
  String get cloudBenefit2 => 'Synchronization across multiple devices';

  @override
  String get cloudBenefit3 => 'Add friends and link match results';

  @override
  String get duelsTitle => 'Duel Mode';

  @override
  String get duelsCardDescription =>
      'Compare two players head-to-head and see who has the most wins.';

  @override
  String get comparePlayersAction => 'Compare players';

  @override
  String get selectMyPlayerTitle => 'Select your player profile';

  @override
  String get selectMyPlayerSubtitle =>
      'This links your account with your statistics.';

  @override
  String get noLocalPlayersYet => 'No local players found yet.';

  @override
  String get enterFriendCodePrompt =>
      'Enter the friend code (e.g. #NAME-1234):';

  @override
  String get friendCodeLabel => 'Friend code';

  @override
  String get invalidOrOwnFriendCode => 'Invalid or own friend code.';

  @override
  String get friendNotFound => 'Profile not found.';

  @override
  String get friendAddedSuccess => 'Friend added successfully!';

  @override
  String get linkPlayerDialogTitle => 'Link player';

  @override
  String linkPlayerDialogSubtitle(Object name) {
    return 'Select an existing local player or create a new one for $name:';
  }

  @override
  String get createNewPlayer => 'Create new player';

  @override
  String get playerLinkedSuccess => 'Player linked!';

  @override
  String get meLabel => 'ME';

  @override
  String get setAsMe => 'Set as \"ME\"';

  @override
  String playerSetAsMeSuccess(Object player) {
    return '$player is now set as \"ME\".';
  }

  @override
  String get linkWithFriend => 'Link with friend';

  @override
  String get friendLinked => 'Friend linked';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get authWelcomeBack => 'Welcome back!';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignInSubtitle => 'Sign in to synchronize your data.';

  @override
  String get authSignUpSubtitle => 'Create a free account for cloud sync.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailRequired => 'Please enter an email address';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Sign up now';

  @override
  String get haveAccountPrompt => 'Already have an account? Sign in';

  @override
  String get signUpSuccessMessage =>
      'Account created successfully! Please check your emails if verification is required.';

  @override
  String get signInSuccessMessage => 'Successfully signed in!';

  @override
  String get notLinked => 'Not linked';

  @override
  String get manageLinkTooltip => 'Manage link';

  @override
  String get linkToLocalPlayerTooltip => 'Link to local player';

  @override
  String get cleanDuplicates => 'Clean duplicate matches';

  @override
  String duplicatesRemoved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicate matches removed.',
      one: '1 duplicate match removed.',
    );
    return '$_temp0';
  }

  @override
  String get noDuplicatesFound => 'No duplicates found.';

  @override
  String get signOutSuccess => 'Successfully signed out.';

  @override
  String linkFriendTitle(Object name) {
    return 'Link \"$name\"';
  }

  @override
  String get linkFriendDescription =>
      'Select a local player or create a new one to synchronize with this friend.';

  @override
  String createNewPlayerFor(Object name) {
    return 'Create new player for \"$name\"';
  }

  @override
  String unlinkPlayerFrom(Object name) {
    return 'Unlink from \"$name\"';
  }

  @override
  String alreadyLinkedWith(Object code) {
    return 'Already linked with $code';
  }

  @override
  String get duelsSubtitle => 'View head-to-head statistics of two players';

  @override
  String get googleSignInSuccessMessage =>
      'Successfully signed in with Google!';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'OR';

  @override
  String get continueWithoutSignIn => 'Continue without signing in';
}
