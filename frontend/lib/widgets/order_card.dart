import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const OrderCard({super.key, required this.order, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final statusColor = c.orderStatus(order.status);

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
                Expanded(
                  child: Text(order.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: Spacing.sm),
                _Pill(label: Formatters.orderStatus(order.status), color: statusColor),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 13, color: c.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order.clientName,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (order.amount != null)
                  Text(Formatters.currency(order.amount!),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
              ],
            ),
            if (order.deadline != null) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 12,
                      color: order.isOverdue ? c.danger : c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.timeUntil(order.deadline!),
                    style: TextStyle(
                        fontSize: 11,
                        color: order.isOverdue ? c.danger : c.textSecondary,
                        fontWeight: order.isOverdue ? FontWeight.w600 : FontWeight.normal),
                  ),
                  const Spacer(),
                  if (order.photos.isNotEmpty) ...[
                    Icon(Icons.photo_library_outlined, size: 12, color: c.textMuted),
                    const SizedBox(width: 3),
                    Text('${order.photos.length}', style: TextStyle(fontSize: 11, color: c.textMuted)),
                    const SizedBox(width: 6),
                  ],
                  if (order.audioId != null)
                    Icon(Icons.mic_rounded, size: 12, color: c.textMuted),
                  if (onDelete != null) ...[
                    const SizedBox(width: Spacing.sm),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline, size: 17, color: c.textMuted),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      );
}
