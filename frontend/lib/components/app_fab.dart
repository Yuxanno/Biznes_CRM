import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// FAB with tap-scale animation (respects reduce motion).
class AppFab extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;

  const AppFab({
    super.key,
    required this.onTap,
    this.icon = Icons.add_rounded,
  });

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> with SingleTickerProviderStateMixin {
  late AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final reduceMotion = WidgetsBinding.instance.disableAnimations;

    return GestureDetector(
      onTapDown: reduceMotion ? null : (_) => _scale.forward(),
      onTapUp: reduceMotion ? null : (_) => _scale.reverse(),
      onTapCancel: reduceMotion ? null : () => _scale.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.92).animate(
          CurvedAnimation(parent: _scale, curve: Curves.easeOut),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: c.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: c.onPrimary, size: IconSize.large),
        ),
      ),
    );
  }
}
