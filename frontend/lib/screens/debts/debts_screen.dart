import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_confirm_sheet.dart';
import '../../components/app_empty_state.dart';
import '../../components/app_error_state.dart';
import '../../components/app_search_bar.dart';
import '../../components/app_skeleton.dart';
import '../../providers/debt_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../widgets/debt_card.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});
  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() => context.read<DebtProvider>().load();

  Future<void> _delete(String id) async {
    final t = context.read<LangProvider>().t;
    final ok = await AppConfirmSheet.show(context,
        title: t.deleteDebt, message: t.deleteDebtConfirm,
        confirmLabel: t.delete, cancelLabel: t.cancel);
    if (!ok || !mounted) return;
    await context.read<DebtProvider>().delete(id);
  }

  Future<void> _openEdit(dynamic d) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDebtScreen(initial: {
        'id': d.id, 'type': d.type, 'personName': d.personName,
        'phone': d.phone, 'amount': d.amount, 'paidAmount': d.paidAmount,
        'description': d.description, 'dueDate': d.dueDate?.toIso8601String(),
      }),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DebtProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;
    final summary = prov.summary;
    final owedToMe = prov.items.where((d) => d.isOwedToMe).toList();
    final iOwe = prov.items.where((d) => !d.isOwedToMe).toList();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(t.debts),
        bottom: TabBar(
          controller: _tabs,
          tabs: [Tab(text: t.owedToMeTab), Tab(text: t.iOweTab)],
        ),
      ),
      body: Column(
        children: [
          if (summary != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.lg, 10, Spacing.lg, 10),
              child: Row(
                children: [
                  _SummaryTile(
                    label: t.totalOwedToMe,
                    value: Formatters.currencyCompact(
                        (summary['owedToMe']?['remaining'] as num? ?? 0).toDouble()),
                    color: c.income, c: c,
                  ),
                  const SizedBox(width: Spacing.sm),
                  _SummaryTile(
                    label: t.totalIOwe,
                    value: Formatters.currencyCompact(
                        (summary['iOwe']?['remaining'] as num? ?? 0).toDouble()),
                    color: c.expense, c: c,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, 10),
            child: AppSearchBar(
              controller: _searchCtrl,
              hintText: '${t.debts}...',
              onChanged: (_) => _load(),
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(
            child: prov.loading && prov.items.isEmpty
                ? const AppSkeletonList()
                : prov.error != null && prov.items.isEmpty
                    ? AppErrorState(message: prov.error!, onRetry: _load)
                    : TabBarView(
                        controller: _tabs,
                        children: [
                          _DebtList(items: owedToMe, t: t, c: c,
                              onDelete: _delete, onEdit: _openEdit),
                          _DebtList(items: iOwe, t: t, c: c,
                              onDelete: _delete, onEdit: _openEdit),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  final List items;
  final L10n t;
  final AppColors c;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(dynamic) onEdit;

  const _DebtList({required this.items, required this.t, required this.c, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppEmptyState(icon: Icons.account_balance_wallet_outlined,
          title: t.noDebts, subtitle: t.noDebtsSub);
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<DebtProvider>().load(),
      color: c.primary,
      backgroundColor: c.surface,
      child: DebtCardLabels(
        owedLabel: t.owedToMeTab,
        iOweLabel: t.iOweTab,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 6, bottom: 100),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final d = items[i];
            return DebtCard(debt: d, onTap: () => onEdit(d), onDelete: () => onDelete(d.id));
          },
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final AppColors c;

  const _SummaryTile({required this.label, required this.value, required this.color, required this.c});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: Radii.rLarge,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: c.textMuted)),
        ],
      ),
    ),
  );
}
