import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_chip.dart';
import '../../components/app_confirm_sheet.dart';
import '../../components/app_empty_state.dart';
import '../../components/app_error_state.dart';
import '../../components/app_search_bar.dart';
import '../../components/app_skeleton.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/l10n.dart';
import '../../widgets/order_card.dart';
import 'add_order_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _statusFilter;

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
    context.read<OrderProvider>()
      ..setFilters(
        status: _statusFilter,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      )
      ..load();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<OrderProvider>().loadMore();
    }
  }

  Future<void> _delete(String id) async {
    final t = context.read<LangProvider>().t;
    final ok = await AppConfirmSheet.show(context,
        title: t.deleteOrder, message: t.deleteOrderConfirm,
        confirmLabel: t.delete, cancelLabel: t.cancel);
    if (!ok || !mounted) return;
    await context.read<OrderProvider>().delete(id);
  }

  Future<void> _openAdd() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddOrderSheet(),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    final statuses = [
      {'label': t.isRu ? 'Все' : 'All', 'value': null},
      {'label': t.statusNew, 'value': 'new'},
      {'label': t.statusInProgress, 'value': 'in_progress'},
      {'label': t.statusWaiting, 'value': 'waiting'},
      {'label': t.statusCompleted, 'value': 'completed'},
      {'label': t.statusCancelled, 'value': 'cancelled'},
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.orders),
      ),
      body: Column(
        children: [
          Container(
            color: c.background,
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 4, Spacing.lg, 10),
            child: Column(
              children: [
                AppSearchBar(
                  controller: _searchCtrl,
                  hintText: t.searchOrders,
                  onChanged: (_) => _load(),
                ),
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: statuses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final s = statuses[i];
                      final val = s['value'] as String?;
                      final selected = _statusFilter == val;
                      final color = val != null ? c.orderStatus(val) : c.primary;
                      return AppChip(
                        label: s['label'] as String,
                        selected: selected,
                        color: color,
                        onTap: () => setState(() { _statusFilter = val; _load(); }),
                      );
                    },
                  ),
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

  Widget _buildList(OrderProvider prov, L10n t, AppColors c) {
    if (prov.loading && prov.items.isEmpty) return const AppSkeletonList();
    if (prov.error != null && prov.items.isEmpty) {
      return AppErrorState(message: prov.error!, onRetry: _load);
    }
    if (prov.items.isEmpty) {
      return AppEmptyState(
        icon: Icons.assignment_outlined,
        title: t.noOrders,
        subtitle: t.noOrdersSub,
        actionLabel: t.addOrder,
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
          final o = prov.items[i];
          return OrderCard(
            order: o,
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)));
              _load();
            },
            onDelete: () => _delete(o.id),
          );
        },
      ),
    );
  }
}
