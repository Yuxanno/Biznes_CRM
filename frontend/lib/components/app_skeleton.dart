import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skeleton loading list — static, no animation (respects reduce motion).
/// If animations are NOT disabled, uses a subtle shimmer.
class AppSkeletonList extends StatefulWidget {
  final int itemCount;

  const AppSkeletonList({super.key, this.itemCount = 5});

  @override
  State<AppSkeletonList> createState() => _AppSkeletonListState();
}

class _AppSkeletonListState extends State<AppSkeletonList>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (!WidgetsBinding.instance.disableAnimations) {
      _ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1000))
        ..repeat();
    }
  }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.itemCount,
      itemBuilder: (_, __) => _SkeletonTile(anim: _ctrl),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  final AnimationController? anim;
  const _SkeletonTile({this.anim});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    // When reduce motion is enabled, use static color
    if (anim == null) {
      return _buildTile(c.border, c.surfaceVariant);
    }

    return AnimatedBuilder(
      animation: anim!,
      builder: (_, child) {
        final v = anim!.value;
        final opacity = v < 0.5 ? v * 2 : 2 - v * 2;
        return _buildTile(c.border.withValues(alpha: 0.4 + opacity * 0.4), c.surfaceVariant);
      },
      child: null,
    );
  }

  Widget _buildTile(Color boxColor, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg, vertical: Spacing.sm + 2),
      child: Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: boxColor, borderRadius: Radii.rMedium)),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: boxColor, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                        color: boxColor, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Container(
              height: 14,
              width: 56,
              decoration: BoxDecoration(
                  color: boxColor, borderRadius: BorderRadius.circular(6))),
        ],
      ),
    );
  }
}
}
