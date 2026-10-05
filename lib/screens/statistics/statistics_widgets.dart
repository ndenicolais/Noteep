// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ─── Section header ───────────────────────────────────────────────────────────

class StatsSectionHeader extends StatelessWidget {
  const StatsSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class StatsDataItem {
  const StatsDataItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int value;
  final Color color;
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.items});
  final List<StatsDataItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 500 ? 3 : 2;
        const spacing = 10.0;
        final cellW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              items
                  .map(
                    (item) =>
                        SizedBox(width: cellW, child: StatCard(item: item)),
                  )
                  .toList(),
        );
      },
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.item});
  final StatsDataItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: item.color.withAlpha(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(item.icon, color: item.color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.value}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pie chart ────────────────────────────────────────────────────────────────

class StatsPieSection {
  const StatsPieSection(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class StatsPieChart extends StatefulWidget {
  const StatsPieChart({super.key, required this.sections});
  final List<StatsPieSection> sections;

  @override
  State<StatsPieChart> createState() => _StatsPieChartState();
}

class _StatsPieChartState extends State<StatsPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.sections.fold(0.0, (s, e) => s + e.value);
    if (total == 0) {
      return Center(
        child: Text(
          'Nessun dato',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (ev, response) {
                  setState(() {
                    _touched =
                        (response?.touchedSection?.touchedSectionIndex) ?? -1;
                  });
                },
              ),
              sections:
                  widget.sections.asMap().entries.map((e) {
                    final isTouched = e.key == _touched;
                    return PieChartSectionData(
                      value: e.value.value,
                      color: e.value.color,
                      radius: isTouched ? 64 : 52,
                      title:
                          e.value.value > 0 ? '${e.value.value.toInt()}' : '',
                      titleStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        // White text is unreadable on light slice colors
                        // (e.g. amber/pink) — pick based on slice luminance.
                        color:
                            e.value.color.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white,
                      ),
                    );
                  }).toList(),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              widget.sections.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${s.label} (${s.value.toInt()})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ─── Task completion bar ──────────────────────────────────────────────────────

class TaskCompletionBar extends StatelessWidget {
  const TaskCompletionBar({
    super.key,
    required this.total,
    required this.completed,
  });
  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Center(
        child: Text(
          'Nessun task',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    final pct = completed / total;
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completati: $completed / $total',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 16,
            backgroundColor: accent.withAlpha(40),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: total.toDouble(),
                      color: accent.withAlpha(80),
                      width: 32,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: completed.toDouble(),
                      color: accent,
                      width: 32,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget:
                        (v, _) => Text(
                          v == 0 ? 'Totale' : 'Completati',
                          style: const TextStyle(fontSize: 11),
                        ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
