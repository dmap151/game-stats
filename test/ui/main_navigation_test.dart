import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/l10n/l10n_extension.dart';
import 'package:game_stats/main.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/theme/app_theme.dart';
import 'package:game_stats/ui/screens/match_entry_screen.dart';

void main() {
  testWidgets('MainScaffold displays modern navigation bar with 4 tabs and center plus button', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRecordsProvider.overrideWith((ref) => Stream.value(<MatchRecord>[])),
          gamesProvider.overrideWith((ref) => Stream.value(<Game>[])),
          playersProvider.overrideWith((ref) => Stream.value(<Player>[])),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainScaffold(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the 4 nav tabs
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Bibliothek'), findsOneWidget);
    expect(find.text('Spieler'), findsWidgets);
    expect(find.text('Duelle'), findsOneWidget);

    // Verify the prominent center "+" action button
    final plusButton = find.byIcon(Icons.add_rounded);
    expect(plusButton, findsOneWidget);

    // Tap on the "Bibliothek" tab
    await tester.tap(find.text('Bibliothek'));
    await tester.pumpAndSettle();

    // Verify library is displayed
    expect(find.text('Spiele-Bibliothek'), findsOneWidget);

    // Tap on the "Duelle" tab
    await tester.tap(find.text('Duelle'));
    await tester.pumpAndSettle();

    expect(find.text('Spieler Vergleich'), findsOneWidget);

    // Tap center "+" button to verify it launches MatchEntryScreen
    await tester.tap(plusButton);
    await tester.pumpAndSettle();

    expect(find.byType(MatchEntryScreen), findsOneWidget);
  });
}
