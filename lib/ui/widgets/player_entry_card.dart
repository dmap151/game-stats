import 'package:flutter/material.dart';
import '../../data/models/player.dart';

class PlayerEntryCard extends StatelessWidget {
  final String playerName;
  final int placement;
  final int? score;
  final List<Player> players;
  final bool showRemoveButton;
  final VoidCallback onRemove;
  final ValueChanged<String> onPlayerNameChanged;
  final ValueChanged<int> onPlacementChanged;
  final ValueChanged<int?> onScoreChanged;

  const PlayerEntryCard({
    super.key,
    required this.playerName,
    required this.placement,
    this.score,
    required this.players,
    required this.showRemoveButton,
    required this.onRemove,
    required this.onPlayerNameChanged,
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
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    initialValue: TextEditingValue(text: playerName),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return players.map((p) => p.name).toList();
                      }
                      return players.map((p) => p.name).where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      }).toList();
                    },
                    onSelected: (String selection) {
                      onPlayerNameChanged(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Spieler auswählen',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: onPlayerNameChanged,
                        onFieldSubmitted: (_) => onFieldSubmitted(),
                      );
                    },
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

