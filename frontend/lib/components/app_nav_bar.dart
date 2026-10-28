import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_fab.dart';

/// Bottom navigation bar with 4 tabs + center FAB.
/// Safe area aware.
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;
  final int unreadCount;

  static const _items = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, labelKey: 'home'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, labelKey: 'finance'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, labelKey: 'orders'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, labelKey: 'profile'),
  ];

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onFabTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Map visual bar index: 0=Home, 1=Finance, [FAB], 2=Orders, 3=Profile
    final labels = _resolveLabels(context);
    final visualIndex = selectedIndex <= 1
        ? selectedIndex
        : selectedIndex - 1; // 2→1, 3→2

    return Container(
      decoration: BoxDecoration(
        color: c.navBarBg,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: _NavBtn(
                item: _items[0],
                label: labels[0],
                active: visualIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: _items[1],
                label: labels[1],
                active: visualIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            // Center FAB space
            SizedBox(
              width: 72,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AppFab(onTap: onFabTap),
                ),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: _items[2],
                label: labels[2],
                active: visualIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: _items[3],
                label: labels[3],
                active: visualIndex == 3,
                unread: unreadCount,
                onTap: () => onTap(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolveLabels(BuildContext context) {
    // We need to access L10n but without importing it to avoid circular deps.
    // Instead we read from a passed-in label list. For now, use hardcoded
    // strings that will be replaced when MainShell passes the labels.
    // Actually, let's just accept labels as a parameter instead.
    // For simplicity, we return placeholder labels — the parent widget
    // should override these via the [AppNavBarWithLabels] variant below.
    return ['Home', 'Finance', 'Orders', 'Profile'];
  }
}

/// Nav bar with explicit labels (for i18n).
class AppNavBarWithLabels extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onFabTap;
  final List<String> labels;
  final int unreadCount;

  const AppNavBarWithLabels({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.onFabTap,
    required this.labels,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final visualIndex = selectedIndex <= 1 ? selectedIndex : selectedIndex - 1;

    return Container(
      decoration: BoxDecoration(
        color: c.navBarBg,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: _NavBtn(
                item: AppNavBar._items[0],
                label: labels[0],
                active: visualIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: AppNavBar._items[1],
                label: labels[1],
                active: visualIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            SizedBox(
              width: 72,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AppFab(onTap: onFabTap),
                ),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: AppNavBar._items[2],
                label: labels[2],
                active: visualIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            Expanded(
              child: _NavBtn(
                item: AppNavBar._items[3],
                label: labels[3],
                active: visualIndex == 3,
                unread: unreadCount,
                onTap: () => onTap(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

class _NavBtn extends StatelessWidget {
  final _NavItem item;
  final String label;
  final bool active;
  final int unread;
  final VoidCallback onTap;

  const _NavBtn({
    required this.item,
    required this.label,
    required this.active,
    required this.onTap,
    this.unread = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final color = active ? c.primary : c.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? item.activeIcon : item.icon, color: color, size: IconSize.medium),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (unread > 0)
            Positioned(
              top: 8,
              right: 14,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
