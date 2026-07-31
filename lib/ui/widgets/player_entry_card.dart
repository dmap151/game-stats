import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/player.dart';

class PlayerEntryCard extends StatelessWidget {
  final int? playerId;
  final int placement;
  final int? score;
  final List<Player> players;
  final bool showRemoveButton;
  final VoidCallback onRemove;
  final ValueChanged<int?> onPlayerChanged;
  final ValueChanged<int> onPlacementChanged;
  final ValueChanged<int?> onScoreChanged;

  const PlayerEntryCard({
    super.key,
    required this.playerId,
    required this.placement,
    this.score,
    required this.players,
    required this.showRemoveButton,
    required this.onRemove,
    required this.onPlayerChanged,
    required this.onPlacementChanged,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: playerId,
                    decoration: const InputDecoration(
                      labelText: 'Spieler auswählen',
                      border: OutlineInputBorder(),
                    ),
                    items: players.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              child: p.imagePath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(p.imagePath!),
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        cacheWidth: 50,
                                      ),
                                    )
                                  : Text(
                                      p.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Text(p.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onPlayerChanged,
                  ),
                ),
                if (showRemoveButton)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: theme.colorScheme.error,
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: placement.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Platz',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emoji_events_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => onPlacementChanged(int.tryParse(val) ?? 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: score?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Punkte',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scoreboard_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => onScoreChanged(val.isEmpty ? null : int.tryParse(val)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
