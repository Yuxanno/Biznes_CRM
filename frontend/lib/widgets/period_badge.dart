import 'package:flutter/material.dart';

import '../models/business_period.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class PeriodBadge extends StatelessWidget {
  final BusinessPeriod period;
  const PeriodBadge({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = period.isActive ? c.income : c.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            period.name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            '· ${Formatters.dateShort(period.startDate)}',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
