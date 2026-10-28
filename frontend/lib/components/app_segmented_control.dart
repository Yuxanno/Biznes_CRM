import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Segmented toggle for two options (e.g. Income/Expense, Owed/I Owe).
class AppSegmentedControl extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label1;
  final String label2;
  final String value1;
  final String value2;
  final Color? color1;
  final Color? color2;

  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label1,
    required this.label2,
    this.value1 = 'income',
    this.value2 = 'expense',
    this.color1,
    this.color2,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isFirst = value == value1;
    final col1 = color1 ?? c.income;
    final col2 = color2 ?? c.expense;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: Radii.rMedium,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value1);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isFirst ? col1 : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(Radii.medium - 2)),
                ),
                child: Center(
                  child: Text(
                    label1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isFirst ? Colors.white : c.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value2);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isFirst ? col2 : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(Radii.medium - 2)),
                ),
                child: Center(
                  child: Text(
                    label2,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !isFirst ? Colors.white : c.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
