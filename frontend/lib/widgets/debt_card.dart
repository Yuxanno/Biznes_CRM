import 'package:flutter/material.dart';

import '../models/debt.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DebtCard({super.key, required this.debt, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final typeColor = debt.isOwedToMe ? c.income : c.expense;
    final statusColor = c.debtStatus(debt.status);

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.rLarge,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: Radii.rLarge,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    debt.isOwedToMe
                        ? (context.findAncestorWidgetOfExactType<_DebtCardLabel>()?.owedLabel ?? 'Owed to me')
                        : (context.findAncestorWidgetOfExactType<_DebtCardLabel>()?.iOweLabel ?? 'I owe'),
                    style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(Formatters.debtStatus(debt.status),
                      style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debt.personName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      if (debt.description?.isNotEmpty == true)
                        Text(debt.description!,
                            style: TextStyle(fontSize: 12, color: c.textSecondary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.currency(debt.amount),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
                    if (debt.paidAmount > 0)
                      Text('paid ${Formatters.currency(debt.paidAmount)}',
                          style: TextStyle(fontSize: 10, color: c.textSecondary)),
                  ],
                ),
              ],
            ),
            if (debt.dueDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.event_rounded, size: 12,
                      color: debt.isOverdue ? c.danger : c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    debt.isOverdue
                        ? 'Overdue · ${Formatters.dateShort(debt.dueDate!)}'
                        : 'Due ${Formatters.dateShort(debt.dueDate!)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: debt.isOverdue ? c.danger : c.textSecondary,
                        fontWeight: debt.isOverdue ? FontWeight.w600 : FontWeight.normal),
                  ),
                  const Spacer(),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline, size: 17, color: c.textMuted),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inherited widget to pass localized labels to DebtCard.
class _DebtCardLabel extends InheritedWidget {
  final String owedLabel;
  final String iOweLabel;

  const _DebtCardLabel({
    required this.owedLabel,
    required this.iOweLabel,
    required super.child,
  });

  static _DebtCardLabel? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<_DebtCardLabel>();

  @override
  bool updateShouldNotify(_DebtCardLabel oldWidget) =>
      owedLabel != oldWidget.owedLabel || iOweLabel != oldWidget.iOweLabel;
}

/// Helper to wrap a list of DebtCards with localized labels.
class DebtCardLabels extends StatelessWidget {
  final String owedLabel;
  final String iOweLabel;
  final Widget child;

  const DebtCardLabels({
    super.key,
    required this.owedLabel,
    required this.iOweLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _DebtCardLabel(
      owedLabel: owedLabel,
      iOweLabel: iOweLabel,
      child: child,
    );
  }
}
