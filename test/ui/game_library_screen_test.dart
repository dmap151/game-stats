import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/ui/screens/game_library_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GameLibraryScreen displays games and sorts via AppBar button', (
    tester,
  ) async {
    final catan = Game()
      ..id = 1
      ..name = 'Catan';

    final carcassonne = Game()
      ..id = 2
      ..name = 'Carcassonne';

    // Catan: 1 match on 2025-01-10
    final m1 = MatchRecord()
      ..id = 101
      ..date = DateTime(2025, 1, 10);
    m1.game.value = catan;

    // Carcassonne: 2 matches on 2025-01-15 & 2025-01-20
    final m2 = MatchRecord()
      ..id = 102
      ..date = DateTime(2025, 1, 15);
    m2.game.value = carcassonne;

    final m3 = MatchRecord()
      ..id = 103
      ..date = DateTime(2025, 1, 20);
    m3.game.value = carcassonne;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gamesProvider.overrideWith(
            (ref) => Stream.value([carcassonne, catan]),
          ),
          matchRecordsProvider.overrideWith(
            (ref) => Stream.value([m1, m2, m3]),
          ),
        ],
        child: const MaterialApp(home: GameLibraryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Default order: Name (A–Z) -> Carcassonne first, Catan second
    final listTilesInitial = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect((listTilesInitial[0].title as Text).data, 'Carcassonne');
    expect((listTilesInitial[1].title as Text).data, 'Catan');

    // Subtitle check
    expect(
      find.text('2 Partien gespielt • Zuletzt 20.01.2025'),
      findsOneWidget,
    );
    expect(find.text('1 Partie gespielt • Zuletzt 10.01.2025'), findsOneWidget);

    // Tap sort button in AppBar
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    expect(find.text('Spiele sortieren nach'), findsOneWidget);
    expect(find.text('Name (Z–A)'), findsOneWidget);
    expect(find.text('Meiste Partien'), findsOneWidget);

    // Select Name (Z–A)
    await tester.tap(find.text('Name (Z–A)'));
    await tester.pumpAndSettle();

    // After Name (Z–A): Catan first, Carcassonne second
    final listTilesAfter = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .toList();
    expect((listTilesAfter[0].title as Text).data, 'Catan');
    expect((listTilesAfter[1].title as Text).data, 'Carcassonne');
  });
}
