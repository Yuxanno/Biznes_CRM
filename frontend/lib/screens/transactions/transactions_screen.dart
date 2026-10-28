import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_chip.dart';
import '../../components/app_confirm_sheet.dart';
import '../../components/app_empty_state.dart';
import '../../components/app_error_state.dart';
import '../../components/app_loading_indicator.dart';
import '../../components/app_search_bar.dart';
import '../../components/app_skeleton.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/l10n.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String? _typeFilter;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final prov = context.read<TransactionProvider>();
    final period = context.read<PeriodProvider>().active;
    prov.setFilters(
      type: _typeFilter,
      periodId: period?.id,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    );
    prov.load();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<TransactionProvider>().loadMore();
    }
  }

  Future<void> _delete(String id) async {
    final t = context.read<LangProvider>().t;
    final ok = await AppConfirmSheet.show(context,
        title: t.deleteTransaction, message: t.deleteTransactionConfirm,
        confirmLabel: t.delete, cancelLabel: t.cancel);
    if (!ok || !mounted) return;
    await context.read<TransactionProvider>().delete(id);
  }

  Future<void> _openAdd() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TransactionProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.transactions),
      ),
      body: Column(
        children: [
          // Search + filters
          Container(
            color: c.background,
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 4, Spacing.lg, 10),
            child: Column(
              children: [
                AppSearchBar(
                  controller: _searchCtrl,
                  hintText: t.searchTransactions,
                  onChanged: (_) => _load(),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    AppChip(
                      label: t.isRu ? 'Все' : 'All',
                      selected: _typeFilter == null,
                      color: c.primary,
                      onTap: () => setState(() { _typeFilter = null; _load(); }),
                    ),
                    const SizedBox(width: Spacing.sm),
                    AppChip(
                      label: t.income,
                      selected: _typeFilter == 'income',
                      color: c.income,
                      onTap: () => setState(() { _typeFilter = 'income'; _load(); }),
                    ),
                    const SizedBox(width: Spacing.sm),
                    AppChip(
                      label: t.expense,
                      selected: _typeFilter == 'expense',
                      color: c.expense,
                      onTap: () => setState(() { _typeFilter = 'expense'; _load(); }),
                    ),
                    const Spacer(),
                    if (prov.total > 0)
                      Text('${prov.total}', style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(child: _buildList(prov, t, c)),
        ],
      ),
    );
  }

  Widget _buildList(TransactionProvider prov, L10n t, AppColors c) {
    if (prov.loading && prov.items.isEmpty) return const AppSkeletonList();
    if (prov.error != null && prov.items.isEmpty) {
      return AppErrorState(message: prov.error!, onRetry: _load);
    }
    if (prov.items.isEmpty) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: t.noTransactions,
        subtitle: t.noTransactionsSub,
        actionLabel: t.addTransaction,
        onAction: _openAdd,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      color: c.primary,
      backgroundColor: c.surface,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(top: 6, bottom: 120),
        itemCount: prov.items.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == prov.items.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final item = prov.items[i];
          return TransactionCard(
            transaction: item,
            onTap: () => _delete(item.id),
            onDelete: () => _delete(item.id),
          );
        },
      ),
    );
  }
}
