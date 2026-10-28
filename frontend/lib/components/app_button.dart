import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary button with tap-scale animation.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool danger;
  final bool expanded;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.danger = false,
    this.expanded = true,
    this.height = 48,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
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

  void _onTapDown(TapDownDetails _) {
    if (WidgetsBinding.instance.disableAnimations) return;
    _scale.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _scale.reverse();
  }

  void _onTapCancel() {
    _scale.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final enabled = widget.onPressed != null && !widget.loading;

    Color bg;
    Color fg;
    BorderSide? side;

    if (widget.danger) {
      bg = c.danger;
      fg = Colors.white;
    } else if (widget.variant == AppButtonVariant.filled) {
      bg = c.primary;
      fg = c.onPrimary;
    } else if (widget.variant == AppButtonVariant.outlined) {
      bg = Colors.transparent;
      fg = c.primary;
      side = BorderSide(color: c.border);
    } else {
      bg = Colors.transparent;
      fg = c.primary;
    }

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _scale, curve: Curves.easeOut),
      ),
      child: SizedBox(
        width: widget.expanded ? double.infinity : null,
        height: widget.height,
        child: GestureDetector(
          onTapDown: enabled ? _onTapDown : null,
          onTapUp: enabled ? _onTapUp : null,
          onTapCancel: enabled ? _onTapCancel : null,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  widget.onPressed!();
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: enabled ? bg : bg.withValues(alpha: 0.4),
              borderRadius: Radii.rMedium,
              border: side != null ? Border.fromBorderSide(side) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.loading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  ),
                ] else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fg, size: IconSize.medium),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AppButtonVariant { filled, outlined, text }
