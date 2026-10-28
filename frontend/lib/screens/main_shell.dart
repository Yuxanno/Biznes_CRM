import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../providers/period_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../utils/l10n.dart';
import '../components/app_nav_bar.dart';

import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

// Form sheets
import 'transactions/add_transaction_screen.dart';
import 'orders/add_order_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  // 4 tabs: Dashboard(0), Transactions(1), Orders(2), Profile(3)
  static const _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
      context.read<PeriodProvider>().load();
    });
  }

  // ── FAB action — open form as bottom sheet ────────────────────────────────
  void _onFabTap() {
    switch (_index) {
      case 1:
        _openSheet(const AddTransactionSheet());
        break;
      case 2:
        _openSheet(const AddOrderSheet());
        break;
      default:
        _showQuickAdd();
    }
  }

  Future<void> _openSheet(Widget sheet) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
    if (result == true) setState(() {});
  }

  void _showQuickAdd() {
    final t = context.read<LangProvider>().t;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuickAddSheet(
        onTransaction: () { Navigator.pop(context); _openSheet(const AddTransactionSheet()); },
        onOrder: () { Navigator.pop(context); _openSheet(const AddOrderSheet()); },
      ),
    );
  }

  void _onBarTap(int barIdx) {
    setState(() => _index = barIdx);
  }

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();
    final t = context.watch<LangProvider>().t;

    final labels = [t.home, t.finance, t.orders, t.profile];

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: IndexedStack(index: _index, children: _screens),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppNavBarWithLabels(
        selectedIndex: _index,
        onTap: _onBarTap,
        onFabTap: _onFabTap,
        labels: labels,
        unreadCount: notifs.unreadCount,
      ),
    );
  }
}

// ─── Quick Add Sheet ──────────────────────────────────────────────────────────
class _QuickAddSheet extends StatelessWidget {
  final VoidCallback onTransaction;
  final VoidCallback onOrder;

  const _QuickAddSheet({
    required this.onTransaction,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.watch<LangProvider>().t;
    final safePad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, safePad + 32),
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
          const SizedBox(height: 16),
          Text(t.quickAdd, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QBtn(icon: Icons.swap_vert_rounded, label: t.finance, color: c.primary, onTap: onTransaction),
              _QBtn(icon: Icons.assignment_add, label: t.orders, color: c.income, onTap: onOrder),
            ],
          ),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: IconSize.xl),
          ),
          const SizedBox(height: 7),
          Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ],
      ),
    );
  }
}
