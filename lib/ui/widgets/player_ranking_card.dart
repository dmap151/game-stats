import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/player.dart';
import 'full_screen_image_viewer.dart';

class PlayerRankingCard extends StatelessWidget {
  final int playerId;
  final String playerName;
  final Player? playerInfo;
  final int wins;
  final int matches;
  final double winRate;
  final int rank;

  const PlayerRankingCard({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.playerInfo,
    required this.wins,
    required this.matches,
    required this.winRate,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirst = rank == 1;

    return Card(
      elevation: 0,
      color: isFirst ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                if (playerInfo?.imagePath != null) {
                  FullScreenImageViewer.show(context, File(playerInfo!.imagePath!), 'ranking_player_${playerInfo!.id}');
                }
              },
              child: Hero(
                tag: 'ranking_player_${playerInfo?.id ?? playerId}',
                child: CircleAvatar(
                  backgroundColor: isFirst ? Colors.amber : theme.colorScheme.primaryContainer,
                  child: playerInfo?.imagePath != null 
                    ? ClipOval(
                        child: Image.file(
                          File(playerInfo!.imagePath!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          cacheWidth: 100,
                        ),
                      )
                    : Text(playerName.substring(0, 1).toUpperCase()),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isFirst ? Colors.amber : theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: isFirst ? Colors.amber.shade700 : theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: isFirst ? Colors.black87 : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$matches gespielte Partien'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$wins Siege', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            Text('${winRate.toStringAsFixed(1)}% Win Rate', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
