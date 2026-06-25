import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/match_record.dart';

class ScoreChart extends StatelessWidget {
  final List<MatchRecord> records;

  const ScoreChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.length < 2) {
      return const Center(
        child: Text('Nicht genug Daten für ein Diagramm (min. 2 Partien nötig)'),
      );
    }

    final theme = Theme.of(context);
    final sortedRecords = List<MatchRecord>.from(records)..sort((a, b) => a.date.compareTo(b.date));

    // Convert to spots (using the highest score of each match for the trend)
    final spots = sortedRecords.asMap().entries.map((e) {
      final maxScore = e.value.playerScores.isEmpty 
          ? 0 
          : e.value.playerScores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
      return FlSpot(e.key.toDouble(), maxScore.toDouble());
    }).toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < sortedRecords.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd.MM').format(sortedRecords[index].date),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.left,
                    );
                  },
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (sortedRecords.length - 1).toDouble(),
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
