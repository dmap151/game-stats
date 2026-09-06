import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_stats/data/models/game.dart';
import 'package:game_stats/data/models/match_record.dart';
import 'package:game_stats/data/models/player.dart';
import 'package:game_stats/l10n/app_localizations.dart';
import 'package:game_stats/providers/providers.dart';
import 'package:game_stats/ui/screens/match_entry_screen.dart';
import 'package:game_stats/ui/widgets/location_picker_dialog.dart';

void main() {
  testWidgets('MatchEntryScreen displays existing match location and allows deleting it', (
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
      ..latitude = 52.5200
      ..longitude = 13.4050
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

    // Verify location switch exists and shows "Standort verwenden"
    expect(find.text('Standort verwenden'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);

    // Edit and delete icon buttons should be visible because location is active
    expect(find.byTooltip('Standort bearbeiten'), findsOneWidget);
    expect(find.byTooltip('Standort löschen'), findsOneWidget);

    // Toggle switch off
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Now it should show "Kein Standort für diese Partie" and edit buttons should be gone
    expect(find.text('Kein Standort für diese Partie'), findsOneWidget);
    expect(find.byTooltip('Standort bearbeiten'), findsNothing);

    // Toggle switch back on
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Now it should show "Kein Standort festgelegt" and add button
    expect(find.text('Kein Standort festgelegt'), findsOneWidget);
    expect(find.byTooltip('Standort hinzufügen'), findsOneWidget);
  });

  testWidgets('LocationPickerDialog allows entering manual coordinates', (
    tester,
  ) async {
    LocationPickerResult? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await LocationPickerDialog.show(
                  context: context,
                  initialLatitude: null,
                  initialLongitude: null,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('Standort hinzufügen'), findsOneWidget);
    expect(find.text('Koordinaten manuell eingeben'), findsOneWidget);

    // Expand manual coordinates
    await tester.tap(find.text('Koordinaten manuell eingeben'));
    await tester.pumpAndSettle();

    // Enter coordinates
    await tester.enterText(find.widgetWithText(TextField, 'Breitengrad (Latitude)'), '48.1371');
    await tester.enterText(find.widgetWithText(TextField, 'Längengrad (Longitude)'), '11.5754');
    await tester.pumpAndSettle();

    // Apply manual coordinates checkmark
    await tester.tap(find.byTooltip('Übernehmen'));
    await tester.pumpAndSettle();

    // Now confirm dialog
    await tester.tap(find.widgetWithText(FilledButton, 'Übernehmen'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.latitude, closeTo(48.1371, 0.0001));
    expect(result!.longitude, closeTo(11.5754, 0.0001));
    expect(result!.isDeleted, isFalse);
  });
}
