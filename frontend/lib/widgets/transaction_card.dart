import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({super.key, required this.transaction, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isIncome = transaction.isIncome;
    final color = isIncome ? c.income : c.expense;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: Radii.rMedium,
              ),
              child: Icon(
                isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.category,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 1),
                  Text(
                    transaction.description?.isNotEmpty == true
                        ? transaction.description!
                        : Formatters.dateShort(transaction.date),
                    style: TextStyle(fontSize: 12, color: c.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${Formatters.currency(transaction.amount)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: Spacing.sm),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, size: 17, color: c.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
