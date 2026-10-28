import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Avatar with initials and gradient/flat background.
class AppAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? color;

  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final accent = color ?? c.primary;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: accent,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
