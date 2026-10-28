import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Confirmation dialog as a bottom sheet (mobile-friendly).
class AppConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  const AppConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.isDanger = false,
  });

  /// Shows the sheet and returns true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDanger = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AppConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? (isDanger ? 'Delete' : 'OK'),
        cancelLabel: cancelLabel ?? 'Cancel',
        isDanger: isDanger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final dangerColor = c.danger;
    final accent = isDanger ? dangerColor : c.primary;

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
      ),
      padding: EdgeInsets.fromLTRB(Spacing.xl, Spacing.md, Spacing.xl, bottomPad + Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
              color: accent,
              size: IconSize.xl,
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xxl),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(cancelLabel),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: Radii.rMedium),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context, true);
                    },
                    child: Text(confirmLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
