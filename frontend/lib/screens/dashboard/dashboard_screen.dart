import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_card.dart';
import '../../components/app_empty_state.dart';
import '../../components/app_error_state.dart';
import '../../components/app_loading_indicator.dart';
import '../../components/app_skeleton.dart';
import '../../components/app_status_badge.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/period_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/transaction_card.dart';
import '../../widgets/chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<DashboardProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final periods = context.watch<PeriodProvider>();
    final notifs = context.watch<NotificationProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: c.background,
        titleSpacing: Spacing.lg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.overview, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary)),
            if (periods.active != null)
              Text(periods.active!.name,
                  style: TextStyle(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: c.textSecondary, size: IconSize.large),
                onPressed: () {},
              ),
              if (notifs.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: Spacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().load(),
        color: c.primary,
        backgroundColor: c.surface,
        child: _buildBody(dash, t, c),
      ),
    );
  }

  Widget _buildBody(DashboardProvider dash, L10n t, AppColors c) {
    if (dash.loading && dash.data == null) {
      return const AppLoadingIndicator();
    }
    if (dash.error != null && dash.data == null) {
      return AppErrorState(message: dash.error!, onRetry: _load);
    }
    final data = dash.data;
    if (data == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 4, Spacing.lg, 120),
      children: [
        // ── 3 stat cards ──
        Row(
          children: [
            Expanded(child: StatCard(
                label: t.income, amount: data.totalIncome,
                icon: Icons.south_west_rounded, color: c.income)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: StatCard(
                label: t.expense, amount: data.totalExpense,
                icon: Icons.north_east_rounded, color: c.expense)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: StatCard(
                label: t.profit, amount: data.netProfit,
                icon: Icons.trending_up_rounded,
                color: data.netProfit >= 0 ? c.income : c.expense)),
          ],
        ),
        const SizedBox(height: Spacing.sm + 2),

        // ── Debt quick tiles ──
        Row(
          children: [
            Expanded(child: _DebtTile(
              label: t.owedToMe, amount: data.debts.owedToMe,
              color: c.income, icon: Icons.call_received_rounded,
            )),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _DebtTile(
              label: t.iOwe, amount: data.debts.iOwe,
              color: c.expense, icon: Icons.call_made_rounded,
            )),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _DebtTile(
              label: t.activeOrders, amount: data.activeOrders.toDouble(),
              color: c.warning, icon: Icons.assignment_rounded,
              isCount: true,
            )),
          ],
        ),
        const SizedBox(height: Spacing.xl),

        // ── Chart ──
        _Section(
          title: t.incomeVsExpense,
          subtitle: t.sixMonths,
          c: c,
          child: Column(
            children: [
              IncomeExpenseChart(data: data.chartData),
              const SizedBox(height: Spacing.sm),
              const ChartLegend(),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // ── Recent transactions ──
        if (data.recentTransactions.isNotEmpty)
          _Section(
            title: t.recent,
            action: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/transactions'),
              child: Text(t.seeAll, style: TextStyle(color: c.primary, fontSize: 13)),
            ),
            c: c,
            child: Column(
              children: data.recentTransactions
                  .take(3)
                  .map((tr) => TransactionCard(transaction: tr))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final AppColors c;

  const _Section({
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(width: 6),
              Text(subtitle!, style: TextStyle(fontSize: 11, color: c.textMuted)),
            ],
            const Spacer(),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: Spacing.sm + 2),
        AppCard(
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class _DebtTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isCount;

  const _DebtTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: Radii.rSmall,
            ),
            child: Icon(icon, color: color, size: IconSize.small),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            isCount ? amount.toInt().toString() : Formatters.currencyCompact(amount),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 1),
          Text(label, style: TextStyle(fontSize: 11, color: context.appColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
