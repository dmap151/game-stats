import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/match_record.dart';
import '../screens/game_details_screen.dart';
import 'package:collection/collection.dart';
import 'location_badge.dart';
import '../../l10n/l10n_extension.dart';

class MatchPreviewCard extends StatelessWidget {
  final MatchRecord match;
  final int? matchIndex;
  final Widget? bottomWidget;

  const MatchPreviewCard({
    super.key,
    required this.match,
    this.matchIndex,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseGameName = match.game.value?.name ?? context.l10n.unknownGame;
    final gameName = matchIndex != null ? '$baseGameName #$matchIndex' : baseGameName;
    final winner = match.playerScores.where((p) => p.placement == 1).firstOrNull;
    final winnerText = winner != null
        ? (winner.playerName != null
            ? context.l10n.playerWon(winner.playerName!)
            : context.l10n.winner)
        : context.l10n.tiedLabel;
    final subtitleText = '${DateFormat('dd.MM.yyyy').format(match.date)} • $winnerText';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: match.imagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(match.imagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      cacheWidth: 100,
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.history),
                  ),
            title: Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtitleText),
                if (match.latitude != null && match.longitude != null) ...[
                  const SizedBox(height: 2),
                  LocationBadge(
                    latitude: match.latitude!,
                    longitude: match.longitude!,
                    compact: true,
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (match.game.value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => GameDetailsScreen(game: match.game.value!),
                  ),
                );
              }
            },
          ),
          if (bottomWidget != null) ...[
            const Divider(height: 1),
            bottomWidget!,
          ],
        ],
      ),
    );
  }
}
