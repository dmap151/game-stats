import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/ui/screens/dashboard_screen.dart';
import 'package:game_stats/ui/widgets/stat_card.dart';

void main() {
  testWidgets('DashboardScreen displays global statistics with full titles and game details', (
    tester,
  ) async {
    final terraformingMars = Game()
      ..id = 1
      ..name = 'Terraforming Mars';

    final match1 = MatchRecord()
      ..id = 101
      ..date = DateTime(2025, 1, 10);
    match1.game.value = terraformingMars;

    final match2 = MatchRecord()
      ..id = 102
      ..date = DateTime(2025, 1, 15);
    match2.game.value = terraformingMars;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRecordsProvider.overrideWith(
            (ref) => Stream.value([match1, match2]),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and StatCards
    expect(find.text('Globale Statistiken'), findsOneWidget);
    expect(find.byType(StatCard), findsNWidgets(2));

    // Verify "Partien gespielt" card
    expect(find.text('Partien gespielt'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Insgesamt erfasst'), findsOneWidget);

    // Verify "Häufigstes Spiel" card
    expect(find.text('Häufigstes Spiel'), findsOneWidget);
    expect(find.text('Terraforming Mars'), findsOneWidget);
    expect(find.text('2 Partien gespielt'), findsOneWidget);
  });

  testWidgets('DashboardScreen handles empty state gracefully', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchRecordsProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Partien gespielt'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Noch keine Partien erfasst'), findsOneWidget);

    expect(find.text('Häufigstes Spiel'), findsOneWidget);
    expect(find.text('Noch keine Partien'), findsOneWidget);
  });
}
