import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Card wrapper with consistent styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool borderless;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderless = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    final container = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.rLarge,
        border: borderless ? null : Border.all(color: c.border, width: 1),
      ),
      child: child,
    );

    if (onTap == null) return container;

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.rLarge,
      child: container,
    );
  }
}
