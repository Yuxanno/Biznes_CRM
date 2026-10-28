import 'package:flutter/material.dart';

// ─── Order status helpers ────────────────────────────────────────────────────
class OrderStatus {
  static const all = ['new', 'in_progress', 'waiting', 'completed', 'cancelled'];
  static const active = ['new', 'in_progress', 'waiting'];

  static IconData icon(String status) {
    switch (status) {
      case 'new':
        return Icons.fiber_new_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'waiting':
        return Icons.hourglass_empty_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}

class DebtStatusColors {
  static Color color(String status, AppColors c) {
    switch (status) {
      case 'unpaid':
        return c.danger;
      case 'partial':
        return c.warning;
      case 'paid':
        return c.income;
      default:
        return c.textSecondary;
    }
  }
}

// Re-export AppColors for convenience in files that still reference it
export '../theme/app_colors.dart' show AppColors, AppColorsX;
