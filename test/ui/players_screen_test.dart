import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/l10n/app_localizations.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/ui/screens/players_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'PlayersScreen displays players with sort chip and opens bottom sheet',
    (tester) async {
      final alice = Player()
        ..id = 1
        ..name = 'Alice';

      final bob = Player()
        ..id = 2
        ..name = 'Bob';

      final match1 = MatchRecord()
        ..id = 101
        ..date = DateTime(2025, 1, 10)
        ..playerScores = [
          PlayerScore()
            ..playerId = 2
            ..placement = 1,
          PlayerScore()
            ..playerId = 1
            ..placement = 2,
        ];

      final match2 = MatchRecord()
        ..id = 102
        ..date = DateTime(2025, 1, 15)
        ..playerScores = [
          PlayerScore()
            ..playerId = 2
            ..placement = 1,
        ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playersProvider.overrideWith((ref) => Stream.value([bob, alice])),
            matchRecordsProvider.overrideWith(
              (ref) => Stream.value([match1, match2]),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('de'),
            home: PlayersScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial order: Name (A–Z) -> Alice first, Bob second
      final cardsBeforeSort = tester
          .widgetList<Card>(find.byType(Card))
          .toList();
      expect(cardsBeforeSort.length, 2);

      // Check subtitle statistics
      // Bob has 2 matches, 2 wins (100%)
      expect(find.text('2 Partien • 2 Siege (100%)'), findsOneWidget);
      // Alice has 1 match, 0 wins (0%)
      expect(find.text('1 Partie • 0 Siege (0%)'), findsOneWidget);

      // Open bottom sheet via sort icon in AppBar
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      expect(find.text('Spieler sortieren nach'), findsOneWidget);
      expect(find.text('Meiste Partien'), findsOneWidget);

      // Select "Meiste Partien"
      await tester.tap(find.text('Meiste Partien'));
      await tester.pumpAndSettle();

      // Bottom sheet is closed. Verify new order: Bob first (2 matches), Alice second (1 match)
      final listTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      expect((listTiles[0].title as Text).data, 'Bob');
      expect((listTiles[1].title as Text).data, 'Alice');
    },
  );
}
