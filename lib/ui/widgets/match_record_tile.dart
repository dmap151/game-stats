import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/match_record.dart';
import '../../data/models/game.dart';
import '../../data/models/player.dart';
import 'full_screen_image_viewer.dart';
import 'location_badge.dart';

class MatchRecordTile extends StatelessWidget {
  final MatchRecord record;
  final Game game;
  final int matchIndex;
  final Player? Function(int) getPlayer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MatchRecordTile({
    super.key,
    required this.record,
    required this.game,
    required this.matchIndex,
    required this.getPlayer,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildImageThumbnail(BuildContext context, String path, [String? heroTag]) {
    return GestureDetector(
      onTap: () {
        FullScreenImageViewer.show(context, File(path));
      },
      child: CircleAvatar(
        radius: 36,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ClipOval(
          child: Image.file(
            File(path),
            height: 72,
            width: 72,
            fit: BoxFit.cover,
            cacheWidth: 150,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final winner = record.playerScores.where((p) => p.placement == 1).firstOrNull;
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ExpansionTile(
        leading: record.imagePath != null
            ? ClipOval(
                child: Image.file(
                  File(record.imagePath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                ),
              )
            : const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.emoji_events, color: Colors.black87, size: 20),
              ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${game.name} #$matchIndex', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(winner != null ? '${winner.playerName} hat gewonnen' : 'Unentschieden', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Bearbeiten'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Löschen', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${DateFormat('dd.MM.yyyy').format(record.date)} - ${record.numberOfPlayers} Spieler',
            ),
            if (record.latitude != null && record.longitude != null) ...[
              const SizedBox(height: 2),
              LocationBadge(
                latitude: record.latitude!,
                longitude: record.longitude!,
                compact: true,
              ),
            ],
          ],
        ),
        children: [
          if (record.latitude != null && record.longitude != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LocationBadge(
                  latitude: record.latitude!,
                  longitude: record.longitude!,
                ),
              ),
            ),
          if (record.imagePath != null || record.imagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (record.imagePath != null) ...[
                      _buildImageThumbnail(context, record.imagePath!, 'match_${record.id}_0'),
                      const SizedBox(width: 8),
                    ],
                    ...record.imagePaths.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildImageThumbnail(context, entry.value, 'match_${record.id}_${entry.key + 1}'),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ...((record.playerScores.toList()..sort((a, b) => a.placement.compareTo(b.placement))).map((ps) {
            final pInfo = getPlayer(ps.playerId ?? -1);
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: pInfo?.imagePath != null 
                  ? ClipOval(
                      child: Image.file(
                        File(pInfo!.imagePath!),
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        cacheWidth: 64,
                      ),
                    )
                  : Text(ps.playerName?.isNotEmpty == true ? ps.playerName!.substring(0, 1).toUpperCase() : '?'),
              ),
              title: Text(ps.playerName ?? 'Unbekannt'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (ps.score != null) ...[
                    Text('${ps.score} Punkte', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ps.placement == 1 ? Colors.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: ps.placement == 1 ? null : Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(
                      '#${ps.placement}',
                      style: TextStyle(
                        color: ps.placement == 1 ? Colors.black87 : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }
}
