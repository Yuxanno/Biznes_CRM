import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shows a bottom sheet using [AppSheetContent] as wrapper.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}

/// Standard bottom sheet wrapper: rounded top corners, handle, optional header.
class AppSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final double? fixedHeight;

  const AppSheetContent({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    final safePad = MediaQuery.of(context).padding.bottom;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHandle(color: c.border),
        if (title != null)
          _SheetHeader(
            title: title!,
            icon: icon,
            iconColor: iconColor ?? c.primary,
            textColor: c.textPrimary,
            subBg: c.surfaceVariant,
          ),
        Flexible(child: child),
        SizedBox(height: bottomPad > 0 ? 0 : safePad),
      ],
    );

    if (fixedHeight != null) {
      content = SizedBox(height: fixedHeight, child: content);
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xxl)),
      ),
      child: content,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final Color color;
  const _SheetHandle({required this.color});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: Spacing.md),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color iconColor;
  final Color textColor;
  final Color subBg;

  const _SheetHeader({
    required this.title,
    this.icon,
    required this.iconColor,
    required this.textColor,
    required this.subBg,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: Radii.rMedium,
              ),
              child: Icon(icon, color: iconColor, size: IconSize.medium),
            ),
            const SizedBox(width: Spacing.md),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: c.textSecondary, size: IconSize.medium),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
          ),
        ],
      ),
    );
  }
}
