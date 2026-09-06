import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/l10n/app_localizations.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/ui/screens/match_entry_screen.dart';
import 'package:game_stats/ui/widgets/primary_button.dart';

void main() {
  testWidgets('MatchEntryScreen has compact PrimaryButton in AppBar for new match', (
    tester,
  ) async {
    final player = Player()
      ..id = 1
      ..name = 'Alice';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playersProvider.overrideWith((ref) => Stream.value([player])),
          matchRecordsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: MatchEntryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar contains the compact PrimaryButton in actions with "Speichern" label
    final appBarSaveFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is PrimaryButton &&
            widget.label == 'Speichern' &&
            widget.isCompact == true &&
            widget.icon == Icons.save_outlined,
      ),
    );
    expect(appBarSaveFinder, findsOneWidget);

    // Verify text "Speichern" is displayed inside the AppBar button
    expect(
      find.descendant(
        of: appBarSaveFinder,
        matching: find.text('Speichern'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('MatchEntryScreen has compact PrimaryButton in AppBar for editing match', (
    tester,
  ) async {
    final game = Game()
      ..id = 1
      ..name = 'Catan';

    final player = Player()
      ..id = 1
      ..name = 'Alice';

    final existingMatch = MatchRecord()
      ..id = 101
      ..date = DateTime(2025, 5, 20)
      ..playerScores = [
        PlayerScore()
          ..playerId = 1
          ..playerName = 'Alice'
          ..placement = 1
          ..score = 10,
      ];
    existingMatch.game.value = game;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playersProvider.overrideWith((ref) => Stream.value([player])),
          matchRecordsProvider.overrideWith((ref) => Stream.value([existingMatch])),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: MatchEntryScreen(existingMatch: existingMatch),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar contains the compact PrimaryButton with "Änderungen speichern"
    final appBarSaveFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is PrimaryButton &&
            widget.label == 'Änderungen speichern' &&
            widget.isCompact == true &&
            widget.icon == Icons.save_outlined,
      ),
    );
    expect(appBarSaveFinder, findsOneWidget);

    expect(
      find.descendant(
        of: appBarSaveFinder,
        matching: find.text('Änderungen speichern'),
      ),
      findsOneWidget,
    );
  });
}
