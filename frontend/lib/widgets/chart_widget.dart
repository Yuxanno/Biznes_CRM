import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import '../utils/l10n.dart';

class IncomeExpenseChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  const IncomeExpenseChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    if (data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(t.noData, style: TextStyle(fontSize: 13, color: c.textSecondary)),
        ),
      );
    }

    final maxY = data.fold<double>(
      0,
      (max, d) => [max, d.income, d.expense].reduce((a, b) => a > b ? a : b),
    );

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final point = data[group.x];
                final label = rodIndex == 0 ? t.income : t.expense;
                final value = rodIndex == 0 ? point.income : point.expense;
                return BarTooltipItem(
                  '$label\n${Formatters.currency(value)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(data[idx].label, style: TextStyle(fontSize: 11, color: c.textMuted)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: c.border, strokeWidth: 1),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.income,
                  color: c.income,
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: e.value.expense,
                  color: c.expense,
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(color: c.income, label: t.income, c: c),
        const SizedBox(width: Spacing.lg),
        _Dot(color: c.expense, label: t.expense, c: c),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  final AppColors c;

  const _Dot({required this.color, required this.label, required this.c});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 13, color: c.textSecondary)),
        ],
      );
}
